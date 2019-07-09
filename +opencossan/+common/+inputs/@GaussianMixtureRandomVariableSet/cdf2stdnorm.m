function MstandardNormalSpace = cdf2stdnorm(Xobj,Mcorrelated)
%  cdf2stdnorm maps a point of the hypercube to standard normal space
%  of the random variables included in the RandomVariableSet object.
%    
%

% The samples in the HyperCube are Correlated
% error('openCOSSAN:GaussianRandomVariableSet:cdf2stdnorm',...
%      ['GaussianRandomVariableSet does not support the mapping in the standard normal space.' ...
%      '\nIt is not possible to use a linear transformation.'])
 
if not(size(Mcorrelated,2)==Xobj.Nrv)
    error('openCOSSAN:GaussianRandomVariableSet:cdf2stdnorm',...
        'Number of columns of Mcorrelated (%d) must be equal to # of rv''s (%d)',...
        size(Mcorrelated,2),Xobj.Nrv);
end

MU=Mcorrelated;
MstandardNormalSpace=norminv(MU);

