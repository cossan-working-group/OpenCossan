function Xobj=computeMapping(Xobj)
% This private function is used to compute the matrix mapping between physical
% space and standard normal space.

%% Compute covariance of the gmDistribution
%Rprime=R+Xobj.Mcovariance; % !!!!

%Msamples=random(Xobj.gmDistribution,Xobj.NsamplesMapping);

% Compute the covariance of the samples
%Xobj.MgmCovariance=cov(Msamples);              % empirical covariance


% MRmod = ones(Xobj.Nrv);
% Nsamples = ceil(Xobj.Ncopulasamples/ Xobj.Ncopulabatches);
% 
% % case of distribution w/out analytical formula
% for i=1:Xobj.Nrv
%     for j  = i+1:Xobj.Nrv
%         rho_s = Xobj.Mcorrelation(i,j);
%         s = 0;
%         for it=1:Xobj.Ncopulabatches
%             if abs(rho_s)>1
%                 error('openCOSSAN:GaussianRandomVariableSet:computeMapping',...
%                     'the marginals could not be computed');
%             end
%             u = copularnd('gaussian',rho_s,Nsamples);
%             gauss = norminv(u,0,1);
%             
%             x(:,1) = Xobj.Hicdf{i}(u(:,1));
%             x(:,2) = Xobj.Hicdf{i}(u(:,2));
%             
%             rho_g = corr(gauss);
%             v = rho_s/rho_g(1,2);
%             
%             rho_l = corr(x);
%             rho_l(1,2) = rho_l(1,2)*v;
%             %rho_l
%             rho_s = rho_s*Xobj.Mcorrelation(i,j)/rho_l(1,2);
%             if(abs(rho_s)<abs(Xobj.Mcorrelation(i,j)))
%                 rho_s = Xobj.Mcorrelation(i,j);
%             elseif(rho_s<-0.999)
%                 rho_s = -0.999;
%             elseif(rho_s>0.999)
%                 rho_s = 0.999;
%             end
%             s = s+rho_s;
%         end
%         MRmod(i,j) = s/(Xobj.Ncopulabatches*Xobj.Mcorrelation(i,j));
%         MRmod(j,i) = MRmod(i,j);
%     end
%     
% end

%Compute modified covariance matrix

if Xobj.gmDistribution.SharedCov
    Mcorr=corrcov(Xobj.gmDistribution.Sigma);
    [Meigvecs,Meigvals] = eig(full(Mcorr));
    Xobj.MUY = Meigvecs * sqrt(Meigvals);
else
    Xobj.MUY=zeros(Xobj.Nrv,Xobj.Nrv,Xobj.Ncomponents);
    for iloop=1:Xobj.Ncomponents
        Mcorr=corrcov(Xobj.Mcovariance(:,:,iloop));
        [Meigvecs,Meigvals] = eig(full(Mcorr));
        Xobj.MUY(:,:,iloop) = Meigvecs * sqrt(Meigvals);
    end
end

end
