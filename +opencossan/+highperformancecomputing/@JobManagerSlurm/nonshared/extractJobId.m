function jobID = extractJobId(sbatchCommandOutput)
% Extracts the job ID from the sbatch command output for Slurm

% Copyright 2015-2017 The MathWorks, Inc.

% Output from sbatch expected to be in the following format:
%   Submitted batch job 12345
%
% sbatch could also attach a warning to the output, such as:
%
%   sbatch: Warning: can't run 1 processes on 3 nodes, setting nnodes to 1
%   Submitted batch job 12346

% Trim sbatch command output for use in debug message
trimmedCommandOutput = strtrim(sbatchCommandOutput);

% Ignore anything before or after 'Submitted batch job ###', and extract the numeric value.
searchPattern = '.*Submitted batch job ([0-9]+).*';

% When we match searchPattern, matchedTokens is a single entry cell array containing the jobID.
% Otherwise we failed to match searchPattern, so matchedTokens is an empty cell array.
matchedTokens = regexp(sbatchCommandOutput, searchPattern, 'tokens', 'once');

if isempty(matchedTokens)
    % Callers check for error in extracting Job ID using isempty() on return value.
    jobID = '';
    dctSchedulerMessage(0, '%s: Failed to extract Job ID from sbatch output: \n\t%s', mfilename, trimmedCommandOutput);
else
    jobID = matchedTokens{1};
    dctSchedulerMessage(0, '%s: Job ID %s was extracted from sbatch output: \n\t%s', mfilename, jobID, trimmedCommandOutput);
end
