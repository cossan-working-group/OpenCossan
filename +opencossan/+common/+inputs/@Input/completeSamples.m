function samples = completeSamples(obj, samples)
    %COMPLETESAMPLES This method takes a table containing samples and adds the missing variables
    %from the input object to prepare the samples for an analysis.
    
    rows = height(samples); % Number of samples
    variables = samples.Properties.VariableNames; % Already present in the samples
    
    %% Add Parameters
    parameters = obj.Parameters;
    names = obj.ParameterNames;
    for i = 1:numel(parameters)
        if ~ismember(names(i), variables)
            samples.(names(i)) = repmat(parameters(i).Value, rows, 1);
        end
    end
    
    %% Add RandomVariables
    rvs = obj.RandomVariables;
    names = obj.RandomVariableNames;
    for i = 1:numel(rvs)
        if ~ismember(variables, names(i))
            samples.(names(i)) = sample(rvs(i), rows);
        end
    end
    
    %% Add RandomVariableSets
    for set = obj.RandomVariableSets
        if any(ismember(set.Names, variables)) && ~all(ismember(set.Names, variables))
            warning('Partial random variable set already present. Ignoring.');
        end
        
        if ~any(ismember(set.Names, variables))
            samples = [samples sample(set, rows)];  %#ok<AGROW>
        end
    end
    
    %% Evaluate Functions
    functions = obj.Functions;
    names = obj.FunctionNames;
    for i = 1:numel(functions)
        if ~ismember(names(i), variables)
            samples.(names(i)) = evaluate(functions(i), samples);
        end
    end
    
end

