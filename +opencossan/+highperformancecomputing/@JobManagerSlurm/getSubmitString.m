function submitString = getSubmitString(obj, quotedCommand, additionalSubmitArgs)
%GETSUBMITSTRING Gets the correct sbatch command for a Slurm cluster

% Copyright 2010-2016 The MathWorks, Inc.

submitString = sprintf('sbatch --job-name=%s --output=%s %s %s', ...
    obj.jobName, obj.LogFile, additionalSubmitArgs, quotedCommand);
