function [XSimOut,PoutputALL] = runJobCompiled(Xmio,varargin)

global OPENCOSSAN

% check that CossanX has been correctly initialized; if SmcrPath is empty,
% the compiled Mio cannot be executed!
assert(~isempty(OPENCOSSAN.SmcrPath),'openCOSSAN:Mio:runJob',...
    ['The compiled Mio cannot executed on remote machines if the path\n',...
    'of the MCR is not specified in the preferences!'])

%% Check existence of bin directory with compiled files
if ~exist(fullfile(Xmio.Spath,'bin'),'dir'),
    error('openCOSSAN:mio:runJob', ...
        ['The directory ' fullfile(Xmio.Spath,'bin') '  with the compiled mio does not exist \n' ...
        'Try to recompile the Mio object before using Mio with the JobManager object']);
end

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
%             Xjob.Sjobname    = ['mio_' Xjob.Sfoldername]; % define name of job to be submitted
        case {'lkeepsimfiles'},     % option for keeping files after simulation is completed
            Xmio.Lkeepsimfiles    = varargin{k+1};
        case {'xsimout','xsimulationoutput','simulationoutput'},  % in case user passes an existing Output object
            XSimOut    = varargin{k+1};
        case {'njobs','nconcurrent'},     % define number of jobs
            Nconcurrent  = varargin{k+1};
        otherwise
            error('openCOSSAN:Mio:runGrid',[varargin{k} ' - PropertyName not valid'])
    end
end
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
else
    Njobs      = min(Xjob.Nconcurrent,length(PinputALL)); % re-adjusts number of jobs (if required)
    Vsimxjobs = floor(length(PinputALL)/Xjob.Nconcurrent)*ones(1,Xjob.Nconcurrent);
    Vsimxjobs(1:rem(length(PinputALL),Xjob.Nconcurrent)) = ...
        Vsimxjobs(1:rem(length(PinputALL),Xjob.Nconcurrent)) + 1; % sets number of simulations per job
    % if there are less samples than concurrent jobs remove jobs with no samples
    Vsimxjobs(Vsimxjobs==0) = [];
end

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
    mkdir(Sfoldername);    % creates the folder
    % set the execution command
    Xjob.Sexecmd = ['cd ' fullfile(Xmio.Spath,Sfoldername) '; '...
        './run_' Xmio.SwrapperName '.sh']; 
    % the compile mio needs as inputs the path of the MCR
    Xjob.Sexeflags = OPENCOSSAN.SmcrPath; 
    %  Copy input files into the new grid folder
    if Xmio.Liostructure
        % copies input - case of structure
        Tinput  = PinputALL(Vstart(irun):Vend(irun));    %#ok<NASGU> 
        save ([Sfoldername filesep 'mioINPUT.mat'],'Tinput');     %saves file
    elseif Xmio.Liomatrix
        % copies input - case of matrix   
        Minput  = PinputALL(Vstart(irun):Vend(irun),:);  %#ok<NASGU>      
        save ([Sfoldername filesep 'mioINPUT.mat'],'Minput');     %saves file
    else
        error('openCOSSAN:mio:runJob',...
            'Method runJob of Mio supports only Mio with functions with structures or single sample matrix Input/Output.')
    end
    %  Copy exec file and script to run it in the folder
    [status,mess] =copyfile(fullfile(Xmio.Spath,'bin',Xmio.SwrapperName),Sfoldername);  % copies exec file
    if status==0
        OpenCossan.cossanDisp(['Copy ' Xmio.SwrapperName ': ' Sfoldername ' mess: ' mess],3);
    end
    [status,mess] =copyfile(fullfile(Xmio.Spath,'bin',['run_' Xmio.SwrapperName '.sh']),Sfoldername);
    if status==0
        OpenCossan.cossanDisp(['Copy run_' Xmio.SwrapperName '.sh: ' Sfoldername ' mess: ' mess],3)
    end
    
    %% Submit the job
    CSjobID(irun)     = Xjob.submitJob('nsimulationnumber',irun,...
        'Sfoldername',Sfoldername);
end

OpenCossan.cossanDisp(['All your jobs have been submitted -' datestr(clock)],2)

%%  Check if all the jobs have finished
Lcompleted(1:Njobs)=false;

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
    Lcompleted = ~(strcmp('running',Cstatus(:,1))|strcmp('pending',Cstatus(:,1)));
    
    %% Termination criteria KILL (from GUI)
    % Check if the file name KILL exists in the working directory
    if exist(fullfile(OpenCossan.getCossanWorkingPath,OPENCOSSAN.Skillfilename),'file')
        % Remove the KILL file
        delete(fullfile(OpenCossan.getCossanWorkingPath,OPENCOSSAN.Skillfilename));
            
        OpenCossan.cossanDisp('Analysis terminated by the user',1);
        % Cancel submitted jobs
        Xjob.deleteJob('CSjobID',CSjobID);
        return
    end
end

%% Retrive results
% Variables for retrieving results
PoutputALL = [];
Vresults   = zeros(Njobs,1);  % vector to define which results have been read so far;
%  Load results form output files
[PoutputALL, Vresults] = Xmio.retrieveResults(Vresults,Vstart,Vend,PoutputALL,Xjob);
% In case some results are missing, try to reload
if any(Vresults==0),
    % if not all the simulation were readed correctly try againg
    [PoutputALL, Vresults] = Xmio.retrieveResults(Vresults,Vstart,Vend,PoutputALL,Xjob);
end
% Manage results that could not be loaded
if any(Vresults==0),
    % Include NaN in the output if the results of the simulation can not be
    % retrieved
    Vpos   = find(Vresults==0);   %determine results that could not be retrieved
    for ij=1:length(Vpos),
        if isa(PoutputALL,'struct'),
            PoutputALL(Vstart(Vpos(ij)):Vend(Vpos(ij)))    = NaN;
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
