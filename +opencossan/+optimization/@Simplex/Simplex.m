classdef Simplex < opencossan.optimization.Optimizer
    %SIMPLEX The simplex class define the optimizator SIMPLEX to solve unconstrained nonlinear problems  using a gradients free method 
    
    properties (Hidden)
        ExitReasons = containers.Map([1, 0, -1],[
            "The function converged to a solution x.", ...
            "Number of iterations exceeded options.MaxIter or number of function evaluations exceeded options.MaxFunEvals.", ...
            "The algorithm was terminated by the output function."]);
    end
    
    methods
        function obj = Simplex(varargin)
            %SIMPLEX            
            obj@opencossan.optimization.Optimizer(varargin{:});
        end
        
        varargout = apply(obj, varargin)
    end
end
