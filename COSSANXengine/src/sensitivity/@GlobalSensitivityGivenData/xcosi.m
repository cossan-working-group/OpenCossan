function [Si,STi,Son,info]=xcosi(x,y,group,M,gfx)
%% XCOSI Calculation of sensitivity indices from given data
%
%     SI = XCOSI(X,Y,GROUP) returns the sensitivity indices for input arguments X,
%     output argument Y and index set GROUP.
%     [SI,STI]=XCOSI(X,Y,GROUP) also returns the total effects. 

% written by elmar.plischke@tu-clausthal.de

% start of Si-calculation function
if(nargin==4)
    if(ischar(M))
        gfx=M;
        M=6;     % max. higher harmonic ( sum (-1)^k sin((2k+1)x)/ (2k+1)^2 )
    else
        gfx=[];
    end
end
if(nargin==3)
    M=6;
    gfx=[];
end
if isempty(M), M=6; end

[n,k]=size(x);
[nn,kk]=size(y);
if nn~=n, error('Input/output sizes mismatch!'), end
if kk~=1, error('Only single output supported.'),end
if length(group)~=length(unique(group)), error('Multiple indices detected!'), end

[xr,index]=sort(x(:,group));

%% test of sensitivity index computation
l=length(group);
if(length(M)==2)
    P=M(2);
    M=M(1);
else
switch(l)
    case 1, P=n;
    case 2, P=min(2*M+1,floor(n/(2*M))-1);
%    case k, Si=1; return;
    otherwise,
    P=min(2*M+1,floor((n+1)^(1/l))); % no. of partitions per dimension
end
end
%%
    if(P<=2*M), 
        disp('Sensitivity Indices: Running low on samples.');
    end

    % map data into [0,1):  stratification of a (l)-dimensional hypercube   
     hyperrank=tocurveaddress((index2rank(index)-0.5)/n,P);
    % save frequencies for graphics output
     F = dct(y(hyperrank));
     spectrum=(abs(F)).^2/n;
% Interactions between group members:
% pick all frequencies in { (1:M)*P^(l-1)+-(1:M)*P^(l-2)+-...+-(1:M) }

%% construct sign matrix
s=ones(l,2^(l-1));
for i=1:(2^(l-1))
%   s(:,i)=1-2*dec2binvec(i-1,l)';  % short, but hidden in obscure toolbox
    bin=dec2bin(i-1,l);
    s(:,i)=1-2*logical(str2num([fliplr(bin);blanks(length(bin))]'));
end
%% construct vector of basic frequencies and higher harmonics
indexx=(1:M)';
for i=1:l-1
    indexx=[repmat(indexx(:,1),M,1),kron(indexx,ones(M,1))*P];
end
%% apply different signs
indexx=indexx*s;

%%
 Vi=sum(spectrum(2:n));
 % cumulative group indices and first order indices
 Son=zeros(1,l);
 STi=zeros(1,l);
 for i=1:l
  STi(i)=sum(spectrum(1+(1:(M*(P^i-1)/(P-1)))))/Vi;
  Son(i)=sum(spectrum(1+P^(l-i)*(1:M)))/Vi;
 end
 % cumulated first order indices
 % test for cutoff-threshold
 %spexx=spectrum(1+indexx(:))/Vi;
 %cutoff=(1-STi(l))/sqrt(n);
 %Si=2*sum(spexx(spexx>=cutoff));
 Si=sum(spectrum(1+indexx(:)))/Vi;
 % unbiasing
 %df=2*numel(indexx);
 %Si=(n*Si-df)/(n-df);

%% test quality of signal
if(nargout==4)
%%
info=zeros(1,l);
xspectrum=(abs(dct(x(hyperrank,group)))).^2/n;
Vx=sum(xspectrum(2:end,:));
for i=1:l
    info(i)=xspectrum(1+P^(l-i),i)/Vx(i);
end
%%
end
%% some graphics
if ischar(gfx)
%% gfx test
    figure(gcf)
    subplot(3,1,1);
    plot(1:n,x(hyperrank,group),'.');
    title(gfx)
    xlabel('Hyperindex');
    ylabel('Indexed Inputs');
    legend(cellstr([char(ones(l,1)*'x_{'),num2str(group'),char(ones(l,1)*'}')]));
    a=axis;a(2)=n;axis(a);
    subplot(3,1,2);
    % regression curve
    % add direct terms (definitely wrong for order >2)
    indeyy=(1:M)'*P.^(0:(l-1));
    %indeyy=[];
    G=zeros(n,1);freqsel=[1,1+[indexx(:);indeyy(:)]'];
    G(freqsel)=F(freqsel);
    plot(1:n,y(hyperrank),'k.', 1:n,idct(G),'r');
    %plot(1:n,y(hyperrank),'k.');
    title(gfx);
    xlabel('Hyperindex');
    ylabel('Output');
    a=axis;a(2)=n;axis(a);
    subplot(3,1,3);
    specshow(spectrum,P.^(0:(l-1)),M,1);
    % test cutoff threshold
    %a=axis;
    %hold on;plot([a(1),a(2)],[1,1]*cutoff,'r:');hold off
    title('Power Spectrum of Output');
    xlabel('Frequency');
    ylabel('Fraction of Variance');  
%%
end

%% ...
return
function index=tocurveaddress(x,P)
%% TOCURVEADDRESS converts to space filling curve address
%  (gray code) x in [0,1)^(n x k) 

[n,k]=size(x);
if(k==1)
    g=x;
else
% round to int
    xi=floor(x*P);
% first dimension has fractions to remove doublets from the sort algorithm
    xx=[x(:,1)*(P-1),xi(:,2:k)]; 
%even/odd detection
    signs=(-1).^xi; %(0.5-mod(xi,2))*2;
    cumsigns=ones(n,k);
% cumprod() wenn nicht indexgemurkse wäre
    s=signs(:,k);
    for i=(k-1):-1:1
        cumsigns(:,i)=s;
        s=s.*signs(:,i);
    end
    cs=(cumsigns+1)/2;
%% change x -> -1-x mod P if negative cumulative sign
% either x or P-1-x
    gx=xx.*cs+(P-1-xx).*(1-cs);
    g=gx*(P.^(0:(k-1))');
%%
end
%% ...
[dummy,index]=sort(g);
%%
return
function rank=index2rank(index)
%% INDEX2RANK transform index matrix to rank matrix

[n,k]=size(index);
rank=zeros(n,k);

for i=1:k
    rank(index(:,i),i)=1:n;
end
%% ...
return
