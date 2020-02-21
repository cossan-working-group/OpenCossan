function stdnorm = map2stdnorm(obj, physical)
    %map2stdnorm
    %  This method maps a values of the RandomVariable(s) of an Input object from physical space to
    %  the standard normal space.
    %
    %  Arguments:
    %                       MX:   Matrix of samples of RV in Physical Space (n. simulation, n. RV)
    %  Example: MU=Xin.map2stdnorm(MX)
    
    % Map RVs
    
    stdnorm = table();
    
    rvs = obj.RandomVariables;
    names = obj.RandomVariableNames;
    for i = 1:obj.NumberOfRandomVariables
        stdnorm.(names(i)) = map2stdnorm(rvs(i), physical.(names(i)));
    end
    
    % TODO: map random variable sets
    
    % temporary fix, I think it is better to use Samples...
    %     maxSNSvalue = norminv(1-0.5*eps(1)); stdnorm(stdnorm>maxSNSvalue) = maxSNSvalue;
    %     stdnorm(stdnorm<-maxSNSvalue) = -maxSNSvalue;
    
end
