function MphysicalSpace = cdf2physical(Xobj,Mhypercube)
%  cdf2physical maps a point of the hypercube to standard normal space
%
%  Input 
%    - Mhypercube:   Matrix of samples in hypercube
%
%  Output
%    - MphysicalSpace:   Matrix of samples in physical space
%
%  Example:  MphysicalSpace=Xobj.cdf2physical(Mhypercube)


if not(size(Mhypercube,2)==Xobj.Nrv)
    error('openCOSSAN:GaussianRandomVariableSet:cdf2physical',...
        'Number of columns of Mhypercube (%d) must be equal to # of Random Variables (%d)',...
        size(Mhypercube,2),Xobj.Nrv);
end


Nsim = size(Mhypercube,1);


% preallocate memory
MphysicalSpace = zeros(Nsim,Xobj.Nrv); %MX - matrix of rv's in Physical Space

for j=1:Xobj.Nrv
    MphysicalSpace(:,j)=Xobj.Hicdf{j}(Mhypercube(:,j));    
end
