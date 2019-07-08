function Si=easi(x,y,M,gfx)
%% EASI Calculation of sensitivity indices from given data
%
%     SI = EASI(X,Y) returns the sensitivity indices for input arguments X 
%     and output arguments Y (per line).
%
%%
%     Written by Elmar Plischke, elmar.plischke@tu-clausthal.de
 if (nargin==2) || (isempty(M))
  M=6;     % max. higher harmonic ( sum (-1)^k sin((2k+1)x)/ (2k+1)^2 )
 end
 [n,k]=size(x);
 [nn,kk]=size(y);
 if nn~=n, error('Input/output sizes mismatch!'), end

 [xr,index]=sort(x);
%%
 if mod(n,2)==0
% even no. of samples
    shuffle=[1:2:(n-1), n:-2:2];
 else
% odd no. of samples
    shuffle=[1:2:n, (n-1):-2:2];
 end
%% create quasi-periodic input of period 1
 indexqper=index(shuffle,:);

 if kk==1
% sort output
    yr=y(indexqper);
 else
    yr=zeros(n,k*kk);
    for i=1:kk
        z=y(:,i);
        yr(:,(i-1)*k+(1:k))=z(indexqper);
    end
 end
 %% look for resonances in the output
 F=fft(yr); % Save for use in gfx output
 spectrum=(abs(F)).^2/n;
 Vi=2*sum(spectrum(2:M+1,:));  
 V=sum(spectrum(2:end,:));
 Si=Vi./V;
%%
 if kk>1, Si=reshape(Si',k,kk)'; end
%%

%if(nargin==3), specshow(spectrum,[1],M); end
if(nargin==4)
     G=zeros(n,k);
     % copy important coefficients
     G( [1+(0:M), n+1-(1:M)],:)=F( [1+(0:M), n+1-(1:M)], :); 
     z=real(ifft(G));
     for i=1:k
        if(k>1),subplot(floor(k/2+.5),2,i);end
        plot(x(indexqper(:, i),i),yr(:,i),'.',x(indexqper(:, i),i),z(:,i),'-','LineWidth',2);        
        xlabel(['x_{',num2str(i),'}']);
        ylabel('y');
        title(gfx);
     end
end
return
