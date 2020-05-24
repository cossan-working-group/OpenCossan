function communicatingSubmitFcn(cluster, job, environmentProperties)
%COMMUNICATINGSUBMITFCN Submit a communicating MATLAB job to a Slurm cluster
%
% Set your cluster's IntegrationScriptsLocation to the parent folder of this
% function to run it when you submit a communicating job.
%
% See also parallel.cluster.generic.communicatingDecodeFcn.

% Copyright 2010-2018 The MathWorks, Inc.

% Store the current filename for the errors, warnings and dctSchedulerMessages
currFilename = mfilename;
if ~isa(cluster, 'parallel.Cluster')
    error('parallelexamples:GenericSLURM:NotClusterObject', ...
        'The function %s is for use with clusters created using the parcluster command.', currFilename)
end

decodeFunction = 'parallel.cluster.generic.communicatingDecodeFcn';

if cluster.HasSharedFilesystem
    error('parallelexamples:GenericSLURM:NotNonSharedFileSystem', ...
        'The function %s is for use with nonshared filesystems.', currFilename)
end

if ~isprop(cluster.AdditionalProperties, 'ClusterHost')
    error('parallelexamples:GenericSLURM:MissingAdditionalProperties', ...
        'Required field %s is missing from AdditionalProperties.', 'ClusterHost');
end
clusterHost = cluster.AdditionalProperties.ClusterHost;
if ~isprop(cluster.AdditionalProperties, 'RemoteJobStorageLocation')
    error('parallelexamples:GenericSLURM:MissingAdditionalProperties', ...
        'Required field %s is missing from AdditionalProperties.', 'RemoteJobStorageLocation');
end
remoteJobStorageLocation = cluster.AdditionalProperties.RemoteJobStorageLocation;
if isprop(cluster.AdditionalProperties, 'UseUniqueSubfolders')
    makeLocationUnique = cluster.AdditionalProperties.UseUniqueSubfolders;
else
    makeLocationUnique = false;
end

if ~strcmpi(cluster.OperatingSystem, 'unix')
    error('parallelexamples:GenericSLURM:UnsupportedOS', ...
        'The function %s only supports clusters with unix OS.', currFilename)
end
if ~ischar(clusterHost)
    error('parallelexamples:GenericSLURM:IncorrectArguments', ...
        'ClusterHost must be a character vector');
end
if ~ischar(remoteJobStorageLocation)
    error('parallelexamples:GenericSLURM:IncorrectArguments', ...
        'RemoteJobStorageLocation must be a character vector');
end
if ~islogical(makeLocationUnique)
    error('parallelexamples:GenericSLURM:IncorrectArguments', ...
        'UseUniqueSubfolders must be a logical scalar');
end

remoteConnection = getRemoteConnection(cluster, clusterHost, remoteJobStorageLocation, makeLocationUnique);

enableDebug = 'false';
if isprop(cluster.AdditionalProperties, 'EnableDebug') ...
        && islogical(cluster.AdditionalProperties.EnableDebug) ...
        && cluster.AdditionalProperties.EnableDebug
    enableDebug = 'true';
end

% The job specific environment variables
% Remove leading and trailing whitespace from the MATLAB arguments
matlabArguments = strtrim(environmentProperties.MatlabArguments);
variables = {'MDCE_DECODE_FUNCTION', decodeFunction; ...
    'MDCE_STORAGE_CONSTRUCTOR', environmentProperties.StorageConstructor; ...
    'MDCE_JOB_LOCATION', environmentProperties.JobLocation; ...
    'MDCE_MATLAB_EXE', environmentProperties.MatlabExecutable; ...
    'MDCE_MATLAB_ARGS', matlabArguments; ...
    'PARALLEL_SERVER_DEBUG', enableDebug; ...
    'MLM_WEB_LICENSE', environmentProperties.UseMathworksHostedLicensing; ...
    'MLM_WEB_USER_CRED', environmentProperties.UserToken; ...
    'MLM_WEB_ID', environmentProperties.LicenseWebID; ...
    'MDCE_LICENSE_NUMBER', environmentProperties.LicenseNumber; ...
    'MDCE_STORAGE_LOCATION', remoteConnection.JobStorageLocation; ...
    'MDCE_CMR', cluster.ClusterMatlabRoot; ...
    'MDCE_TOTAL_TASKS', num2str(environmentProperties.NumberOfTasks); ...
    'MDCE_NUM_THREADS', num2str(cluster.NumThreads)};
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
% How we refer to the job directory on the cluster
remoteJobDirectory = remoteConnection.getRemoteJobLocation(job.ID, cluster.OperatingSystem);
% Specify the job wrapper script to use.
if isprop(cluster.AdditionalProperties, 'UseSmpd') && cluster.AdditionalProperties.UseSmpd
    scriptName = 'communicatingJobWrapperSmpd.sh';
