function Xobj = runFESolverParallel(Xobj)
%RUNNASTRAN   Calls FE solver to perform the analysis for the prepared SFEM problem
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/runFESolverParallel@SFEM
%
% =======================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% =======================================================================

global OPENCOSSAN

startTime = OPENCOSSAN.Xtimer.currentTime;

OpenCossan.cossanDisp('[SFEM.runFESolverParallel] Execution of FE solver is performed in parallel using Xgrid',2);
OpenCossan.cossanDisp(' ',2);

%% Retrieve input data

Xinp            = Xobj.Xmodel.Xinput;                                 % Obtain Input
assert(length(Xinp.CnamesRandomVariableSet)==1,'openCOSSAN:SFEM:checkInput',...
    'Only 1 Random Variable Set is allowed in SFEM.')
Xrvs            = Xinp.Xrvset.(Xinp.CnamesRandomVariableSet{1});    % Obtain RVSET
Crvnames        = Xinp.CnamesRandomVariable;                  % Obtain RV names
Nrvs            = Xinp.NrandomVariables;                      % Obtain No of RVs
Xconnector      = Xobj.Xmodel.Xevaluator.CXsolvers{1};                % Obtain Connector object
Sfesolver       = Xconnector.Stype;                                   % Obtain FE solver type
XsfemGrid       = Xobj.Xmodel.Xevaluator.getJobManager(...            % Obtain the Grid
    'SsolverName',Xobj.Xmodel.Xevaluator.CSnames{1});

%% Setup related parameters if Xgrid is to be used

% Define the root name for the directories
% Note: Later a directory with a unique name for EACH FE Solver
%       analysis will be created
XsfemGrid.Sfoldername = datestr(now,30);
% Set the working directory
XsfemGrid.Sworkingdirectory = Xconnector.Sworkingdirectory;
% Set the main input path
XsfemGrid.Smaininputpath    = OpenCossan.getCossanWorkingPath;

Nrunningjobs = 0;
if XsfemGrid.Nconcurrent == Inf
    % in order to be able to exit the cycle, if XsfemGridNconcurrent is
    % unlimited it must be set to the total nr. of samples
    Nconcurrent = length(Tinput);
else
    Nconcurrent = XsfemGrid.Nconcurrent;
end
%% Determine how many runs will be needed in total

% NOTE: For Guyan-PC and Modal analysis (using ABAQUS), two nominal
%       analysis are required
if strcmpi(Xobj.Smethod,'Guyan')
    Ntotalruns = Nrvs*Xobj.NinputApproximationOrder+2;
elseif strcmpi(Xobj.Simplementation,'Componentwise')
    Ntotalruns = Nrvs*Xobj.NinputApproximationOrder+Nrvs+1;
elseif strcmpi(Xobj.Sanalysis,'Modal') && strcmpi(Sfesolver,'abaqus')
    Ntotalruns = Nrvs*Xobj.NinputApproximationOrder+2;
else
    Ntotalruns = Nrvs*Xobj.NinputApproximationOrder+1;
end
% Initialize the cell array to store the IDs of the submitted jobs
CSjobID = cell(Ntotalruns,1);
% assure that all the entries are strings otherwhise validatecossaninputs
% will fail
for nid=1:Ntotalruns;
    CSjobID{nid}='';
end
% Set the Jobid counter
jobid   = 1;

%% Obtain nominal response

% ABAQUS only accepts files with .inp extension
if strcmpi(Sfesolver,'abaqus')
    Xconnector.Smaininputfile='nominal.inp';
else
    Xconnector.Smaininputfile='nominal.dat';
end

Xconnector.Sworkingdirectory = fullfile(OpenCossan.getCossanWorkingPath,[XsfemGrid.Sfoldername...
    '_sfem_' num2str(jobid) ]);
XsfemGrid.Sexecmd            = Xconnector.SexecutionCommand;
Xobj                         = fileManagementXgrid(Xobj,Xconnector.Sworkingdirectory,...
    Xconnector.Smaininputfile);

% Submit the job
CSjobID(jobid) = XsfemGrid.submitJob('nsimulationnumber',jobid,...
    'Sfoldername',[XsfemGrid.Sfoldername '_sfem_' num2str(jobid)]);
jobid = jobid + 1;
Nrunningjobs = Nrunningjobs+1;

%% following part is necessary only for Guyan P-C

