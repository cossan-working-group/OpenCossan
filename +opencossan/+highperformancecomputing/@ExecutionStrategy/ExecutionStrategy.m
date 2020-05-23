classdef ExecutionStrategy < opencossan.common.CossanObject
    %EXECUTIONSTRATEGY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Queues(1,1) string                  % Where to submit workers (one per solver)
        Hostnames(1,1) string               % Names of hostnames where to evaluate workers
        ParallelEnvironments(1,1) string    % Name of the parallel environment of each solver
        Slots(1,1) double {mustBePositive}  % Number of slots used in each job
        IsCompiled(1,1) logical             % Compiled MatlabWorker
        MaxCuncurrentJobs(1,1) double {mustBePositive} = Inf  % Number of concurrent execution of each solver
        RemoteInjectExtract = false         %TODO: make it true by default
        MaxNumberofJobs double {mustBePositive} = 1     % max number of jobs submitted for each analysis
        WrapperMatlabInputName(1,1) string  % Name of the input Matlab file loaded by the job
        WrapperMatlabOutputName(1,1) string % Name of the output Matlab file create by the job
    end
    
    methods
        function obj = ExecutionStrategy(varargin)
            %EXECUTIONSTRATEGY Construct an instance of this class
            %   Detailed explanation goes here
           if nargin==0
                % Crate empty object
                superArg={};
            else
                [requiredArgs, varargin] = opencossan.common.utilities.parseRequiredNameValuePairs(...
                    "Solver", varargin{:});
                
                % Define optional arguments and default values
                
                OptionalsArguments={...
                    "JobManager", opencossan.highperformancecomputing.JobManagerInterface.empty(1,0);...
                    "Queues","";...
                    "Hostnames","";...
                    "ParallelEnvironments","";...
                    "Slots",Inf;...
                    "IsCompiled",false;...
                    "MaxCuncurrentJobs",[];...
                    "RemoteInjectExtract", false;...
                    "MaxNumberofJobs",[];...
                    "WrapperMatlabInputName","";...
                    "WrapperMatlabOutputName","";...
                    "SolverName",[]};
                
                [optionalArg, superArg] = opencossan.common.utilities.parseOptionalNameValuePairs(...
                    [OptionalsArguments{:,1}],{OptionalsArguments{:,2}}, varargin{:});
                
            end
            
            % Now we define all the inputs not filtered out by the parsers
            obj@opencossan.common.CossanObject(superArg{:});
            
                obj.JobManager = optionalArg.jobmanager;
                obj.Queues = optionalArg.queues;
                obj.Hostnames = optionalArg.hostnames;
                obj.ParallelEnvironments = optionalArg.parallelenvironments;
                obj.Slots = optionalArg.slots;
                obj.IsCompiled = optionalArg.iscompiled;
                obj.MaxCuncurrentJobs = optionalArg.maxcuncurrentjobs;
                obj.RemoteInjectExtract=optionalArg.remoteinjectextract;
                obj.MaxNumberofJobs = optionalArg.maxnumberofjobs;
                obj.WrapperMatlabInputName = optionalArg.wrappermatlabinputname;
                obj.WrapperMatlabOutputName = optionalArg.wrappermatlaboutputname;
                
                
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