else
    scriptName = 'communicatingJobWrapper.sh';
end
% The wrapper script is in the same directory as this file
dirpart = fileparts(mfilename('fullpath'));
localScript = fullfile(dirpart, scriptName);
% Copy the local wrapper script to the job directory
copyfile(localScript, localJobDirectory);

% The command that will be executed on the remote host to run the job.
remoteScriptName = sprintf('%s%s%s', remoteJobDirectory, fileSeparator, scriptName);
quotedScriptName = sprintf('%s%s%s', quote, remoteScriptName, quote);

% Choose a file for the output. Please note that currently, JobStorageLocation refers
% to a directory on disk, but this may change in the future.
logFile = sprintf('%s%s%s', remoteJobDirectory, fileSeparator, sprintf('Job%d.log', job.ID));
quotedLogFile = sprintf('%s%s%s', quote, logFile, quote);

jobName = sprintf('Job%d', job.ID);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CUSTOMIZATION MAY BE REQUIRED %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% You might want to customize this section to match your cluster,
% for example to limit the number of nodes for a single job.
%additionalSubmitArgs = sprintf('--ntasks=%d --cpus-per-task=%d', environmentProperties.NumberOfTasks, cluster.NumThreads);
additionalSubmitArgs = sprintf('--ntasks=%d --tasks-per-node=%d -t %s -A %s -p %s ',environmentProperties.NumberOfTasks,cluster.AdditionalProperties.Ppn,cluster.AdditionalProperties.Time, cluster.AdditionalProperties.Aname,cluster.AdditionalProperties.Queue);
commonSubmitArgs = getCommonSubmitArgs(cluster);
if ~isempty(commonSubmitArgs) && ischar(commonSubmitArgs)
    additionalSubmitArgs = strtrim([additionalSubmitArgs, ' ', commonSubmitArgs]);
end
% Create a script to submit a Slurm job - this will be created in the job directory
dctSchedulerMessage(5, '%s: Generating script for job.', currFilename);
localScriptName = tempname(localJobDirectory);
[~, scriptName] = fileparts(localScriptName);
remoteScriptLocation = sprintf('%s%s%s', remoteJobDirectory, fileSeparator, scriptName);
createSubmitScript(localScriptName, jobName, quotedLogFile, quotedScriptName, ...
    variables, additionalSubmitArgs);
% Create the command to run on the remote host.
commandToRun = sprintf('sh %s', remoteScriptLocation);
dctSchedulerMessage(4, '%s: Starting mirror for job %d.', currFilename, job.ID);
% Start the mirror to copy all the job files over to the cluster
remoteConnection.startMirrorForJob(job);

% Now ask the cluster to run the submission command
dctSchedulerMessage(4, '%s: Submitting job using command:\n\t%s', currFilename, commandToRun);
% Execute the command on the remote host.
[cmdFailed, cmdOut] = remoteConnection.runCommand(commandToRun);
if cmdFailed
    % Stop the mirroring if we failed to submit the job - this will also
    % remove the job files from the remote location
    % Only stop mirroring if we are actually mirroring
    if remoteConnection.isJobUsingConnection(job.ID)
        dctSchedulerMessage(5, '%s: Stopping the mirror for job %d.', currFilename, job.ID);
        try
            remoteConnection.stopMirrorForJob(job);
        catch err
            warning('parallelexamples:GenericSLURM:FailedToStopMirrorForJob', ...
                'Failed to stop the file mirroring for job %d.\nReason: %s', ...
                job.ID, err.getReport);
        end
    end
    error('parallelexamples:GenericSLURM:FailedToSubmitJob', ...
        'Failed to submit job to Slurm using command:\n\t%s.\nReason: %s', ...
        commandToRun, cmdOut);
end

jobIDs = extractJobId(cmdOut);
% jobIDs must be a cell array
if isempty(jobIDs)
    warning('parallelexamples:GenericSLURM:FailedToParseSubmissionOutput', ...
        'Failed to parse the job identifier from the submission output: "%s"', ...
        cmdOut);
end
if ~iscell(jobIDs)
    jobIDs = {jobIDs};
end

% set the cluster host, remote job storage location and job ID on the job cluster data
jobData = struct('ClusterJobIDs', {jobIDs}, ...
    'RemoteHost', clusterHost, ...
    'RemoteJobStorageLocation', remoteConnection.JobStorageLocation, ...
    'HasDoneLastMirror', false);
cluster.setJobClusterData(job, jobData);
