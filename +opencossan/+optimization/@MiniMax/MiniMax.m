classdef MiniMax < opencossan.optimization.Optimizer
    %MINIMAX MiniMax is an algorithm for solving an multi-objective optimization problems.
    
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
        ExitReasons = containers.Map([1, 4, 5, 0, -1, -2],[
            "Function converged to a solution x.", ...
            "Magnitude of the search direction was less than the specified tolerance, and the constraint violation was less than options.ConstraintTolerance.", ...
            "Magnitude of the directional derivative was less than the specified tolerance, and the constraint violation was less than options.ConstraintTolerance.", ...
            "Number of iterations exceeded options.MaxIterations or the number of function evaluations exceeded options.MaxFunctionEvaluations.", ...
            "Stopped by an output function or plot function.", ...
            "No feasible point was found."]);
    end
    
    methods
        function obj = MiniMax(varargin)
            %MINIMAX
            
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
        
        varargout = apply(obj, varargin)
    end
end
