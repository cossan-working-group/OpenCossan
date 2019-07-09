function MY = physical2cdf(obj,MX)
%  PHYSICAL2CDF maps a point of the physical space to the hypercube
%  of the random variables included in the RandomVariableSet object.
%    
%  MANDATORY ARGUMENTS
%    - obj:  object of RandomVariableSet
%    - MX:   Matrix of realizations of RandomVariable in physical space
%
%  OUTPUT ARGUMENTS:
%    - MY:   Matrix of realizations of RandomVariable in unit hypercube
%
%
%  Example:  MY = obj.physical2cdf(MX)
%

%% Check inputs
assert(size(MX,2) == obj.Nrv,...
    'openCOSSAN:RandomVariableSet:physical2cdf',...
          ['Number of columns of sample matrix must be equal to the ' ...
           'number of Random Variable (' num2str(obj.Nrv) ...
           ') in defined in the RandomVariableSet'])

% preallocate memory
MY = zeros(size(MX)); 

for iRV = 1:obj.Nrv
    MY(:,iRV) = physical2cdf(obj.Members(iRV), MX(:,iRV));                                                                                
end

end
