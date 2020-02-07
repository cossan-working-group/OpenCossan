function optimum = apply(obj, varargin)
    %   APPLY   This method applies the algorithm
    %           SequentialQuadraticProgramming (i.e. Sequential Quadratic
    %           Programming) for optimization
    %
    %   SequentialQuadraticProgramming is intended for solving an optimization
    %   problem using gradients of the objective function and constraints. When
    %   generating the constructor, it is possible to select the parameters of
    %   the optimization algorithm. It should be noted that default parameters
    %   are provided for the algorithm; nonetheless, the user should always
    %   check whether or not a particular set of parameters is appropriate for
    %   the problem at hand. A poor selection on these parameters may prevent
    %   finding the correct solution.
    %
    %   SequentialQuadraticProgramming is intended for solving the following
    %   class of problems
    %
    %                       min     f_obj(x)
    %                       subject to
    %                               ceq(x)      =  0
    %                               cineq(x)    <= 0
    %                               lb <= x <= ub
    %
    % See Also: https://cossan.co.uk/wiki/apply@MiniMax
    %
    % Author: Edoardo Patelli
    % Website: http://www.cossan.co.uk
    
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
    
    import opencossan.optimization.OptimizationRecorder;
    import opencossan.common.utilities.*;
    
    [required, varargin] = parseRequiredNameValuePairs(...
        "optimizationproblem", varargin{:});
    
    optProb = required.optimizationproblem;
    
    optional = parseOptionalNameValuePairs(...
        "initialsolution", {optProb.InitialSolution}, ...
        varargin{:});
    
    x0 = optional.initialsolution;
    % Check inputs and initialize variables
    obj = initializeOptimizer(obj);
    
    assert(size(x0, 1) == 1, ...
        'OpenCossan:SequentialQuadraticProgramming:apply',...
        'Only 1 initial setting point is allowed')
    
    options = optimoptions('fmincon', 'Algorithm', 'sqp', 'Display', 'iter');
    options.MaxFunctionEvaluations = obj.MaxFunctionEvaluations;
    options.MaxIterations = obj.MaxIterations;
    
    options.OptimalityTolerance = obj.ObjectiveFunctionTolerance;
    options.ConstraintTolerance = obj.ConstraintTolerance;
    options.StepTolerance = obj.DesignVariableTolerance;
    
    options.FiniteDifferenceStepSize = obj.FiniteDifferenceStepSize;
    options.FiniteDifferenceType = obj.FiniteDifferenceType;
    
    memoizedModel = opencossan.optimization.memoizeModel(optProb);
    
    objfun = @(x)evaluate(optProb.ObjectiveFunctions,...
        'optimizationproblem', optProb, ...
        'referencepoints', x, ...
        'model', memoizedModel, ...
        'scaling', obj.ObjectiveFunctionScalingFactor);
    
    assert(~logical(isempty(optProb.Constraints)) ||  ...
        ~logical(isempty(optProb.LowerBounds)) || ...
        ~logical(isempty(optProb.UpperBounds)), ...
        'OpenCossan:SequentialQuadraticProgramming:apply',...
        'SequentialQuadraticProgramming is a constrained Nonlinear Optimization and requires or a constrains object or design variables with bounds')
    
    % Create handle for the constrains
    if isempty(optProb.Constraints)
        constraints = [];
    else
        constraints = @(x)evaluate(optProb.Constraints, ...
            'optimizationproblem', optProb, ...
            'referencepoints', x, ...
            'model', memoizedModel, ...
            'scaling', obj.ConstraintScalingFactor);
    end
    
    OptimizationRecorder.clear();
    
    startTime = tic;
    
    % optimize using fmincon
    [optimalSolution, ~, exitFlag] = ...
        fmincon(objfun, ...
        x0, [], [], [], [], ...
        optProb.LowerBounds, optProb.UpperBounds, ...
        constraints, ...
        options);
    
    totalTime = toc(startTime);
    
    optimum = opencossan.optimization.Optimum(...
        'optimalsolution', optimalSolution, ...
        'exitflag', exitFlag, ...
        'totaltime', totalTime, ...
        'optimizationproblem', optProb, ...
        'optimizer', obj, ...
        'constraints', OptimizationRecorder.getInstance().Constraints, ...
        'objectivefunction', OptimizationRecorder.getInstance().ObjectiveFunction, ...
        'modelevaluations', OptimizationRecorder.getInstance().ModelEvaluations);
    
    if ~isdeployed; obj.saveOptimumToDatabase(optimum); end
    
end
