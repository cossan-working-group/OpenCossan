function Xobj=computeCovarianceMatrix(Xobj)
% COMPUTECOVARIANCEMATRIX
% This method compute the convariance Matrix from the user data. It used a
% sort of PCA to reduce the space.
%% cnx_04: Gaussian Mixture Models
% hjp 20100806
%
% Implemented in COSSAN-X by Edoardo Patelli

%% Retrieve information from the object

Nsamples=size(Xobj.MdataSet,1);
Nrv=Xobj.Nrv; % store values of dependent field
%% SIMPLE CASES

hjpFactor=(1+3*(1-Xobj.alpha^(1/Nsamples)));


%% COORDINATE TRANSFORMATION
% MdataSetMean = mean(Xobj.MdataSet,1);
% MdataSetZeroMean = Xobj.MdataSet-repmat(MdataSetMean,Nsamples,1);
% 
% R = MdataSetZeroMean'*MdataSetZeroMean;

if Nsamples==1
   u_vec=eye(Nrv); 
else
    R=cov(Xobj.MdataSet);
    [u_vec, ~ ] = eig(R);
end

%VstandardDeviations = sqrt(diag(var));

r1 = Xobj.MdataSet*u_vec;

%% standard deviation by ksdensity
% Preallocate memory
MR=zeros(Nrv);
for irv=1:Nrv
    [~,~, Vbandwidth]=ksdensity(r1(:,irv));
    
    % Rescale bandwidth by the HJP factor
    MR(:,irv)=u_vec(:,irv)*Vbandwidth*hjpFactor;
end

% Covariance Matrix
Xobj.Mcovariance=MR*MR';

%Xobj.Mcovariance=MR^2;
%s = sqrt(diag(Xobj.Mcovariance)); % diag(MR)

Xobj.Mcorrelation = corrcov(Xobj.Mcovariance);

% Xobj.Mcorrelation = (diag(diag(MR))\Xobj.Mcovariance)/diag(diag(MR)); % CORRELATION coefficient

end



