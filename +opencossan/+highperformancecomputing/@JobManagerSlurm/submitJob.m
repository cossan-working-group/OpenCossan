function JobObject=submitJob(obj,varargin)
%INDEPENDENTSUBMITFCN Submit a job to a Slurm cluster
%
% Set your cluster's IntegrationScriptsLocation to the parent folder of this
% function to run it when you submit an independent job.
%
% See also: JobManagerSlurm

% Store the current filename for the errors and warnings
currFilename = mfilename;

%% check resources available
[areAvailable, errorMsg]=obj.checkResources(varargin);

if ~areAvailable  
    error('JobManagerSlurm:SubmissionFailed', ...
        'Resources not available on the defined cluster:\n%s', errorMsg);
end

[requiredArgs, varargin] = opencossan.common.utilities.parseRequiredNameValuePairs(...
    ["Hostname","Queue"], varargin{:});

Sscriptname = Xobj.prepareScript(Number);

%TODO: I don't know the meanining of quotedCommand. Integrate to the object
%or remove it.
additionalSubmitArgs='';
quotedCommand='';
commandToRun = getSubmitString(obj, quotedCommand, additionalSubmitArgs);

if obj.isRemoteCluster
    % copy the script file to the remote host
    obj.SSHconnection.putFile('SlocalFileName',fullfile(obj.JobStorageLocation,Sscriptname),...
        'DestinationFolder',obj.WorkingPath);
    opencossan.OpenCossan.cossanDisp(sprintf('%s: Copyfile file: %s\n\tto remote cluster:\%s.',...
        currFilename, fullfile(obj.JobStorageLocation,Sscriptname),obj.WorkingPath),3);
    
    [cmdFailed, cmdOut] = obj.SSHconnection.runCommand(commandToRun);
    
else
    try
        % Make the shelled out call to run the command.
        [cmdFailed, cmdOut] = system(commandToRun);
    catch err
        cmdFailed = true;
        cmdOut = err.message;
    end
end

if cmdFailed
    error('JobManagerSlurm:SubmissionFailed', ...
        'Submit failed with the following message:\n%s', cmdOut);
end

% Extract jobID and store into a Job object
jobID=obj.extractJobId(cmdOut);
jobState=obj.getJobState(sbatchCommandOutput);

JobObject=Job('SscriptName',Sscriptname,'ID',jobID,'Name','to be fixed','State',jobState);


% % The wrapper script is in the same directory as this file
% dirpart = fileparts(mfilename('fullpath'));
% quotedScriptName = sprintf('%s%s%s', quote, fullfile(dirpart, scriptName), quote);
%
% % Get the tasks for use in the loop
% tasks = JobObject.Tasks;
% numberOfTasks = environmentProperties.NumberOfTasks;
% jobIDs = cell(numberOfTasks, 1);
% % Loop over every task we have been asked to submit
% for ii = 1:numberOfTasks
%     taskLocation = environmentProperties.TaskLocations{ii};
%     % Set the environment variable that defines the location of this task
%     setenv('MDCE_TASK_LOCATION', taskLocation);
%
%     % Choose a file for the output. Please note that currently, JobStorageLocation refers
%     % to a directory on disk, but this may change in the future.
%     logFile = obj.getLogLocation(tasks(ii));
%     quotedLogFile = sprintf('%s%s%s', quote, logFile, quote);
%
%     % Submit one task at a time
%     jobName = sprintf('Job%d.%d', JobObject.ID, JobObject.tasks(ii).ID);
%
%     additionalSubmitArgs = sprintf('--ntasks=1 --tasks-per-node=1 -A %s -t %s -p %s',...
%         obj.AdditionalProperties.Aname,obj.AdditionalProperties.Time,obj.AdditionalProperties.Queue);
%
%     commonSubmitArgs = getCommonSubmitArgs(obj);
%     if ~isempty(commonSubmitArgs) && ischar(commonSubmitArgs)
%         additionalSubmitArgs = strtrim([additionalSubmitArgs, ' ', commonSubmitArgs]);
%     end
%     dctSchedulerMessage(5, '%s: Generating command for task %i', currFilename, ii);
%     commandToRun = getSubmitString(jobName, quotedLogFile, quotedScriptName, ...
%         additionalSubmitArgs);
%
%     % Now ask the cluster to run the submission command
%     dctSchedulerMessage(4, '%s: Submitting job using command:\n\t%s', currFilename, commandToRun);
%     try
%         % Make the shelled out call to run the command.
%         [cmdFailed, cmdOut] = system(commandToRun);
%     catch err
%         cmdFailed = true;
%         cmdOut = err.message;
%     end
%     if cmdFailed
%         error('parallelexamples:GenericSLURM:SubmissionFailed', ...
%             'Submit failed with the following message:\n%s', cmdOut);
%     end
%
%     dctSchedulerMessage(1, '%s: Job output will be written to: %s\nSubmission output: %s\n', currFilename, logFile, cmdOut);
%     jobIDs{ii} = extractJobId(cmdOut);
%
%     if isempty(jobIDs{ii})
%         warning('parallelexamples:GenericSLURM:FailedToParseSubmissionOutput', ...
%             'Failed to parse the job identifier from the submission output: "%s"', ...
%             cmdOut);
%     end
% end





