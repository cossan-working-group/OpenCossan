function [XSimOut,varargout] = runJobRemoteInjectExtractSSH(Xobj,PinputALL,Xjob)
% Private function of the CONNECTOR to submitt the job via SSH connector
% and using remote inject/extract
%
% PinputALL: Input data
% Xjob: JobManager object
%
% See Also: http://cossan.co.uk/wiki/index.php/runJob@Connector
%
% $Copyright~1993-2014,~COSSAN~Working~Group,~University~of~Liverpool,~UK$
% $Author: Matteo Broggi and Edoardo Patelli$

% =====================================================================
% This file is part of openCOSSAN.  The open general purpose matlab
% toolbox for numerical analysis, risk and uncertainty quantification.
%
% openCOSSAN is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License.
%
% openCOSSAN is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
% =====================================================================

Ldatabase = ~isempty(OpenCossan.getDatabaseDriver);
NverbosityLevel= OpenCossan.getVerbosityLevel;

% Collect the SSHconnection
% !!!!!!DO NOT MODIFY Xssh!!!!!!!!!!!
% it is a handle object. If you change the properties
% in Xssh they will be reflected in OpenCossan.
Xssh=OpenCossan.getSSHConnection;

assert(~isempty(Xssh.SremoteMCRPath),...
    'openCOSSAN:Connector:runJobRemoteInjectExtractSSH:noMCRPath',...
    ['The Connector cannot be executed with the remote inject and extract!\n',...
    'The path of the MATLAB Compiler Runtime (MCR) has NOT been specified!\n', ...
    'Please define SremoteMCRpath in SSH connector or using OpenCossan'])

% path to the script used to run the compiled wrapper for method run of
% Connector

SconnectorScriptPath = fullfile(OpenCossan.getCossanExternalPath,Xobj.SconnectorRelativePath);

assert(logical(exist(fullfile(SconnectorScriptPath,Xobj.SconnectorScriptName),'file')), ...
    'openCOSSAN:Connector:runJobRemoteInjectExtract:noRunConnectorScript',...
    'Cannot find %s script in %s! \n Please check the Path for External Software in OpenCossan',...
    Xobj.SconnectorScriptName, SconnectorScriptPath)

%% Check the initialization of the simulation Database
% if a connection to the simulation database is available, enables the
% property LkeepSimulationFiles, because it is necessary to populate the database
if Ldatabase
    Xobj.LkeepSimulationFiles = true;
end

%% Define number of simulations per job
if (Xjob.Nconcurrent == Inf),     % checks whether or not Nconcurrents has been defined
    Njobs      = length(PinputALL);   % sets number of jobs equal to number of simulations to be performed
    %     Nsimxjobs  = 1;    % obviously, there is one simulation per job
    Vsimxjobs = ones(1,length(PinputALL));  % obviously, there is one simulation per job
else
    Njobs      = min(Xjob.Nconcurrent,length(PinputALL)); % re-adjusts number of jobs (if required)
    Vsimxjobs = floor(length(PinputALL)/Xjob.Nconcurrent)*ones(1,Xjob.Nconcurrent);
    Vsimxjobs(1:rem(length(PinputALL),Xjob.Nconcurrent)) = ...
        Vsimxjobs(1:rem(length(PinputALL),Xjob.Nconcurrent)) + 1; % sets number of simulations per job
    % if there are less samples than concurrent jobs remove jobs with no samples
    Vsimxjobs(Vsimxjobs==0) = [];
end

% Define vectors with counter for determining the simulations that go into
% each job
Vend = cumsum(Vsimxjobs);  % defines number of final simulation for job
Vstart = [1, Vend(1:end-1)+1]; % defines number of starting simulation for job
CSjobID=cell(Njobs,1);  % cell array to store the Id of the jobs

%% Prepare the JobManager
Xjob.Sworkingdirectory = OpenCossan.getRemoteWorkingPath; % set the working directory
Xjob.Smaininputpath = Xobj.Smaininputpath; %set the main input path
% Use the timestamp created by the connector
% Each batch have an unique name identified by the Sfoldername plus the
% current simulation number
% TODO: we should use the object ANALYSIS
Xjob.Sfoldername = Xobj.SfolderTimeStamp; 
Xjob.Sexecmd = ['./' Xobj.SconnectorScriptName]; % set the execution command to the connector wrapper script

% the connector wrapper script needs as inputs the external path and the path of the MCR
Xjob.Sexeflags = [Xssh.SremoteExternalPath ' ' Xssh.SremoteMCRPath];

