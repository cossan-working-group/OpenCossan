function Mhypercube = stdnorm2cdf(Xobj,MstandardNormalSpace)
%stdnorm2cdf maps samples from the standard normal space to the Hypercube
%(correlated)
%
%  MANDATORY ARGUMENTS
%    - MS:   Matrix of samples in Standard Normal Space (# samples,# of RVs)
%
%  OUTPUT ARGUMENTS:
%    - MU:   Matrix of samples of RV in the Hypercube (# samples, # of RV)
%
%  Usage: MU = Xobj.physical2cdf(MS) 
%  
if ~size(MstandardNormalSpace,2)==Xobj.Nrv
   error('openCOSSAN:GaussianRandomVariableSet:stdnorm2cdf',...
    'Number of columns of MstandardNormalSpace must be equal to # of RandomVariables ');
end

% The samples in the standard normal space ARE correlated
Mhypercube=normcdf(MstandardNormalSpace);

