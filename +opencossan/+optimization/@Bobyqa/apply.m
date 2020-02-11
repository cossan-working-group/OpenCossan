function optimum = apply(obj, varargin)
    %   APPLY   This method applies the algorithm BOBYQA (Bounded
    %           Optimization by Quadratic Approximations) for optimization
    %
    %   APPLY This method applies the algorithm BOBYQA.
    %
    %   min f_obj(x)
    %   subject to
    %       lower(x) <= x <= upper(x)
    
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
        'OpenCossan:BOBYQA:apply',...
        'Only 1 initial setting point is allowed')
    
    assert(isempty(optProb.Constraints), ...
        'OpenCossan:BOBYQA:apply',...
        'BOBYQA is an UNconstrained Nonlinear Optimization.')
    
    assert(all(isfinite(optProb.LowerBounds)), ...
        "OpenCossan:optimization:bobyqa:apply", ...
        ['BOBYQA operates on bounded design variables.\n', ...
        'Please provide a LOWER bound for the following variables: %s'], ...
        strjoin(optProb.DesignVariableNames(~isfinite(optProb.LowerBounds)), ","));
    
    assert(all(isfinite(optProb.UpperBounds)), ...
        "OpenCossan:optimization:bobyqa:apply", ...
        ['BOBYQA operates on bounded design variables.\n', ...
        'Please provide an UPPER bound for the following variables: %s'], ...
        strjoin(optProb.DesignVariableNames(~isfinite(optProb.UpperBounds)), ","));
    
    memoizedModel = opencossan.optimization.memoizeModel(optProb);
    
    % Create handle of the objective function
    % This variable is retrieved by mex file by name.
    objective_function_bobyqa = @(x) evaluate(optProb.ObjectiveFunctions,...
        'optimizationproblem', optProb, 'model', memoizedModel, ...
        'referencepoints',x','scaling',obj.ObjectiveFunctionScalingFactor); %#ok<NASGU>
    
    opencossan.optimization.OptimizationRecorder.clear();
    
    startTime = tic;
    
    [optimalSolution, exitFlag] = bobyqa_matlab(optProb.NumberOfDesignVariables, ...
        obj.npt, x0, optProb.LowerBounds, optProb.UpperBounds, ...
        repmat(obj.stepSize, 1, optProb.NumberOfDesignVariables), ...
        obj.rhoEnd, obj.xtolRel, obj.minfMax, obj.ftolRel, obj.ftolAbs, ...
        obj.MaxFunctionEvaluations, obj.verbose);
    
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
