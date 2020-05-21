function checkFunction(obj)
    %CHECKFUNCTION This method is used to validate the Function objects
    
    %{
    This file is part of OpenCossan <https://cossan.co.uk>. Copyright (C) 2006-2018 COSSAN WORKING
    GROUP

    OpenCossan is free software: you can redistribute it and/or modify it under the terms of the GNU
    General Public License as published by the Free Software Foundation, either version 3 of the
    License or, (at your option) any later version.

    OpenCossan is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
    even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
    General Public License for more details.

    You should have received a copy of the GNU General Public License along with OpenCossan. If not,
    see <http://www.gnu.org/licenses/>.
    %}
    
    functions = obj.Functions;
    names = obj.FunctionNames;
    
    % Check that the inputs required by the functions are present
    for i = 1:numel(functions)
        [found, idx] = ismember(functions(i).Tokens, obj.InputNames);
        assert(all(found), 'OpenCossan:Input:checkFunctions', ...
            'The following inputs required by Function %s are missing: %s\n', ...
            names(i), strjoin(obj.InputNames(idx(idx > 0)), ','));
    end
    
    % Check that the functions can be called in the right order
    blacklist = containers.Map();
    for i = 1:numel(functions)
        [found, idx] = ismember(functions(i).Tokens, names);
        if any(found)
            assert(all(idx > 0) && all(idx < i), 'OpenCossan:Input:checkFunctions', ...
                'Function %s depends on the following functions later in the order: %s', ...
                names(i), strjoin(names(idx), ','));
            
            for n = names(idx)
                assert(ismember(n, blacklist(names(i))), ...
                    'OpenCossan:Input:checkFunctions', ...
                    'Circular dependency between functions %s and %s.', ...
                    names(i), n);
                blacklist(n) = [blacklist(n) names(i)];
            end
        end
    end
end
