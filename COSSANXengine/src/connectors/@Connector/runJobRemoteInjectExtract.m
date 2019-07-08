function [XSimOut,varargout] = runJobRemoteInjectExtract(Xobj,PinputALL,Xjob)

% TODO: Remove dependence from OPENCOSSAN at least for the remote connector
% You can store all the variables in the connector from the constructor

Ldatabase = ~isempty(OpenCossan.getDatabaseDriver);
NverbosityLevel= OpenCossan.getVerbosityLevel;

% check that OpenCossan has been correctly initialized; if SmcrPath is empty,
% the remote inject/extract cannot be executed!
assert(~isempty(OpenCossan.getMCRPath),'openCOSSAN:Connector:runJob:noMCRPath',...
    ['The Connector cannot be executed with the remote inject and extract!\n',...
    'The path of the MATLAB Compiler Runtime (MCR) has NOT been specified!\n', ...
    'Please define SMCRpath in OpenCossan'])

% path to the script used to run the compiled wrapper for method run of
% Connector
SconnectorScriptPath = fullfile(OpenCossan.getCossanExternalPath,'src','ConnectorWrapper');
if ~exist(fullfile(SconnectorScriptPath,'run_Connector.sh'),'file')
    error('openCOSSAN:Connector:runJobRemoteInjectExtract',...
        'Cannot find run_Connector.sh script in external software path')
end
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
Xjob.Sworkingdirectory = OpenCossan.getCossanWorkingPath; % set the working directory
Xjob.Smaininputpath = Xobj.Smaininputpath; %set the main input path

Xjob.Sfoldername = Xobj.SfolderTimeStamp; % Unique name for EACH batch
Xjob.Sexecmd = ['./' Xobj.SconnectorScriptName]; % set the execution command to the connector wrapper script 

% the connector wrapper script needs as inputs the external path and the path of the MCR
Xjob.Sexeflags = [OpenCossan.getCossanExternalPath ' ' OpenCossan.getMCRPath];

Sjobscriptname = Xjob.SjobScriptName;

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
        error('openCOSSAN:Connector:runJob:simulationKilled','Simulation killed by the user.')
    end
        
    OpenCossan.cossanDisp(['Submitting Simulation block #' num2str(ijob) ' of ' num2str(Njobs) ],1);
    
    SsimulationFolderName=[Xjob.Sfoldername Xjob.SbatchIdentification num2str(ijob)];
    Sfoldername=fullfile(OpenCossan.getCossanWorkingPath,[SsimulationFolderName filesep]);
    [~,mess] = mkdir(Sfoldername);
    OpenCossan.cossanDisp(['Create folder: ' Sfoldername ' mess: ' mess],3)
    if ~isempty(mess)
        OpenCossan.cossanDisp(['Mess: ' mess],1)
    end
    
    %  Copy input files into the new grid folder
    if isa(PinputALL,'struct')
        Pinput  = PinputALL(Vstart(ijob):Vend(ijob));    % copies input - case of structure
    else
        Pinput  = PinputALL(Vstart(ijob):Vend(ijob),:);  % copies input - case of matrix
    end
    % set the correct connector working directory for remote execution of
    % injector and extractor for each job
    Xc_to_file = Xobj;
    Xc_to_file.LkeepSimulationFiles = true; % the cleanup is done by runJob
    Xc_to_file.Lremote = true; % flag the to indicate that the execution is on a remote machine
    Xc_to_file.NverboseLevel=NverbosityLevel;
    Xc_to_file.Smaininputpath = Sfoldername;
    Xc_to_file.SremoteWorkingDirectory = fullfile(OpenCossan.getCossanWorkingPath,...
        SsimulationFolderName);

    save(fullfile(Sfoldername,Xobj.matlabInputName),'Pinput','Xc_to_file','Ldatabase');
    
    %% 3. Copy execution files and scripts in the folder
    % copy input files into the new grid folder
    Xobj.copyFiles('Sdestdir',Sfoldername);
    
    % copy compiled connector execution files
    [~,mess] =copyfile(fullfile(SconnectorScriptPath,'run_Connector.sh'),Sfoldername);
    OpenCossan.cossanDisp(['Copy compiled Connector wrapper execution script. Message: ' mess],4)
    % check that attributes of run_Connector.sh allows execution (UNIX only)
    if isunix
        [~,Tattrib] = fileattrib(fullfile(Sfoldername,'run_Connector.sh'));
        if Tattrib.UserExecute == 0
            fileattrib(fullfile(Sfoldername,'run_Connector.sh'),'+x','a');
        end
    end
    
    %% Submit the job
    if NverbosityLevel>=3
        temp = tic;
    end
    
    CSjobID(ijob) = submitJob(Xjob,'nsimulationnumber',ijob,...
        'Sfoldername',SsimulationFolderName);
    
end

%% Because of problem at Daresbury Cluster try to resubmit the jobs
% that had error at submission
LErrorAtSubmission = true(size(CSjobID));
while any(LErrorAtSubmission)
    Cstatus = Xjob.getJobStatus('CSjobID',CSjobID);
    LErrorAtSubmission = strcmp('Error at submission',Cstatus(:,1));
    for ijobinerror = 1:length(LErrorAtSubmission)
        if LErrorAtSubmission(ijobinerror)
            SoldjobID = Cstatus{ijobinerror,2};
            if ~OpenCossan.hasSSHConnection
                [~, status_job]=system(['qresub ' SoldjobID]);
            else
                [~, status_job]=OpenCossan.issueSSHcommand(['qresub ' SoldjobID]);
            end
            % retrieve the job number using a regular expression extracting numbers
            SnewjobID = regexp(status_job,'[0-9](\w*)[0-9]','match');
            if isempty(SnewjobID)
                error('openCOSSAN:JobManager:submit',['No job ID found! Status job: ' status_job]);
            end
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
            Tdir = dir(fullfile(OpenCossan.getCossanWorkingPath,....
                [Xjob.Sfoldername '_sim_' num2str(ijob)],...
                [Xjob.Sfoldername(1:9) '*_sim_1']));
            CfolderNames{ijob} = Tdir.name(1:15);
        else
            if ~Xobj.LkeepSimulationFiles
                try
                    delete(fullfile(OpenCossan.getCossanWorkingPath,[Sjobscriptname num2str(ijob) '.sh']));
                catch ME
                    OpenCossan.cossanDisp(['The job script ' Sjobscriptname '_'  num2str(ijob) '.sh can not be removed' ],2)
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
        % move the compressed folder out of the "block" folder
        for isample = Vstart(ijob):Vend(ijob)
            Ssource = fullfile(Xobj.Smaininputpath,...
                [Xjob.Sfoldername '_sim_' num2str(ijob)],...
                [CfolderNames{ijob} '_sim_' num2str(isample - Vstart(ijob) +1) ]);
            Sdestination = fullfile(Xobj.Smaininputpath,...
                [Xjob.Sfoldername '_sim_' num2str(isample) '.tgz']);
            tar(Sdestination,Ssource);
        end
        try
            delete(fullfile(Xobj.Smaininputpath,[Sjobscriptname num2str(ijob) '.sh']));
        catch ME
            OpenCossan.cossanDisp(['The job script ' Sjobscriptname '_'  num2str(ijob) '.sh can not be removed' ],2)
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
OpenCossan.cossanDisp('Writing Xouput object',3)

XSimOut=PoutputALL(1);
for i=2:Njobs
    XSimOut=XSimOut.merge(PoutputALL(i)); % the problem is here!
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
