function MX = cdf2physical(obj,values)
    %  cdf2physical maps a point of the hypercube to standard normal space of the random variables
    %  included in the RandomVariableSet object.
    %
    %
    %  MANDATORY ARGUMENTS
    %    - MU:   Matrix of samples of RV in hypercube
    %
    %  OUTPUT ARGUMENTS:
    %    - MX:   Matrix of samples of RV in physical space
    %
    %
    %  Example:  MX = cdf2physical(rvs,MU)
    %
    %  See also: RandomVariableSet
    
    if istable(values)
        MU = values{:,:};
    else
        MU = values;
    end
    
    if not(size(MU,2) == obj.Nrv)
        error('openCOSSAN:RVSET:map2physical', ...
            ['Number of columns (' num2str(size(MU,2))  ...
            ') of the Matrix of samples must be equal to # of rv''s in rvset ( ' ...
            num2str(obj.Nrv) ')']);
    end
    
    MX = zeros(size(MU));
    
    for iRV = 1:size(MU,2)
        MX(:,iRV) = obj.Members(iRV).cdf2physical(MU(:,iRV) );
    end
    
    if istable(values)
        MX = array2table(MX);
        MX.Properties.VariableNames = obj.Names;
    end
end

