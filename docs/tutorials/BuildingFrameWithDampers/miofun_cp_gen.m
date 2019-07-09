function Toutput = miofun_cp_gen(Tinput)
OpenCossan.resetRandomNumberGenerator(51125);
%
%
Nrviid = floor(Tinput(1).t_tot/Tinput(1).dt + 1);

dt=Tinput(1).dt; %deltaT
t=0:dt:Tinput(1).t_tot; %time

parfor isample = 1:length(Tinput)
    % Filter parameters
    S0=Tinput(isample).S0;
    wg=Tinput(isample).wg;
    csig=Tinput(isample).csig;
    wf=Tinput(isample).wf;
    csif=Tinput(isample).csif;
    
    w = zeros(1,Nrviid);
    for irv = 1:Nrviid
        w(irv) = Tinput(isample).(['Xrv_' num2str(irv)]);
    end
    % Sato Shinozuka time modulation
    B1=0.045*pi;
    B2=0.05*pi;
    C=B1/(B2-B1)*exp(B2/(B2-B1)*log(B2/B1));
    phi=C*(exp(-B1.*t)-exp(-B2.*t));
    
    % %State space formulation
    % As=[1 0 1 0
    %     0 0 0 1
    %     -wf^2 +wg^2 -2*csif*wf +2*csig*wg
    %     0 -wg^2 0 -2*csig*wg];
    % B=[0;0;0;-(2*pi*S0/dt)^0.5];
    %
    % Z0=[0;0;0;0];
    % options=[];
    % [tt Z] = ode45(@cp_gen_rk,t,Z0,options,As,B,w(1,:),t,phi);
    % ag=As(3,:)*Z'
    
    
    %piecewise direct integration
    ug=[];
    for i=1:length(w(:,1))
        ug=[ug,(2*pi*S0/dt)^0.5*w(i,:)'.*phi'];
    end
    
    wdi= wg*(1-csig^2)^0.5;
    nt = length(ug(:,1));
    u=zeros(nt,length(w(:,1)));
    udot=zeros(nt,length(w(:,1)));
    u2dot=zeros(nt,length(w(:,1)));
    A1=-diff(ug)/dt/wg^2;
    A0=(-ug(1:nt-1,:)-2*csig*wg*A1)/wg^2;
    c1=cos(wdi*dt);
    c2=sin(wdi*dt);
    c3=exp(-csig*wg*dt);
    % Exact piece-wgse linear integration
    for mm=2:nt
        A2=u(mm-1,:)-A0(mm-1,:);
        A3=(udot(mm-1,:)+csig*wg*A2-A1(mm-1,:))/wdi;
        u(mm,:)=A0(mm-1,:)+A1(mm-1,:)*dt+(A2*c1+A3*c2)*c3;
        udot(mm,:)=A1(mm-1,:)+((wdi*A3-csig*wg*A2)*c1-(wdi*A2+csig*wg*A3)*c2)*c3;
        u2dot(mm,:)=-2*csig*wg*udot(mm,:)-wg^2*u(mm,:);
    end
    
    ug=u2dot;
    wdi= wf*(1-csif^2)^0.5;
    nt = length(ug(:,1));
    u=zeros(nt,length(w(:,1)));
    udot=zeros(nt,length(w(:,1)));
    u2dot=zeros(nt,length(w(:,1)));
    A1=-diff(ug)/dt/wf^2;
    A0=(-ug(1:nt-1,:)-2*csif*wf*A1)/wf^2;
    c1=cos(wdi*dt);
    c2=sin(wdi*dt);
    c3=exp(-csif*wf*dt);
    % Exact piece-wgse linear integration
    for mm=2:nt
        A2=u(mm-1,:)-A0(mm-1,:);
        A3=(udot(mm-1,:)+csif*wf*A2-A1(mm-1,:))/wdi;
        u(mm,:)=A0(mm-1,:)+A1(mm-1,:)*dt+(A2*c1+A3*c2)*c3;
        udot(mm,:)=A1(mm-1,:)+((wdi*A3-csif*wf*A2)*c1-(wdi*A2+csif*wf*A3)*c2)*c3;
        u2dot(mm,:)=-2*csif*wf*udot(mm,:)-wf^2*u(mm,:)-ug(mm,:);
    end
    
    Toutput(isample,1).ground_acc=Dataseries('Mcoord',t,'Vdata',u2dot','SindexName','time','SindexUnit','s'); 
end


end