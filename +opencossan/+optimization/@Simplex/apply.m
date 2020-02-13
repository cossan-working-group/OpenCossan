function optimum = apply(obj, varargin)
    %   APPLY   This method applies the algorithm
    %           Simplex for solving unconstrained problems
    %
    %
    % See Also: https://cossan.co.uk/wiki/apply@Simplex
    %
    % Author: Edoardo Patelli Website: http://www.cossan.co.uk
    
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
    
    % Check inputs and initialize variables
    obj = initializeOptimizer(obj);
    
    options = optimset('fminsearch');
    options.Display = 'iter';
    options.MaxFunEvals = obj.MaxFunctionEvaluations;
    options.MaxIter = obj.MaxIterations;
    options.TolFun = obj.ObjectiveFunctionTolerance;
    options.TolX = obj.DesignVariableTolerance;
    
    memoizedModel = opencossan.optimization.memoizeModel(optProb);
    
    hobjfun=@(x)evaluate(optProb.ObjectiveFunctions,'optimizationproblem',optProb,...
        'referencepoints',x,'model',memoizedModel,...
        'scaling',obj.ObjectiveFunctionScalingFactor);
    
    assert(isempty(optProb.Constraints),  ...
        'OpenCossan:Simplex:apply', ...
        'Simplex is an UNconstrained Nonlinear Optimization.')
   
    opencossan.optimization.OptimizationRecorder.clear();
    
    startTime = tic;
    
    [optimalSolution, ~, exitFlag]  = fminsearch(hobjfun, x0, options);
    
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