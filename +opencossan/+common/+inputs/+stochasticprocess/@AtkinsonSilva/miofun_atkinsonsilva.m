function Toutput = miofun_ASGM(Tinput)

%% Generation of synthics seismologically-based accelerograms
%-------------------------------------------------------------------------
N=length(Tinput);
TT = Tinput(1).Xsp0.Mcoord;

LL=length(TT);
a=zeros(1,LL);
x_UM=zeros(N,LL);

T_strong_mot=zeros(N,1);
aRMS=zeros(N,1);
Velocity=zeros(N,length(TT)-1);
Displacement=zeros(N,length(TT)-1);
Arias=zeros(N,length(TT)-1);

for n=1:length(Tinput)

VS=Tinput(n).XVS;
J=Tinput(n).XJ;

% TT=(0:Tinput.Xdt:Tinput.XTmax); %n=1; N=1; 
Eps=1;
%d=Tinput.XTmax/Tinput.Xdt; % dimension of the input space (i.e. number of elements for each accelerogram)
Time=Tinput(n).XTmax;

XXXX(:,n)=Tinput(n).Xsp0.Vdata; % ------- Record to Record variability -----

Fci_M(1,n)=Tinput(n).XrvM;%rand(1,1);
Mi(1,n)=Tinput(n).XMmin-1/Tinput(n).Xbi*(log10(1-Fci_M(1,n)*(1-10^(-Tinput(n).Xbi*(Tinput(n).XMmax-Tinput(n).XMmin)))));
M=Mi(1,n);

Fci_R(1,n)=Tinput(n).XrvR;%rand(1,1);
Ri(1,n)=sqrt(Tinput(n).XRmin^2+(Tinput(n).XRmax^2-Tinput(n).XRmin^2)*Fci_R(1,n));
r=Ri(1,n);

%R=r;
wa= 2*pi*(10^(2.181-0.496*M));
wb= 2*pi*(10^(2.41-0.408*M)); % exp(1)^log(2.41-0.408*M) 1.778 - 0.302*M  1.38-0.227*M
e= 10^(0.605-0.255*M); % (0.605-0.255*M);(3.223-0.670*M) 2.764 - 0.623*M 
M0= (10^((M+10.7)*3/2)); % dynxcm  (reletionship of HANKS and KANAMORI, 1979 --- in Boore 2003)
% Constant C -------------
RR=0.55; % radiation pattern
V=1/sqrt(2); % partition onto 2 horizontal components
F=2; % free surface amplification (reflection)
ro=2.8; % density in the vicinity of the source
b=3.50000; % cm/s - shear-waves velocity
C=10^-20*RR*V*F/(4*pi*ro*b^3); % RR*V*F =1
% -------------------------
% sigma=100; % bar
% wc= 2*pi*4.9*10^6*b/100000*(sigma/M0)^(1/3);
 h=10^(-0.05+0.15*M); % pseudo-depth
 R=(h^2+r^2)^0.5;% Km - radial distance from the earthquake source to the site
%R=20;  % CALIBRAZIONE MODELLO AS e Boore2003
%%-------------------------------------------------------------------
%%-------------------------------------------------------------------
Tstr=2*pi/(2*wa)+0.05*R;   
w_max=(pi/Tinput(n).Xdt);
Tw=2*floor(Tstr/Tinput(n).Xdt+1)*Tinput(n).Xdt;

% if mod(L,2)==0
% else
%   T=(L+1)*dt;
% end
dw=2*pi/Tinput(n).XTmax;
W=(dw:dw:w_max+dw);
df=1/Tinput(n).XTmax;
freq=(W)/(2*pi);
m=length(W);

