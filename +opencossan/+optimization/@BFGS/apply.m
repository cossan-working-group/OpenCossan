function optimum = apply(obj,varargin)
    %APPLY  This method applies the algorithm BFGS for solving an unconstrained
    %       optimization problem.
    %
    % See also: https://cossan.co.uk/wiki/apply@Optimizer
    %
    % Author: Edoardo Patelli
    % Website: https://www.cossan.co.uk
    
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
        'OpenCossan:BFGS:apply',...
        'Only 1 initial setting point is allowed')
    
    assert(isempty(optProb.Constraints), ...
        'OpenCossan:BFGS:apply',...
        'BFGS is an UNconstrained Nonlinear Optimization.')
    
    options = optimoptions('fminunc', 'Display', 'iter');  %Default optimization options
    
    options.MaxFunctionEvaluations = obj.MaxFunctionEvaluations;
    options.MaxIterations = obj.MaxIterations;
    
    options.OptimalityTolerance = obj.ObjectiveFunctionTolerance;
    options.StepTolerance = obj.DesignVariableTolerance;
    
    options.FiniteDifferenceStepSize = obj.FiniteDifferenceStepSize;
    options.FiniteDifferenceType = obj.FiniteDifferenceType;
    
    memoizedModel = opencossan.optimization.memoizeModel(optProb);
    
    objfun = @(x) evaluate(optProb.ObjectiveFunctions, ...
        'optimizationproblem', optProb, ...
        'referencepoints', x, ...
        'model', memoizedModel, ...
        'scaling', obj.ObjectiveFunctionScalingFactor);
    
    OptimizationRecorder.clear();
    
    startTime = tic;
    
    [optimalSolution, ~, exitFlag] = ...
        fminunc(objfun, x0, options);
    
    totalTime = toc(startTime);
    
    optimum = opencossan.optimization.Optimum(...
        'optimalsolution', optimalSolution, ...
        'exitflag', exitFlag, ...
        'totaltime', totalTime, ...
        'optimizationproblem', optProb, ...
        'optimizer', obj, ...
        'objectivefunction', OptimizationRecorder.getInstance().ObjectiveFunction, ...
        'modelevaluations', OptimizationRecorder.getInstance().ModelEvaluations);
    
    if ~isdeployed; obj.saveOptimumToDatabase(optimum); end
end
