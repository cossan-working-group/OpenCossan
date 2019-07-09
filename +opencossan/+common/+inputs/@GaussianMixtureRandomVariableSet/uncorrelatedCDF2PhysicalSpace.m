function Mphysical = uncorrelatedCDF2PhysicalSpace(Xobj,MuncorrelatedCDF)
%uncorrelatedSamples2PhysicalSpace  maps samples generated from quasi Monte
%Carlo methods to the physical space
%
%  MANDATORY ARGUMENTS
%    - MuncorrelatedCDF:   Matrix of samples in hypercube (# samples,# of RVs + 1)
%
%  OUTPUT ARGUMENTS:
%    - Mphysical:   Matrix of samples of RV in the Physical Space (# samples, # of RV)
%
%  Usage: Mphysical = Xobj.physical2cdf(MS) 
%  

if size(MuncorrelatedCDF,2)~=Xobj.Nrv+1
     error('openCOSSAN:GaussianRandomVariableSet:uncorrelatedSamples2PhysicalSpace',...
    'Number of columns of MstandardNormalSpace must be equal to # of RandomVariables +1');
end


Msamples=norminv(MuncorrelatedCDF(:,1:Xobj.Nrv)); % Samples in SNS
Mcdf=MuncorrelatedCDF(:,end); 
Mphysical=zeros(size(Msamples));

if Xobj.gmDistribution.SharedCov
        Vsigma=sqrt(diag(Xobj.gmDistribution.Sigma)); 
        Mcorrelated = transpose(Xobj.MUY * Msamples');
        nlevel=0;
        for n=1:Xobj.Ncomponents
            nlevel=nlevel+Xobj.gmDistribution.PComponents(n);
            Vindex= Mcdf<nlevel;
            Mcdf(Vindex)=Inf;
            Nel=sum(Vindex);
            Mphysical(Vindex,:)=Mcorrelated(Vindex,:).*repmat(Vsigma,1,Nel)'...
                +repmat(Xobj.gmDistribution.mu(n,:),Nel,1);
        end
else
        nlevel=0;
        for n=1:Xobj.Ncomponents
            % Update level 
            nlevel=nlevel+Xobj.gmDistribution.PComponents(n);
            % Identify samples of the current gaussan distrubution
            Vindex= Mcdf<nlevel;
            Mcdf(Vindex)=Inf;
            Nel=sum(Vindex);
            
            % Correlate samples
            Mcorrelated=transpose(Xobj.MUY(:,:,n) * Msamples(Vindex,:)');
            % Retrieve standard deviations
            Vsigma=sqrt(diag(Xobj.gmDistribution.Sigma(:,:,n))); 
            % Map samples in the physical space            
            Mphysical(Vindex,:)=Mcorrelated.*repmat(Vsigma,1,Nel)'...
                +repmat(Xobj.gmDistribution.mu(n,:),Nel,1);
        end
    end
end

