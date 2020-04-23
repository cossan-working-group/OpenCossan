classdef Constraint < opencossan.workers.Mio
    %CONSTRAINT The class Constraint defines the constraints for the
    % optimization problem.
    
    %{
    This file is part of OpenCossan <https://cossan.co.uk>. Copyright (C)
    2006-2019 COSSAN WORKING GROUP

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
    
    properties (SetAccess=protected)
        % Flag defining whether a constraint is an inequality (TRUE) or an
        % equality (FALSE)
        IsInequality(1,1) logical = true
    end
    
    methods
        function obj = Constraint(varargin)
            % CONSTRAINT This constructor defines an object Constraint. It
            % is a sub-class of Mio and hinerite from this class all the
            % properties and methods. The only restriction is that it needs
            % to have only 1 output.
            
            if nargin == 0
                super_args = {};
            else
                [optional, super_args] = opencossan.common.utilities.parseOptionalNameValuePairs(...
                    "inequality", {true}, varargin{:});
            end
            
            obj@opencossan.workers.Mio(super_args{:});
            
            if nargin > 0
                obj.IsInequality = optional.inequality;
            end
            
            % Assert that the constraint has a single output
            assert(length(obj.OutputNames) == 1,...
                'OpenCossan:Constraint:IllegalArgument',...
                'A single output (OutputNames) must be defined.');
        end
        
        [in, eq] = evaluate(obj, varargin)
    end
end
