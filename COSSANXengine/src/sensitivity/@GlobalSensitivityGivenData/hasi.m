function Si=hasi(x,y,M,gfx)
%% HASI Calculation of sensitivity indices from given data.
%     SI = HASI(X,Y) returns the sensitivity indices for input arguments X 
%     and output arguments Y (per line) based upon a Hadamard transformation.
%	  Note that the length of X and Y should be a power of 2.
%%
%     Written by Elmar Plischke, elmar.plischke@tu-clausthal.de


 [n,k]=size(x);
 [nn,kk]=size(y);
 if nn~=n, error('Input/output sizes mismatch!'), end

 s=floor(log2(n)); n2=2^s;
 if n2~=n, 
	disp('Length is not a power of 2, ignoring excess elements.'), 
	x((n2+1):n,:)=[];
    if(kk==1)
     y((n2+1):n)=[];
    else
     y((n2+1):n,:)=[];
    end
    n=n2;
 end

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
 M=min(s-4,7); % 1/2^7 < 1%
 fprintf('HASI: Using 2^%d coefficients.\n',M);
end 
% consider 2^M terms
d=zeros(1,n);
d(1+n/(2^M)*(0:(2^M-1)))=1;

%% Construct Walsh-Hadamard trafo. 
%% This should be done by a "fast" algorithm
% H=1;
% for(i=1:s); H=[H,H;H,-H]; end
%% Compute model prediction
%coeff=diag(d)*H*yr;
allcoeff=wht(yr);
%coeff=diag(d)*allcoeff;
%if kk==1
% EY=coeff(1)/n2;
% else
% EY=ones(n2,1)*coeff(1,:)/n2;
%end
%yhat=1/n2*H*coeff;
%yhat=1/n2*wht(coeff);  
%Si=  sum( (yhat -EY).*(yr-EY))./ sum( (y-EY).*(y-EY));
% transformation is orthogonal, so by Parseval's Therorem
V = sum(allcoeff(2:end,:).^2);
Vi= sum(allcoeff(1+n/(2^M)*(1:(2^M-1)),:).^2);
Si= Vi./V;
%% 
if nargin==4
% % Z=abs(H*yr);
% see also wasi
% Z=abs(allcoeff); 
% Z=64*(Z/(max(max(Z))));
% subplot(1,1,1);
% image(0:(k+1), 1:n,[d'*64,Z,d'*64]);colorbar;
% title(gfx);
% xlabel('Permuted output');ylabel('Hadamard coefficients');
% pause;
% if(gcf<2), figure, end
 for i=1:k
  subplot(floor(k/2+.5),2,i);
  yhat=zeros(n,1);
  yhat(1+n/(2^M)*(0:(2^M-1)))=allcoeff(1+n/(2^M)*(0:(2^M-1)),i);
  plot(x(index(:,i),i),y(index(:,i)),'.',x(index(:,i),i),wht(yhat)/n,'-','LineWidth',2);
  xlabel(['x_{',num2str(i),'}']);ylabel('y');
  title(gfx);
 end
% h=text(k+.75,n/2+10,'Selected Coefficients','Rotation',90);
% bw=(63:-1:0)'*[1,1,1]/64;
% colormap(bw)
% colormap(hot)
end
%%%
 if kk>1, Si=reshape(Si',k,kk)'; end
 return