if strcmpi(Xobj.Smethod,'Guyan')
    Xconnector.Smaininputfile    = 'nominal2.dat';
    Xconnector.Sworkingdirectory = fullfile(OpenCossan.getCossanWorkingPath,[XsfemGrid.Sfoldername...
        '_sfem_' num2str(jobid) ]);
    XsfemGrid.Sexecmd            = Xconnector.SexecutionCommand;
    Xobj                         = fileManagementXgrid(Xobj,Xconnector.Sworkingdirectory,...
        Xconnector.Smaininputfile);
    
    while (Nrunningjobs - Nconcurrent)>=0
        Cstatus = XsfemGrid.getJobStatus('CSjobID',CSjobID);
        Lrunning = strcmp('running',Cstatus(:,1))|strcmp('pending',Cstatus(:,1));
        Nrunningjobs = sum(Lrunning);
        pause(Xconnector.sleepTime)
    end
    % Submit the job
    CSjobID(jobid) = XsfemGrid.submitJob('nsimulationnumber',jobid,...
        'Sfoldername',[XsfemGrid.Sfoldername '_sfem_' num2str(jobid)]);
    jobid = jobid + 1;
    Nrunningjobs = Nrunningjobs+1;
end

%% Obtain the perturbed System Matrices
%
% PARALLEL EXECUTION - USING XGRID
if Xobj.NinputApproximationOrder == 1
    for irvno=1:Nrvs
        % POSITIVE PERTURBED
        if strcmpi(Sfesolver,'abaqus')
            Xconnector.Smaininputfile = ['positive_perturbed_' Crvnames{irvno} '.inp'];
        else
            Xconnector.Smaininputfile = ['positive_perturbed_' Crvnames{irvno} '.dat'];
        end
        Xconnector.Sworkingdirectory = fullfile(OpenCossan.getCossanWorkingPath,[XsfemGrid.Sfoldername...
            '_sfem_' num2str(jobid) ]);
        XsfemGrid.Sexecmd            = Xconnector.SexecutionCommand;
        Xobj                         = fileManagementXgrid(Xobj,Xconnector.Sworkingdirectory,...
            Xconnector.Smaininputfile);
        
        while (Nrunningjobs - Nconcurrent)>=0
            Cstatus = XsfemGrid.getJobStatus('CSjobID',CSjobID);
            Lrunning = strcmp('running',Cstatus(:,1))|strcmp('pending',Cstatus(:,1));
            Nrunningjobs = sum(Lrunning);
            pause(Xconnector.sleepTime)
        end
        % Submit the job
        CSjobID(jobid) = XsfemGrid.submitJob('nsimulationnumber',jobid,...
            'Sfoldername',[XsfemGrid.Sfoldername '_sfem_' num2str(jobid)]);
        jobid = jobid + 1;
        Nrunningjobs = Nrunningjobs+1;
        
        if strcmpi(Xobj.Simplementation,'Componentwise')
            % NOMINAL COMPONENTWISE
            Xconnector.Smaininputfile = ['nominal_' Crvnames{irvno} '.dat'];
            Xconnector.Sworkingdirectory = fullfile(OpenCossan.getCossanWorkingPath,[XsfemGrid.Sfoldername...
                '_sfem_' num2str(jobid) ]);
            XsfemGrid.Sexecmd            = Xconnector.SexecutionCommand;
            Xobj                         = fileManagementXgrid(Xobj,Xconnector.Sworkingdirectory,...
                Xconnector.Smaininputfile);
            
            while (Nrunningjobs - Nconcurrent)>=0
                Cstatus = XsfemGrid.getJobStatus('CSjobID',CSjobID);
                Lrunning = strcmp('running',Cstatus(:,1))|strcmp('pending',Cstatus(:,1));
                Nrunningjobs = sum(Lrunning);
                pause(Xconnector.sleepTime)
            end
            % Submit the job
            CSjobID(jobid) = XsfemGrid.submitJob('nsimulationnumber',jobid,...
                'Sfoldername',[XsfemGrid.Sfoldername '_sfem_' num2str(jobid)]);
            jobid = jobid + 1;
            Nrunningjobs = Nrunningjobs+1;
        end
    end
