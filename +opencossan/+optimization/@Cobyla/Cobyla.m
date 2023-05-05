classdef Cobyla < opencossan.optimization.Optimizer
    % COBYLA COBYLA is intended for solving an optimization problem using the gradient-free
    % algorithm COBYLA. When generating the constructor, it is possible to select the parameters of
    % the optimization algorithm. It should be noted that default parameters are provided for the
    % algorithm; nonetheless, the user should always check whether or not a particular set of
    % parameters is appropriate for the problem at hand. A poor selection on these parameters may
    % prevent finding the correct solution.
    
    properties
        InitialTrustRegion(1,1) double = 1; % Size of initial Trust Region
        FinalTrustRegion(1,1) double = 1e-3; % Size of target Trust Region
    end
    
    properties (Hidden)
        ExitReasons = containers.Map([3, 2, 1, 0, -1, -2],[
            "User requested end of minimization.", ...
            "Rounding errors are becoming damaging.", ...
            "Maximum number of function evaluations reached.", ...
            "Normal return from cobyla.", ...
            "Memory allocation failed.", ...
            "No. optimization variables <0 or No. constraints <0."]);
    end
    
    methods    
        function obj = Cobyla(varargin)
            % COBYLA
            import opencossan.common.utilities.parseOptionalNameValuePairs;
            if nargin == 0
                super_args = {"ConstraintScalingFactor", -1, "MaxFunctionEvaluations", 1e3};
            else
                [optional, super_args] = parseOptionalNameValuePairs(...
                    ["InitialTrustRegion", "FinaltrustRegion", "ConstraintScalingFactor", "MaxFunctionEvaluations"], ...
                    {1, 1e-3, -1, 1e3}, varargin{:});
            end
            
            obj@opencossan.optimization.Optimizer(super_args{:});
            
            if nargin > 0
                obj.InitialTrustRegion = optional.initialtrustregion;
                obj.FinalTrustRegion = optional.finaltrustregion;
                obj.ConstraintScalingFactor = optional.constraintscalingfactor;
                obj.MaxFunctionEvaluations = optional.maxfunctionevaluations;
            end
            
            assert(obj.InitialTrustRegion >= obj.FinalTrustRegion, ...
                'openCOSSAN:Cobyla:invalidTrustRegions', ...
                ['The size of the final trust region (%d) must be smaller than the initial ' ...
                 'trust region rho_ini (%d)'], obj.FinalTrustRegion, obj.InitialTrustRegion);
            
            assert(obj.ConstraintScalingFactor < 0,...
                'openCOSSAN:Cobyla:wrongScalingFactor',...
                ['COBYLA will try to make all the values of the constraints positive.\n' ...
                'The scaling factor must be negative. ConstraintScalingFactor: %d'], ...
                obj.ConstraintScalingFactor);
            
            assert(isfinite(obj.MaxFunctionEvaluations), 'openCossan:Cobyla:InvalidArgument',...
                'Cobyla does not accept Inf as MaxFunctionEvaluations'); 
        end
        
        optimum = apply(obj, varargin)
    end
end
