function independentSubmitFcn(cluster, job, environmentProperties)
%INDEPENDENTSUBMITFCN Submit a MATLAB job to a Slurm cluster
%
% Set your cluster's IntegrationScriptsLocation to the parent folder of this
% function to run it when you submit an independent job.
%
% See also parallel.cluster.generic.independentDecodeFcn.

% Copyright 2010-2017 The MathWorks, Inc.

% Store the current filename for the errors, warnings and dctSchedulerMessages
currFilename = mfilename;
if ~isa(cluster, 'parallel.Cluster')
    error('parallelexamples:GenericSLURM:SubmitFcnError', ...
        'The function %s is for use with clusters created using the parcluster command.', currFilename)
end

decodeFunction = 'parallel.cluster.generic.independentDecodeFcn';

if ~cluster.HasSharedFilesystem
    error('parallelexamples:GenericSLURM:SubmitFcnError', ...
        'The submit function %s is for use with shared filesystems.', currFilename)
end

if ~isprop(cluster.AdditionalProperties, 'ClusterHost')
    error('parallelexamples:GenericSLURM:MissingAdditionalProperties', ...
        'Required field %s is missing from AdditionalProperties.', 'ClusterHost');
end
clusterHost = cluster.AdditionalProperties.ClusterHost;

if ~strcmpi(cluster.OperatingSystem, 'unix')
    error('parallelexamples:GenericSLURM:SubmitFcnError', ...
        'The submit function %s only supports clusters with unix OS.', currFilename)
end
if ~ischar(clusterHost)
    error('parallelexamples:GenericSLURM:IncorrectArguments', ...
        'Hostname must be a character vector');
end

remoteConnection = getRemoteConnection(cluster, clusterHost);

% The job specific environment variables
% Remove leading and trailing whitespace from the MATLAB arguments
matlabArguments = strtrim(environmentProperties.MatlabArguments);
variables = {'MDCE_DECODE_FUNCTION', decodeFunction; ...
    'MDCE_STORAGE_CONSTRUCTOR', environmentProperties.StorageConstructor; ...
    'MDCE_JOB_LOCATION', environmentProperties.JobLocation; ...
    'MDCE_MATLAB_EXE', environmentProperties.MatlabExecutable; ...
    'MDCE_MATLAB_ARGS', matlabArguments; ...
    'MDCE_DEBUG', 'true'; ...
    'MLM_WEB_LICENSE', environmentProperties.UseMathworksHostedLicensing; ...
    'MLM_WEB_USER_CRED', environmentProperties.UserToken; ...
    'MLM_WEB_ID', environmentProperties.LicenseWebID; ...
    'MDCE_LICENSE_NUMBER', environmentProperties.LicenseNumber; ...
    'MDCE_STORAGE_LOCATION', environmentProperties.StorageLocation};
% Trim the environment variables of empty values.
nonEmptyValues = cellfun(@(x) ~isempty(strtrim(x)), variables(:,2));
variables = variables(nonEmptyValues, :);

% Get the correct quote and file separator for the Cluster OS.
% This check is unnecessary in this file because we explicitly
% checked that the ClusterOsType is unix.  This code is an example
% of how your integration code should deal with clusters that
% can be unix or pc.
if strcmpi(cluster.OperatingSystem, 'unix')
    quote = '''';
    fileSeparator = '/';
else
    quote = '"';
    fileSeparator = '\';
end

% The local job directory
localJobDirectory = cluster.getJobFolder(job);
% Find out how we should refer to the job storage location on the cluster.
remoteJobDirectory = cluster.getJobFolderOnCluster(job);

% The script name is independentJobWrapper.sh
scriptName = 'independentJobWrapper.sh';
% The wrapper script is in the same directory as this file
dirpart = fileparts(mfilename('fullpath'));
localScript = fullfile(dirpart, scriptName);
% Copy the local wrapper script to the job directory
copyfile(localScript, localJobDirectory);

% The command that will be executed on the remote host to run the job.
remoteScriptName = sprintf('%s%s%s', remoteJobDirectory, fileSeparator, scriptName);
quotedScriptName = sprintf('%s%s%s', quote, remoteScriptName, quote);

% Get the tasks for use in the loop
tasks = job.Tasks;
numberOfTasks = environmentProperties.NumberOfTasks;
jobIDs = cell(numberOfTasks, 1);
% Loop over every task we have been asked to submit
for ii = 1:numberOfTasks
    taskLocation = environmentProperties.TaskLocations{ii};
    % Add the task location to the environment variables
    environmentVariables = [variables; ...
        {'MDCE_TASK_LOCATION', taskLocation}];
    
    % Choose a file for the output. Please note that currently, JobStorageLocation refers
    % to a directory on disk, but this may change in the future.
    logFile = sprintf('%s%s%s', remoteJobDirectory, fileSeparator, sprintf('Task%d.log', tasks(ii).ID));
    quotedLogFile = sprintf('%s%s%s', quote, logFile, quote);
    
    % Submit one task at a time
    jobName = sprintf('Job%d.%d', job.ID, tasks(ii).ID);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% CUSTOMIZATION MAY BE REQUIRED %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    additionalSubmitArgs = '--ntasks=1';
    commonSubmitArgs = getCommonSubmitArgs(cluster);
    if ~isempty(commonSubmitArgs) && ischar(commonSubmitArgs)
        additionalSubmitArgs = strtrim([additionalSubmitArgs, ' ', commonSubmitArgs]);
    end
    % Create a script to submit a Slurm job - this will be created in the job directory
    dctSchedulerMessage(5, '%s: Generating script for task %i', currFilename, ii);
    localScriptName = tempname(localJobDirectory);
    [~, scriptName] = fileparts(localScriptName);
    remoteScriptLocation = sprintf('%s%s%s', remoteJobDirectory, fileSeparator, scriptName);
    createSubmitScript(localScriptName, jobName, quotedLogFile, quotedScriptName, ...
        environmentVariables, additionalSubmitArgs);
    % Create the command to run on the remote host.
    commandToRun = sprintf('sh %s', remoteScriptLocation);
    
    % Now ask the cluster to run the submission command
    dctSchedulerMessage(4, '%s: Submitting job using command:\n\t%s', currFilename, commandToRun);
    % Execute the command on the remote host.
    [cmdFailed, cmdOut] = remoteConnection.runCommand(commandToRun);
    if cmdFailed
        error('parallelexamples:GenericSLURM:FailedToSubmitJob', ...
            'Failed to submit job to Slurm using command:\n\t%s.\nReason: %s', ...
            commandToRun, cmdOut);
    end
    jobIDs{ii} = extractJobId(cmdOut);
    
    if isempty(jobIDs{ii})
        warning('parallelexamples:GenericSLURM:FailedToParseSubmissionOutput', ...
            'Failed to parse the job identifier from the submission output: "%s"', ...
            cmdOut);
    end
end

% set the cluster host, job ID on the job cluster data
jobData = struct('ClusterJobIDs', {jobIDs}, ...
    'RemoteHost', clusterHost);
cluster.setJobClusterData(job, jobData);
