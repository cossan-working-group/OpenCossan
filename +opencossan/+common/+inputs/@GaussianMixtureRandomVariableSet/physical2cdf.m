function Mhypercube = physical2cdf(Xobj,MphysicalSpace)
%physical2cdf maps samples from the physical space to the Hypercube
%(correlated)
%
%  MANDATORY ARGUMENTS
%    - MphysicalSpace:   Matrix of samples in Physical Space (# samples,# of RVs)
%
%  OUTPUT ARGUMENTS:
%    - Mhypercube:   Matrix of samples of RV in the Hypercube (# samples, # of RV)
%
%  Usage: Mhypercube = Xobj.physical2cdf(MphysicalSpace) 
%

assert(size(MphysicalSpace,2)==Xobj.Nrv, ...
    'openCOSSAN:GaussianRandomVariableSet:physical2cdf',...
    'Number of columns of MphysicalSpace must be equal to # of RandomVariables');


Nsim = size(MphysicalSpace,1);


Mhypercube = zeros(Nsim,Xobj.Nrv); %MUU - Uncorrelated Hypercube

for j=1:Xobj.Nrv
    Mhypercube(:,j)=Xobj.Hcdf{j}(MphysicalSpace(:,j));    
end
