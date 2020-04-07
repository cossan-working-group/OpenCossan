function [Xrvset] = natafTransformation(Xrvset)
%BUILDNATAF   applies NATAF model to the set of RVs
%  This is a private function and it can be used only by the methods of
%  rvset
%
%  MANDATORY ARGUMENTS:
%	- Xrvset rvset object
%
%
%  Example:
%			Xrv=natafTransformation(Xrv)
% =====================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2008 IfM
% =====================================================
%
%   see also: rvset, rv, xinput

Nvar=length(Xrvset.Cmembers); %number of RVs

SVdistri = repmat(' ',Nvar,1); %Vector of string with numbers indicating
%distribution; e.g. if RV2 is Uniform,
%SVdistri(2) = '3'

Nsamples = ceil(Xrvset.Ncopulasamples/ Xrvset.Ncopulabatches);

%% Collect information of the rv and rvset
Mcorr=Xrvset.Mcorrelation;
Sdist = get(Xrvset,'Cmembers','Sdistribution');
Vcov = get(Xrvset,'Cmembers','CoV');

Vdistrition=zeros(Nvar,1);

if Xrvset.LanalyticalCopula
    
    for i=1:Nvar
        switch lower(Sdist{i})
            case {'ln','lognormal'}
                Vdistrition(i)=2;
            case {'norm','normal'}
                Vdistrition(i)=1;
            case {'exp','exponential'}
                Vdistrition(i)=0;
            case {'uni','uniform'}
                Vdistrition(i)=3;
            case {'rayleigh'}
                Vdistrition(i)=5;
            case {'small-i','sml','small1'}
                Vdistrition(i)=6;
            case {'large-i','lar','gumbel-i','gumbeli'}
                Vdistrition(i)=7;
            case {'weibull'}
                Vdistrition(i)=8;
        end
    end
    
    Vidist1 = find(Vdistrition==1);  %assemble vector w/ indices of normal RV's
    Vidist2 = find(Vdistrition==2);  %assemble vector w/ indices of lognormal RV's
    Vidist3 = find(Vdistrition==3);  %assemble vector w/ indices of uniform RV's
    Vidist4 = find(Vdistrition==4);  %assemble vector w/ indices of exponential RV's
    Vidist5 = find(Vdistrition==5);  %assemble vector w/ indices of rayleigh RV's
    Vidist6 = find(Vdistrition==6);  %assemble vector w/ indices of gumbel type I smallest values RV's
    Vidist7 = find(Vdistrition==7);  %assemble vector w/ indices of gumbel type I largest values RV's
    Vidist8 = find(Vdistrition==8);  %assemble vector w/ indices of weibull
    
end

Vidist0 = find(Vdistrition==0);  %assemble vector w/ indices of any other distribution

