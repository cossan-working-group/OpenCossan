function MY = physical2cdf(Xrvs,MX)
%  PHYSICAL2CDF maps a point of the physical space to the hypercube
%  of the random variables included in the RandomVariableSet object.
%    
%  MANDATORY ARGUMENTS
%    - MX:   Matrix of realizations of RandomVariable in physical space
%
%  OUTPUT ARGUMENTS:
%    - MX:   Matrix of realizations of RandomVariable in unit hypercube
%
%
%  Example:  MY=Xrvs.physical2cdf(MX)
%

%% Check inputs
if not(size(MX,2)==Xrvs.Nrv)
    error('openCOSSAN:RandomVariableSet:physical2cdf',...
          ['Number of columns of sample matrix must be equal to the ' ...
           'number of Random Variable (' num2str(Xrvs.Nrv) ...
           ') in defined in the RandomVariableSet']);
end

% preallocate memory
MY = zeros(size(MX)); 

for irv=1:Xrvs.Nrv
    MY(:,irv) = physical2cdf(Xrvs.Xrv{irv}, MX(:,irv));                                                                                
end

end
