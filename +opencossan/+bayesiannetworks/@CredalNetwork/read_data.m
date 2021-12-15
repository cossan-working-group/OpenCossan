function [variable_states, variable_data] = read_data(filename, variable)
    %%%
    % Gets a variable's states and data from a text file or spreadsheet.
    %   States and data will be returned as strings. Missing data will be
    %   returned as "?"
    %
    %   filename: string of relative location of file to read from
    %   variable: string, variable name as it appears in the sheet
    %%%
    
    data = readcell(filename);
    
    indexes = data(1,:) == variable;
    
    if ~any(indexes)
        error('OpenCossan:CredalNetwork:VariableNotFound',...
            'Could not find variable in file.')
    end
    
    if sum(indexes) > 1
        error('OpenCossan:CredalNetwork:DuplicateVariables',...
            'Found multiple variables with the same name.')
    end
    
    variable_data = string(data(2:end, indexes));
    
    variable_data(ismissing(variable_data)) = "?";
    variable_data(variable_data == '') = "?";
    variable_data(variable_data == " ") = "?";
    
    variable_states = unique(variable_data);
    variable_states = setdiff(variable_states, "?");
end

