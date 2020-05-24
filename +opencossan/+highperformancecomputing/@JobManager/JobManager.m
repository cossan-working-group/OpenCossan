classdef(Abstract) JobManager < opencossan.common.CossanObject
    %  This class defines the interface with the cluster/cloud computing. 
    %   The requested computation are automatically converted to jobs and
    %   submitted to the Job management software on the cluster. The results are then retrieved and
    %  processed by OpenCossan (i.e., in a SimulationData object).
    %
    % See also: JobManagerSlurm, Worker, Evaluator, 
    
    %{
    This file is part of OpenCossan <https://cossan.co.uk>.
    Copyright (C) 2006-2020 COSSAN WORKING GROUP

    OpenCossan is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License or,
    (at your option) any later version.

    OpenCossan is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with OpenCossan. If not, see <http://www.gnu.org/licenses/>.
    %}
    
    % =====================================================================
    
    properties
        PreExeCmd           % prepocessor executeble cmd TODO: check with connector
        PostExeCmd          % postprocessor executeble cmd TODO: check with connector
        WorkingPath         % directory when the job will be executed (better if not on NFS!)
        MainInputPath       % 
        SubFolder           % Subfolder name for the batch execution
        HasSharedFilesystem(1,1) logical  %
        ClusterMatlabRoot
        OperatingSystem
        JobStorageLocation
        SSHconnection
        LogFile(1,1) {string}
    end
    
    properties (Hidden)
        ExeCmd         % job submission executable cmd. Set by runJob of connector!
        ExeFlags
    end
    
    properties (Hidden,SetAccess=protected)
        ShellScriptPrefix='OpenCossan_job'      % Prefix used in the shell script
        BatchIdentification='_job_'  % Batch identification name
        JobNamePrefix = 'CossanJob'  % Job name
    end
    
    properties (Dependent=true)
        JobName     % name of the script used to start the job
        Username
        isRemoteCluster 
    end
    
    
    methods
        
        function obj=JobManager(varargin)
            %Constructor of JobManager
            if nargin == 0
                superArg = {};
            else
                % No mandatory parameters
                
                % Process optional paramets
                OptionalsArguments={...
                    "PreExeCmd", opencossan.highperformancecomputing.JobManagerInterface.empty(1,0);...
                    "PostExeCmd",[];...
                    "WorkingPath",opencossan.OpenCossan.getWorkingPath;...
                    "MainInputPath",[];...
                    "OperatingSystem",'unix';...
                    "SubFolder",datestr(now,30);...
                    "HasSharedFilesystem",true;...
                    "LogFile","OpenCossanJob.log"};
                
                [optionalArgs, superArg] = opencossan.common.utilities.parseOptionalNameValuePairs(...
                    [OptionalsArguments{:,1}],{OptionalsArguments{:,2}}, varargin{:});
            end
            
            obj@opencossan.common.CossanObject(superArg{:});
            
            if nargin > 0
                obj.WorkingPath=optionalArgs.workingpath;
                obj.KeepSimulationFiles=optionalArgs.keepsimulationfiles;
                obj.HasSharedFilesystem=optionalArgs.hassharedfilesystem;
                obj.LogFile=optionalArgs.logfile;
            end
          
        end
 
        function JobName = get.JobName(obj)
            %TODO: This is not an unique name, better to use Sfoldername
            %instead SjobPrefixName
            JobName = [obj.JobNamePrefix obj.jobname];
        end
        
        function isRemoteCluster = get.isRemoteCluster(obj)
            % Check if a SSHConnection object has been defined
            if isempty(obj.SSHconnection)
                isRemoteCluster=false;
            else
                isRemoteCluster=true;
            end     
        end
        
        
        jobObj = submitJob(obj,varargin)        % submit single job
        jobObj = submitAnalysis(obj,Samples)    % submit analysis (multiple jobs)
        
        % Define function requirements for subclasses
        
        isOK=cancelJob(obj,JobObject)           % delete job from the job manager
        state = getJobState(Xobj,JobObject)     % Get state of the Job
        clusterStatus=checkCluster(obj,varargin)% Check status of the cluster
        % Extract job ID
        jobID=extractJobId(obj,sbatchCommandOutput)
    end
            
end
