function obj = remove(obj, varargin)
    %REMOVE   Removes the Xrvset/Xparametes/Xfunction/Xrv from the object Xinput
    
    %{
    This file is part of OpenCossan <https://cossan.co.uk>.
    Copyright (C) 2006-2020 COSSAN WORKING GROUP

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
    
    required = opencossan.common.utilities.parseRequiredNameValuePairs("name", varargin{:});
    
    [found, index] = ismember(required.name, obj.Names);
    
    assert(found, 'OpenCossan:Input:remove', ...
        "Can not remove %s. Not present in the input.", required.name);
    
    obj.Members(index) = [];
    obj.Names(index) = [];
    
    if obj.DoFunctionsCheck
        obj.checkFunction();
    end
end