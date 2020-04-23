function optimum = apply(obj, varargin)
    %   APPLY   This method applies the algorithm
    %           EvolutionStrategy for optimization
    %
    %   Evolution Strategies is a gradient-free optimization algorithm that performs a stochastic
    %   search in the space of the design variables. Evolution Strategies solves the problem
    %
    %           min f_obj(x) x in R^n
    %
    %   [Xoutput_ES]   = apply(Xobj,'OptimizationProblem'Xop)
    %
    % See also: https://cossan.co.uk/wiki/index.php/Apply@EvolutionStrategy
    %
    % Author: Edoardo Patelli
    
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
    
    assert(isempty(optProb.Constraints), ...
        'OpenCossan:EvolutionStrategy:apply',...
        'CrossEntropy is an UNconstrained Nonlinear Optimization.')
    
    obj = initializeOptimizer(obj);
    
    assert(isscalar(obj.Sigma) || numel(obj.Sigma) == optProb.NumberOfDesignVariables, ...
        'OpenCossan:EvolutionStrategy:apply', ...
        'Sigma must be a scalar or vector of length equal to the number of design variables.');
        
    if isempty(x0) || isvector(x0)
        x0 = randn(obj.Nmu, optProb.NumberOfDesignVariables);
        if isvector(obj.Sigma)
            for i = 1:numel(obj.Sigma)
                x0(:, i) = x0(:, i) * obj.Sigma(i);
            end
        else
            x0 = obj.Sigma .* x0;
        end
    end
    
    memoizedModel = opencossan.optimization.memoizeModel(optProb);
    % Create handle of the objective function
    hobjfun=@(x)evaluate(optProb.ObjectiveFunctions,'optimizationproblem',optProb, ...
        'referencepoints',x,'model', memoizedModel, ...
        'scaling',obj.ObjectiveFunctionScalingFactor);
    
    %% Evaluation of initial population
    parents = x0;
    
    if isscalar(obj.Sigma)
        sigma = repmat(obj.Sigma, obj.Nmu, optProb.NumberOfDesignVariables);
    else
        sigma = repmat(obj.Sigma, obj.Nmu, 1);
    end
    
    startTime = tic;
    
    iteration = 0;
    
    recorder = OptimizationRecorder.getInstance();
    recorder.clear();    
    
    parent_fitness = hobjfun(parents);
    mean_fitness = mean(parent_fitness);
    full_parents = [parents, sigma, parent_fitness];
    
    while true
        iteration = iteration + 1;
        
        parents_old = full_parents(:, 1:optProb.NumberOfDesignVariables);
        mean_fitness_old = mean_fitness;
        
        % Generate Lambda offspring
        % Recombination and Mutation
        offsprings = mutation(obj, recombination(obj,full_parents));
        % Objective function evaluation
        offsprings(:,end) = hobjfun(offsprings(:,1:optProb.NumberOfDesignVariables));
        
        % Select new parent population
        full_parents = selection(obj,full_parents,offsprings);
        
        % calculate mean fitness
        mean_fitness = mean(full_parents(:,end));        

        if abs(mean_fitness - mean_fitness_old) < obj.ObjectiveFunctionTolerance
            % Convergance
            exitFlag = 0;
            break;
        elseif iteration >= obj.MaxIterations
            % maximum number of iterations
            exitFlag = 1;
            break;
        elseif recorder.ObjectiveFunctionEvaluations >= obj.MaxFunctionEvaluations
            % maximum number of objective function evaluations
            exitFlag = 2;
            break;
        elseif height(recorder.ModelEvaluations) >= obj.MaxModelEvaluations
            % maximum number of model evaluations
            exitFlag = 3;
            break;
        elseif norm(full_parents(:, 1:optProb.NumberOfDesignVariables) - parents_old) < obj.DesignVariableTolerance
            % change in design variables smaller than tolerance
            exitFlag = 4;
            break;
        end
    end
    
    totalTime = toc(startTime);
    
    [~, idx] = min(full_parents(:, end));
    optimalSolution = full_parents(idx, 1:optProb.NumberOfDesignVariables);
    
    optimum = opencossan.optimization.Optimum( ...
        'optimalsolution', optimalSolution, ...
        'exitflag', exitFlag, ...
        'totaltime', totalTime, ...
        'optimizationproblem', optProb, ...
        'optimizer', obj, ...
        'objectivefunction', OptimizationRecorder.getInstance().ObjectiveFunction, ...
        'modelevaluations', OptimizationRecorder.getInstance().ModelEvaluations);
    
    if ~isdeployed; obj.saveOptimumToDatabase(optimum); end
end
