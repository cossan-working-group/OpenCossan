function XSimOut = executeWorkersGrid(Xobj,XSimInp,Xjob)
% EXECUTEWORKERSGRID  This is a protected method of evaluator to run the
% analysis in vertical chunks using the Job Manager.
%
% It requires a SimulationData object as second argument
%
%  Usage:  XSimout = executeWorkersGrid(Xobj,XSimInp,Xjob)
%
% See Also: http://cossan.co.uk/wiki/index.php/executeWorkers@Evaluator
%
%
% Author: Edoardo Patelli
% Institute for Risk and Uncertainty, University of Liverpool, UK
% email address: openengine@cossan.co.uk
% Website: http://www.cossan.co.uk

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

%% The analysis is split over the number of samples

% split input samples between jobs

if (Xjob.Nconcurrent == Inf)     % checks whether or not Njobs has been defined
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

%% Divide Input samples through different jobs (1 folder for each job)
% Define vectors with counter for determining the simulations that go into
% each job
Vend = cumsum(Vsimxjobs);  % defines number of final simulation for job
Vstart = [1, Vend(1:end-1)+1]; % defines number of starting simulation for job

% iteration over the number of jobs
for irun=1:Njobs
    %  If required, displays information on which job is being processed
    OpenCossan.cossanDisp(['Preparing input file for Worker job #' num2str(irun) ' of ' num2str(Njobs) ],2);
    %  Creates folder where the job will be executed
    Sfoldername    = [Xjob.Sfoldername '_job_' num2str(irun)];  % defines name of folder where the job will be executed
    mkdir(fullfile(OpenCossan.getCossanWorkingPath,Sfoldername));    % creates the folder
    % set the execution command. This is a method/property depending on
    % whether you run worker compiled or not
    Xjob.Sexecmd = ['cd ' fullfile(OpenCossan.getCossanWorkingPath,Sfoldername) '; '...
        strrep(fullfile(OpenCossan.getMatlabPath,'bin','matlab'),' ','\\ ') ...
        ' -r workers.remoteWorkerJob -nosplash -nodesktop'];
    %  Copy input table and worker into the new grid folder
    % split table with inputs
    TableInput  = PinputALL(Vstart(irun):Vend(irun)); %#ok<NASGU>
    % get individual solver from Evaluator
    % TODO: how to loop on the available solvers???
    Xworker = Xobj.CXsolvers{1};    %#ok<NASGU>
    save (fullfile(OpenCossan.getCossanWorkingPath, Sfoldername, 'workerInput.mat'),'TableInput','Xworker');  
end


% submit job array
CSjobID=Xjob.submitJobArray('Ntotaljobs', Njobs);  % this method create the job array execution script and submit is to
  % JobManager, returns job ids


%%  Check if the job array has finished
Lcompleted = false;
LfirstResubmission = true;

while 1
    while ~Lcompleted
        %% Termination criteria KILL (from GUI)
        % Check if the file name KILL exists in the working directory
        if exist(fullfile(OpenCossan.getCossanWorkingPath,OPENCOSSAN.Skillfilename),'file')
            OpenCossan.cossanDisp('Analysis terminated by the user',1);
            % Cancel submitted jobs
            Xjob.deleteJob('CsjobID',CSjobID);
            error('openCOSSAN:Evaluator:JobKilled','Simulation killed by the user.')
        end
        % Check status of job every second. 
        % TODO: Get this value from JobManager 
        pause(1);
        Cstatus = Xjob.getJobStatus('CSjobID',CSjobID); %#ok<AGROW> % check the status of the one that are not yet completed only
        
        % TODO: Use properties of JobManagerInterface
        % It should be 
        % Lcompleted =
        %  Lcompleted = ~(any(strcmp(Xjob.JobManagerInterface.Cstatus,Cstatus(:,1)))
        Lcompleted = ~(strcmp('running',Cstatus(:,1))|strcmp('pending',Cstatus(:,1)) | ... % gridengine status return
            strcmp('RUN',Cstatus(:,1))|strcmp('PEND',Cstatus(:,1))); % LSF status return
    end
    
    % do job resubmission when not succesfull (do we still need it?)
    
    % retrieve workerOutput.mat for each job
    
    % assemble simulationdata
    
    return
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


% for n=1:length(Xobj.CXsolvers)
%     switch class(Xobj.CXsolvers{n})
%         case 'Connector'
%             % The connector requires always a Structure
%             Xc = Xobj.CXsolvers{n};
%             Xjob.Spreexecmd = Xc.SpreExecutionCommand;
%             Xc.SpreExecutionCommand = '';
%             Xjob.Spostexecmd = Xc.SpostExecutionCommand;
%             Xc.SpostExecutionCommand = '';
%             
%             % Run connector
%             XSimOutTmp=Xc.runJob('Tinput',TinputSolver, ...
%                 'Xjobmanager',Xjob,'LremoteInjectExtract',Xobj.LremoteInjectExtract);
%     case {'Mio'}
%         % Prepare inputs
%         
%         if exist('XSimOut','var')
%             PinputMio=prepareInput(Xobj,TinputSolver);
%         else
%             PinputMio=prepareInput(Xobj,TinputSolver,XSimOut);
%         end
%         
%         if Xmio.Lcompiled
%             [XSimOut,PoutputALL] = Xmio.runJobCompiled(Cinputs{:});
%         else
%             [XSimOut,PoutputALL] = Xmio.runJobMatlab(Cinputs{:});
%         end
%         
%         if isa(PinputMio,'Input')
%             XSimOutTmp=Xobj.CXsolvers{n}.runJob('Xinput',PinputMio, ...
%                 'Xjobmanager',Xjob);
%         elseif isa(PinputMio,'Samples')
%             XSimOutTmp=Xobj.CXsolvers{n}.runJob('Xsamples',PinputMio, ...
%                 'Xjobmanager',Xjob);
%         elseif isstruct(PinputMio)
%             XSimOutTmp=Xobj.CXsolvers{n}.runJob('Tinput',PinputMio, ...
%                 'Xjobmanager',Xjob);
%         elseif isnumeric(PinputMio)
%             XSimOutTmp=Xobj.CXsolvers{n}.runJob('Minput',PinputMio, ...
%                 'Xjobmanager',Xjob);
%         else
%             % You should never arrive here if the code is correct...
%             error('OpenCossan:Evaluator:applyErrorCode','You should never arrive here if the code is correct..');
%         end
%         
%         case 'SolutionSequence'
%             Xobj.CXsolvers{n}.XjobManager=Xjob;
%             XSimOutTmp=Xobj.CXsolvers{n}.apply(TinputSolver);
%             otherwise
%                 % Create empty SimulationData object
%                 XSimOutTmp=SimulationData;
%     end
% end

