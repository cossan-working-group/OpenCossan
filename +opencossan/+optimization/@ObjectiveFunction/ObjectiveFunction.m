classdef ObjectiveFunction < opencossan.workers.Mio
    %OBJECTIVEFUNCTION Defines an objective function for use in
    %optimization problems.
    
    %{
    This file is part of OpenCossan <https://cossan.co.uk>.
    Copyright (C) 2006-2018 COSSAN WORKING GROUP

    OpenCossan is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License or,
    (at your option) any later version.

    OpenCossan is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with OpenCossan. If not, see <http://www.gnu.org/licenses/>.
    %}
    
    properties
        % Scaling parameter for the objective function
        Scaling(1,1) double = 1;
    end
    
    methods
        function obj = ObjectiveFunction(varargin)
            %OBJECTIVEFUNCTION Can only have one single output.
            %
            % see also 
            
            if nargin == 0
                super_args = {};
            else
                [optional, super_args] = ...
                    opencossan.common.utilities.parseOptionalNameValuePairs( ...
                        "scaling",{1}, varargin{:});
            end
            
            obj@opencossan.workers.Mio(super_args{:});
            
            if nargin > 0
                obj.Scaling = optional.scaling;

                % The objective function must have a single output
                assert(length(obj.OutputNames) == 1,...
                    'openCOSSAN:optimization:ObjectiveFunction',...
                    'A single output (OutputNames) must be defined');
            end
        end

        value = evaluate(obj, varargin)
    end
end

