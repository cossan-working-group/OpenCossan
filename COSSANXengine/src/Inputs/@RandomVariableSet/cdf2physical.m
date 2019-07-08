function MX = cdf2physical(Xrvs,MU)
%  cdf2physical maps a point of the hypercube to standard normal space
%  of the random variables included in the RandomVariableSet object.
%    
%
%  MANDATORY ARGUMENTS
%    - MU:   Matrix of samples of RV in hypercube
%
%  OUTPUT ARGUMENTS:
%    - MS:   Matrix of samples of RV in physical space
%
%
%  Example:  MX=cdf2physical(Xrvs,MU)
%
%  See also: RandomVariableSet


if not(size(MU,2)==Xrvs.Nrv)
    error('openCOSSAN:RVSET:map2physical', ...
          ['Number of columns (' num2str(size(MU,2))  ...
          ') of the Matrix of samples must be equal to # of rv''s in rvset ( ' ...
          num2str(Xrvs.Nrv) ')']);
end

MX = zeros(size(MU));

for iRV =1:size(MU,2)
    MX(:,iRV) = Xrvs.Xrv{iRV}.cdf2physical(MU(:,iRV) );
end

