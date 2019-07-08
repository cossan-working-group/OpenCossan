function [XSimOut,PoutputALL] = runJobMatlab(Xmio,varargin)

global OPENCOSSAN

%% Initialize variables
OpenCossan.validateCossanInputs(varargin{:});
% Initialize other parameters
for k=1:2:length(varargin),
    switch lower(varargin{k}),
        case {'minput','tinput','xinput','xsamples'},   % case of input (realizations to be evaluated)
            PinputALL   = checkPinput(Xmio,varargin{k+1});     % check input to be passed in private method
        case {'xgrid','xjobmanager'},     % case of JobManager object
            Xjob     = varargin{k+1};        % save JobManager object
            Xjob.Sfoldername = datestr(now,30);              % define name of folders to run simulations
        case {'lkeepsimfiles'},     % option for keeping files after simulation is completed
            Xmio.Lkeepsimfiles    = varargin{k+1};
        case {'xsimout','xsimulationdata'},  % in case user passes an existing Output object
            XSimOut    = varargin{k+1};
        case {'njobs','nconcurrent'},     % define number of jobs
            Nconcurrent  = varargin{k+1};
        otherwise
            error('openCOSSAN:Mio:runJob',[varargin{k} ' - PropertyName not valid'])
    end
end

LresubmitFailedJobs = false;
% Check that required arguments have been defined
Creqfields  = {'Xjob','PinputALL'};   % mandatory variables
for i=1:length(Creqfields),
    if ~exist(Creqfields{i},'var'),
        error('openCOSSAN:Mio:runJob',[Creqfields{i} ' is a mandatory argument and it has not been passed']);
    end
end
% Define number of simulations per job
if exist('Nconcurrent','var')
    Xjob.Nconcurrent = Nconcurrent;
end

if (Xjob.Nconcurrent == Inf),     % checks whether or not Njobs has been defined
    Njobs      = size(PinputALL,1);   % sets number of jobs equal to number of simulations to be performed
    Vsimxjobs  = ones(size(PinputALL))';    % obviously, there is one simulation per job
else
    Njobs      = min(Xjob.Nconcurrent,size(PinputALL,1)); % re-adjusts number of jobs (if required)
    Vsimxjobs = floor(size(PinputALL,1)/Xjob.Nconcurrent)*ones(1,Xjob.Nconcurrent);
    Vsimxjobs(1:rem(size(PinputALL,1),Xjob.Nconcurrent)) = ...
        Vsimxjobs(1:rem(size(PinputALL,1),Xjob.Nconcurrent)) + 1; % sets number of simulations per job
    % if there are less samples than concurrent jobs remove jobs with no samples
    Vsimxjobs(Vsimxjobs==0) = [];
end

%% Create the function-wrapping script
if ~isempty(Xmio.Sscript)
    Xmio.SwrapperName = 'run_script.m';
else
    Xmio.SwrapperName = ['run_',Xmio.Sfile,'.m'];
end
OpenCossan.cossanDisp(['[OpenCossan.connector.mio.run] Creating the "function wrapping" script '...
    fullfile(OpenCossan.getCossanWorkingPath,Xmio.SwrapperName)],4);
[Nfid,Serr] = fopen(fullfile(OpenCossan.getCossanWorkingPath,Xmio.SwrapperName),'w');

assert(Nfid>0,'openCOSSAN:Mio:runJob',['Failed creating MIO wrapper file! Error message: ' Serr])
%%
fprintf(Nfid,'%%%% Wrapping script. DO NOT EDIT!\n');

% assemble the string used to call the main function in a try-catch block
fprintf(Nfid,'%% initialize error variable\n');
fprintf(Nfid,'ME = [];\n');
fprintf(Nfid,'%% Add the location of the function to the path\n');
if ~isempty(Xmio.Spath)
    fprintf(Nfid,'addpath(''%s'');\n',Xmio.Spath);
end
if ~isempty(Xmio.Sadditionalpath)
    fprintf(Nfid,'addpath(''%s'');\n',Xmio.Sadditionalpath);