elseif Xobj.NinputApproximationOrder == 2
    for irvno=1:Nrvs
        % POSITIVE PERTURBED
        Xconnector.Smaininputfile = ['positive_perturbed_' Crvnames{irvno} '.dat'];
        Xconnector.Sworkingdirectory = fullfile(OpenCossan.getCossanWorkingPath,[XsfemGrid.Sfoldername...
            '_sfem_' num2str(jobid) ]);
        XsfemGrid.Sexecmd            = Xconnector.SexecutionCommand;
        Xobj                         = fileManagementXgrid(Xobj,Xconnector.Sworkingdirectory,...
            Xconnector.Smaininputfile);
        
        while (Nrunningjobs - Nconcurrent)>=0
            Cstatus = XsfemGrid.getJobStatus('CSjobID',CSjobID);
            Lrunning = strcmp('running',Cstatus(:,1))|strcmp('pending',Cstatus(:,1));
            Nrunningjobs = sum(Lrunning);
            pause(Xconnector.sleepTime)
        end
        % Submit the job
        CSjobID(jobid) = XsfemGrid.submitJob('nsimulationnumber',jobid,...
            'Sfoldername',[XsfemGrid.Sfoldername '_sfem_' num2str(jobid)]);
        jobid = jobid + 1;
        Nrunningjobs = Nrunningjobs+1;
        % NEGATIVE PERTURBED
        Xconnector.Smaininputfile = ['negative_perturbed_' Crvnames{irvno} '.dat'];
        Xconnector.Sworkingdirectory = fullfile(OpenCossan.getCossanWorkingPath,[XsfemGrid.Sfoldername...
            '_sfem_' num2str(jobid) ]);
        XsfemGrid.Sexecmd            = Xconnector.SexecutionCommand;
        Xobj                         = fileManagementXgrid(Xobj,Xconnector.Sworkingdirectory,...
            Xconnector.Smaininputfile);
        
        while (Nrunningjobs - Nconcurrent)>=0
            Cstatus = XsfemGrid.getJobStatus('CSjobID',CSjobID);
            Lrunning = strcmp('running',Cstatus(:,1))|strcmp('pending',Cstatus(:,1));
            Nrunningjobs = sum(Lrunning);
            pause(Xconnector.sleepTime)
        end
        % Submit the job
        CSjobID(jobid) = XsfemGrid.submitJob('nsimulationnumber',jobid,...
            'Sfoldername',[XsfemGrid.Sfoldername '_sfem_' num2str(jobid)]);
        jobid = jobid + 1;
        Nrunningjobs = Nrunningjobs+1;
        if strcmpi(Xobj.Simplementation,'Componentwise')
            % NOMINAL COMPONENTWISE
            Xconnector.Smaininputfile = ['nominal_' Crvnames{irvno} '.dat'];
            Xconnector.Sworkingdirectory = fullfile(OpenCossan.getCossanWorkingPath,[XsfemGrid.Sfoldername...
                '_sfem_' num2str(jobid) ]);
            XsfemGrid.Sexecmd            = Xconnector.SexecutionCommand;
            Xobj                         = fileManagementXgrid(Xobj,Xconnector.Sworkingdirectory,...
                Xconnector.Smaininputfile);
            
            while (Nrunningjobs - Nconcurrent)>=0
                Cstatus = XsfemGrid.getJobStatus('CSjobID',CSjobID);
                Lrunning = strcmp('running',Cstatus(:,1))|strcmp('pending',Cstatus(:,1));
                Nrunningjobs = sum(Lrunning);
                pause(Xconnector.sleepTime)
            end
            % Submit the job
            CSjobID(jobid) = XsfemGrid.submitJob('nsimulationnumber',jobid,...
                'Sfoldername',[XsfemGrid.Sfoldername '_sfem_' num2str(jobid)]);
            jobid = jobid + 1;
            Nrunningjobs = Nrunningjobs+1;
        end
    end
end

%% Check if all the jobs have finished

Lcompleted=false(size(CSjobID,1),1);
while ~all(Lcompleted==1)
    pause(Xconnector.sleepTime);
    if OpenCossan.getVerbosityLevel>3 && isdeployed
        disp('Uncompleted jobs:')
        CSjobID(~Lcompleted)
    end
    Cstatus(~Lcompleted,:) = XsfemGrid.getJobStatus('CSjobID',CSjobID(~Lcompleted));
    Lcompleted = ~(strcmp('running',Cstatus(:,1))|strcmp('pending',Cstatus(:,1)));
end
% Check for errors
Cstatus = XsfemGrid.getJobStatus('CSjobID',CSjobID);
% check for completed status
Lcheck = strcmp('completed',Cstatus(:,1));
if all(Lcheck==1)
    OpenCossan.cossanDisp('[SFEM.runFESolverParallel] All submitted jobs completed',2);
    OpenCossan.cossanDisp(' ',2);
