classdef JobManager
    %  %  Objects of this class are used by an Evaluator to run the
    %  analysis on a remote machine. The JobManagerInterface defines the
    %  interface with the Job Management software.  The requested computation are
    %  automatically converted to jobs and submitted to the Job management
    %  software on the cluster. The results are then retrieved and
    %  processed by COSSAN (i.e., in a SimulationData object).
    
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
    
    properties
        Squeue          % Queue name
        Shostname       % Specific node (host) selection
        Sdescription    % Description of the JobManager
        Sjobname = 'CossanJob'  % Job name
        Spreexecmd      % prepocessor executeble cmd TODO: check with connector
        Spostexecmd     % postprocessor executeble cmd TODO: check with connector
        Sworkingdirectory % directory when the job will be executed (better if not on NFS!)
        Smaininputpath
        Sfoldername     % Name of the folder created by the JobManager for its execution
        Xdependent = [] % Dependent object (no execution until this object job is finished) - TODO: which kind of object is?
        Xjobmanagerinterface
        Nconcurrent = Inf % Number of concurrent job execution (Default = unlimited)
        Sduration    = ''% job timeout
        SparallelEnvironment % Specific parallel environment (e.g. openmpi) and number of process
        Nslots          % Number of slots to be used in the simulation
    end
    
    properties (Hidden)
        Sexecmd         % job submission executable cmd. Set by runJob of connector!
        Sexeflags
    end
    
    properties (Hidden,SetAccess=protected)
        SjobPrefixName='run'
        SbatchIdentification='_job_'
    end
    
    properties (Dependent=true)
        SjobScriptName     % name of the script used to start the job
        SuserName
    end
    
    
    methods
        
        function Xobj=JobManager(varargin)
            % ==================================================================
            % COSSAN-X - The next generation of the computational stochastic analysis
            % University of Innsbruck, Copyright 1993-2011 IfM
            % ==================================================================
            
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
            
            %%  Argument Check
            OpenCossan.validateCossanInputs(varargin{:})
            
            % set the values of the public properties from the input
            % parameters
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case ('sdescription')
                        Xobj.Sdescription = varargin{k+1};
                    case ('squeue')
                        Xobj.Squeue = varargin{k+1};
                    case ('shostname')
                        Xobj.Shostname = varargin{k+1};
                    case ('sduration')
                        Xobj.Sduration = varargin{k+1};    
                    case ('sjobname')
                        Xobj.Sjobname = varargin{k+1};
                    case ('spreexecmd')
                        Xobj.Spreexecmd = varargin{k+1};
                    case ('spostexecmd')
                        Xobj.Spostexecmd = varargin{k+1};
                    case ('xdependent')
                        if isa(varargin{k+1},'Evaluator')
                            if ~isempty(varargin{k+1}.Xjob)
                                Xobj.Xdependent = varargin{k+1}.Xjob;
                            else
                                error('openCOSSAN:JobManager:JobManager',...
                                    'Cannot create dependent job using an Evaluator without JobManager.');
                            end
                        elseif isa(varargin{k+1},'JobManager')
                            Xobj.Xdependent = varargin{k+1};
                        else
                            error('openCOSSAN:JobManager:JobManager',...
                                'Dependent object must be of Evaluator or JobManager class');
                        end
                        if isempty(Xobj.Xdependent.Sjobname)
                            error('openCOSSAN:JobManager:JobManager',...
                                'A job name must be defined in the dependent object');
                        end
                    case{'xjobmanagerinterface'}
                        Xobj.Xjobmanagerinterface = varargin{k+1};
                    case{'cxjobmanagerinterface'}
                        Xobj.Xjobmanagerinterface = varargin{k+1}{1};
                    case{'nconcurrent'}
                        Xobj.Nconcurrent = varargin{k+1};
                    case ('sparallelenvironment')
                        Xobj.SparallelEnvironment = varargin{k+1};
                    case ('nslots')
                        Xobj.Nslots = varargin{k+1};
                    case ('sworkingdirectory')
                        Xobj.Sworkingdirectory = varargin{k+1};
                    otherwise
                        error('openCOSSAN:JobManager',...
                            ['PropertyName name (' varargin{k} ') not allowed']);
                end
            end
            
            
            %% Check JobManager                 
            % It is mandatory to have a JobManagerInterface object. If such
            % object is missing, an error is given.
            assert(isa(Xobj.Xjobmanagerinterface,'JobManagerInterface'), ...
                'openCOSSAN:JobManager', ...
                'An object of class JobManagerInterface is required.');
            
            if ~isempty(Xobj.Squeue)
                assert(logical(ismember(Xobj.Squeue,Xobj.Xjobmanagerinterface.getQueues)), ...
                    'openCOSSAN:JobManager', ...
                    'The selected queue %s is not available \nAvailable queues are: %s', ...
                    Xobj.Squeue,sprintf('%s ',Xobj.Xjobmanagerinterface.getQueues{:}));
            end
            
            if ~isempty(Xobj.SparallelEnvironment)
                assert(logical(ismember(Xobj.SparallelEnvironment,...
                    Xobj.Xjobmanagerinterface.getParallelEnvironments)), ...
                    'openCOSSAN:JobManager', ...
                    ['The selected parallel environment %s is not available \n'...
                    'Available parallel environments are: %s'], ...
                    Xobj.SparallelEnvironment,sprintf('%s ',Xobj.Xjobmanagerinterface.getParallelEnvironments{:}));
                assert(~isempty(Xobj.Nslots),...
                    'openCOSSAN:JobManager', ...
                    ['It is mandatory to specify the number of slots to be'...
                    ' used with the selected parallel environment.']);
            end
            
            if ~isempty(Xobj.Shostname)
                [Lavailable, Smess]=Xobj.Xjobmanagerinterface.checkHost( ...
                    'SqueueName',Xobj.Squeue,'ShostName',Xobj.Shostname);
                assert(Lavailable, 'openCOSSAN:JobManager', Smess)
            end
            
            %% set the value of the private properties
            Xobj.Sfoldername = datestr(now,30);
            
        end
        
        function SjobScriptName = get.SjobScriptName(Xobj)
            %TODO: This is not an unique name, better to use Sfoldername
            %instead SjobPrefixName
            SjobScriptName = [Xobj.SjobPrefixName Xobj.Sjobname];
        end
        
        
        SjobID = submitJob(Xobj,varargin)
        varargout=deleteJob(Xobj,varargin)
        Lsuccessfull = checkSuccessfulJobs(Xobj,ScheckFileName)
        
        display(Xobj)
        
    end
            
    methods (Access=private)
        Sscriptname = prepareGridEngineScript(Xobj,NsimulationNumber)
        Sscriptname = prepareLSFScript(Xobj,NsimulationNumber)
    end
end
