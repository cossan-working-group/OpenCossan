function varargout=HPIS(Xsys,varargin)
% HPImportanceSampling estimate the failure probability for parallel
% systems

Lverbose=false;
Lplot=false;
Llhs=false;

for k=1:2:length(varargin)
	switch lower(varargin{k})
		case {'nsamples','nsample'}
			Nsamples=varargin{k+1};
		case {'vmembers'}
			Vmembers=varargin{k+1};
        case {'llatinhypercubesampling','llhs'}
			Llhs=varargin{k+1};
	end		
end


%% Plot limit state functions

%% get the important direction and the design point
C_dir=cell(1,length(Xsys.XdesignPoints));
C_Vdpu=cell(1,length(Xsys.XdesignPoints));

for idp=1:length(Xsys.XdesignPoints)
    C_dir{idp}=Xsys.XdesignPoints{idp}.VDirectionDesignPointStdNormal;
    C_Vdpu{idp}=Xsys.XdesignPoints{idp}.VDesignPointStdNormal;
end

% collect dp
for i=1:length(C_Vdpu)
	Vdp(i,:)=C_Vdpu{i}; %#ok<AGROW>
end

% collect Valpha
for i=1:length(Vmembers)
	Malpha(i,:)=C_dir{Vmembers(i)}; %#ok<AGROW>
end

Xin=Xsys.Xmodel.Xinput;

Nvar=get(Xin,'nrv');



%% Compute kappa 
% here the size of the matrix Malpha is (Nlimstate function,Nrv)
kappa=sqrt(det(Malpha*Malpha'));

%% Check if the Calpha == number of RVs
if size(Malpha,1)~=Nvar
	X=rand(Nvar,Nvar-size(Malpha,1));
	% Mextra=Malpha*X;
	% Mextraorth=X-Malpha'*Mextra;
	Malphaextra=gram_schmidt([Malpha; X']');
    Malpha=[Malpha; Malphaextra(:,size(Malpha,1)+1:end)'];
end

%% Test the HPIS
if Llhs
    Vsample_U=lhsdesign(Nsamples,Nvar,'criterion','maximin');
else
    Vsample_U=rand(Nsamples,Nvar);
end
C=zeros(Nsamples,length(C_dir));

Vbeta=zeros(length(C_dir),1);

for i=1:length(C_dir)
	Vbeta(i)=norm(Vdp(i,:));
	C(:,i)=-(norminv(normcdf(-Vbeta(i))*(Vsample_U(:,i))));
end

C(:,length(C_dir)+1:Nvar)=Vsample_U(:,length(C_dir)+1:Nvar);

%% Compute the point in the SNS from the values of C 
M12=findintersectionlinear2('Mbeta',C,'Malpha',Malpha);

Xo=SimulationData('Cnames',get(Xin,'rvnames'),'mvalues',M12);

%% PLOT FIGURE
if Lplot
% Plot figure
	x0 = draw_limit_states2(Vdp(1:2,:)',[1 0],[0 1]);		
	scatter(M12(:,1),M12(:,2));
end

%% Compute the weights without log
det_A=det(Malpha);

Vh=kappa*prod(normpdf(C),2);
Vf=prod(normpdf(M12),2);
Vweights=prod(normcdf(-Vbeta'),2)*Vf./Vh;
pf3= sum(Vweights)/Nsamples; %/abs(det_A);

varpfhat = var(Vweights) / Nsamples;
CoVnolog = sqrt(varpfhat) /pf3;


% % Now we have the points in SNS and we have to compute the weigths
% Vhlog=sum(log(normpdf(C)),2)-sum(log(normcdf(-Vbeta')),2);
% % Use the logaritm of the pf otherwise the Vpf becames zeros in high
% % dimensions (>100)
% VfpdfUlog=sum(log(normpdf(M12)),2);
% Vweights=exp(VfpdfUlog - Vhlog);
% pflog3= sum(Vweights)/Nsamples/abs(det_A);
% 
% varpfhat = var(Vweights) / Nsamples;
% CoV = sqrt(varpfhat) /pflog3;

%% This should be the results!!!!
% if Lverbose
% CDF = cumsum(Vweights);
% Normalize
% CDF=CDF/CDF(end);
% CCDF=1-CDF;
% 
% figure;
% hold on
% semilogy(CDF,'b');
% semilogy(CCDF,'r');
% title(['Kappa= ' num2str(kappa) '; Nsamples = ' num2str(Nsamples)]) 


% OpenCossan.cossanDisp(['Pf estimated by HPIS: ' num2str(pf3)])
%OpenCossan.cossanDisp(['Pf estimated by HPIS (log): ' num2str(pflog3)])
%OpenCossan.cossanDisp(['Pf estimated by FORM: ' num2str(pf3_FORM)])
% OpenCossan.cossanDisp(['CoV (nolog): ' num2str(CoVnolog)])
%OpenCossan.cossanDisp(['CoV (log): ' num2str(CoV)])
%end

pfhat=pf3; %pflog3;
CoV=CoVnolog;  %COV

Tpf = struct('Stype','HPIS','pfhat',pfhat, 'CoV', CoV, ...
            'Nsamples',Nsamples);
		 
%Xo=add(Xo,'Tpf',Tpf);
Xo=Xo.addVariable('Cnames',{'Vweights'},'mvalues',Vweights);

%% Export data
varargout{1}=Xo;
varargout{2}=Tpf;
