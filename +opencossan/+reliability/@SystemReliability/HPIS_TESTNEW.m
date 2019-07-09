function varargout=HPIS(Xsys,varargin)
% HPImportanceSampling estimate the failure probability for parallel
% systems
%
% See Also http://cossan.cfd.liv.ac.uk/wiki/index.php/hpis@SystemReliability
%
% Copyright~1993-2011, COSSAN Working Group,University of Innsbruck, Austria
% Author: Edoardo-Patelli

Lplot=false;
Llhs=false;
Nsamples=100;

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case ('ccutset')
            % User define cut set
            Cmcs=varargin{k+1};
        case {'nsamples','nsample'}
            Nsamples=varargin{k+1};
        case ('vcutsetindex')
            Cmcs=varargin(k+1);
        case {'llatinhypercubesampling','llhs'}
            Llhs=varargin{k+1};
        otherwise
            error('openCOSSAN:SystemReliabiliy:hpis',...
                '%s is not a valid PropertyName',varargin{k})
    end
end

if ~exist('Cmcs','var')
    Cmcs=getMinimalCutSets(Xsys);
end

%% get the important directions and the design points
Xin=Xsys.Xmodel.Xinput;
Ninputs=Xin.NrandomVariables;

for imcs=1:length(Cmcs)
    VcutsetIndex=Cmcs{imcs};
    Npf=length(VcutsetIndex);
    Mdp=zeros(Npf,Ninputs);
    Malpha=zeros(Npf,Ninputs);
    
    for n=1:Npf
        Malpha(n,:)=Xsys.XdesignPoints{VcutsetIndex(n)}.VDirectionDesignPointStdNormal;
        Mdp(n,:)=Xsys.XdesignPoints{VcutsetIndex(n)}.VDesignPointStdNormal;
    end
    
    %% Compute kappa
    % here the size of the matrix Malpha is (Nlimstate function,Nrv)
    kappa=sqrt(det(Malpha*Malpha'));
    
    % %% Check if the Calpha == number of RVs
    % if size(Malpha,1)~=Nvar
    % 	X=rand(Nvar,Nvar-size(Malpha,1));
    % 	% Mextra=Malpha*X;
    % 	% Mextraorth=X-Malpha'*Mextra;
    % 	Malphaextra=gram_schmidt([Malpha; X']');
    %     Malpha=[Malpha; Malphaextra(:,size(Malpha,1)+1:end)'];
    % end
    
    %% Test the HPIS
    if Llhs
        Vsample_U=lhsdesign(Nsamples,Nvar,'criterion','maximin');
    else
        % Samples only along LSF
        Vsample_U=rand(Nsamples,length(Malpha));
    end
    C=zeros(Nsamples,Npf);
    Vbeta=zeros(Npf,1);
    
    for i=1:Npf
        Vbeta(i)=norm(Mdp(i,:));
        C(:,i)=-(norminv(normcdf(-Vbeta(i))*(Vsample_U(:,i))));
    end
    
    %C(:,length(C_dir)+1:Nvar)=Vsample_U(:,length(C_dir)+1:Nvar);
    
    %% Compute the point in the SNS from the values of C
    %M12=findintersectionlinear2('Mbeta',C,'Malpha',Malpha);
    % Intersection point
    M12=zeros(Nsamples,Npf);

    for i=1:Nsamples
        M12(i,:)=Malpha\C(i,:)';
    end

    % Add values in PhysicalSpace
    MphisicalSpace=Xin.map2physical(M12);

    XsimData(imcs)=SimulationData('Cnames',Xin.CnamesRandomVariable,'Mvalues',MphisicalSpace); %#ok<AGROW>
    
    %% PLOT FIGURE
    
    % Plot figure
   % x0 = draw_limit_states2(Vdp(1:2,:)',[1 0],[0 1]);
    scatter(M12(:,1),M12(:,2));
    
    
    %% Compute the weights without log
    Vh=kappa*prod(normpdf(C),2);
    Vf=prod(normpdf(M12),2);
    Vweights=prod(normcdf(-Vbeta'),2)*Vf./Vh;
    pfhat= sum(Vweights)/Nsamples; %/abs(det_A);
    
    varpfhat = var(Vweights) / Nsamples;
    
    Xobj.XfailureProbability(imcs)=FailureProbability('Smethod','ImportanceSampling', ...
         'pf',pfhat,'variancepf',varpfhat,'Nsamples',Nsamples,...
         'SweigthsName','Vweigths');
                        
    
    XsimData(imcs)=XsimData(imcs).addVariable('Cnames',{'Vweights'},'Mvalues',Vweights); %#ok<AGROW>
end


%% EXPORT Results

varargout{1}=Xobj.XfailureProbability;

if nargout>1
    for n=1:length(Cmcs)
        Xcutset(n)=Xsys.getCutset('Vcutsetindex',Cmcs{n},...
            'XfailureProbability',Xobj.XfailureProbability(n)); %#ok<AGROW>
    end
    varargout{2}=Xcutset;
    varargout{3}=XsimData;
end


