classdef ObjectiveFunction < opencossan.workers.MatlabWorker
    %OBJECTIVEFUNCTION Defines an objective function for use in
    %optimization problems.
    %
    % See also: Worker Optimization
    
    %{
    This file is part of OpenCossan <https://cossan.co.uk>.
    Copyright (C) 2006-2030 COSSAN WORKING GROUP

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
    
    methods
        function obj = ObjectiveFunction(varargin)
            %OBJECTIVEFUNCTION Can only have one single output.
            %
            % see also 
            
            obj@opencossan.workers.MatlabWorker(varargin{:});
            
            if nargin > 0
                % The objective function must have a single output
                assert(length(obj.OutputNames) == 1,...
                    'OpenCossan:optimization:ObjectiveFunction',...
                    'A single output (OutputNames) must be defined');
            end
        end

        value = evaluate(obj, varargin)
    end
end

