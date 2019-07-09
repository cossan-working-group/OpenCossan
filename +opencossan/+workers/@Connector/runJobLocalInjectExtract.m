function [Xout, varargout]= runJobLocalInjectExtract(Xobj,Tinput,Xjob)

XsshConnection = OpenCossan.getSSHConnection();
Ldatabase = ~isempty(OpenCossan.getDatabaseDriver);

%% Run pre-processor (Only once)
% Run pre-processor on the simulation folder
if ~isempty(Xobj.SpreExecutionCommand)
    [status, result] = system(Xobj.SpreExecutionCommand);
    if status ~= 0
        warning('openCOSSAN:Connector:run','Non-zero exit status from pre-execution command.');
    end
    OpenCossan.cossanDisp(['[COSSAN-X.Connector.run] Run pre-execution command: ' Xobj.SpreExecutionCommand ],2)
    OpenCossan.cossanDisp(['[COSSAN-X.Connector.run] Command output: ' result],3)
end

%% Set the properties of the job
Xjob.Sworkingdirectory = OpenCossan.getCossanWorkingPath; %set the working directory
Xjob.Smaininputpath = Xobj.Smaininputpath; %set the main input path
Xjob.Sfoldername = Xobj.SfolderTimeStamp; %Unique name for EACH batch

SjobScriptName = Xjob.SjobScriptName;


%% Run the external code (e.g. FE)

Xjob.Sexecmd = Xobj.SexecutionCommand; %set the execution command
if OpenCossan.hasSSHConnection
    % set to execute post-execution command remotely when SSH connection is
    % used
    Xjob.Spostexecmd = Xobj.SpostExecutionCommand;
end

CSjobID=cell(length(Tinput),1); % preallocate memory
% initialize some logic index to false
Lsubmitted = false(length(Tinput),1);
Lextracted = false(length(Tinput),1);
Lcompleted = false(length(Tinput),1);
Lkilled = false(length(Tinput),1);
LerrorFound = false(length(Tinput),1);
LsuccessfullExtract = true(length(Tinput),1);
isample = 0;
% assure that all the entries are strings otherwhise validatecossaninputs
% will fail
for nid=1:length(Tinput);
    CSjobID{nid}='';
end
Nrunningjobs = 0;
if Xjob.Nconcurrent == Inf
    % in order to be able to exit the cycle, if XjobNconcurrent is
    % unlimited it must be set to the total nr. of samples
    Nconcurrent = length(Tinput);
else
    Nconcurrent = Xjob.Nconcurrent;
end
%% Inject paramaters in different folders (1 folder for each simulation)
% SworkingdirectoryOriginal = Xobj.Sworkingdirectory;
while ~all(Lsubmitted&(Lextracted|Lkilled)) % until all samples have been submitted and extracted or killed
    %% Termination criteria KILL (from GUI)
    % Check if the file name KILL exists in the working directory
    if exist(fullfile(OpenCossan.getCossanWorkingPath,OpenCossan.getKillFilename),'file')
        % Remove the KILL file
        delete(fullfile(OpenCossan.getCossanWorkingPath,OpenCossan.getKillFilename));
            
        OpenCossan.cossanDisp('Analysis terminated by the user',1);
        % Cancel submitted jobs
        Xjob.deleteJob('CSjobID',CSjobID);
        error('openCOSSAN:Connector:runJob','Simulation killed by the user.')
    end
    % check if the user have killed any job from a shell/qmon
    if any(Lkilled)~=0
        OpenCossan.cossanDisp('Analysis terminated by the user',1);
