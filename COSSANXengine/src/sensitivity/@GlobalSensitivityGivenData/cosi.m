function [Si,V]=cosi(x,y,M,gfx)
%% COSI Calculation of sensitivity indices from given data.
%     SI = COSI(X,Y) returns the sensitivity indices for input arguments X 
%     and output arguments Y (per line) based upon a discrete cosine 
%     transformation.
%     SI = COSI(X,Y,M) specifies the max. harmonic cutoff.
%     SI = COSI(X,Y,M,'Gfx Title') provides a figure.
%     [Vi,V]=COSI(X,Y,M) with M<0 returns absolute contributions

%     References: 
%      E. Plischke, "An Effective Algorithm for Computing 
%       Global Sensitivity Indices (EASI)",
%       Reliability Engineering & Systems Safety, 95(4), 354-360, 2010
%      E. Plischke, "How to compute variance-based sensitivity 
%       indicators with your spreadsheet software", 
%       Environmental Modelling & Software, In Press, 2012

%%
%     Written by Elmar Plischke, elmar.plischke@tu-clausthal.de
 [n,k]=size(x);
 [nn,kk]=size(y);
 if nn~=n, error('Input/output sizes mismatch!'), end

 [xr,index]=sort(x);
 if kk==1
% sort output
    yr=y(index);
 else
    yr=zeros(n,k*kk);
    for i=1:kk
        z=y(:,i);
        yr(:,(i-1)*k+(1:k))=z(index);
    end
 end
 
 %% frequency selection
if (nargin==2) || (isempty(M))
  M=max(ceil(sqrt(n)),3);
 fprintf('COSI: Using %d coefficients.\n',M);
end 

if(M<0), M=-M; unscaled=1; else unscaled=0; end
% consider M terms
d=zeros(1,n);
d(1+(1:M))=1;

%% Compute transformation
allcoeff=dct(yr);

% transformation is orthogonal, so by Parseval's Theorem
V = sum(allcoeff(2:end,:).^2);
if(M==0)
% estimate approximation error
% or mean
Si=1-median(n*cumsum(allcoeff(end:-1:2,:).^2)./ ((1:(n-1))'*V));
else
Vi= sum(allcoeff(1+(1:M),:).^2);
if(~unscaled)
Si= Vi./V;
else
Si=Vi/(n-1);
V=V/(n-1);
end
end
%% 
if nargin==4

 for i=1:k
  if(k>1), subplot(floor(k/2+.5),2,i); end
  yhat=zeros(n,1);
  yhat(1:(M+1))=allcoeff(1:(M+1),i);
  plot(x(index(:,i),i),y(index(:,i)),'.',x(index(:,i),i),idct(yhat),'-','LineWidth',2);
  xlabel(['x_{',num2str(i),'}']);ylabel('y');
  title(gfx);
 end
end
%%%
 if kk>1, Si=reshape(Si',k,kk)'; V=reshape(V',k,kk);end
 return
