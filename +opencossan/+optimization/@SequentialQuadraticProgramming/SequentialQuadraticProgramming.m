classdef SequentialQuadraticProgramming < opencossan.optimization.Optimizer
    %SEQUENTIALQUADRATICPROGRAMMING is a class for optimization of problems
    % using gradients of the objective function and constraints.
    %
    % SequentialQuadraticProgramming is intended for solving the following
    % class of problems
    %   min	f_obj(x)
    %   subject to
    %   	ceq(x)   =  0
    %   	cineq(x) <= 0
    %   	lb <= x <= ub
    
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
        ExitReasons = containers.Map([1, 0, -1, -2, -3],[
            "First-order optimality measure was less than options.OptimalityTolerance, and maximum constraint violation was less than options.ConstraintTolerance.", ...
            "Number of iterations exceeded options.MaxIterations or number of function evaluations exceeded options.MaxFunctionEvaluations.", ...
            "Stopped by an output function or plot function.", ...
            "No feasible point was found.", ...
            "Objective function at current iteration went below options.ObjectiveLimit and maximum constraint violation was less than options.ConstraintTolerance."]);
    end
    
    methods
        function obj = SequentialQuadraticProgramming(varargin)
            %SEQUENTIALQUADRATICPROGRAMMING
            
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
