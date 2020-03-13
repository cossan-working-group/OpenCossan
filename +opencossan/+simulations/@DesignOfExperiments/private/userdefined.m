function [samples, obj] = userdefined(obj, input)
    %USERDEFINED
    nrv = input.NumberOfRandomInputs;
    ndv = input.NumberOfDesignVariables;
    
    assert((ndv + nrv) == size(obj.Factors, 2), ...
         'OpenCossan:DesignOfExperiments:sample',...
         'Number of columns (%i) of the provided MdoeFactors should be %i', ...
         size(obj.Factors, 2), ndv + nrv)
     
    assert(all(obj.Factors <= 1, 'all') && all(obj.Factors >= -1, 'all'), ...
        'OpenCossan:DesignOfExperiments:samples', ...
        'All values of Factors must be in the interval [-1, 1].');
    
    samples = table();
    if nrv > 0
        samples = [samples obj.maprandomvariables(input, obj.Factors(:, 1:nrv))];
    end
    
    if ndv > 0
        samples = [samples obj.mapdesignvariables(input, obj.Factors(:, 1+nrv:end))];
    end
end