end
fprintf(Nfid,'try\n');
fprintf(Nfid,'    load mioINPUT.mat\n');
if Xmio.Lfunction
%% wrapping a function
    if Xmio.Liomatrix
        Sfunctioncall = '    Moutput = ';
    elseif Xmio.Liostructure
        Sfunctioncall = '    Toutput = ';
    else
        Sfunctioncall = '    [';
        for iout = 1:length(Xmio.Coutputnames)-1
            Sfunctioncall = [Sfunctioncall, 'Moutput(:,' num2str(iout) '), ']; %#ok<AGROW>
        end
        Sfunctioncall=[Sfunctioncall 'Moutput(:,' num2str(length(Xmio.Coutputnames)) ')] ='];
    end
    Sfunctioncall = [Sfunctioncall,strrep(Xmio.Sfile,'.m','') '(']; % remove .m from the filename if present
    if Xmio.Liomatrix
        Sfunctioncall = [Sfunctioncall,'Minput'];
    elseif Xmio.Liostructure
        Sfunctioncall = [Sfunctioncall,'Tinput'];
    else
        Sfunctioncall = [Sfunctioncall,'Cinput{:}'];
    end
    Sfunctioncall = [Sfunctioncall, ');\n'];
    fprintf(Nfid,Sfunctioncall);
