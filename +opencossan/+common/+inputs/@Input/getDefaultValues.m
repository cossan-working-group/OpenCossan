function values = getDefaultValues(obj)
    %GETDEFAULTVALUES
    
    values = table();
    % Parameters
    if obj.NumberOfParameters > 0
        parameterTable = array2table([obj.Parameters.Value]);
        parameterTable.Properties.VariableNames = obj.ParameterNames;
        
        values = [values parameterTable];
    end
    
    % DesignVariables
    if obj.NumberOfDesignVariables > 0
        designVariableTable = array2table([obj.DesignVariables.Value]);
        designVariableTable.Properties.VariableNames = obj.DesignVariableNames;
    
        values = [values designVariableTable];
    end
    
    % RandomVariables
    if obj.NumberOfRandomVariables > 0
        randomVariableTable = array2table([obj.RandomVariables.Mean]);
        randomVariableTable.Properties.VariableNames = obj.RandomVariableNames;
    
        values = [values randomVariableTable]; 
    end
    
    % RandomVariableSets
    if obj.NumberOfRandomVariableSets > 0
        means = [];
        names = [];
        for rvset = obj.RandomVariableSets
            means = [means rvset.Members.Mean]; %#ok<AGROW>
            names = [names rvset.Names]; %#ok<AGROW>
        end
        randomVariableSetTable = array2table(means);
        randomVariableSetTable.Properties.VariableNames = names;
        
        values = [values randomVariableSetTable];
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
