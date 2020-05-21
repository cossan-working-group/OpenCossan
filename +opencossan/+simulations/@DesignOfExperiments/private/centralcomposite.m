function [samples, obj] = centralcomposite(obj, input)
    %TWOLEVELFACTORIAL
    nrv = input.NumberOfRandomInputs;
    ndv = input.NumberOfDesignVariables;
    
    assert(nrv + ndv < 26, ...
        'OpenCossan:DesignOfExperiments:sample', ...
        'For CentralComposite the dimension (Nrv + Ndv) should be between 2 and 24.');
    
    obj.Factors = ccdesign(nrv + ndv, 'center', 1, 'type', obj.CentralCompositeType);
    
    samples = table();
    if nrv > 0
        samples = [samples obj.maprandomvariables(input, obj.Factors(:, 1:nrv))];
    end
    
    if ndv > 0
        samples = [samples obj.mapdesignvariables(input, obj.Factors(:, 1+nrv:end))];
    end
end

