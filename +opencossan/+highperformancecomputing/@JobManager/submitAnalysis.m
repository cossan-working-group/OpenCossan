function CSjobID=submitAnalysis(Xjob,XSimInp)

%% Prepare Job
if (Xjob.Nconcurrent == Inf),     % checks whether or not Njobs has been defined
    Njobs      = Nsamples;   % sets number of jobs equal to number of simulations to be performed
    Vsimxjobs  = ones(Nsamples,1)';    % obviously, there is one simulation per job
else
    Njobs      = min(Xjob.Nconcurrent,Nsamples); % re-adjusts number of jobs (if required)
    Vsimxjobs = floor(Nsamples/Xjob.Nconcurrent)*ones(1,Xjob.Nconcurrent);
    Vsimxjobs(1:rem(Nsamples,Xjob.Nconcurrent)) = ...
        Vsimxjobs(1:rem(Nsamples,Xjob.Nconcurrent)) + 1; % sets number of simulations per job
    % if there are less samples than concurrent jobs remove jobs with no samples
    Vsimxjobs(Vsimxjobs==0) = [];
end

%% Divide Input samples through different jobs (1 folder for each job)
% Define vectors with counter for determining the simulations that go into
% each job
CSjobID=cell(Njobs,1);          % cell array to store the Id of the jobs

% iteration over the number of jobs
for irun=1:Njobs
    %  If required, displays information on which job is being processed
    OpenCossan.cossanDisp(['Preparing input file for Job #' num2str(irun) ' of ' num2str(Njobs) ],2);
    %  Creates folder where the job will be executed
    Sfoldername    = [Xjob.Sfoldername '_sim_' num2str(irun)];  % defines name of folder where the job will be executed
    mkdir(fullfile(OpenCossan.getCossanWorkingPath,Sfoldername));    % creates the folder
    % set the execution command
    Xjob.Sexecmd = ['cd ' fullfile(OpenCossan.getCossanWorkingPath,Sfoldername) '; '...
        strrep(fullfile(OpenCossan.getMatlabPath,'bin','matlab'),' ','\\ ') ...
        ' -r ' strrep(OpenCossan.SwrapperName,'.m','') ' -nosplash -nodesktop'];
    
    Tinput  = PinputALL(Vstart(irun):Vend(irun)); 
    
    %  Copy exec file and script to run it in the folder
    [status,mess] =copyfile(fullfile(OpenCossan.getCossanWorkingPath,OpenCossan.SwrapperName),...
        fullfile(OpenCossan.getCossanWorkingPath,Sfoldername));  % copies exec file
    if status==0
        OpenCossan.cossanDisp(['Copy ' OpenCossan.SwrapperName ': ' Sfoldername ' mess: ' mess],3);
    end
    
    %% Submit the job
    CSjobID(irun)     = Xjob.submitJob('Nsimulationnumber',irun,...
        'Sfoldername',Sfoldername);
end
OpenCossan.cossanDisp(['All your jobs have been submitted -' datestr(clock)],2)