else
    OpenCossan.cossanDisp('[SFEM.runFESolverParallel] Some jobs returned with error',2);
    OpenCossan.cossanDisp(' ',2);
end

%% Copy the files for system matrices/vectors & DOF info back to the main directory

for i=1:Ntotalruns
    Sfoldername = fullfile(OpenCossan.getCossanWorkingPath,[XsfemGrid.Sfoldername '_sfem_' num2str(i) ]);
    if strcmpi(Sfesolver,'ansys')
        if i==1
            [status, ~] = copyfile(fullfile(Sfoldername,...
                [Xobj.Sjobname '_K_NOMINAL.mapping']),OpenCossan.getCossanWorkingPath);
            if status == 0
                error('openCOSSAN:SFEM:runFESolverParallel',['[SFEM.runFESolverParallel] ' Xobj.Sjobname '_K_NOMINAL.mapping could not be copied']);
            elseif status == 1
                OpenCossan.cossanDisp(['[SFEM.runFESolverParallel] ' Xobj.Sjobname '_K_NOMINAL.mapping successfully'],3);
            end
            [status, ~] = copyfile(fullfile(Sfoldername,...
                [Xobj.Sjobname '_K_NOMINAL']),OpenCossan.getCossanWorkingPath);
            if status == 0
                error('openCOSSAN:SFEM:runFESolverParallel',['[SFEM.runFESolverParallel] ' Xobj.Sjobname '_K_NOMINAL could not be copied']);
            elseif status == 1
                OpenCossan.cossanDisp(['[SFEM.runFESolverParallel] ' Xobj.Sjobname '_K_NOMINAL copied successfully'],3);
            end
        elseif i>1
            [status, ~] = copyfile(fullfile(Sfoldername,...
                [Xobj.Sjobname '_K_POS_PER_' Crvnames{i-1}]),OpenCossan.getCossanWorkingPath);
            if status == 0
                error('openCOSSAN:SFEM:runFESolverParallel',['[SFEM.runFESolverParallel] ' Xobj.Sjobname '_K_POS_PER_' upper(Crvnames{i-1}) 'could not be copied']);
            elseif status == 1
                OpenCossan.cossanDisp(['[SFEM.runFESolverParallel] ' Xobj.Sjobname  '_K_POS_PER_' Crvnames{i-1} ' copied successfully'],3);
            end
        end
    elseif strcmpi(Sfesolver(1:5),'nastr')
        [status, ~] = copyfile(fullfile(Sfoldername,'*.OP4'),OpenCossan.getCossanWorkingPath);
        [status, ~] = copyfile(fullfile(Sfoldername,'*.PCH'),OpenCossan.getCossanWorkingPath);
    elseif strcmpi(Sfesolver,'abaqus')
        if strcmpi(Xobj.Sanalysis,'Modal')
            if i==1
                [status, ~] = copyfile(fullfile(Sfoldername,'nominal_LOAD2.mtx'),...
                    OpenCossan.getCossanWorkingPath);
                [status, ~] = copyfile(fullfile(Sfoldername,'nominal_STIF2.mtx'),...
                    fullfile(OpenCossan.getCossanWorkingPath,[Xobj.Sjobname '_K_NOMINAL.mtx']));
            elseif i==2
                [status, ~] = copyfile(fullfile(Sfoldername,'nominal2_MASS2.mtx'),...
                    fullfile(OpenCossan.getCossanWorkingPath,[Xobj.Sjobname '_M_NOMINAL.mtx']));
            elseif i>2
                [status, ~] = copyfile(fullfile(Sfoldername,['positive_perturbed_'  Crvnames{i-2} '_STIF2.mtx']),...
                    fullfile(OpenCossan.getCossanWorkingPath,[Xobj.Sjobname '_K_POS_PER_' upper(Crvnames{i-2}) '.mtx']));
            end
        else
            if i==1
                [status, ~] = copyfile(fullfile(Sfoldername,'nominal_LOAD2.mtx'),...
                    OpenCossan.getCossanWorkingPath);
                [status, ~] = copyfile(fullfile(Sfoldername,'nominal_STIF2.mtx'),...
                    fullfile(OpenCossan.getCossanWorkingPath,[ Xobj.Sjobname '_K_NOMINAL.mtx']));
            elseif i>1
                [status, ~] = copyfile(fullfile(Sfoldername,['positive_perturbed_'  Crvnames{i-1} '_STIF2.mtx']),...
                    fullfile(OpenCossan.getCossanWorkingPath,[Xobj.Sjobname '_K_POS_PER_' upper(Crvnames{i-1}) '.mtx']));
            end
        end
        
    end
    if Xobj.Lcleanfiles
        [status, ~] = rmdir(Sfoldername,'s');
    end