if (abs(norm(eye(Nvar)-Mcorr))) > 1.e-8
    
    MRmod = ones(Nvar); %Matrix storing the modification factors for the correlation matrix of the Nataf model
    
    %Checking if there are any RVs with normal distribution
    if ~isempty(Vidist1)
        
        %Combination N-LN
        for i=1:length(Vidist2) %loop over all lognormal rv's
            corrmodfac = Vcov(Vidist2(i)) / sqrt(log(1+Vcov(Vidist2(i))^2));
            %the following 2 lines are only applied to combinations of Normal
            %(Vidist1) and Lognormal (Vidist2) rv's
            MRmod(Vidist1,Vidist2(i)) = corrmodfac; %assign modification factor to corresponding entry
            MRmod(Vidist2(i),Vidist1) = corrmodfac; %do the same for the transposed entry
        end
        
        %Combination N-WEI
        for i=1:length(Vidist8) %loop over all weibull rv's
            corrmodfac = 1.031 - 0.195*Vcov(Vidist8(i)) + 0.328*Vcov(Vidist8(i))^2;
            %the following 2 lines are only applied to combinations of Normal
            %(Vidist1) and weibull (Vidist8) rv's
            MRmod(Vidist1,Vidist8(i)) = corrmodfac; %assign modification factor to corresponding entry
            MRmod(Vidist8(i),Vidist1) = corrmodfac; %do the same for the transposed entry
        end
        
        %Combination N-U
        for i=1:length(Vidist3)
            corrmodfac = 1.023;
            MRmod(Vidist1,Vidist3(i)) = corrmodfac;
            MRmod(Vidist3(i),Vidist1) = corrmodfac;
        end
        
        %Combination N-EXP
        for i=1:length(Vidist4)
            corrmodfac = 1.107;
            MRmod(Vidist1,Vidist4(i)) = corrmodfac;
            MRmod(Vidist4(i),Vidist1) = corrmodfac;
        end
        
        %Combination N-RAY
        for i=1:length(Vidist5)
            corrmodfac = 1.014;
            MRmod(Vidist1,Vidist5(i)) = corrmodfac;
            MRmod(Vidist5(i),Vidist1) = corrmodfac;
        end
        
        %Combination N-SML
        for i=1:length(Vidist6)
            corrmodfac = 1.031;
            MRmod(Vidist1,Vidist6(i)) = corrmodfac;
            MRmod(Vidist6(i),Vidist1) = corrmodfac;
        end
        
        %Combination N-LAR
        for i=1:length(Vidist7)
            corrmodfac = 1.031;
            MRmod(Vidist1,Vidist7(i)) = corrmodfac;
            MRmod(Vidist7(i),Vidist1) = corrmodfac;
        end
        
    end
    
    %Combination LN-LN
    for i=1:length(Vidist2)
        for j=i+1:length(Vidist2)
            rij = Mcorr(Vidist2(i),Vidist2(j));
            if rij
                corrmodfac = log( 1+rij*Vcov(Vidist2(i))*Vcov(Vidist2(j))) / ...
                    (rij * sqrt( log(1+Vcov(Vidist2(i))^2) * log(1+Vcov(Vidist2(j))^2)));
                
                MRmod(Vidist2(i),Vidist2(j)) = corrmodfac;
                MRmod(Vidist2(j),Vidist2(i)) = corrmodfac;
            end
        end
    end
    
    %Combination U-U
    for i=1:length(Vidist3)
        for j=i+1:length(Vidist3)
            rij = Mcorr(Vidist3(i),Vidist3(j));
            corrmodfac = 1.047 - 0.047 * rij ^2;
            MRmod(Vidist3(i),Vidist3(j)) = corrmodfac;
            MRmod(Vidist3(j),Vidist3(i)) = corrmodfac;
        end
    end
    
    %Combination EXP-EXP
    for i=1:length(Vidist4)
        for j=i+1:length(Vidist4)
            rij = Mcorr(Vidist4(i),Vidist4(j));
            corrmodfac = 1.229 - 0.367 * rij + 0.153* rij ^2;
            MRmod(Vidist4(i),Vidist4(j)) = corrmodfac;
            MRmod(Vidist4(j),Vidist4(i)) = corrmodfac;
        end
    end
    
    %Combination RAY-RAY
    for i=1:length(Vidist5)
        for j=i+1:length(Vidist5)
            rij = Mcorr(Vidist5(i),Vidist5(j));
            corrmodfac = 1.028 - 0.029 * rij;
            MRmod(Vidist5(i),Vidist5(j)) = corrmodfac;
            MRmod(Vidist5(j),Vidist5(i)) = corrmodfac;
        end
    end
    
    %Combination SML-SML
    for i=1:length(Vidist6)
        for j=i+1:length(Vidist6)
            rij = Mcorr(Vidist6(i),Vidist6(j));
            corrmodfac = 1.064 - 0.069 * rij +...
                0.005 * rij^2;
            MRmod(Vidist6(i),Vidist6(j)) = corrmodfac;
            MRmod(Vidist6(j),Vidist6(i)) = corrmodfac;
        end
    end
    
    %Combination LAR-LAR
    for i=1:length(Vidist7)
        for j=i+1:length(Vidist7)
            rij = Mcorr(Vidist7(i),Vidist7(j));
            corrmodfac = 1.064 + 0.069 * rij + ...
                0.005 * rij^2;
            MRmod(Vidist7(i),Vidist7(j)) = corrmodfac;
            MRmod(Vidist7(j),Vidist7(i)) = corrmodfac;
        end
    end
    
    %Combination WEI-WEI
    for i=1:length(Vidist8)
        for j=i+1:length(Vidist8)
            rij = Mcorr(Vidist8(i),Vidist8(j));
            corrmodfac = 1.063 - 0.004*rij + 0.200* (Vcov(Vidist8(i)) + Vcov(Vidist8(j))) ...
                -0.001*rij^2 + 0.337*(Vcov(Vidist8(i))^2+Vcov(Vidist8(j))^2) ...
                +0.007*rij*(Vcov(Vidist8(i)) + Vcov(Vidist8(j))) ...
                -0.007*Vcov(Vidist8(i)) * Vcov(Vidist8(j));
            MRmod(Vidist8(i),Vidist8(j)) = corrmodfac;
            MRmod(Vidist8(j),Vidist8(i)) = corrmodfac;
        end
    end
    
    %Combination U-LN
    for i=1:length(Vidist3)
        for j=1:length(Vidist2)
            rij = Mcorr(Vidist3(i),Vidist2(j));
            corrmodfac = 1.019 + 0.010 * rij ^2 +...
                0.014 * Vcov(Vidist2(j)) + ...
                0.249 * Vcov(Vidist2(j)) ^2;
            MRmod(Vidist3(i),Vidist2(j)) = corrmodfac;
            MRmod(Vidist2(j),Vidist3(i)) = corrmodfac;
        end
    end
    
    %Combination EXP-U
    for i=1:length(Vidist4)
        for j=1:length(Vidist3)
            rij = Mcorr(Vidist4(i),Vidist3(j));
            corrmodfac = 1.133 + 0.029 * rij ^2;
            MRmod(Vidist4(i),Vidist3(j)) = corrmodfac;
            MRmod(Vidist3(j),Vidist4(i)) = corrmodfac;
        end
    end
    
    %Combination EXP-LN
    for i=1:length(Vidist4)
        for j=1:length(Vidist2)
            rij = Mcorr(Vidist4(i),Vidist2(j));
            corrmodfac = 1.098 + 0.003 * rij + ...
                0.019 * Vcov(Vidist2(j)) + ...
                0.025 * rij^2 + ...
                0.303 * Vcov(Vidist2(j)) ^2 - ...
                0.437 * Vcov(Vidist2(j)) * rij;
            MRmod(Vidist4(i),Vidist2(j)) = corrmodfac;
            MRmod(Vidist2(j),Vidist4(i)) = corrmodfac;
        end
    end
    
    %Combination EXP-RAY
    for i=1:length(Vidist4)
        for j=1:length(Vidist5)
            rij = Mcorr(Vidist4(i),Vidist5(j));
            corrmodfac = 1.123 - 0.100 * rij + 0.021* rij ^2;
            MRmod(Vidist4(i),Vidist5(j)) = corrmodfac;
            MRmod(Vidist5(j),Vidist4(i)) = corrmodfac;
        end
    end
    
    %Combination RAY-LN
    for i=1:length(Vidist5)
        for j=1:length(Vidist2)
            rij = Mcorr(Vidist5(i),Vidist2(j));
            corrmodfac = 1.011 + 0.001 * rij + ...
                0.014 * Vcov(Vidist2(j)) + ...
                0.004 * rij^2 + ...
                0.231 * Vcov(Vidist2(j))^2 - ...
                0.130 * Vcov(Vidist2(j))* rij;
            MRmod(Vidist5(i),Vidist2(j)) = corrmodfac;
            MRmod(Vidist2(j),Vidist5(i)) = corrmodfac;
        end
    end
    
    %Combination RAY-U
    for i=1:length(Vidist5)
        for j=1:length(Vidist3)
            rij = Mcorr(Vidist5(i),Vidist3(j));
            corrmodfac = 1.038 + 0.008 * rij ^2;
            MRmod(Vidist5(i),Vidist3(j)) = corrmodfac;
            MRmod(Vidist3(j),Vidist5(i)) = corrmodfac;
        end
    end
    
    %Combination SML-EXP
    for i=1:length(Vidist6)
        for j=1:length(Vidist4)
            rij = Mcorr(Vidist6(i),Vidist4(j));
            corrmodfac = 1.142 + 0.154 * rij + 0.031* rij ^2;
            MRmod(Vidist6(i),Vidist4(j)) = corrmodfac;
            MRmod(Vidist4(j),Vidist6(i)) = corrmodfac;
        end
    end
    
    %Combination SML-U
    for i=1:length(Vidist6)
        for j=1:length(Vidist3)
            rij = Mcorr(Vidist6(i),Vidist3(j));
            corrmodfac = 1.055 + 0.015* rij ^2;
            MRmod(Vidist6(i),Vidist3(j)) = corrmodfac;
            MRmod(Vidist3(j),Vidist6(i)) = corrmodfac;
        end
    end
    
    %Combination SML-LN
    for i=1:length(Vidist6)
        for j=1:length(Vidist2)
            rij = Mcorr(Vidist6(i),Vidist2(j));
            corrmodfac = 1.029 - 0.001 * rij + ...
                0.014 *Vcov(Vidist2(j))+ ...
                0.004 * rij^2 + ...
                0.233 * Vcov(Vidist2(j)) ^2 + ...
                0.197 * Vcov(Vidist2(j)) * rij;
            MRmod(Vidist6(i),Vidist2(j)) = corrmodfac;
            MRmod(Vidist2(j),Vidist6(i)) = corrmodfac;
        end
    end
    
    %Combination SML-RAY
    for i=1:length(Vidist6)
        for j=1:length(Vidist5)
            rij = Mcorr(Vidist6(i),Vidist5(j));
            corrmodfac = 1.046 + 0.045 * rij + 0.006* rij ^2;
            MRmod(Vidist6(i),Vidist5(j)) = corrmodfac;
            MRmod(Vidist5(j),Vidist6(i)) = corrmodfac;
        end
    end
    
    %Combination LARGE-I - RAY
    for i=1:length(Vidist7)
        for j=1:length(Vidist5)
            rij = Mcorr(Vidist7(i),Vidist5(j));
            corrmodfac = 1.046 - 0.045 * rij + 0.006* rij ^2;
            MRmod(Vidist7(i),Vidist5(j)) = corrmodfac;
            MRmod(Vidist5(j),Vidist7(i)) = corrmodfac;
        end
    end
    
    %Combination LARGE-I - EXP
    for i=1:length(Vidist7)
        for j=1:length(Vidist4)
            rij = Mcorr(Vidist7(i),Vidist4(j));
            corrmodfac = 1.142 - 0.154 * rij + 0.031* rij ^2;
            MRmod(Vidist7(i),Vidist4(j)) = corrmodfac;
            MRmod(Vidist4(j),Vidist7(i)) = corrmodfac;
        end
    end
    
    %Combination LARGE-I - Uniform
    for i=1:length(Vidist7)
        for j=1:length(Vidist3)
            rij = Mcorr(Vidist7(i),Vidist3(j));
            corrmodfac = 1.055 + 0.015* rij ^2;
            MRmod(Vidist7(i),Vidist3(j)) = corrmodfac;
            MRmod(Vidist3(j),Vidist7(i)) = corrmodfac;
        end
    end
    
    %Combination LARGE-I - LN
    for i=1:length(Vidist7)
        for j=1:length(Vidist2)
            rij = Mcorr(Vidist7(i),Vidist2(j));
            corrmodfac = 1.029 + 0.001 * rij +...
                0.014 * Vcov(Vidist2(j)) +...
                0.004 * rij^2 +...
                0.233 * Vcov(Vidist2(j)) ^2 - ...
                0.197 * Vcov(Vidist2(j)) * rij;
            MRmod(Vidist7(i),Vidist2(j)) = corrmodfac;
            MRmod(Vidist2(j),Vidist7(i)) = corrmodfac;
        end
    end
    
    %Combination SML-LAR
    for i=1:length(Vidist6)
        for j=1:length(Vidist7)
            rij = Mcorr(Vidist6(i),Vidist7(j));
            corrmodfac = 1.064 + 0.069 * rij + 0.005 * rij^2;
            MRmod(Vidist6(i),Vidist7(j)) = corrmodfac;
            MRmod(Vidist7(j),Vidist6(i)) = corrmodfac;
        end
    end
    
    %Combination LN-WEI
    for i=1:length(Vidist2)
        for j=1:length(Vidist8)
            rij = Mcorr(Vidist2(i),Vidist8(j));
            corrmodfac = 1.031 + 0.052*rij + 0.011*Vcov(Vidist2(i)) - 0.210*Vcov(Vidist8(j)) ...
                + 0.002*rij^2 + 0.220*Vcov(Vidist2(i))^2 + 0.350*Vcov(Vidist8(j))^2 ...
                + 0.005*rij*Vcov(Vidist2(i)) + 0.009*Vcov(Vidist2(i))*Vcov(Vidist8(j))^2 - 0.174*rij*Vcov(Vidist8(j));
            MRmod(Vidist2(i),Vidist8(j)) = corrmodfac;
            MRmod(Vidist8(j),Vidist2(i)) = corrmodfac;
        end
    end
    
    %Combination U-WEI
    for i=1:length(Vidist3)
        for j=1:length(Vidist8)
            rij = Mcorr(Vidist3(i),Vidist8(j));
            corrmodfac = 1.061 - 0.237*Vcov(Vidist8(j)) ...
                - 0.005*rij^2 + 0.379*Vcov(Vidist8(j))^2;
            MRmod(Vidist3(i),Vidist8(j)) = corrmodfac;
            MRmod(Vidist8(j),Vidist3(i)) = corrmodfac;
        end
    end
    
    %Combination EXP-WEI
    for i=1:length(Vidist4)
        for j=1:length(Vidist8)
            rij = Mcorr(Vidist4(i),Vidist8(j));
            corrmodfac = 1.147 + 0.145*rij -0.271*Vcov(Vidist8(j)) ...
                + 0.010*rij^2 +0.459*Vcov(Vidist8(j))^2 - 0.467*rij*Vcov(Vidist8(j));
            MRmod(Vidist4(i),Vidist8(j)) = corrmodfac;
            MRmod(Vidist8(j),Vidist4(i)) = corrmodfac;
        end
    end
    
    %Combination RAY-WEI
    for i=1:length(Vidist5)
        for j=1:length(Vidist8)
            rij = Mcorr(Vidist5(i),Vidist8(j));
            corrmodfac = 1.047 + 0.042*rij -.212*Vcov(Vidist8(j)) ...
                 + 0.353*Vcov(Vidist8(j))^2 -0.136*rij*Vcov(Vidist8(j));
            MRmod(Vidist5(i),Vidist8(j)) = corrmodfac;
            MRmod(Vidist8(j),Vidist5(i)) = corrmodfac;
        end
    end
    
    %Combination SML-WEI
    for i=1:length(Vidist6)
        for j=1:length(Vidist8)
            rij = Mcorr(Vidist6(i),Vidist8(j));
            corrmodfac = 1.064 + 0.065*rij -0.210*Vcov(Vidist8(j)) ...
                + 0.003*rij^2 + 0.356*Vcov(Vidist8(j))^2 - 0.211*rij*Vcov(Vidist8(j));
            MRmod(Vidist6(i),Vidist8(j)) = corrmodfac;
            MRmod(Vidist8(j),Vidist6(i)) = corrmodfac;
        end
    end
    
    %Combination LAR-WEI
    for i=1:length(Vidist7)
        for j=1:length(Vidist8)
            rij = Mcorr(Vidist7(i),Vidist8(j));
            corrmodfac = 1.064 - 0.065*rij -0.210*Vcov(Vidist8(j)) ...
                + 0.003*rij^2 + 0.356*Vcov(Vidist8(j))^2 + 0.211*rij*Vcov(Vidist8(j));
            MRmod(Vidist7(i),Vidist8(j)) = corrmodfac;
            MRmod(Vidist8(j),Vidist7(i)) = corrmodfac;
        end
    end
    
    
    % case of distribution w/out analytical formula
    for i=1:length(Vidist0)
        VidistN = [Vidist0; Vidist1; Vidist2; Vidist3; Vidist4 ;Vidist5; Vidist6; Vidist7; Vidist8];
        for j  = i+1:length(VidistN)
            
            rho_s = Xrvset.Mcorrelation(Vidist0(i),VidistN(j));
            s = 0;
            
            if ~isempty(rho_s) && sum(full(rho_s))
                
                
            
            for it=1:Xrvset.Ncopulabatches
                if abs(rho_s)>1
                    error('openCOSSAN:RandomVariableSet:natafTransformation','the margines could not be computed');
                end
                
                try
                    u = copularnd('gaussian',rho_s,Nsamples);
                catch ME
                    error('openCOSSAN:RandomVariableSet:natafTransformation','the margines could not be computed');
                end
                
                gauss = norminv(u,0,1);
                
                x(:,1) = Xrvset.Xrv{i}.cdf2physical(u(:,1));
                x(:,2) = Xrvset.Xrv{j}.cdf2physical(u(:,2));
                
                rho_g = corr(gauss);
                v = rho_s/rho_g(1,2);
                
                rho_l = corr(x);
                rho_l(1,2) = rho_l(1,2)*v;
                %rho_l
                rho_s = rho_s*Xrvset.Mcorrelation(Vidist0(i),VidistN(j))/rho_l(1,2);
                if(abs(rho_s)<abs(Xrvset.Mcorrelation(Vidist0(i),VidistN(j))))
                    rho_s = Xrvset.Mcorrelation(Vidist0(i),VidistN(j));
                elseif(rho_s<-0.999)
                    rho_s = -0.999;
                elseif(rho_s>0.999)
                    rho_s = 0.999;
                end
                s = s+rho_s;
            end
            end
            if Xrvset.Mcorrelation(i,j)
            MRmod(Vidist0(i),VidistN(j)) = s/(Xrvset.Ncopulabatches*Xrvset.Mcorrelation(i,j));
            MRmod(VidistN(j),Vidist0(i)) = s/(Xrvset.Ncopulabatches*Xrvset.Mcorrelation(i,j));
            end
        end
        
    end
    
    
    
    %Compute the modified correlation matrix of the Nataf model, by taking the
    %actual target correlation matrix and multiply each entry with the
    %modification factor (stored in MRmod)
    McorrelationNataf = Mcorr .* MRmod;
else
    McorrelationNataf = Mcorr;
end

%Compute modified covariance matrix
Vstd=get(Xrvset,'Cmembers','std');
McovarianceNataf = Vstd * Vstd' .* McorrelationNataf;

%MUY - matrix transforming rv's from uncorrelated std. norm. space (U) to
MUY = chol(McorrelationNataf,'lower');

%MYU - matrix transforming rv's from correlated std. norm. space (Y) to
%uncorrelated std. norm. space (U)
MYU =  inv(MUY);
%% Store the matricies in sparse format
Xrvset.McorrelationNataf=sparse(McorrelationNataf);
Xrvset.McovarianceNataf=sparse(McovarianceNataf );
Xrvset.MUY=sparse(MUY);
Xrvset.MYU=sparse(MYU);