XXX=2*pi*[0.01 0.09 0.16 0.51 0.84 1.25 2.26 3.17 6.05 16.6 61.2 (w_max+dw)/(2*pi)];
logXXX=log(XXX);
VS30_2=2*[1 1 1 1 1 1 1 1 1 1 1 1];
VS30_2=interp1(XXX,VS30_2,W);
VS30_800=[1 1 1 1 1 1 1 1 1 1 1 1];
VS30_800=interp1(XXX,VS30_800,W);
%  ---- -------------------------------------- Log Interpol VS30_620
VS30_620=[1 1.1 1.18 1.42 1.58 1.74 2.06 2.25 2.58 3.13 4.00 4];
%VS30_620=interp1(XXX,VS30_620,W);
logVS30_620=log(VS30_620);
VS30_620=interp1(logXXX,logVS30_620,log(W));
VS30_620=exp(VS30_620);
% figure,loglog(W/(2*pi),VS30_620.*exp(-(0.0)*W/2));
% hold on,loglog(W/(2*pi),VS30_620.*exp(-(0.01)*W/2));
% hold on,loglog(W/(2*pi),VS30_620.*exp(-(0.02)*W/2));
% hold on,loglog(W/(2*pi),VS30_620.*exp(-(0.04)*W/2));
% hold on,loglog(W/(2*pi),VS30_620.*exp(-(0.08)*W/2));
% hold on,loglog(W/(2*pi),VS30_620.*exp(-(0.035)*W/2));
% xlim([10^-1 10^2]);
% ylim([0.4 4]);
%  ---- ------------------------------------------------------------
VS30_520=[1 1.21 1.32 1.59 1.77 1.96 2.25 2.42 2.7 3.25 4.15 4.15];
VS30_520=interp1(XXX,VS30_520,W);
%figure,plot(W,VS30_520)
%  ---- -------------------------------------- Log Interpol VS30_620
VS30_310=[1 1.34 1.57 2.24 2.57 2.76 2.98 2.95 3.05 3.18 3.21 3.21];
%VS30_310=interp1(XXX,VS30_310,W);
logVS30_310=log(VS30_310);
VS30_310=interp1(logXXX,logVS30_310,log(W));
VS30_310=exp(VS30_310);
% figure,loglog(W/(2*pi),VS30_310.*exp(-(0.035)*W/2));
% xlim([10^-1 10^2]);
% ylim([0.4 4]);
% -----------------------------------------
VS30_255=[1 1.43 1.71 2.51 2.92 3.1 3.23 3.18 3.18 3.18 3.18 3.18];
VS30_255=interp1(XXX,VS30_255,W);
%figure,plot(W,VS30_255)

% Matrix initialization 
A=zeros(1,m);
A0=zeros(1,m);
Alog=zeros(1,m);

%%-------------------------------------------------------------------
%%-------------------------------------------------------------------
nnn=1;
%k0=0.035; % in order to use Soil Factors V (from Boore and Joyner 1997)
k=0.03;%0.0106*M-0.012;
Q0=180;%204; % regional parameters for anelastic attenuation
y=0.45; % regional parameters for anelastic attenuation
fmax=100; %rad/s
ss=['V=VS30_' num2str(VS) ';' ];
eval(ss);

LL=zeros(1,m);
for i=1:m
    w=W(i);
A0(1,i)=1*(C*(w^2)*M0*((1-e)/(1+(w/wa)^2)+e/(1+(w/wb)^2))); % Source spectrum 3*10^-21
G=1/(R^nnn); % Geometric spreading
Q=Q0*(w/(2*pi))^y; % Quality factor of the transmission (for anelastic attenuation)
Ll=exp(-w*R/(2*b*Q)); % Anelastic attenuation
LL(1,i)=Ll;
D1=exp(-(k)*w/2); % K-Filter (ANDERSON and HOUGH, 1984): Near surface attenuation for high-frequency (upper crust attenuation)
%D1=exp(-(0.035)*w/2)*exp(-(0.035-k)*w/2); % K-Filter (ANDERSON and HOUGH, 1984): Near surface attenuation for high-frequency (upper crust attenuation)
D2=(1+(w/(2*pi*fmax))^8)^(-1/2); % fmax-Filter (HANKS, 1982; BOORE, 1983):
%Near surface attenuation for high-frequency (upper crust attenuation)
%D=D1;
% D=D2;
%D=0.5*D1+0.5*D2;
%D=1*D1+0.6*D2;
 D=D1*D2;
