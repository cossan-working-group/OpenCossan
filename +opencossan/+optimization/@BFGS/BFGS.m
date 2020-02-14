classdef BFGS < opencossan.optimization.Optimizer
    % BFFS class is intended for solving unconstrained nonlinear optimization
    % problem using gradients
    
    %{
    This file is part of OpenCossan <https://cossan.co.uk>.
    Copyright (C) 2006-2019 COSSAN WORKING GROUP

    OpenCossan is free software: you can redistribute it and/or modify it
    under the terms of the GNU General Public License as published by the
    Free Software Foundation, either version 3 of the License or, (at your
    option) any later version.

    OpenCossan is distributed in the hope that it will be useful, but
    WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
    General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with OpenCossan. If not, see <http://www.gnu.org/licenses/>.
    %}
    
    properties
        FiniteDifferenceStepSize(1,1) = sqrt(eps);
        FiniteDifferenceType {mustBeMember(FiniteDifferenceType, {'forward', 'central'})} = 'forward';
    end
    
    properties (Hidden)
        ExitReasons = containers.Map([1, 2, 3, 5, 0, -1, -3],[
            "Magnitude of gradient is smaller than the OptimalityTolerance tolerance.", ...
            "Change in x was smaller than the StepTolerance tolerance.", ...
            "Change in the objective function value was less than the FunctionTolerance tolerance.", ...
            "Predicted decrease in the objective function was less than the FunctionTolerance tolerance.", ...
            "Number of iterations exceeded MaxIterations or number of function evaluations exceeded MaxFunctionEvaluations.", ...
            "Algorithm was terminated by the output function.", ...
            "Objective function at current iteration went below ObjectiveLimit."]);
    end
    
    methods
        function obj = BFGS(varargin)
            %BFGS
            
            import opencossan.common.utilities.parseOptionalNameValuePairs;
            if nargin == 0
                super_args = {};
            else
                [optional, super_args] = parseOptionalNameValuePairs(...
                    ["FiniteDifferenceStepSize", "FiniteDifferenceType"], ...
                    {sqrt(eps), 'forward'}, varargin{:});
            end
            
            obj@opencossan.optimization.Optimizer(super_args{:});
            
            if nargin > 0
                obj.FiniteDifferenceStepSize = optional.finitedifferencestepsize;
                obj.FiniteDifferenceType = optional.finitedifferencetype;
            end
        end
        
        varargout = apply(obj, varargin);
    end
end
