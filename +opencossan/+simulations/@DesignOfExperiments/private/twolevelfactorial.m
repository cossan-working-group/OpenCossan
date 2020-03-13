function [samples, obj] = twolevelfactorial(obj, input)
    %TWOLEVELFACTORIAL
    nrv = input.NumberOfRandomInputs;
    ndv = input.NumberOfDesignVariables;
    
    % If TWO-LEVEL FACTORIAL is chosen, the dimension should be less than 25
    % (due to memory issues)
    % TODO: Is this still a thing?
    
    assert(nrv + ndv < 24, ...
        'OpenCossan:DesignOfExperiments:sample', ...
        'For CentralComposite the dimension (Nrv + Ndv) should be between 2 and 24.');
    
    obj.Factors = ff2n(nrv + ndv);
    
    samples = table();
    if nrv > 0
        samples = [samples obj.maprandomvariables(input, obj.Factors(:, 1:nrv))];
    end
    
    if ndv > 0
        samples = [samples obj.mapdesignvariables(input, obj.Factors(:, 1+nrv:end))];
    end
end

