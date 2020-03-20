function values = getDefaultValues(obj)
    %GETDEFAULTVALUES
    
    values = table();
    % Parameters
    if obj.NumberOfParameters > 0
        values(:, obj.ParameterNames) = {obj.Parameters.Value};
    end
    
    % DesignVariables
    if obj.NumberOfDesignVariables > 0
        values(:, obj.DesignVariableNames) = {obj.DesignVariables.Value};
    end
    
    % RandomVariables
    if obj.NumberOfRandomVariables > 0
        values(:, obj.RandomVariableNames) = {obj.RandomVariables.Mean};
    end
    
    % RandomVariableSets
    if obj.NumberOfRandomVariableSets > 0
        for set = obj.RandomVariableSets
            values(:, set.Names) = {set.Members.Mean};
        end
    end
    
    % Functions
    if obj.NumberOfFunctions > 0
        functions = obj.Functions;
        names = obj.FunctionNames;
        for i = 1:obj.NumberOfFunctions
            values.(names(i)) = functions(i).evaluate(values);
        end
    end
end
