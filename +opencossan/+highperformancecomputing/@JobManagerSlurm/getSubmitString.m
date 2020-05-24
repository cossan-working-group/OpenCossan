function submitString = getSubmitString(obj)
%GETSUBMITSTRING Gets the correct sbatch command for a Slurm cluster

% Copyright 2010-2016 The MathWorks, Inc.

submitString = sprintf('sbatch --job-name=%s --output=%s %s %s', ...
    obj.jobName, obj.LogFile, obj.additionalSubmitArgs, obj.quotedCommand);
