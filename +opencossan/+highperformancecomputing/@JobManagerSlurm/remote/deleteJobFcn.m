function deleteJobFcn(cluster, job)
%DELETEJOBFCN Deletes a job on cluster
%
% Set your cluster's IntegrationScriptsLocation to the parent folder of this
% function to run it when you delete a job.

% Copyright 2017 The MathWorks, Inc.
cancelJobFcn(cluster, job);
