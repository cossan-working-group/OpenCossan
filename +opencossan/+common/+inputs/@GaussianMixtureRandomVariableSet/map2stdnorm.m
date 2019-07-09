function MstandardNormalSpace = map2stdnorm(Xobj,MphysicalSpace)
%MAP2STDNORM maps samples from the physical space to the standard normal space
%
%  MANDATORY ARGUMENTS
%    - MphysicalSpace:   Matrix of samples in Physical Space (# samples,# of RVs)
%
%  OUTPUT ARGUMENTS:
%    - MstandardNormalSpace:   Matrix of samples of RV in SNS (# samples, # of RV)
%
%  Usage: MstandardNormalSpace = Xobj.map2stdnorm(MphysicalSpace) 
%

% error('openCOSSAN:GaussianRandomVariableSet:map2stdnorm',...
%      ['GaussianRandomVariableSet does not support the mapping in the standard normal space.' ...
%      '\nIt is not possible to use a linear transformation.'])
 
Nsim = size(MphysicalSpace,1);


Mcorrelated = zeros(Nsim,Xobj.Nrv); %MUU - Uncorrelated Hypercube

for j=1:Xobj.Nrv
    Mcorrelated(:,j)=norminv(Xobj.Hcdf{j}(MphysicalSpace(:,j)));    
end
% if not(size(MphysicalSpace,2)==Xobj.Nrv)
%     error('openCOSSAN:GaussianRandomVariableSet:map2physical',...
%     'Number of columns of MphysicalSpace must be equal to # of rv''s');
% end
% 
% %% Transform the uncorrelated hypercube to SNS
% 
% % Go to hypercube
% Mcorrelated = Xobj.physical2cdf(MphysicalSpace);
% 
% % Remove correlation
%MstandardNormalSpace = transpose(Xobj.MYU *Mcorrelated');
MstandardNormalSpace = Mcorrelated;
% 
% MstandardNormalSpace=norminv(MU);