else
%% wrapping a script
    if ~isempty(Xmio.Sscript)
        fprintf(Nfid,'    %s \n',Xmio.Sscript);
    else
        Sscriptcall = ['    run(''' fullfile(Xmio.Spath,Xmio.Sfile) ''');\n' ];
        fprintf(Nfid,Sscriptcall);
    end
end
fprintf(Nfid,'catch ME\n');
if Xmio.Lfunction
    fprintf(Nfid,'    display(''Error in function execution'');\n');
else
    fprintf(Nfid,'    display(''Error in script execution'');\n');
end
fprintf(Nfid,'    display(ME.message)\n');
fprintf(Nfid,'    for i=length(ME.stack):-1:1;\n');
fprintf(Nfid,'        display(ME.stack(i).file)\n');
fprintf(Nfid,'        display(ME.stack(i).line)\n');
fprintf(Nfid,'    end\n');
fprintf(Nfid,'end\n');
fprintf(Nfid,'if isempty(ME)\n');
if Xmio.Liostructure
    fprintf(Nfid,'save mioOUTPUT.mat Toutput\n');
else
    fprintf(Nfid,'save mioOUTPUT.mat Moutput\n');
end
fprintf(Nfid,'end\n');
fprintf(Nfid,'exit;\n');
%%
fclose(Nfid);


%% Divide Input samples through different jobs (1 folder for each job)
% Define vectors with counter for determining the simulations that go into
% each job
Vend = cumsum(Vsimxjobs);  % defines number of final simulation for job
Vstart = [1, Vend(1:end-1)+1]; % defines number of starting simulation for job
CSjobID=cell(Njobs,1);          % cell array to store the Id of the jobs

% iteration over the number of jobs
for irun=1:Njobs
    %  If required, displays information on which job is being processed
    OpenCossan.cossanDisp(['Preparing input file for Mio Simulation #' num2str(irun) ' of ' num2str(Njobs) ],2);
    %  Creates folder where the job will be executed
    Sfoldername    = [Xjob.Sfoldername '_sim_' num2str(irun)];  % defines name of folder where the job will be executed
    mkdir(fullfile(OpenCossan.getCossanWorkingPath,Sfoldername));    % creates the folder
    % set the execution command
    Xjob.Sexecmd = ['cd ' fullfile(OpenCossan.getCossanWorkingPath,Sfoldername) '; '...
        strrep(fullfile(OpenCossan.getMatlabPath,'bin','matlab'),' ','\\ ') ...
        ' -r ' strrep(Xmio.SwrapperName,'.m','') ' -nosplash -nodesktop'];
    %  Copy input files into the new grid folder
    if Xmio.Liostructure
        % copies input - case of structure
        Tinput  = PinputALL(Vstart(irun):Vend(irun));    %#ok<NASGU>
        save ([OpenCossan.getCossanWorkingPath filesep Sfoldername filesep 'mioINPUT.mat'],'Tinput');     %saves file
    elseif Xmio.Liomatrix
        % copies input - case of matrix
        Minput  = PinputALL(Vstart(irun):Vend(irun),:);  %#ok<NASGU>
        save ([OpenCossan.getCossanWorkingPath filesep Sfoldername filesep 'mioINPUT.mat'],'Minput');     %saves file
    else
        error('openCOSSAN:mio:runJob',...
            'Method runJob of Mio supports only Mio with functions with structures or single sample matrix Input/Output.')
    end
    %  Copy exec file and script to run it in the folder
    [status,mess] =copyfile(fullfile(OpenCossan.getCossanWorkingPath,Xmio.SwrapperName),...
        fullfile(OpenCossan.getCossanWorkingPath,Sfoldername));  % copies exec file
    if status==0
        OpenCossan.cossanDisp(['Copy ' Xmio.SwrapperName ': ' Sfoldername ' mess: ' mess],3);
    end
    
    %% Submit the job
    CSjobID(irun)     = Xjob.submitJob('Nsimulationnumber',irun,...
        'Sfoldername',Sfoldername);
end

OpenCossan.cossanDisp(['All your jobs have been submitted -' datestr(clock)],2)

%%  Check if all the jobs have finished
Lcompleted(1:Njobs)=false;
LfirstResubmission(1:Njobs) = true;
while 1
    while ~all(Lcompleted==1)
        %% Termination criteria KILL (from GUI)
        % Check if the file name KILL exists in the working directory
        if exist(fullfile(OpenCossan.getCossanWorkingPath,OPENCOSSAN.Skillfilename),'file')
            OpenCossan.cossanDisp('Analysis terminated by the user',1);
            % Cancel submitted jobs
            Xjob.deleteJob('CsjobID',CSjobID);
            error('openCOSSAN:Mio:runJob','Simulation killed by the user.')
        end
        pause(1);
        Cstatus(~Lcompleted,:) = Xjob.getJobStatus('CSjobID',CSjobID(~Lcompleted)); % check the status of the one that are not yet completed only
        Lcompleted = ~(strcmp('running',Cstatus(:,1))|strcmp('pending',Cstatus(:,1)) | ... % gridengine status return
            strcmp('RUN',Cstatus(:,1))|strcmp('PEND',Cstatus(:,1))); % LSF status return
    end
    %% check if all the jobs completed successfully
    Lsuccessfull = Xjob.checkSuccessfulJobs('mioOUTPUT.mat');
    if LresubmitFailedJobs
        if ~all(Lsuccessfull)
            OpenCossan.cossanDisp(['Number of failed jobs at previous submission: ' num2str(sum(~Lsuccessfull))],4)
            assert(all(LfirstResubmission),'openCOSSAN:Mio:runJob',...
                'Trying to resubmit a failed job for the second time. Aborted!')
            Lcompleted(~Lsuccessfull)=false;
            % try to resubmit the failed jobs
            for ijob = (find(~Lsuccessfull)')
                CSjobID(ijob)     = Xjob.submitJob('Nsimulationnumber',ijob,...
                    'Sfoldername',Sfoldername,'Lresubmit',true);
            end
            LfirstResubmission(ijob) = false; % set the flag to indicate that job has been resubmitted
        end
    end
    
    % check cycle exit condition
    if all(Lcompleted)
        break
    end
end

%% Retrieve results
% Variables for retrieving results
PoutputALL = [];
Vresults   = zeros(Njobs,1);  % vector to define which results have been read so far;

%  Load results form output files
[PoutputALL, Vresults] = Xmio.retrieveResults(Vresults,Vstart,Vend,PoutputALL,Xjob);
% In case some results are missing, try to reload
if any(Vresults==0),
    % if not all the simulation were readed correctly try againg
    [PoutputALL(Vresults==0), Vresults] = Xmio.retrieveResults(Vresults,Vstart,Vend,PoutputALL,Xjob);
end
% Manage results that could not be loaded
if any(Vresults==0),
    % Include NaN in the output if the results of the simulation can not be
    % retrieved
    Vpos   = find(Vresults==0);   %determine results that could not be retrieved
    for ij=1:length(Vpos),
        if isa(PoutputALL,'struct'),
            for isim = Vstart(Vpos(ij)):Vend(Vpos(ij))
                for ifield = 1:length(Xmio.Coutputnames)
                    PoutputALL(isim).(Xmio.Coutputnames{ifield})    = NaN;
                end
            end
        else
            if ~isempty(PoutputALL)
                PoutputALL(Vstart(Vpos(ij)):Vend(Vpos(ij)),:)  = NaN(size(Xmio.Coutputnames));
            else
                PoutputALL = NaN(Vend(Vpos(ij)) - Vstart(Vpos(ij))+1,length(Xmio.Coutputnames));
            end
        end
    end
end

%% Export results - create output object
if isa(PoutputALL,'struct'),
    Xsimtmp=SimulationData('Tvalues',PoutputALL);
elseif isa(PoutputALL,'double'),
    Xsimtmp=SimulationData('Mvalues',PoutputALL,'Cvariablenames',Xmio.Coutputnames);
else
    error('openCOSSAN:Mio:runJob','The output of a compiled MIO has to be a structure or a matrix');
end

if  exist('XSimOut','var')
    XSimOut=XSimOut.merge(Xsimtmp);
else
    XSimOut=Xsimtmp;
end

return
