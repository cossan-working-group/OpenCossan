classdef Optimum < opencossan.common.CossanObject
    %OPTIMUM   Constructor of Optimum object; this object contains the
    %solutions of an optimization problem.
    %
    % See Also: TutorialOptimum OptimisationProblem
    %
    % Author: Edoardo Patelli
    
    %{
    This file is part of OpenCossan <https://cossan.co.uk>.
    Copyright (C) 2006-2018 COSSAN WORKING GROUP

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
    
    
    %% Properties of the object
    properties
        % Exit flag of the optimization algorithm
        ExitFlag(1,1) {mustBeInteger}
        % Time required to solve the problem
        TotalTime(1,1) double
        % Associated optimization problem
        OptimizationProblem(1,1) opencossan.optimization.OptimizationProblem
        % Optimizer used to solve the problem
        Optimizer(1,1)
        % Design variable values at the optimal solution
        OptimalSolution(1,:) double
        % Results of constraint evaluations
        Constraints table = table();
        % Results of objective function evaluations
        ObjectiveFunction table = table();
        % Results of model evaluations
        ModelEvaluations table = table();
    end
    
    properties (Dependent=true)
        ConstraintNames
        ObjectiveFunctionNames
        DesignVariableNames
    end
    
    %% Methods of the class
    methods
        
        function obj = Optimum(varargin)
            if nargin == 0
                super_args = {};
            else
                [required, super_args] = ...
                    opencossan.common.utilities.parseRequiredNameValuePairs(...
                    ["exitflag", "totaltime", "optimizationproblem", ...
                     "optimizer", "optimalsolution", "constraints", ...
                     "objectivefunction", "modelevaluations"], varargin{:});
            end
            obj@opencossan.common.CossanObject(super_args{:});
            
            if nargin > 0
                obj.ExitFlag = required.exitflag;
                obj.TotalTime = required.totaltime;
                obj.OptimizationProblem = required.optimizationproblem;
                obj.Optimizer = required.optimizer;
                obj.OptimalSolution = required.optimalsolution;
                obj.Constraints = required.constraints;
                obj.ObjectiveFunction = required.objectivefunction;
                obj.ModelEvaluations = required.modelevaluations;
            end
        end
        
        function names = get.ConstraintNames(obj)
            names = obj.OptimizationProblem.ConstraintNames;
        end
        
        function names = get.ObjectiveFunctionNames(obj)
            names = obj.OptimizationProblem.ObjectiveFunctionNames;
        end
        
        varargout = plotOptimum(obj, varargin);
        varargout = plotObjectiveFunctions(obj, varargin)
        varargout = plotConstraints(obj, varargin)
        varargout = plotDesignVariables(obj, varargin)
    end
end