%         error('openCOSSAN:Connector:runJob','Simulation killed by the user.');
    end
    
    if isample < length(Tinput) % submit a new sample if the total number of samples have not been reached
        isample = isample +1; % process the next samples
        OpenCossan.cossanDisp(['Preparing input file for Simulation #' num2str(isample) ' of ' num2str(length(Tinput)) ],1);
        SsimulationFolderName=[Xjob.Sfoldername Xjob.SbatchIdentification num2str(isample)];
        Sworkingdirectory = fullfile(OpenCossan.getCossanWorkingPath, SsimulationFolderName);
        [~,mess] = mkdir(Sworkingdirectory);
        OpenCossan.cossanDisp(['Create folder: ' SsimulationFolderName ' mess: ' mess],3)
        
        % copy the additional files in the working directory
        Xobj.copyFiles('Sdestdir',Sworkingdirectory);
        
        if strcmpi(Xobj.Stype,'aster') % if code-aster is used
            % create the .export file with the right paths
            fid = fopen([fullfile(Sworkingdirectory,Xobj.Smaininputfile) '.export'],'w');
            fprintf(fid, 'P version STA9.4\n');
            fprintf(fid,'A memjeveux  32\n');
            fprintf(fid,'A tpmax 120\n');
            fprintf(fid, ['R base ' fullfile(Sworkingdirectory,Xobj.Smaininputfile) '.base RC 0 \n']);
            fprintf(fid, ['F comm ' fullfile(Sworkingdirectory,Xobj.Smaininputfile) '.comm D 1 \n']);
            fprintf(fid, ['F med  ' fullfile(Sworkingdirectory,Xobj.Smaininputfile) '.med D 20 \n']);
            fprintf(fid, ['F resu ' fullfile(Sworkingdirectory,Xobj.Smaininputfile) '.resu R 8 \n']);
            fprintf(fid, ['F mess ' fullfile(Sworkingdirectory,Xobj.Smaininputfile) '.mess R & \n']);
            fprintf(fid, 'P actions make_etude');
            fclose(fid);
            OpenCossan.cossanDisp(['Create file: ' Xobj.Smaininputfile '.export for ASTER'],3)
        end
        % create the structure with the values to be injected (i.e., if there
        % is a parameter its values is stored in Tinput(1))
        Tinject = Connector.prepareInputStructure(Tinput,isample);
        Xobj.SfolderTimeStamp = Sworkingdirectory;
        inject(Xobj,Tinject); % Inject parameters in the CWD
        
        % If Cossan is using SSH, copy the simulation directory to the
        % work folder of the remote host
        if OpenCossan.hasSSHConnection
            OpenCossan.cossanDisp('Copying simulation folder to remote machine',4);
            OpenCossan.cossanDisp(['Source dir:' Sworkingdirectory],4);
            OpenCossan.cossanDisp(['Dest dir:' XsshConnection.SremoteWorkFolder],4);
            XsshConnection.putDir('SlocalDirName',Sworkingdirectory,...
                'SremoteDestinationDir',XsshConnection.SremoteWorkFolder);
        end
        
        %% Submit the job
        CSjobID(isample) = submitJob(Xjob,'Nsimulationnumber',isample,...
            'Sfoldername',SsimulationFolderName);
        Nrunningjobs = Nrunningjobs + 1;
        LfirstWait = true; % this logical is used to give the waiting messagge only once
    else
        %% if all the sample have been submitted but not extracted, there
        % is still some job running. This statement oblige to re-enter in
        % the following while-loop, so that the running jobs are checked
        % until they are all completed and extracted.
        Nrunningjobs = Nconcurrent;
        LfirstWait = false;
    end
    while (Nrunningjobs - Nconcurrent)>=0
        
        %% Termination criteria KILL (from GUI)
        % Check if the file name KILL exists in the working directory
        if exist(fullfile(OpenCossan.getCossanWorkingPath,OpenCossan.getKillFilename),'file')
            % Remove the KILL file
            delete(fullfile(OpenCossan.getCossanWorkingPath,OpenCossan.getKillFilename));
            
            OpenCossan.cossanDisp('Analysis terminated by the user',1);
            % Cancel submitted jobs
            Xjob.deleteJob('CSjobID',CSjobID);
            error('openCOSSAN:Connector:runJob','Simulation killed by the user.')
        end
        
        %% if all the available slot are in use, wait that one job finish
        % (check every 3 seconds if one slot have been freed)
        if LfirstWait
            OpenCossan.cossanDisp('Waiting for an available slot.',1)
            LfirstWait = false;
        end
        pause(Xobj.sleepTime)
        % get the index of jobs that have been submitted, thus without
        % empty string as IDs
        Lsubmitted = ~strcmp('',CSjobID);
        % initialize the status cell array
        Cstatus = cell(length(CSjobID),2);
        % get the status of the submitted jobs not yet completed
        Cstatus(Lsubmitted&~Lcompleted,:) = Xjob.getJobStatus('CSjobID',CSjobID(Lsubmitted&~Lcompleted));
        if OpenCossan.getVerbosityLevel>3 % debug informations
            for isampledebug = 1:length(Tinput)
                if ~isempty(CSjobID{isampledebug})
                    OpenCossan.cossanDisp(['Sample ' num2str(isampledebug) ' submitted '...
                        'to job ' CSjobID{isampledebug}],4)
                    OpenCossan.cossanDisp(['Job status: ' Cstatus{isampledebug, 1}],4)
                else
                    OpenCossan.cossanDisp(['Sample ' num2str(isampledebug) ' not yet submitted'],4);
                end
            end
            %pause(5) % just a pause to be able to read the debug info...
        end
        
        %% Because of problem at Daresbury Cluster try to resubmit the jobs
        % that had error at submission
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
        %% Check the job status and extract the result of finished jobs
        % get the index and number of running jobs (either 'running' or
        % 'pending')
        Lrunning = strcmp('running',Cstatus(:,1))|strcmp('pending',Cstatus(:,1))|... % SGE status
            strcmp('RUN',Cstatus(:,1))|strcmp('PEND',Cstatus(:,1)); % LSF status
        Nrunningjobs = sum(Lrunning);
        % check which jobs have been completed
        Lcompleted = strcmp('completed',Cstatus(:,1))|strcmp('DONE',Cstatus(:,1));
        % check which jobs have been killed
        Lkilled = strcmp('killed',Cstatus(:,1));
        % check which jobs have been completed but with a non-zero return
        Lcompleted_non_zero_return = zeros(size(Lcompleted));
        for ijobcheck=1:length(Lcompleted)
            Lcompleted_non_zero_return(ijobcheck) = ...
                ~isempty(Cstatus{ijobcheck,1})&&...
                (strncmp(Cstatus{ijobcheck,1},'Failed',6)||strcmp(Cstatus{ijobcheck,1},'EXIT'));
        end
        Lcompleted = Lcompleted|Lcompleted_non_zero_return|Lkilled;
        % extract the quantities of interest from the jobs that have just
        % been completed (thus completed but not extracted)
        if ~isempty(find(Lcompleted&~Lextracted, 1)) % workaround for a matlab bug...
            NtoExtract = find(Lcompleted&~Lextracted)'; % transpose because for loop works only with row vectors...
            for ij = NtoExtract
                Lextracted(ij) = true;
                OpenCossan.cossanDisp(['Job ' CSjobID{ij} ' completed'],1);
                if OpenCossan.hasSSHConnection
                    OpenCossan.cossanDisp('Retrieving simulation folder from remote machine',4);
                    OpenCossan.cossanDisp(['Source dir:' fullfileunix(XsshConnection.SremoteWorkFolder,...
                        [Xjob.Sfoldername Xjob.SbatchIdentification num2str(ij)])],4);
                    OpenCossan.cossanDisp(['Dest dir:' OpenCossan.getCossanWorkingPath],4);
                    % copy back from remote host the simulation folder if is using SSH
                    XsshConnection.getDir...
                        ('SremoteDirName',fullfileunix(XsshConnection.SremoteWorkFolder,...
                        [Xjob.Sfoldername Xjob.SbatchIdentification num2str(ij)]),...
                        'SlocalDestinationDir',OpenCossan.getCossanWorkingPath,'Loverwrite',true)
                    % remove the folder on the remote host
                    XsshConnection.issueCommand(['rm -fr ' ...
                        fullfileunix(Xjob.Sworkingdirectory,[Xjob.Sfoldername Xjob.SbatchIdentification num2str(ij)])])
                end
                % Run post-processor & Extract paramaters
                SextractFolderName=fullfile(OpenCossan.getCossanWorkingPath,...
                    [Xjob.Sfoldername Xjob.SbatchIdentification num2str(ij)]);
                Xobj.SfolderTimeStamp = SextractFolderName;
                % Run post-processor on the simulation folder if without
                % SSH Connection
                if ~isempty(Xobj.SpostExecutionCommand) && ~OpenCossan.hasSSHConnection
                    [status, result] = system(['cd ' SextractFolderName ';' Xobj.SpostExecutionCommand]);
                    if status ~= 0
                        warning('openCOSSAN:Connector:runJob','Non-zero exit status from post-execution command.');
                    end
                    OpenCossan.cossanDisp(['[COSSAN-X.Connector.run] Run post-execution command: ' Xobj.SpostExecutionCommand ],2)
                    OpenCossan.cossanDisp(['[COSSAN-X.Connector.run] Command output: ' result],3)
                end
                
                if ~any(Xobj.Lextractors)
                    warning('openCOSSAN:Connector:runJob','No Extractor defined in Connector');
                    Sname = 'null';
                    Tout(ij).(Sname) = NaN; %#ok<AGROW>
                else
                    % check if the FE has been successfully executed
                    LerrorFound(ij) = Xobj.checkForErrors;
                    % extract outputs from the current directory
                    [Ttmp.Cout,LsuccessfullExtract(ij)]=extract(Xobj,'Nsimulation',ij);
                    % return to the main folder
                    %%  Associate extracted values with COSSAN variables
                    Sname=fieldnames(Ttmp.Cout);
                    for in=1:length(Sname)
                        Tout(ij).(Sname{in})=Ttmp.Cout.(Sname{in}); 
                    end
                end
            end
        end
    end
    
