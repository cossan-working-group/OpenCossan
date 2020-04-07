function obj = remove(obj, names)
    %REMOVE
    
    validateattributes(names, {'string'}, {'vector'});
    
    [found, loc] = ismember(names, obj.Names);
    
    assert(all(found), 'OpenCossan:RandomVariableSet:remove', ...
        'RandomVariable %s not present in the RandomVariableSet', strjoin(names, ', '));
    
    obj.Members(loc) = [];
    obj.Names(loc) = [];
    
    % Remove correlation in temporary variable because the matrix in the rvset has to be square at
    % all times
    tmp = obj.Correlation;
    tmp(:, loc) = [];
    tmp(loc, :) = [];
    
    obj.Correlation = tmp;
    
    % Update NatafModel for new correlation
    obj.NatafModel = opencossan.common.inputs.random.NatafModel(obj);
end