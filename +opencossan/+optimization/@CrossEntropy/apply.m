function optimum = apply(obj, varargin)
    % APPLY This method applies the algorithm CrossEntropy for optimization
    %
    %   Gradient-free unconstrained optimization algorithm based in stochastic search; if
    %   parameters of the model are tuned correctly, the solution provided by CE may correspond
    %   to the global optimum. This algorithm solves the problem:
    %
    %       min f_obj(x)
    %           x in R^n
    %
    % See Also: https://cossan.co.uk/wiki/@CrossEntropy
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
        'OpenCossan:CrossEntropy:apply',...
        'CrossEntropy is an UNconstrained Nonlinear Optimization.')
    
    bounded = all(isfinite([optProb.Input.DesignVariables.LowerBound, ...
        optProb.Input.DesignVariables.UpperBound]));
    
    assert(size(x0, 1) >= obj.NUpdate || bounded, ...
        'OpenCossan:CrossEntropy:apply', ...
        'Please specify at least %i initial solutions or use bounded design variables.', obj.NUpdate);
    
    obj = initializeOptimizer(obj);
    
    if isempty(x0) || isvector(x0)
        opencossan.OpenCossan.cossanDisp('Generate initial solutions for Cross Entropy',4);
        
        x0 = zeros(obj.NUpdate, optProb.NumberOfDesignVariables);
        for n = 1:optProb.NumberOfDesignVariables
            dv = optProb.Input.DesignVariables(n);
            x0(:,n) = dv.sample('nsamples', obj.NUpdate);
        end
    end
    
    memoizedModel = opencossan.optimization.memoizeModel(optProb);
    
    % Create handle of the objective function
    hobjfun=@(x)evaluate(optProb.ObjectiveFunctions,'optimizationproblem',optProb,...
        'referencepoints',x,'model',memoizedModel,...
        'scaling',obj.ObjectiveFunctionScalingFactor);
    
    %% Initialise optimiser
    obj = initializeOptimizer(obj);
    
    samples = x0;
    
    recorder = OptimizationRecorder.getInstance();
    recorder.clear();
    
    startTime = tic;
    
    iteration = 0;
    while true
        iteration = iteration + 1;
        %  Evaluate objective function
        objfunvalues = hobjfun(samples);  %Objective function evaluation
        
        % Sort values and calculate mean and standard deviation
        [~,idx] = sort(objfunvalues);        %Sort values of objective functions generated at current stage
        %Update mean according to promising samples
        Vmu = mean(samples(idx(1:obj.NUpdate), :));
        %Covariance Matrix of the Samples
        Mcov = cov(samples(idx(1:obj.NUpdate),:));
        
        Vsigma = std(samples(idx(1:obj.NUpdate), :));    %Update std according to promising samples
        
        % Check termination of the algorithm
        if max(Vsigma) < obj.SigmaTolerance
            % convergance achieved
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
        end
        
        [Mfi,Mlambda] = eig(Mcov); %Decomposition of Covariance Matrix
        Vlambda = diag(Mlambda); %Eigenvalues of covariance matrix
        Veigvl_g0 = find(Vlambda>0); % determine Eigenvalues larger than zero
        MB = Mfi(:,Veigvl_g0) * sqrt(Mlambda(:,Veigvl_g0)); % Matrix to generate correlated rv's
        
        % Generate new random samples
        samples = repmat(Vmu,obj.NFunEvalsIter,1) + (MB*randn(length(Veigvl_g0),obj.NFunEvalsIter))';
    end
    
    totalTime = toc(startTime);
    
    optimum = opencossan.optimization.Optimum( ...
        'optimalsolution', samples(idx(1), :), ...
        'exitflag', exitFlag, ...
        'totaltime', totalTime, ...
        'optimizationproblem', optProb, ...
        'optimizer', obj, ...
        'objectivefunction', OptimizationRecorder.getInstance().ObjectiveFunction, ...
        'modelevaluations', OptimizationRecorder.getInstance().ModelEvaluations);
    
    if ~isdeployed; obj.saveOptimumToDatabase(optimum); end
end