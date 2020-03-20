function [median, skewness, curtosis] = getStatistics(obj)
    %GETSTATISTICS Retrieve median, skewness and curtosis for the random inputs contained in the
    %Input object.
    %
    % Note: Skewness and curtosis not yet implemented.
    
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
    median = table();
    
    if nargout > 1
        error('OpenCossan:Input:getStatistics', 'Skewness and curtosis not yet implemented');
    end
    
    % RandomVariables
    rvs = obj.RandomVariables;
    names = obj.RandomVariableNames;
    for i = 1:numel(rvs)
        median.(names(i)) = rvs(i).map2physical(0);
    end
    
    % RandomVariableSets
    for set = obj.RandomVariableSets
        median(:, set.Names) = num2cell(set.map2physical(zeros(1, set.Nrv)));
    end
    
end