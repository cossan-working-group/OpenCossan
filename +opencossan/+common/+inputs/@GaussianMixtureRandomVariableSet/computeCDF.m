function Xobj=computeCDF(Xobj)
% This private function is used to compute the CDF of UNCORRELATED samples


% Compute experimental correlation
Msamples=Xobj.generatePhysicalSamples(Xobj.NsamplesMapping);
Xobj.Mcorrelation = corr(Msamples); 
Xobj.Vsigma=std(Msamples);
Mcov = cov(Msamples);
Vvar=diag(Mcov);
% Preallocate Memory
Xobj.Mcdfs=zeros(Xobj.NsamplesMapping+1,Xobj.Nrv); % CDF of the uncorrelated  data
Xobj.McdfsValues=zeros(size(Xobj.Mcdfs)); 


for j=1:size(Xobj.MdataSet,2) % loop over the variables
    [Xobj.McdfsValues(:,j) Xobj.Mcdfs(:,j)]=ecdf(Msamples(:,j));
    Xobj.Mcdfs(1,j)=min(Msamples(:,j))-10*Vvar(j);
    Xobj.Hcdf{j} = @(y)interp1(Xobj.Mcdfs(:,j),Xobj.McdfsValues(:,j),y,'linear');
    Xobj.Hicdf{j} = @(y)interp1(Xobj.McdfsValues(:,j),Xobj.Mcdfs(:,j),y,'linear');
end

return

% Preallocate Memory
Xobj.Mcdfs=zeros(Xobj.NcdfPoints,Xobj.Nrv); % CDF of the uncorrelated  data
Xobj.McdfsValues=zeros(size(Xobj.Mcdfs));   % Values of the CDFs of the uncorrelated data

% VYmin=min(Xobj.MYuncorrelatedDataSet,[],1);
% VYmax=max(Xobj.MYuncorrelatedDataSet,[],1);

VYmin=min(Xobj.MdataSet,[],1);
VYmax=max(Xobj.MdataSet,[],1);

if Xobj.gmDistribution.SharedCov
    Vsigma=sqrt(diag(Xobj.gmDistribution.Sigma));
    Msigma=repmat(Vsigma,1,Xobj.Ncomponents);
else
    Msigma=zeros(Xobj.Nrv,Xobj.Ncomponents);
    for icmp=1:Xobj.Ncomponents
        Msigma(:,icmp)=sqrt(diag(Xobj.gmDistribution.Sigma(:,:,icmp)));        
    end
    Vsigma=max(Msigma,[],2);
end


for j=1:size(Xobj.MdataSet,2) % loop over the variables
    % Compute the point where the cdf is computed
    
    Xobj.Mcdfs(:,j) = [VYmin(j)-10*Vsigma(j) ...
                      linspace(VYmin(j)-4*Vsigma(j),VYmax(j)+4*Vsigma(j),Xobj.NcdfPoints-2) ...
                      VYmax(j)+10*Vsigma(j)];
    
    for k=1:Xobj.NcdfPoints % loop over the points
        for icmp=1:Xobj.Ncomponents % loop over the gaussian distribution
%             Xobj.McdfsValues(k,j)=Xobj.McdfsValues(k,j)+ ...
%                     Xobj.gmDistribution.PComponents(icmp)* ...
%                     normcdf(Xobj.Mcdfs(k,j),Xobj.MYuncorrelatedDataSet(icmp,j),1);
                
            Xobj.McdfsValues(k,j)=Xobj.McdfsValues(k,j)+ ...
                    Xobj.gmDistribution.PComponents(icmp)* ...
                    normcdf(Xobj.Mcdfs(k,j),Xobj.gmDistribution.mu(icmp,j),Msigma(j,icmp));   
                
                
            %         if Msorted(k,j)<Xobj.MYsortedDataSet(k,j)
            %             U=U+normcdf(Vx(j),Xobj.MYsortedDataSet(k,j),Xobj.VsigmaYspace(j))
            %         else
            %             break
            %         end
        end
    end
    
   % Xobj.McdfsValues(end,j)=1;
    
    %% Peacewise linear interpolation
    % This piecewise linear function provides a nonparametric estimate of the CDF
    % that is continuous and symmetric.  Evaluating it at points other than the
    % original data is just a matter of linear interpolation, and it can be
    % convenient to define an anonymous function to do that.
    Xobj.Hcdf{j} = @(y)interp1(Xobj.Mcdfs(:,j),Xobj.McdfsValues(:,j),y,'linear');
    Xobj.Hicdf{j} = @(y)interp1(Xobj.McdfsValues(:,j),Xobj.Mcdfs(:,j),y,'linear');
end


