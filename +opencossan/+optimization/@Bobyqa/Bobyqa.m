classdef Bobyqa < opencossan.optimization.Optimizer
    %    BOBYQA (Bounded Optimization by Quadratic Approximation)
    %   seeks the least value of a function of many variables,
    %   by applying a trust region method that forms quadratic models
    %   by interpolation. There is usually some freedom in the
    %   interpolation conditions, which is taken up by minimizing
    %   the Frobenius norm of the change to the second derivative
    %   of the model, beginning with the zero matrix. The values of
    %   the variables are constrained by upper and lower bounds.
    %   Bobyqa is an open source derivative-free optimization algorithm with
    %   constraints by M. J. D. Powell.
    %   This program is free software; you can redistribute it and/or modify it
    %   under the terms of the GNU General Public License as published by the
    %   Free Software Foundation; either version 2 of the License, or
    %   (at your option) any later version. This program is distributed in the
    %   hope that it will be useful, but WITHOUT ANY WARRANTY; without even the
    %   implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    %   See the GNU General Public License for more details.
    
    properties
        npt = 0         % Number of interpolation conditions. Its value must be in the interval [N+2,(N+1)(N+2)/2]. Choices that exceed 2*N+1 are not recommended.
        stepSize = 0.01 % Step size
        rhoEnd = 1e-6   % Required accuracy for the variables. RHOEND should indicate the accuracy that is required in the final values of the variables
        xtolRel = 1e-9  % Relative tolerance on the design variables
        minfMax = 1e-9  % Tolerance on the objective function
        ftolRel = 1e-8  % Relative tolerance on the objective function
        ftolAbs = 1e-14 % Absolute tolerance on the objective function
        verbose = 1     % Verbosity level {0,1,2,3,4,>4}
    end
    
    properties (Hidden)
        ExitReasons = containers.Map([-4, -1, -2, -3, 0, 1, 2, 5, 6, 3, 4],[
            "Failure.", ...
            "Invalid Argument.", ...
            "Out of Memory.", ...
            "Round-off limited.", ...
            "Success.", ...
            "Requested function value reached.", ...
            "Function value tolerance reached.", ...
            "Relative function value tolerance reached.", ...
            "Absolute functon value tolerance reached.", ...
            "Parameter tolerance reached.", ...
            "Maximum number of function evaluations reached."]);
    end
    
    methods
        varargout    = apply(Xobj,varargin)  %This method perform the simulation adopting the Xobj
        
        function obj = Bobyqa(varargin)
            
            import opencossan.common.utilities.parseOptionalNameValuePairs;
            if nargin == 0
                super_args = {};
            else
                [optional, super_args] = parseOptionalNameValuePairs(...
                    ["npt", "rhoend", "stepsize", "xtolrel", "minfmax", "ftolrel", "ftolabs", "verbose"], ...
                    {0, 1e-6, 0.01, 1e-9, 1e-9, 1e-8, 1e-14, 1}, varargin{:});
            end
            
            obj@opencossan.optimization.Optimizer(super_args{:});
            
            if nargin > 0
                obj.npt = optional.npt;
                obj.stepSize = optional.stepsize;
                obj.rhoEnd = optional.rhoend;
                obj.xtolRel = optional.xtolrel;
                obj.minfMax = optional.minfmax;
                obj.ftolRel = optional.ftolrel;
                obj.ftolAbs = optional.ftolabs;
                obj.verbose = optional.verbose;
            end
            
            % Check consistency of Optimization object w.r.t. the
            % trust region
            assert(obj.ftolRel >= obj.ftolAbs,...
                'openCOSSAN:Bobyqa',...
                ['the relative tolerance on the objective function (' num2str(obj.ftolRel) ')' ...
                'should be smaller than the absolute one (' num2str(obj.ftolAbs) ')']);
        end
    end
end