end
if any(Lcompleted_non_zero_return)~=0
    warning('openCOSSAN:Connector:runJob','Non-zero exit status from third-party solver.');
end

OpenCossan.cossanDisp('All your jobs have been completed',1);

%% Add a entries in the simulation database
if Ldatabase
    for isample = 1:length(Tinput)
        % create a binary file containing the input and output values obtained
        % from the simulation
        XSimData = (SimulationData('Tvalues',Tinput(isample)));
        XSimData = XSimData.merge(SimulationData('Tvalues',Tout(isample)));
        
        SsimulationFolder = fullfile(OpenCossan.getCossanWorkingPath,...
            [Xjob.Sfoldername Xjob.SbatchIdentification num2str(isample)]);
        %% Add record
        insertRecord(OpenCossan.getDatabaseDriver,'StableType','Solver',...
            'Nid',getNextPrimaryID(OpenCossan.getDatabaseDriver,'Solver'),...
            'XsimulationData',XSimData,...
            'LsuccessfullExtract',LsuccessfullExtract(isample), ...
            'SsimulationFolder', SsimulationFolder, 'Nsimulation',isample, ...
            'LsuccessfullExecution',~LerrorFound(isample));
    end
end

%% Return outputs
if ~Xobj.LkeepSimulationFiles % If the database is not used, cleans the simulation folders
    % Clean the directory
    if ~isempty(Xjob.Sfoldername)
        for isample = 1:length(Tinput)
            try
                rmdir(fullfile(OpenCossan.getCossanWorkingPath,[Xjob.Sfoldername Xjob.SbatchIdentification num2str(isample)]),'s');                
            catch ME %#ok<NASGU>
                warning('openCOSSAN:Connector:runJob','Cannot delete folder %s\n',...
                    fullfile(OpenCossan.getCossanWorkingPath,[Xjob.Sfoldername Xjob.SbatchIdentification num2str(isample)]))
            end
            try
                delete([fullfile(OpenCossan.getCossanWorkingPath,SjobScriptName) num2str(isample) '.sh']);
            catch ME %#ok<NASGU>
                warning('openCOSSAN:Connector:runJob','Cannot delete script file %s\n',...
                    [fullfile(OpenCossan.getCossanWorkingPath,SjobScriptName) num2str(isample) '.sh'])
            end
        end
    end
end

%% Export results
OpenCossan.cossanDisp('Writing SimulationData object',3)
% create SimulationData object
Xout=SimulationData('Tvalues',Tout);
% Return optional output argument
varargout{1}=Tout;
varargout{2}=LerrorFound;
end
