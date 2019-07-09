
function [varargout] = importancesampling(Xsys,varargin)
%IMPORTANCESAMPLING  Estimate prob. of failure with Importance Sampling
% IMPORTANCESAMPLING  estimates probability of failure of the probabilistic 
%   model (probmodel) with Importance Sampling (variance reduction
%   technique)
%
% MANDATORY ARGUMENTS: -
%   - Xpm:  probabilistic model object
%   - Tpf       Structure that contains the estimated Failure Probability
%
% OPTIONAL ARGUMENTS:
% - CoV: target coefficient of variation (CoV) of estimator, at which sampling is stopped
%             (default 0 -> no used as termination criteria)
% - Nsamples: maximum number of samples 
%					   (default 10000)
% - Ntimeout: maximum execution time (s), after which sampling is stopped 
%					 (default 6000)
% - Nbatches: number of samples per batch (convergence criteria are checked
%                      after each batch of samples)
%					  (default 100)
%  - Cdistribution: type of distrubution used to samples rv around the dp
%					  (default normal), the defined distribution has a mean
%  - 'Vstd',(Default 1),  std of the selected distribution
%  - 'Vmean',[],    mean of the selected distribution
%  - 'Vpar1',[], parameter 1 of the selected distribution
%  - 'Vpar2',[], parameter 2 of the selected distribution
%  - 'Vpar3',[],  parameter 3 of the selected distribution
%  - Vdp_u: User defined design point in the standard normal space
%
%  The length of the parameters Cdistribution Vspead Vmean Vpar1 Vpar2
%  Vpar3 must be equal to the number of rv present in the rvset. If the
%  size of these parameter is = 1, the same value is adopted for all the
%  rvs.
%
%  varargout{1}: Xo
%					    Export Xo object containg the samples and the
%						 corresponding performance functions
%  varargout{2}: Tpf 
%					    Structure of the estimated pf
%
% EXAMPLES:
%  importancesampling(Xpm)
% Xo = importancesampling(Xpm, 'Nsamples', 1000)
% Xo = importancesampling(Xpm, 'CoV', 0.1);
% Xo = importancesampling(Xpm, 'CoV', 0.1, 'Nsamples',50); 
%
% =====================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2008 IfM
% =====================================================

global Clog
Clog{end+1}=['COSSAN-X:Xmodel:importancesampling  - START -' datestr(clock)];

%% Processing Inputs
% get the important direction and the design point
Nbatches=1;
Lbasicevent=false;

for k=1:2:length(varargin)
	switch lower(varargin{k})
		case ('mcs')
			Vpos=find(dec2bin(varargin{k+1})=='1');
		case {'nsamples','nsample'}
			Nsamples=varargin{k+1};
		case{'smethod'}
			Smethod=varargin{k+1};
		case{'vpos'}
			Vpos=varargin{k+1};
		case{'nbatches'}
			Nbatches=varargin{k+1};
		case{'lbasicevent'}
			Lbasicevent=varargin{k+1};
	end
end

%%  1.  Initialize variables
Xo=Xoutput; % initialize Xoutput

Tsim.Stype='IS';
Ldone=false;
Xpm=Xsys.Xmembers{1};
Xin=get(Xpm,'Xin');
Tsim.Nvar = get(Xin,'numberrv');
Tsim.Vweights = zeros(Nbatches ,1);
Tsim.CoV=0;
Tsim.Nsamples=0;

% use user defined design point (overwrite the design point defined in the
% probmodel)

Mdp_u=findlinearintersection(Xsys,'cmcs',{[1;2;3;4]});


%%  1.  Data of the Simulation


for i=1:Tsim.Nvar
     Xrv(i) = rv('Sdistribution','normal','mean',Mdp_u(i)+1,'std',1);  %#ok<AGROW>
     Crv_name{i} = ['Xrvu_' num2str(i)]; %#ok<AGROW>
 end

Xrvs_hU = rvset('Cmembers',Crv_name,'Xrv',Xrv,'Sdescription','IS: rvset in SNS');

tic;

