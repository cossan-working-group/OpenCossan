function optimum = apply(obj, varargin)
    %APPLY   This method applies the algorithm
    %           StochasticRanking for optimization
    %
    %
    % See Also: https://cossan.co.uk/wiki/index.php/apply@StochasticRanking
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
    
    assert(~isempty(optProb.Constraints),...
        'OpenCossan:StochasticRanking:apply', ...
        'Stochastic ranking can not optimize unconstrained problems.')
    
    assert(all([optProb.Constraints.IsInequality]), ...
        'OpenCossan:StochasticRanking:apply',...
        'StochasticRanking can perform optimization with inequality constraint only.')
    
    bounded = all(isfinite([optProb.Input.DesignVariables.LowerBound, ...
        optProb.Input.DesignVariables.UpperBound]));
    
    assert(bounded, ...
        'OpenCossan:StochasticRanking:apply', ...
        'All design variables must be bounded.');
    
    % Check inputs and initialize variables
    obj = initializeOptimizer(obj);
    
    memoizedModel = opencossan.optimization.memoizeModel(optProb);
    
    % Create handle of the objective function
    objfun=@(x)evaluate(optProb.ObjectiveFunctions,'optimizationproblem', optProb,...
        'referencepoints',x,'model',memoizedModel,...
        'scaling',obj.ObjectiveFunctionScalingFactor);
    
    constraint=@(x)evaluate(optProb.Constraints,'optimizationproblem',optProb,...
        'referencepoints',x,'model',memoizedModel, ...
        'scaling',obj.ConstraintScalingFactor);
    
    opencossan.optimization.OptimizationRecorder.clear();
    
    startTime = tic;
    
    [optimalSolution, ~, ~, exitFlag] = obj.sres(objfun,constraint,'min',...
        [[optProb.Input.DesignVariables.LowerBound]; [optProb.Input.DesignVariables.UpperBound]],...
        obj.Lambda, obj.MaxIterations,obj.Mu,obj.WinProbability, 1);
    
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