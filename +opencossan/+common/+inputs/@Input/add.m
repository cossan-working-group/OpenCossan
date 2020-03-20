function obj = add(obj,varargin)
    %ADD This method add an object to the Input object.
    %
    % To add an object into input, the user must pass to the add method an
    % object and a name in pair/value.
    %
    %  - MEMBER: object to be passed
    %  - NAME: name of the input inside OpenCossan
    %
    % Example:
    %
    %   Xinput = Xinput.add('Member',Parameter('value1'),'Name','Par1')
    
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
    
    required = opencossan.common.utilities.parseRequiredNameValuePairs(["member", "name"], varargin{:});
    
    assert(~ismember(required.name, obj.Names), 'OpenCossan:Input:add', ...
        "A member with the name %s is already present in the input.", required.name);
    
    obj.Members{end+1} = required.member;
    obj.Names(end+1) = required.name;
    
    if obj.DoFunctionsCheck
        obj.checkFunction();
    end
end