%% start simulation
for ibatch=1:Toptions.Nbatches
	
	% Generate the samples from the the "user defined distributions"
	Tsim.MUimpsamples = sample(Xrvs_hU,Toptions.Nsimxbatch);
	
	% Compute the weights
	%VfpdfU=prod(normpdf(Tsim.MUimpsamples),2);		%pdf in the original space (SNS)
	VfpdfUlog=sum(log(normpdf(Tsim.MUimpsamples)),2);
	VhpdfUlog = evalpdf(Xrvs_hU,'Msamples',Tsim.MUimpsamples,'Llog',true);	 %pdf of the samples  
	%Tsim.Vweights(Tsim.Nsamples+1:Tsim.Nsamples+Toptions.Nsimxbatch,1) = VfpdfU ./ VhpdfU;
	Tsim.Vweights(Tsim.Nsamples+1:Tsim.Nsamples+Toptions.Nsimxbatch,1) = exp(VfpdfUlog - VhpdfUlog);
	% Evaluate the performance function
	
				% Now reuse the same samples to estimate the pf of the cut-set
			for imcs=1:4
				Tinput=Tinput(Vg<0);
				Vweights=Vweights(Vg<0);
				if isempty(Tinput)
					break
				end
				Xprobmodel=Xsys.Xmembers{Vpos(imcs)};
				Vg=apply(get(Xprobmodel,'Xg'),Tinput);
			end
			pfhat=sum(Vweights(Vg<0))/Nsamples;
			varpfhat = var(Vweights(Vg<0)) / Nsamples;
			CoV = sqrt(varpfhat) /pfhat;
			Tpf = struct('Stype','IS','pfhat', pfhat,'CoV',CoV);
			
			
    [Vg Xo_tmp]= gueval(Xpm,'MU',Tsim.MUimpsamples);
    
	% Collect Vg
    Tsim.Vg(Tsim.Nsamples+1:Tsim.Nsamples+Toptions.Nsimxbatch) = Vg;
	% Update number of samples
    Tsim.Nsamples =Tsim.Nsamples + Toptions.Nsimxbatch;
	Tsim.Nfail =  length(find(Tsim.Vg(1:Tsim.Nsamples)<0));
    Tsim.pfhat = sum(Tsim.Vweights(Tsim.Vg(1:Tsim.Nsamples)<0)) / Tsim.Nsamples;

	% Compute CoV 
	Tsim.varpfhat = var(Tsim.Vweights(Tsim.Vg(1:Tsim.Nsamples)<0)) / Tsim.Nsamples;
    Tsim.CoV = sqrt(Tsim.varpfhat) / Tsim.pfhat;
    
    Tsim.t = toc;
        
	%% Export results
	Xo=add(Xo,'Xoutput',Xo_tmp);
	
    % check termination criteria
	OpenCossan.cossanDisp(['Batch ' num2str(ibatch) ' of ' num2str(Toptions.Nbatches) ' Nbatches completed']);
	 Ldone=check_termination(Tsim,Toptions);
	 if Ldone
		 break
	 end
end

%Confidence Level based on Chebyshev's inequality
Tsim.epsilon = 1 / (1-Toptions.confLevel) * sqrt(Tsim.varpfhat);
Tsim.TConfInt.confLevel = Toptions.confLevel;
Tsim.TConfInt.Vinterval = [max([Tsim.pfhat-Tsim.epsilon 0]) Tsim.pfhat+Tsim.epsilon];

% Export results

Tpf = struct('Stype','IS','pfhat',Tsim.pfhat, 'CoV', Tsim.CoV, ...
             'TConfInt', Tsim.TConfInt,'Nsamples',Tsim.Nsamples,'Ntime',Tsim.t,'Vweights',Tsim.Vweights);

Xo=add(Xo,'Tpf',Tpf);
Xo=add(Xo,'Vweights',Tsim.Vweights);

%% Display output
if Toptions.Lverbose
    %3.6.   Output to Screen
    OpenCossan.cossanDisp(' ');
    OpenCossan.cossanDisp('----------------------------------- ');
    OpenCossan.cossanDisp('Results obtained with Importance Sampling' );
    OpenCossan.cossanDisp(['Pf_IS   = ' num2str(Tsim.pfhat)]);
    OpenCossan.cossanDisp(['CoV_IS  = ' num2str(Tsim.CoV)]);
    OpenCossan.cossanDisp(['CPU time = ' num2str(Tsim.t)]);
    OpenCossan.cossanDisp(['Nsamples = ' num2str(Tsim.Nsamples)]);
    OpenCossan.cossanDisp('---------------------------------- ');
end

%% Export data
varargout{1}=Xo;
varargout{2}=Tpf;

Clog{end+1}=['COSSAN-X:probmodel:importancesampling  - STOP -' datestr(clock)];
