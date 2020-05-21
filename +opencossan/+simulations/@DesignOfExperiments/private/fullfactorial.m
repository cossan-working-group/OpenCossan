function [samples, obj] = fullfactorial(obj, input)
    %TWOLEVELFACTORIAL
    nrv = input.NumberOfRandomInputs;
    ndv = input.NumberOfDesignVariables;
    
    
    if ndv > 0
        assert(~isempty(obj.LevelValues), 'OpenCossan:DesignOfExperiments:sample', ...
            ['If FullFactorial is used together with continous DesignVariables\n.', ...
            'LevelValues should be provided for each continous DesignVariable']);
    end
    
    levels = 3 * ones(nrv + ndv, 1);
    continuous = 1;
    for idv = 1:ndv
        dv = input.DesignVariables(idv);
        if isa(dv, 'opencossan.optimization.ContinuousDesignVariable')
            levels(nrv + idv) = obj.LevelValues(continuous);
            continuous = continuous + 1;
        else
            levels(nrv + idv) = length(dv.Support);
        end
    end
    
    obj.Factors = fullfact(levels);
    
    % NOTE: FullFactorial must map the rv coordinates from 1,level => 0,1
    for irv = 1:nrv
        obj.Factors(:, irv) = (obj.Factors(:,irv) - 1) / max(obj.Factors(:, irv) - 1);
    end
    
    samples = table();
    if nrv > 0
        samples = [samples obj.maprandomvariables(input, obj.Factors(:, 1:nrv))];
    end
    
    % This mapping is done differently for the FULLFACTORIAL design and
    % for the remaining desing types, mainly because fullfactorial creates
    % coordinates based on defined no of levels (i.e. includes positive integer
    % values such as 1,2,3,...), while the other design types generated
    % coordinates between [-1,1].
    if ndv > 0
        dvSamples = zeros(size(obj.Factors, 1), ndv);
        for idv = 1:ndv
            dv = input.DesignVariables(idv);
            if isa(dv, 'opencossan.optimization.ContinuousDesignVariable')
                dummy = linspace(dv.LowerBound, dv.UpperBound, levels(nrv + idv));
                dvSamples(:, idv) = dummy(obj.Factors(:, nrv + idv));
            else
                dvSamples(:,idv) = dv.Support(obj.Factors(:,nrv + idv));
            end
        end
        dvSamples = array2table(dvSamples);
        dvSamples.Properties.VariableNames = input.DesignVariableNames;
        
        samples = [samples dvSamples];
    end
end
