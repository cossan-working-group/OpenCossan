function optimum = apply(obj, varargin)
    %   APPLY   This method applies the algorithm SimulatedAnnealing for optimization
    %
    %   Simulated Annealing (SA) can be used to found a MINIMUM of a function. It is intended for
    %   solving the problem
    %
    %                       min f_obj(x) x in R^n
    %
    % See Also: https://cossan.co.uk/wiki/index.php/Apply@SimultatedAnnealing
    %
    % Author: Edoardo Patelli Website: https://www.cossan.co.uk
    
    %{
    This file is part of OpenCossan <https://cossan.co.uk>. Copyright (C) 2006-2018 COSSAN WORKING
    GROUP

    OpenCossan is free software: you can redistribute it and/or modify it under the terms of the GNU
    General Public License as published by the Free Software Foundation, either version 3 of the
    License or, (at your option) any later version.
    
    OpenCossan is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
    even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
    General Public License for more details.
    
    You should have received a copy of the GNU General Public License along with OpenCossan. If not,
    see <http://www.gnu.org/licenses/>.
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
    
    assert(size(x0, 1) == 1, ...
        'OpenCossan:MiniMax:apply',...
        'Only 1 initial setting point is allowed')
    
    assert(isempty(optProb.Constraints),  ...
        'OpenCossan:SimulatedAnnealing:apply', ...
        'SimulatedAnnealing is an UNconstrained Nonlinear Optimization.')
    
    memoizedModel = opencossan.optimization.memoizeModel(optProb);
    
    objfun=@(x)evaluate(optProb.ObjectiveFunctions,'optimizationproblem',optProb,...
        'referencepoints',x,'model',memoizedModel,...
        'scaling',obj.ObjectiveFunctionScalingFactor);
    
    options = optimoptions('simulannealbnd'); % Default options for simulated anneling
    
    options.AnnealingFcn = obj.AnnealingFunction;
    options.TemperatureFcn = obj.TemperatureFunction;
    options.TolFun = obj.ObjectiveFunctionTolerance;
    options.StallIterLimit = obj.StallIterLimit;
    options.MaxFunEvals = obj.MaxFunctionEvaluations;
    options.Display = 'iter';
    options.TimeLimit = obj.Timeout;
    options.MaxIter = obj.MaxIterations;
    options.ObjectiveLimit = obj.ObjectiveFunctionLimit;
    options.InitialTemperature = obj.InitialTemperature;
    options.ReannealInterval = obj.ReannealInterval;
    
    opencossan.optimization.OptimizationRecorder.clear();
    
    startTime = tic;
    
    [optimalSolution, ~, exitFlag]  = ...
        simulannealbnd(objfun, ...
        x0, ...
        optProb.LowerBounds,optProb.UpperBounds, ...
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
