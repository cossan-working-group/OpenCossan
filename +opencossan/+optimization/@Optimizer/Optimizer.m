classdef Optimizer < opencossan.common.CossanObject
    %OPTIMIZER Abstract Optimizer class

    %{
    This file is part of OpenCossan <https://cossan.co.uk>.
    Copyright (C) 2006-2019 COSSAN WORKING GROUP

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
        % maximum number of model evaluations
        MaxModelEvaluations(1,1) = Inf;
        % maximum number of function evaluations
        MaxFunctionEvaluations(1,1) = Inf;
        % maximum number of iterations
        MaxIterations(1,1) = Inf;    
        % minimum objective function value desired
        ObjectiveFunctionLimit(1,1) double = -Inf;   
        % maximum execution time
        Timeout(1,1) double {mustBePositive} = Inf;
        % Termination tolerance on the value of the objective function.
        ObjectiveFunctionTolerance(1,1) double = 1e-6;   
        % Termination tolerance on the constrains violation.
        ConstraintTolerance(1,1) double = 0.001;         
        % Termination tolerance on the design variable vector
        DesignVariableTolerance(1,1) double = 0.001;     
        % save SimulationData object after each iteration
        SaveIntermediateResults(1,1) logical = true;     
        % scale objective function
        ObjectiveFunctionScalingFactor(1,1) double = 1;        
        % scaling factor for Constraints 
        ConstraintScalingFactor(1,1) double = 1;     
        % for constraint
        PenaltyFactor(1,1) double = 100;        
        % Job Manager
        JobManager(1,1)
        % field containing RandStream object for generating random numbers
        RandomNumberGenerator              
    end
    
    properties (Dependent = true, SetAccess = protected)
        IterationName;
    end
    
    properties (Abstract, Hidden)
        ExitReasons;
    end
    
    properties (Hidden, SetAccess = protected)
        IterationFileName = 'SimulationData_iteration_';
        IterationFolder = [];
        InitialLapTime;     % Store the initial laptime number of the optimization
        NumberOfIterations(1,1) {mustBeInteger} = 0;   % Number of iterations processed
    end
    
    methods
        function obj = Optimizer(varargin)
            import opencossan.common.utilities.parseOptionalNameValuePairs
            
            if nargin == 0
                super_args = {};
            else
                names = ["maxmodelevaluations", ...
                    "maxfunctionevaluations", ...
                    "maxiterations", ...
                    "objectivefunctionlimit", ...
                    "timeout"];
                defaults = {Inf, Inf, Inf, -Inf, Inf};

                [results, super_args] = parseOptionalNameValuePairs(names, ...
                    defaults, varargin{:});
            end
            
            obj@opencossan.common.CossanObject(super_args{:});
            
            if nargin > 0
                obj.MaxModelEvaluations = results.maxmodelevaluations;
                obj.MaxFunctionEvaluations = results.maxfunctionevaluations;
                obj.MaxIterations = results.maxiterations;
                obj.ObjectiveFunctionLimit = results.objectivefunctionlimit;
                obj.Timeout = results.timeout;
            end
        end
        
        function name = get.IterationName(obj)
            format = '%s_%d_%s';
            name = sprintf(format, obj.IterationFileName, ...
                obj.NumberOfIterations, class(obj));
        end
        
        [done, flag] = checkTermination(obj, results) % Check the termination criteria
        stop = outputFunctionOptimiser(obj, x , optimValues, state)        
    end
    
    methods (Access=protected)
        exportResults(Xobj,varargin)  % This method is used to export the SimulationData
        [Xobj, Xinput]=initializeOptimizer(Xobj,Xtarget)
    end
    
    methods (Abstract)
        optimum = apply(obj, varargin)
    end
end
