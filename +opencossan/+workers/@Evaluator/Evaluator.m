classdef Evaluator < opencossan.common.CossanObject
    %EVALUATOR  Constructor function for class EVALUATOR
    % The evaluator is the object that controls the execution of the analysis.
    % If a JobManager is defined, it distributes jobs on the cluster/grid.
    %
    % See also: Worker
    
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
    
    properties
        JobManager opencossan.highperformancecomputing.JobManagerInterface  % Define JobManager to submit job to grid/cluster computer
        Solver(1,:)                         % List of OpenCossan Workers opencossan.workers.Worker
        SolverName(1,:) string              % Names of the workers (optional)
        Queues(1,:) string                  % Where to submit workers (one per solver)
        Hostnames(1,:) string               % Names of hostnames where to evaluate workers
        ParallelEnvironments(1,:) string    % Name of the parallel environment of each solver
        Slots(1,:) double {mustBePositive}  % Number of slots used in each job
        IsCompiled(1,:) logical             % Number of slots used in each job
        MaxCuncurrentJobs(1,:) double {mustBePositive} = 1  % Number of concurrent execution of each solver
        RemoteInjectExtract = false         %TODO: make it true by default
        VerticalSplit = false               % if true split the analysis in vertical components (see wiki for more details)
        MaxNumberofJobs double {mustBePositive} = 1     % max number of jobs submitted for each analysis
        WrapperMatlabInputName(1,1) string  % Name of the input Matlab file loaded by the job
        WrapperMatlabOutputName(1,1) string % Name of the output Matlab file create by the job
    end
    
    properties (Dependent=true)
        OutputNames  % Output variables defined in the Evaluator
        InputNames   % Input variables required by the Evaluator
    end
    
    methods
        function obj=Evaluator(varargin)
            % EVALUATOR This constructor defines an Evaluator that is collection
            % of Connectors.
            %
            % Please see the reference manual for the complete documentation
            %
            % Copyright 1983-2015 COSSAN Working Group
            % Author: Edoardo Patelli
            
            
            if nargin==0
                % Crate empty object
                superArg={};
            else
                [requiredArgs, varargin] = opencossan.common.utilities.parseRequiredNameValuePairs(...
                    "Solver", varargin{:});
                
                % Define optional arguments and default values
                
                OptionalsArguments={...
                    "JobManager", opencossan.highperformancecomputing.JobManagerInterface.empty(1,0);...
                    "Queues",[];...
                    "Hostnames",[];...
                    "ParallelEnvironments",[];...
                    "Slots",[];...
                    "IsCompiled",false;...
                    "MaxCuncurrentJobs",[];...
                    "RemoteInjectExtract", false;...
                    "VerticalSplit",[];...
                    "MaxNumberofJobs",[];...
                    "WrapperMatlabInputName","";...
                    "WrapperMatlabOutputName","";...
                    "SolverName",[]};
                
                [optionalArg, superArg] = opencossan.common.utilities.parseOptionalNameValuePairs(...
                    [OptionalsArguments{:,1}],{OptionalsArguments{:,2}}, varargin{:});
                
            end
            
            % Now we define all the inputs not filtered out by the parsers
            obj@opencossan.common.CossanObject(superArg{:});
            
            if nargin>0
                
                obj.Solver = requiredArgs.solver;
                
                obj.SolverName = optionalArg.solvername;
                
                if ~isempty(obj.SolverName)
                    assert(numel(obj.Solver) == numel(obj.SolverName),...
                        'Evaluator:IllegalArguments',...
                        'Number of solvers (%i) specified must be the same size of SolverName (%i)',...
                        numel(obj.Solver),numel(obj.SolverName));
                end
                
                obj.JobManager = optionalArg.jobmanager;
                obj.Queues = optionalArg.queues;
                obj.Hostnames = optionalArg.hostnames;
                obj.ParallelEnvironments = optionalArg.parallelenvironments;
                obj.Slots = optionalArg.slots;
                obj.IsCompiled = optionalArg.iscompiled;
                obj.MaxCuncurrentJobs = optionalArg.maxcuncurrentjobs;
                obj.RemoteInjectExtract=optionalArg.remoteinjectextract;
                obj.VerticalSplit = optionalArg.verticalsplit;
                obj.MaxNumberofJobs = optionalArg.maxnumberofjobs;
                obj.WrapperMatlabInputName = optionalArg.wrappermatlabinputname;
                obj.WrapperMatlabOutputName = optionalArg.wrappermatlaboutputname;
                
                 obj=validateObject(obj);
            end
            
           
        end %end constructor
        
        Xout=apply(Xobj,Pinput) % Run the analysis
        
        Xout=deterministicAnalysis(Xobj,Xinput) % Perform the deterministic analysis
        
        Xout=add(Xobj,varargin) % Add a worker to the evaluator object
        
        function OutputNames=get.OutputNames(Xobj)
            % Extract output names from the target object
            if isempty(Xobj.Solver)
                OutputNames={};
            else
                OutputNames={};
                for n=1:length(Xobj.Solver)
                    if isrow(Xobj.Solver(n).OutputNames)
                        Caddoutput=Xobj.Solver(n).OutputNames;
                    else
                        Caddoutput=transpose(Xobj.Solver(n).OutputNames);
                    end
                    OutputNames=[OutputNames Caddoutput]; %#ok<AGROW>
                end
            end
        end
        
        function InputNames=get.InputNames(Xobj)
            % Extract output names from the target object
            if isempty(Xobj.Solver)
                InputNames={};
            else
                InputNames=Xobj.Solver(1).InputNames;
                CoutEvaluator={};
                for n=2:length(Xobj.Solver)
                    CaddInputs=Xobj.Solver(n).InputNames; % tmp variable
                    % Remove already present inputs
                    Vindex=false(length(CaddInputs),1);
                    for j=1:length(CaddInputs)
                        Vindex(j)=any(strcmp(InputNames,CaddInputs(j)));
                    end
                    CaddInputs(Vindex)=[];
                    
                    if isrow(Xobj.Solver(n-1).OutputNames)
                        Caddoutput=Xobj.Solver(n-1).OutputNames;
                    else
                        Caddoutput=transpose(Xobj.Solver(n-1).OutputNames);
                    end
                    CoutEvaluator=[CoutEvaluator Caddoutput];  %#ok<AGROW>
                    
                    for j=1:length(CoutEvaluator)
                        % Remove Evaluator inputs provided by the previous Evaluator
                        CaddInputs(strcmp(CoutEvaluator(j),CaddInputs))=[];
                    end
                    InputNames=[InputNames CaddInputs]; %#ok<AGROW>
                end
            end
        end
        
        Xjm=getJobManager(Xobj,varargin)
        
    end
    
    methods (Access=protected)
        [Xout,varargout]=executeWorkersLocal(Xobj,XsimInput);
        outputTable=executeWorkersHorizontal(Xobj,inputTable);
        outputTable=executeWorkersVertical(Xobj,inputTable);
        [Xout,varargout]=executeWorkersGrid(Xobj,XsimInput,Xjob);
        Xout=validateObject(Xobj);
    end
    
    methods (Static)
        % Static methods that allows to add to the input structure output
        % of available in SimulationData.
        % If the simulationData and Tinput structure contains the same
        % variables the variable provided by the structure are exported in
        % the output.
        
        Toutput=addField2Table(Xsolver,XsimData,Tinput)
    end
    
end