end

%% clean files

if Xobj.Lcleanfiles
    if strcmpi(Sfesolver(1:5),'nastr')
        delete(fullfile(OpenCossan.getCossanWorkingPath,'*.f06'));
        delete(fullfile(OpenCossan.getCossanWorkingPath,'*.f04'));
        delete(fullfile(OpenCossan.getCossanWorkingPath,'*.log'));
%         delete([Xconnector.Smaininputpath  '*.sh'));
        delete(fullfile(OpenCossan.getCossanWorkingPath,'*.err'));
        delete(fullfile(OpenCossan.getCossanWorkingPath,'*.out'));
        delete(fullfile(OpenCossan.getCossanWorkingPath,'dmap*.dat'));
        delete(fullfile(OpenCossan.getCossanWorkingPath,'pos*.*'));
        delete(fullfile(OpenCossan.getCossanWorkingPath,'neg*.*'));
        delete(fullfile(OpenCossan.getCossanWorkingPath,'nominal*.*'));
        delete(fullfile(OpenCossan.getCossanWorkingPath,'constant*.*'));
%         delete([Xconnector.Smaininputpath  '*.inp'));
    elseif strcmpi(Sfesolver,'ansys')
        delete(fullfile(OpenCossan.getCossanWorkingPath,'*.db'));
        delete(fullfile(OpenCossan.getCossanWorkingPath,'*.err'));
        delete(fullfile(OpenCossan.getCossanWorkingPath,'*.mntr'));
        delete(fullfile(OpenCossan.getCossanWorkingPath,'*.log'));
        delete(fullfile(OpenCossan.getCossanWorkingPath,'*.esav'));
        delete(fullfile(OpenCossan.getCossanWorkingPath,'*.full'));
        delete(fullfile(OpenCossan.getCossanWorkingPath,'pos*.*'));
        delete(fullfile(OpenCossan.getCossanWorkingPath,'neg*.*'));
        delete(fullfile(OpenCossan.getCossanWorkingPath,'nominal*.*'));
        delete(fullfile(OpenCossan.getCossanWorkingPath,'*.mlv'));
        delete(fullfile(OpenCossan.getCossanWorkingPath,'*.emat'));
        delete(fullfile(OpenCossan.getCossanWorkingPath,'*.inp'));
%         delete([Xconnector.Smaininputpath  '*.sh'));
        delete(fullfile(OpenCossan.getCossanWorkingPath,'*.err'));
        delete(fullfile(OpenCossan.getCossanWorkingPath,'*.out'));
%         delete([Xconnector.Smaininputpath  '*.inp'));
    elseif strcmpi(Sfesolver,'abaqus')
        delete(fullfile(OpenCossan.getCossanWorkingPath,'*.odb'));
        delete(fullfile(OpenCossan.getCossanWorkingPath,'*.com'));
        delete(fullfile(OpenCossan.getCossanWorkingPath,'*.prt'));
        delete(fullfile(OpenCossan.getCossanWorkingPath,'*.sta'));
        delete(fullfile(OpenCossan.getCossanWorkingPath,'*.msg'));
        delete(fullfile(OpenCossan.getCossanWorkingPath,'*.dat'));
        delete(fullfile(OpenCossan.getCossanWorkingPath,'*.inp'));
%         delete([Xconnector.Smaininputpath  '*.inp'));
%         delete([Xconnector.Smaininputpath  '*.sh'));
        delete(fullfile(OpenCossan.getCossanWorkingPath,'*.err'));
        delete(fullfile(OpenCossan.getCossanWorkingPath,'*.out'));
    end
end

%% Stop clock

stopTime = OPENCOSSAN.Xtimer.currentTime;
Xobj.Ccputimes{3} = stopTime - startTime;

OpenCossan.cossanDisp(['[SFEM.runFESolverParallel] Running the 3rd party FE solver completed in ' num2str(Xobj.Ccputimes{3}) ' sec'],1);
OpenCossan.cossanDisp(' ',1);

%% close all the .nfs files

fclose all;

return