Alog(1,i)=log10(1*(A0(1,i).*V(1,i)*D*Ll*G)); % 0.6*10^1
A(1,i)=(Eps*(A0(1,i)*V(1,i)*D*Ll*G));
end


% ----------------------------------------------------

if Tw>Time
    Tw=Time;
end
%-------------------------------------------------------------------------

x(1,:)=XXXX(:,n);
Xx(n,:)=XXXX(:,n);
% LL=size(x,2);
% a=zeros(1,LL);
% x_UM=zeros(N,LL);
%% Uniform Modulation of Amplitudes by means of Iwan and How formulation
% Iwan and How parameters
s=2;
b=0.25;
tmax=7;
d=((b/s)^s)*exp(s);
% Jennings parameters
t1=3;
t2=15;
beta=0.6;

if  J==1  % Jennings et al.
    for g=1:1:LL
    t=TT(g);
    if t<t1
        a(1,g)=(t/t1)^2;       
    end
    if t1<=t<=t2
        a(1,g)=1;
    end
    if t2<t
        a(1,g)=exp(-beta*(t-t2));
    end
    end
end   
    if J==2 % Iwan and How  
        
% Saragoni Hart  Normalized
eps=0.2;
eta=0.05;
% ftgm=2;
% tn=ftgm*Tw;
bb=-(eps*log(eta))/(1+eps*(log(eps)-1));
c=bb/eps;
aa=(exp(1)/eps)^bb;
% Saragoni Hart - Au_Beck settings
bb1=-(eps*log(eta))/(1+eps*(log(eps)-1));
c1=bb1/(eps*Tstr);
aa1=sqrt(((2*c1)^(2*bb1+1))/gamma(2*bb1+1));

    a(1,:)=d*TT.^s.*exp(-b*TT);      
    end
    
    if J==3  % SARAGONI and HART (1974) Normalized
% Saragoni Hart  Normalized
eps=0.2;
eta=0.05;
bb=-(eps*log(eta))/(1+eps*(log(eps)-1));
c=bb/eps;
aa=(exp(1)/eps)^bb;
% Saragoni Hart - Au_Beck settings
a(1,:)=(aa*(TT/Tw).^bb).*exp(-c*(TT/Tw)); 
% Here Tw is the duration of th while, in general it is expressed as
% 2*Duration
    end
    
    if J==4   
eps=0.2;
eta=0.05;
% Saragoni Hart - Au_Beck settings
bb1=-(eps*log(eta))/(1+eps*(log(eps)-1));
c1=bb1/(eps*Tstr);
aa1=sqrt(((2*c1)^(2*bb1+1))/gamma(2*bb1+1));
a(1,:)=(aa1*(TT).^bb1).*exp(-c1*(TT/1)); % SARAGONI and HART (1974) 
    end
%figure, plot(TT,a(1,:),'-k','linewidth',2);xlabel('Time  [s]','fontsize',13),ylabel('e(t)  [-]','fontsize',13)%,legend('Gaussian white-noise','fontsize',13,'fontweight','b'),legend boxoff;
x_UM(n,:)=a.*x; 
XX(n,:)=(fft(x_UM(n,:)))*Tinput(n).Xdt;
XX_RMS = sqrt(sum(abs(XX(n,:)).^2)/length(XX(n,:)));
XX_norm=XX(n,:)/XX_RMS;
XX_conv = abs(XX_norm).*[A fliplr(A(2:end))].*exp(1i*angle(XX(n,:)));
Acc(n,:)=real(ifft(XX_conv)/Tinput(n).Xdt)/100;

end

Toutput.ground_acc=Dataseries('Mcoord',TT,'Mdata',Acc,'SindexName','time','SindexUnit','s'); 
    
    %