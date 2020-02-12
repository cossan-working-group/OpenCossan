classdef CrossEntropy < opencossan.optimization.Optimizer
    %   Cross Entropy is a gradient-free unconstrained optimization algorithm based in stochastic
    %   search; if parameters of the model are tuned correctly, the solution provided by CE may
    %   correspond to the global optimum.
    
    properties
        NFunEvalsIter = 100   %Number of Function Evaluations per Iteration
        NUpdate = 20    %Number of samples per iteration used to update the associated stochastic problem
        SigmaTolerance = 0.001 %Termination tolerance on the standard deviation of the associated stochastic problem (scalar)
    end
    
    properties (Hidden)
        ExitReasons = containers.Map([0, 1, 2, 3],[
            "Standard deviation of associated stochastic problem smaller than tolerance.", ...
            "Maximum number of iterations reached.", ...
            "Maximum number of objective function evaluations reached.", ...
            "Maximum number of model evaluations reached."]);
    end
    
    methods        
        function obj = CrossEntropy(varargin)
            %CROSSENTROPY
            
            import opencossan.common.utilities.parseOptionalNameValuePairs;
            if nargin == 0
                super_args = {"MaxFunctionEvaluations", 1e5};
            else
                [optional, super_args] = parseOptionalNameValuePairs(...
                    ["NFunEvalsIter", "NUpdate", "SigmaTolerance", "MaxFunctionEvaluations"], ...
                    {100, 20, 0.001, 1e5}, varargin{:});
            end
            
            obj@opencossan.optimization.Optimizer(super_args{:});
            
            if nargin > 0
                obj.NFunEvalsIter = optional.nfunevalsiter;
                obj.NUpdate = optional.nupdate;
                obj.SigmaTolerance = optional.sigmatolerance;
                obj.MaxFunctionEvaluations = optional.maxfunctionevaluations;
            end
        end
        
        optimum = apply(obj,varargin);
    end
end