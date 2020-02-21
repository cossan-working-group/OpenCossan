function physical = map2physical(obj, stdnorm)
    %MAP2PHYSICAL This method maps realizations of the RandomVariables from standard normal space to
    %the
    % physical space.
    
    % Map Rvs
    physical = table();
    
    rvs = obj.RandomVariables;
    names = obj.RandomVariableNames;
    for i = 1:obj.NumberOfRandomVariables
        physical.(names(i)) = map2physical(rvs(i), stdnorm.(names(i)));
    end
    
    % Map Rvsets
    
    for set = obj.RandomVariableSets
        physical = [physical map2physical(set, stdnorm(:, set.Names))];
    end
    
end