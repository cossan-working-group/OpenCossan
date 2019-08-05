classdef OptimizationProblem
    %   This class allows defining an optimization problem. The objective
    %   function and constraints are defined using the object Function. The
    %   parameters associated with the problem are defined using a Input
    %   object and the design variables are defined by means of a cell of
    %   Parameters

    % Properties
    properties (SetAccess = protected)
        Model(1, 1)
        ObjectiveFunctions(1,:) opencossan.optimization.ObjectiveFunction;
        Constraints(1,:) opencossan.optimization.Constraint;
    end

    properties
        Description(1, 1) string = "";
        InitialSolution double
        % Weights of the objective functions
        Weights double = [];
    end

    properties (Dependent = true)
        Input
        OutputNames
        InputNames
        ConstraintNames% Names of the constraint outputs
        ObjectiveFunctionNames% Names of the objectiveFunction outputs
        DesignVariableNames% names of the DesignVariable
        NumberOfDesignVariables% Total number of DesignVariable
        NumberOfObjectiveFunctions% Total number of ObjectiveFunction
        NumberOfConstraints% Total number of Constraints
        IsInequality% Type of inequality constraints
        LowerBounds% Lower Bounds of the DesignVariable
        UpperBounds% Upper Bounds of the DesignVariable
    end

    methods

        function obj = OptimizationProblem(varargin)
            %OPTIMIZATIONPROBLEM This method defines a OptimizationProblem object
            %
            % Copyright 1993-2011, COSSAN Working Group, University of Innsbruck, Austria
            % Author: Edoardo-Patelli

            if nargin == 0, return, end

            [required, varargin] = ...
                opencossan.common.utilities.parseRequiredNameValuePairs(...
                ["model", "objectivefunctions"], varargin{:});

            [optional, ~] = ...
                opencossan.common.utilities.parseOptionalNameValuePairs(...
                ["description", "constraints", "weights", "initialsolution"], {"", opencossan.optimization.Constraint.empty, [], []}, varargin{:});

            obj.Model = required.model;
            obj.ObjectiveFunctions = required.objectivefunctions;

            obj.Description = optional.description;
            obj.Constraints = optional.constraints;
            obj.Weights = optional.weights;
            obj.InitialSolution = optional.initialsolution;

            if isempty(obj.Weights)
                obj.Weights = ones(size(obj.ObjectiveFunctions));
            else
                assert(length(obj.ObjectiveFunctions) == length(obj.Weights), ...
                    'openCOSSAN:OptimizationProblem', ...
                    'NUmber of weights (%i) must match the number of objective functions (%i)', ...
                    length(obj.Weights), length(obj.ObjectiveFunction))
            end

            assert(~isempty(obj.Input.DesignVariableNames), ...
                'openCOSSAN:OptimizationProblem', ...
                'The input object must contains at least 1 design variable')

            assert(length(obj.ObjectiveFunctionNames) == length(unique(obj.ObjectiveFunctionNames)), ...
                'openCOSSAN:OptimizationProblem', ...
                'The name of the objective functions name must be unique!/n Outputnames: %s', ...
                sprintf('\n* "%s"', obj.ObjectiveFunctionNames{:}))

            assert(length(obj.ConstraintNames) == length(unique(obj.ConstraintNames)), ...
                'openCOSSAN:OptimizationProblem', ...
                'The name of the constraints output name must be unique!/n Outputnames: %s', ...
                sprintf('\n* "%s"', obj.ConstraintNames{:}))

            if isempty(obj.InitialSolution)
                obj.InitialSolution = [obj.Input.DesignVariables.Value];
            else
                assert(length(obj.DesignVariableNames) == size(obj.InitialSolution, 2), ...
                    'openCOSSAN:OptimizationProblem', ...
                    ['The length of InitialSolution (' num2str(size(obj.InitialSolution, 2)) ...
                    ') must be equal to the number of design variables (' ...
                    num2str(length(obj.Xinput.DesignVariableNames)) ')'])
            end
        end

        function input = get.Input(obj)
            switch (class(obj.Model))
                case 'opencossan.common.Model'
                    input = obj.Model.Input;
                case 'opencossan.reliability.ProbabilisticModel'
                    input = obj.Model.Xmodel.Xinput;
                case {'opencossan.metamodels.ResponseSurface''opencossan.metamodels.NeuralNetwork'}
                    input = obj.Model.XFullmodel.Xinput;
            end
        end

        function n = get.NumberOfDesignVariables(obj)
            n = length(obj.Input.DesignVariables);
        end

        function n = get.NumberOfConstraints(obj)
            n = length(obj.Constraints);
        end

        function n = get.NumberOfObjectiveFunctions(obj)
            n = length(obj.ObjectiveFunctions);
        end

        function ineq = get.IsInequality(obj)
            ineq = true(length(obj.Constraints), 1);

            for n = 1:length(obj.Constraints)
                ineq(n) = obj.Constraints(n).IsInequality;
            end

        end

        function names = get.DesignVariableNames(obj)
            names = obj.Input.DesignVariableNames;
        end

        function names = get.InputNames(obj)
            % Collect Inputs required by the model
            names = [{} obj.Model.InputNames];

            % Collect inputs required by the Objective function(s)
            for n = 1:length(obj.ObjectiveFunctions)
                names = [names obj.ObjectiveFunctions(n).InputNames]; %#ok<AGROW>
            end

            % Collect inputs required by the Constraint(s)
            for n = 1:length(obj.Constraints)
                names = [names obj.Constraints(n).InputNames]; %#ok<AGROW>
            end

            % Remove duplicates
            names = unique(names);
        end

        function names = get.OutputNames(obj)
            names = [obj.Model.OutputNames obj.ObjectiveFunctionNames obj.ConstraintNames];
        end

        function names = get.ObjectiveFunctionNames(obj)

            names = {};

            for n = 1:length(obj.ObjectiveFunctions)
                names = [names obj.ObjectiveFunctions(n).OutputNames]; %#ok<AGROW>
            end

        end

        function names = get.ConstraintNames(obj)

            names = {};

            for n = 1:length(obj.Constraints)
                names = [names obj.Constraints(n).OutputNames]; %#ok<AGROW>
            end

        end

        function bounds = get.LowerBounds(obj)
            bounds = [obj.Input.DesignVariables.LowerBound];
        end

        function bounds = get.UpperBounds(obj)
            bounds = [obj.Input.DesignVariables.UpperBound];
        end

        function obj = addConstraint(obj, constraint)% add a new Constraint
            assert(isa(constraint, 'opencossan.optimization.Constraint'), ...
                'openCOSSAN:OptimizationProblem:addConstraint', ...
                'The object of type %s can not be used here, required a Constraint object', class(constraint))

            if isempty(obj.Constraints)
                obj.Constraints = constraint;
            else
                obj.Constraints(end + 1) = constraint;
            end
        end

        function obj = addObjectiveFunction(obj, objectiveFunction)% add a new Objective Function
            assert(isa(objectiveFunction, 'ObjectiveFunction'), ...
                'openCOSSAN:OptimizationProblem:addObjectiveFunction', ...
                'The object of type %s can not be used here, required an ObjectiveFunction object', class(objectiveFunction))

            obj.ObjectiveFunctions(end + 1) = objectiveFunction;
        end

        %% Method optimize
        function [Xopt, varargout] = optimize(obj, varargin)

            assert(~isempty(varargin), 'openCOSSAN:OptimizationProblem:optimize', ...
                'Missing input argument!');

            for k = 1:2:length(varargin)

                switch lower(varargin{k})
                    case 'xoptimizer'
                        Xoptimizer = varargin{k + 1};
                        npos = k;
                        break
                    case 'cxoptimizer'
                        Xoptimizer = varargin{k + 1}{1};
                        npos = k;
                        break
                end

            end

            % Remove optimizer from varargin
            varargin = varargin([1:npos-1 npos+2:end]);

            % This method call the apply method of the Optimizer object
            [Xopt, XSimOutput] = Xoptimizer.apply('XOptimizationProblem', obj, varargin{:});

            if nargout > 1
                varargout{1} = XSimOutput;
            end

        end

        Xoptimum = initializeOptimum(obj, varargin)% Initialize an empty Optimum object
    end
end
