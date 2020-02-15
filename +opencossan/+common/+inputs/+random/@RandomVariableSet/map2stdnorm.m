function MU = map2stdnorm(obj,values)
    %MAP2STDNORM maps a value from the space of the random variables included in the
    %RandomVariableSet object to the standard normal space
    %
    %  MANDATORY ARGUMENTS
    %    - obj:  object of RandomVariableSet - MX:   Matrix of samples of RV in Physical Space (n.
    %    simulation, n. RV)
    %
    %  OUTPUT ARGUMENTS:
    %    - MU:   Matrix of samples of RV in SNS (n. simulation, n. RV)
    %
    %  EXAMPLE: MU = MAP2STDNORM(obj,'MX',MX)
    %
    %  See also: RandomVariableSet
    
    if istable(values)
        MX = values{:,:};
    else
        MX = values;
    end
    
    if size(MX,2) == length(obj.Names)
        Mx = MX;
    elseif size(MX,1) == length(obj.Names)
        Mx = transpose(MX);
    else
        error('openCOSSAN:Input:map2standnorm', ...
            'Number of columns must be equal to the total number of rv''s in Input object');
    end
    
    
    Nvar = length(obj.Names);
    Nsim = size(Mx,1);
    
    % preallocate memory
    MY = zeros(Nsim,Nvar); %MY - matrix of rv's in stand. normal space, but correlated
    
    % apply method map2stdnorm to rv (not rvset!) hence correlations are not taken care of
    
    for i = 1:Nvar
        MY(:,i) = map2stdnorm(obj.Members(i), Mx(:,i));
    end
    
    if ~obj.isIndependent()
        MU  = transpose(obj.NatafModel.MYU * MY'); %transform MY to uncorrelated standard normal rv's w/ MYU
    else
        MU  = MY;
    end
    
    % return the matrix in the original order
    if size(MU,2) ==  size(Mx,1)
        MU  = transpose(MU);
    end
    
    if istable(values)
        MU = array2table(MU);
        MU.Properties.VariableNames = obj.Names;
    end
    
end

