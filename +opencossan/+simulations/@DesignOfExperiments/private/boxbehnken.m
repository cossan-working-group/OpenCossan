function [samples, obj] = boxbehnken(obj, input)
    %BOXBEHNKEN
    nrv = input.NumberOfRandomInputs;
    ndv = input.NumberOfDesignVariables;
    
    assert(nrv + ndv >= 3, ...
        'OpenCossan:DesignOfExperiments:sample', ...
        'BoxBehnken requires at least 3 inputs (DesignVariable+RandomVariables >=3).');
    
    % NOTE: the parameter center is set to 1 so that there will be only
    % one sample at the mean values, i.e. at 0,0,0,...
    obj.Factors = bbdesign(nrv + ndv, 'center', 1);
    
    samples = table();
    if nrv > 0
        samples = [samples obj.maprandomvariables(input, obj.Factors(:, 1:nrv))];
    end
    
    if ndv > 0
        samples = [samples obj.mapdesignvariables(input, obj.Factors(:, 1+nrv:end))];
    end
end

