function MphysicalSpace = map2physical(Xobj,MstandardNormalSpace)
%MAP2PHISICAL maps samples from standard normal space to physical space
%
%  MANDATORY ARGUMENTS
%    - MstandardNormalSpace:   Matrix of samples of RV in SNS (# samples, # of RV) 
%
%  OUTPUT ARGUMENTS:
%    - MphysicalSpace:   Matrix of samples in Physical Space (# samples,# of RVs)
%
%  Usage: MphysicalSpace = Xobj.map2stdnorm(MstandardNormalSpace) 
%

% error('openCOSSAN:GaussianRandomVariableSet:map2physical',...
%      ['GaussianRandomVariableSet does not support the mapping in the standard normal space.' ...
%      '\nIt is not possible to use a linear transformation.'])
 
Nsim = size(MstandardNormalSpace,1);

%Mcorrelated= transpose(Xobj.MUY * MstandardNormalSpace');
Mcorrelated=MstandardNormalSpace;
% preallocate memory
MphysicalSpace = zeros(Nsim,Xobj.Nrv); %MX - matrix of rv's in Physical Space

for j=1:Xobj.Nrv
    MphysicalSpace(:,j)=Xobj.Hicdf{j}(normcdf(Mcorrelated(:,j)));    
end
% if not(size(MstandardNormalSpace,2)==Xobj.Nrv)
%     error('openCOSSAN:GaussianRandomVariableSet:map2physical',...
%     'Number of columns of MstandardNormalSpace must be equal to # of rv''s');
% end
% 
% % add correlation



% 
% % Go to hypercube space
% MU=normcdf(Mcorrelated);
% % from hypercube 2 physical
% MphysicalSpace = Xobj.cdf2physical(MU);