%% Inject numbers, run FE code and extract results on different machines
for ijob=1:Njobs
    %% Termination criteria KILL (from GUI)
    % Check if the file name KILL exists in the working directory
    if exist(fullfile(OpenCossan.getCossanWorkingPath,OpenCossan.getKillFilename),'file')
        % Remove the KILL file
        delete(fullfile(OpenCossan.getCossanWorkingPath,OpenCossan.getKillFilename));
        
        OpenCossan.cossanDisp('Analysis terminated by the user',1);
        % Cancel submitted jobs
        Xjob.deleteJob('CsjobID',CSjobID);
        error('openCOSSAN:Connector:runJob:simulationKilled','Simulation aborted by the user.')
    end
    
    OpenCossan.cossanDisp(['Submitting Simulation Job #' num2str(ijob) ' of ' num2str(Njobs) ],1);
    
    SsimulationFolderName=[Xjob.Sfoldername Xjob.SbatchIdentification num2str(ijob)];
    Sfoldername=fullfile(OpenCossan.getCossanWorkingPath,[SsimulationFolderName filesep]);
    [~,mess] = mkdir(Sfoldername);
    OpenCossan.cossanDisp(['Create folder: ' Sfoldername],3)
    if ~isempty(mess)
        OpenCossan.cossanDisp(['Mess: ' mess],1)
    end
    % TODO: Use the Timer
    if NverbosityLevel>=3
        temp = tic;
    end
    %  Copy input files into the new grid folder
    if isa(PinputALL,'struct')
        % copies input - case of structure
        Pinput  = PinputALL(Vstart(ijob):Vend(ijob));
    else
        % copies input - case of matrix
        Pinput  = PinputALL(Vstart(ijob):Vend(ijob),:);
    end
    
    %% Create a Connector object for remote  set the correct connector working directory for remote execution of
    % injector and extractor for each job
    Xc_to_file = Xobj;
    Xc_to_file.LkeepSimulationFiles = true; % the cleanup is done by runJob
    Xc_to_file.Lremote = true; % flag the to indicate that the execution is on a remote machine
    Xc_to_file.NverboseLevel=NverbosityLevel;
    Xc_to_file.Smaininputpath = fullfileunix(Xjob.Sworkingdirectory,...
        SsimulationFolderName);
    Xc_to_file.SremoteWorkingDirectory = fullfileunix(OpenCossan.getRemoteWorkingPath,...
        SsimulationFolderName);
    for iinjext = 1:length(Xc_to_file.CXmembers)
        Xc_to_file.CXmembers{iinjext}.Srelativepath = ...
            strrep(Xc_to_file.CXmembers{iinjext}.Srelativepath,'\','/');
    end
    
    % TODO: ConnectorInput and ConnectorOutput should be constants of the
    % Connector
    
    save(fullfile(Sfoldername,Xobj.matlabInputName),'Pinput','Xc_to_file','Ldatabase');
    if NverbosityLevel>=3
        OpenCossan.cossanDisp('Time elapsed creating ConnectorInput.mat',3);toc(temp);
    end
    %% 3. Copy execution files and scripts in the folder
    % copy input files into the new grid folder
    Xobj.copyFiles('Sdestdir',Sfoldername);
    
    % copy compiled connector execution files
    [~,mess] =copyfile(fullfile(SconnectorScriptPath,Xobj.SconnectorScriptName),Sfoldername);
    OpenCossan.cossanDisp(['Copy compiled Connector wrapper execution script. Message: ' mess],4)
    % check that attributes of run_Connector.sh allows execution (UNIX only)
    if isunix
        [~,Tattrib] = fileattrib(fullfile(Sfoldername,Xobj.SconnectorScriptName));
        if Tattrib.UserExecute == 0
            fileattrib(fullfile(Sfoldername,Xobj.SconnectorScriptName),'+x','a');
            OpenCossan.cossanDisp('[OpenCossan:Connector:runJobRemoteInjectExtractSSH]: Execution permission changed ',4)
        end
    end
    
    % Copy the simulation directory to the work folder of the remote host
    Xssh.putDir('SlocalDirName',Sfoldername,'SremoteDestinationDir',Xjob.Sworkingdirectory);
    
    
    %% Submit the job
    if NverbosityLevel>=3
        temp = tic;
    end
    
    CSjobID(ijob) = submitJob(Xjob,'nsimulationnumber',ijob,...
        'Sfoldername',SsimulationFolderName);
    
end

%% Job resubmission
% Because of problem at Daresbury Cluster try to resubmit the jobs that had
% error at submission
LErrorAtSubmission = true(size(CSjobID));
while any(LErrorAtSubmission)
    Cstatus = Xjob.getJobStatus('CSjobID',CSjobID);
    LErrorAtSubmission = strcmp('Error at submission',Cstatus(:,1));
    for ijobinerror = 1:length(LErrorAtSubmission)
        if LErrorAtSubmission(ijobinerror)
            SoldjobID = Cstatus{ijobinerror,2};
            if ~OpenCossan.hasSSHConnection
                % TODO: Are we assuming a specific job manager? Should we
                % not read the infomation form JobManagerInterface
                [~, status_job]=system(['qresub ' SoldjobID]);
            else
                [~, status_job]=OpenCossan.issueSSHcommand(['qresub ' SoldjobID]);
            end
            % retrieve the job number using a regular expression extracting numbers
            SnewjobID = regexp(status_job,'[0-9](\w*)[0-9]','match');
            assert (~isempty(SnewjobID),...
                'OpenCossan:Connector:runJobRemoteInjectExtractSSH:emptyJobStatus',...
                'No job ID found! Status job: %s',status_job);
            % change the job id of the resubmitted job
            CSjobID(strcmpi(SoldjobID,CSjobID))=SnewjobID;
            % delete the job in error
            Xjob.deleteJob('CsjobID',{SoldjobID});
            pause(max(2,8/sum(double(LErrorAtSubmission))));
        end
    end
end

OpenCossan.cossanDisp('All your jobs has been submitted',2)

%% Check if all the jobs have finished
Lcompleted = false(Njobs,1);
while ~all(Lcompleted==1)
    %% Termination criteria KILL (from GUI)
    % Check if the file name KILL exists in the working directory
    if exist(fullfile(OpenCossan.getCossanWorkingPath,OpenCossan.getKillFilename),'file')
        % Remove the KILL file
        delete(fullfile(OpenCossan.getCossanWorkingPath,OpenCossan.getKillFilename));
        
        OpenCossan.cossanDisp('Analysis terminated by the user',1);
        % Cancel submitted jobs
        Xjob.deleteJob('CsjobID',CSjobID);
        error('openCOSSAN:Connector:runJob','Simulation killed by the user.')
    end
    
    pause(Xobj.sleepTime);
    Cstatus(~Lcompleted,:) = Xjob.getJobStatus('CSjobID',CSjobID(~Lcompleted));
    Lcompleted = ~(strcmp('running',Cstatus(:,1))|strcmp('pending',Cstatus(:,1)));
end
if NverbosityLevel>=3
    OpenCossan.cossanDisp('Time spend executing the job',3);toc(temp);
end
%% Retrieve outputs
% Variables for retrieving results
PoutputALL(Njobs,1) = SimulationData;
LerrorFound = ones(length(PinputALL),1);
LsuccessfullExtract = ones(length(PinputALL),1);
CfolderNames = cell(Njobs,1);
% load results form output files
for ijob=1:Njobs
    SsimulationFolderName=[Xjob.Sfoldername Xjob.SbatchIdentification num2str(ijob)];
    % copy back from remote host the simulation folder with SSH
    SremoteDirName=fullfileunix(Xssh.SremoteWorkFolder,SsimulationFolderName);
    
    if Xobj.LkeepSimulationFiles
        Xssh.getDir('SremoteDirName',SremoteDirName, ...
            'SlocalDestinationDir',OpenCossan.getCossanWorkingPath,'Loverwrite',true);
    else
        % copy only the ConnectorOutput.mat file
        Xssh.getFile('SremoteFileName',fullfileunix(SremoteDirName,Xobj.matlabOutputName),...
            'SlocalDestinationFolder',fullfile(OpenCossan.getCossanWorkingPath,SsimulationFolderName));
    end
    
    % remove the folder on the remote host
    Xssh.issueCommand(['rm -fr ' SremoteDirName]);
    
    try
        load(fullfile(OpenCossan.getCossanWorkingPath,SsimulationFolderName,Xobj.matlabOutputName));
        LerrorFound(Vstart(ijob):Vend(ijob)) = LerrorPartials;
        LsuccessfullExtract(Vstart(ijob):Vend(ijob)) = LsuccessfullExtractPartials;
        Lread=true;
    catch ME %#ok<*NASGU>
        OpenCossan.cossanDisp(['Output of simulations block # ' num2str(ijob) ' not available'],2)
        Lread=false;
    end
    
    if Lread
        if Ldatabase
            % dir only the _sim_1 subfolder to retrieve the name of the
            % folders used for the remote inject/extract
            % TODO: WHAT IS THAT!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            Tdir = dir(fullfile(OpenCossan.getCossanWorkingPath,....
                [Xjob.Sfoldername '_sim_' num2str(ijob)],...
                [Xjob.Sfoldername(1:9) '*_sim_1']));
            CfolderNames{ijob} = Tdir.name(1:15);
        else
            if ~Xobj.LkeepSimulationFiles
                try
                    delete(fullfile(OpenCossan.getCossanWorkingPath,[Xjob.SjobScriptName num2str(ijob) '.sh']));
                catch ME
                    OpenCossan.cossanDisp(['The job script ' Xjob.SjobScriptName '_'  num2str(ijob) '.sh can not be removed' ],2)
                end
                % Clean the directory
                Scleanfolder=fullfile(OpenCossan.getCossanWorkingPath,[Xjob.Sfoldername Xjob.SbatchIdentification num2str(ijob)]);
                try
                    rmdir(Scleanfolder,'s');
                catch ME
                    OpenCossan.cossanDisp(['The folder ' Scleanfolder ' can not be removed' ],2)
                end
            end
        end
        
        PoutputALL(ijob)=Xout;
    end
end


%% if the database of simulations is used, moves the folders with the
% connector execution in the main input path with the correct name
if Ldatabase
    for ijob=1:Njobs
        SsimulationFolderName=[Xjob.Sfoldername Xjob.SbatchIdentification num2str(ijob)];
        % move the compressed folder out of the "block" folder
        for isample = Vstart(ijob):Vend(ijob)
            Ssource = fullfile(Xobj.Smaininputpath,...
                SsimulationFolderName,...
                [CfolderNames{ijob} '_sim_' num2str(isample - Vstart(ijob) +1) ]);
            Sdestination = fullfile(Xobj.Smaininputpath,...
                [Xjob.Sfoldername '_sim_' num2str(isample) '.tgz']);
            tar(Sdestination,Ssource);
        end
        try
            delete(fullfile(Xobj.Smaininputpath,[Xjob.Sjobscriptname num2str(ijob) '.sh']));
        catch ME
            OpenCossan.cossanDisp(['The job script ' Xjob.Sjobscriptname '_'  num2str(ijob) '.sh can not be removed' ],2)
        end
        % Clean the directory
        Scleanfolder=fullfile(Xobj.Smaininputpath,[Xjob.Sfoldername '_sim_' num2str(ijob)]);
        try
            rmdir(Scleanfolder,'s');
        catch ME
            OpenCossan.cossanDisp(['The folder ' Scleanfolder ' can not be removed' ],2)
        end
    end
    
end
%% Export results
OpenCossan.cossanDisp('[OpenCossan:Connector:runJobRemoteInjectExtractSSH] Writing SimulationData object',3)

XSimOut=PoutputALL(1);
for i=2:Njobs
    XSimOut=XSimOut.merge(PoutputALL(i)); % the problem is here! TODO: ?????
end
% workaround until I understand what is wrong with the reassembly of the
% results using merger
XSimOut = SimulationData('Tvalues',XSimOut.Tvalues);
Tout = XSimOut.Tvalues;

% Return optional output argument
varargout{1}=Tout;
varargout{2}=LerrorFound;

%% Add a entries in the simulation database
if Ldatabase
    for isample = 1:length(PinputALL)
        % create a binary file containing the input and output values obtained
        % from the simulation
        XSimData = (SimulationData('Tvalues',PinputALL(isample)));
        XSimData = XSimData.merge(SimulationData('Tvalues',Tout(isample)));
        
        SsimulationZip = fullfile(Xobj.Smaininputpath,[Xjob.Sfoldername '_sim_' num2str(isample) '.tgz']);
        %% Add record
        insertRecord(OpenCossan.getDatabaseDriver,'StableType','Solver',...
            'Nid',getNextPrimaryID(OpenCossan.getDatabaseDriver,'Solver'),...
            'XsimulationData',XSimData,...
            'LsuccessfullExtract',logical(LsuccessfullExtract(isample)), ...
            'SsimulationZip', SsimulationZip, 'Nsimulation',isample, ...
            'LsuccessfullExecution',~logical(LerrorFound(isample)));
    end
end
end
