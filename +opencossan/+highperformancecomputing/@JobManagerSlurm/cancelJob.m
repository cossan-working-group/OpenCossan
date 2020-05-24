function isOK = cancelJob(obj, JobObject)
%CANCELJOB Cancels a job on Slurm. Adapted from cancelJobFnc. Available at
%https://github.com/cossan-working-group/matlab-roll
%
% Set your cluster's IntegrationScriptsLocation to the parent folder of this
% function to run it when you cancel a job.

% Copyright 2010-2018 The MathWorks, Inc.

% Store the current filename for the errors, warnings and dctSchedulerMessages
currFilename = mfilename;

% This should work for all the cases
%
% if ~obj.HasSharedFilesystem
%     error('JobManagerSlurm:GenericSLURM:NotSharedFileSystem', ...
%         'The function %s is for use with shared filesystems.', currFilename)
% end


% Get the information about the actual cluster used

try
    JobObject = getJobState(obj,JobObject);
catch err
    ex = MException('JobManagerSlurm:GenericSLURM:FailedToRetrieveJobID', ...
        'Failed to retrieve clusters''s job IDs from the job cluster data.');
    ex = ex.addCause(err);
    throw(ex);
end

if isempty(JobObject.State)
    % This indicates that the job has not been submitted, so return true
    opencossan.OpenCossan.cossanDisp(sprintf('%s: Job cluster data was empty for job with ID %d.', currFilename, JobObject.ID),2);
    isOK = true;
    return
end

% Only ask the cluster to cancel the job if it is hasn't reached a terminal
% state.
erroredJobAndCauseStrings = cell(size(JobObject.ID));

for ii = 1:length(jobIDs)
    jobState = JobObject.State(ii);
    jobID = JobObject.ID(ii);
    if ~(strcmp(jobState, "finished") || strcmp(jobState, "failed"))
        % Get the cluster to delete the job
        commandToRun = sprintf('scancel ''%s''', jobID);
        opencossan.OpenCossan.cossanDisp(sprintf('%s: Canceling job on cluster using command:\n\t%s.',...
            currFilename, commandToRun),4);
        try
            if obj.isRemoteCluster
                [cmdFailed, cmdOut] = obj.SSHconnection.runCommand(commandToRun);
            else
            % Make the shelled out call to run the command.
                [cmdFailed, cmdOut] = system(commandToRun);
            end
        catch err
            cmdFailed = true;
            cmdOut = err.message;
        end
        
        if cmdFailed
            % Keep track of all jobs that errored when being cancelled.
            % We'll report these later on.
            erroredJobAndCauseStrings{ii} = sprintf('Job ID: %s\tReason: %s', jobID, strtrim(cmdOut));
            opencossan.OpenCossan.cossanDisp(sprintf('%s: Failed to cancel job %d on cluster.  Reason:\n\t%s',...
                currFilename, jobID, cmdOut),1);
        end
    end
end

% Now warn about those jobs that we failed to cancel.
erroredJobAndCauseStrings = erroredJobAndCauseStrings(~cellfun(@isempty, erroredJobAndCauseStrings));
if ~isempty(erroredJobAndCauseStrings)
    warning('JobManagerSlurm:GenericSLURM:FailedToCancelJob', ...
        'Failed to cancel the following jobs on the cluster:\n%s', ...
        sprintf('  %s\n', erroredJobAndCauseStrings{:}));
end
isOK = isempty(erroredJobAndCauseStrings);
