function Si=wasi(x,y,M,gfx)
%% WASI Calculation of sensitivity indices from given data.
%     SI = WASI(X,Y) returns the sensitivity indices for input arguments X 
%     and output arguments Y (per line) based upon a truncated Haar wavelet
%	  transformation.
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
end 

d=zeros(1,n);

%% Haar wavelet trafo. 
allcoeff=wavetrafo(yr);
% transformation is orthogonal, so by Parseval's Theorem
V = sum(allcoeff(2:end,:).^2);
if(M>0)
Vi= sum(allcoeff(1+1:(2^M),:).^2);
else
% different selection scheme: use only the largest contributors
if (M==0), thres=0.2; else thres=-M/100; end
 Vi=zeros(size(V));
 for( i=1:(k*kk) )
  coeff=allcoeff(2:end,i).^2;
  Vi(i)=sum(coeff(find(coeff>thres*V(i))));
 end
end
Si= Vi./V;
%% 
if nargin==4
% Z=abs(H*yr);
 Z=abs(allcoeff); 
 Z=64*(Z/(max(max(Z))));
 subplot(1,1,1);
 d=zeros(1,n);d(1:(1+2^M))=1;
 image(0:(k+1), 1:n,[d'*64,Z,d'*64]);colorbar;
 title(gfx);
 xlabel('Permuted output');ylabel('Haar coefficients');
% h=text(k+.75,n/2+10,'Selected Coefficients','Rotation',90);
% bw=(63:-1:0)'*[1,1,1]/64;
% colormap(bw)
% colormap(hot)
end
%%%
 if kk>1, Si=reshape(Si',k,kk)'; end
 return
