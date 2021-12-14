function [variable_states, variable_data] = get_data_xcell(sheetname, variable)
    %%%
    % Gets a variable's states and data from an XCELL spread sheet.
    %   States and data will be returned as strings. Missing data will be returned as "?"
    %
    %   - Sheetname: string of relative location of spreadsheet
    %   - variable: string, variable name as it appears in the sheet
    %%%

    [nums, strs, raw_data] = xlsread(sheetname);
    
    vars = strs(1,:);
    
    indexes = vars == variable;

    if all(~indexes)
         error('Error. \n Could not find variable in xcell sheet')
    end

    if sum(indexes) > 1
         error('Error. \n Found multiple variables with same name')
    end
    
    variable_data = string(raw_data(2:end, indexes));
    
    for i = 1:length(variable_data)

        if isempty(variable_data{i})
            variable_data{i} = '?';
        end

        if variable_data{i} == " "
            variable_data{i} = '?';
        end
    end
    
    variable_states = unique(variable_data);
    variable_states = setdiff(variable_states, "?");

end

