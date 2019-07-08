% Thi USE CASE #6 Simple example in 1 dimension and in high dimensional space 
%
% This is a very simple example where the dimensionality of the problem is
% increased.
%
% Author: Edoardo Patelli


%% 1 Random Variable

RV=RandomVariable('Sdistribution','normal','mean',0,'std',1); 
Xpar=Parameter('Sdescription','Define Capacity','value',-3);
Xrvs = RandomVariableSet('Xrv',RV,'Nrviid',1);
% Define Input
Xin = Input('XRandomVariableSet',Xrvs,'Xparameter',Xpar);

%%  Definition of Mio objects
% The mio object contains the performance fucntion
Xmio=Mio('Sscript','Moutput=Minput(:,1);','Liomatrix',true,...n
    'Liostructure',false,'Coutputnames',{'out'},'Cinputnames',Xin.CnamesRandomVariable);
	
Xmdl= Model('Xevaluator',Evaluator('Xmio',Xmio),'Xinput',Xin);

Xperfun=PerformanceFunction('Scapacity','out','Sdemand','Xpar','Soutputname','Vg1');
% Define a ProbabilisticModel
Xpm=ProbabilisticModel('Xmodel',Xmdl,'XPerformanceFunction',Xperfun);

%% Construct a SubSet simulation objects
% Define the simulation object
XssMCMC=SubSet('Nmaxlevels',5,'target_pf',0.1,'Ninitialsamples',100,...
    'Nbatches',1,'Vdeltaxi',.2);

XssVar=SubSet('Nmaxlevels',7,'target_pf',0.1, ...
    'Ninitialsamples',100, 'Nbatches',1,'VproposalVariance',0.5);

[XpfMCMC,XoutMCMC]=Xpm.computeFailureProbability(XssMCMC);
[XpfVar,XoutVar]=Xpm.computeFailureProbability(XssVar);

XoutMCMC.plotLevels
XoutVar.plotLevels


% Define numbe of dimension
%Vdim=[1 10 100 1000];

Vdim=1000;

RV=RandomVariable('Sdistribution','normal','mean',0,'std',1); 
Xpar=Parameter('Sdescription','Define Capacity','value',-3);

% Define Performance Functions
Xperfun=PerformanceFunction('Scapacity','out','Sdemand','Xpar','Soutputname','Vg1');



for idim=1:length(Vdim)

%% Define the input parameters
% Definition of Set of IID random variables 
Xrvs = RandomVariableSet('Xrv',RV,'Nrviid',Vdim(idim));
% it is equal to -3 (the threshold value)

% Define Input
Xin = Input('XRandomVariableSet',Xrvs,'Xparameter',Xpar);

%%  Definition of Mio objects
% The mio object contains the performance fucntion
Xmio=Mio('Sscript','Moutput=Minput(:,1);','Liomatrix',true,...n
    'Liostructure',false,'Coutputnames',{'out'},'Cinputnames',Xin.CnamesRandomVariable);
	
Xmdl= Model('Xevaluator',Evaluator('Xmio',Xmio),'Xinput',Xin);

% Define a ProbabilisticModel
Xpm=ProbabilisticModel('Xmodel',Xmdl,'XPerformanceFunction',Xperfun);

% % Compute the reference solution by means of MC simulation using only 1
% % limit state function
% Xmc=MonteCarlo('Nsamples',1e4);
% 
% Xpf=Xpm.computeFailureProbability(Xmc);
% % Analytical solution
% sprintf('Analytical solution: %e',normcdf(Xpar.value))

%% Performe subset simulation
for nrep=1:10
tic, 
[Xpf(idim),XoutSS(idim)]=Xpm.computeFailureProbability(XssMCMC);
Vpf1(idim,nrep)=Xpf(idim).pfhat;
Vtime1(idim,nrep)=toc;
Vsamples1(idim,nrep)=Xpf(idim).Nsamples;


%% Performe subset simulation
tic,
[XpfVar(idim),XoutSSVar(idim)]=Xpm.computeFailureProbability(XssVar);
Vtime2(idim,nrep)=toc;
Vpf2(idim,nrep)=XpfVar(idim).pfhat;
Vsamples2(idim,nrep)=XpfVar(idim).Nsamples;

end

end

% Prepare plot 
figure
scatter(repmat([10 100 1000],1,10),reshape(Vpf1(1:3,:),1,30))
hold
scatter(repmat([10 100 1000],1,10),reshape(Vpf2(1:3,:),1,30))




% %% Plot figures
% XoutSS.plotLevels('Smarker','.','Sfigurename','StandardSS_levels')
% HfigureChains=XoutSS.plotMarkovChains('Smarker','.','Cnames',{'RV_1','RV_2'});
% Haxes=get(HfigureChains,'CurrentAxes');
% 
% %% Create countour plot
% % create mesh
% [x,y]=meshgrid(-4:0.1:4,-4:0.1:4);
% % z=(x*11709.7+78064.4).*(y*0.00156+0.0104)-146.14;
% z=Xpar.value-x;
% V=linspace(min(min(z)),max(max(z)),10);XoutSS(n).VrejectionRates
% [C,h] =contour(Haxes,x,y,z,XoutSS.VsubsetThreshold,'ShowText','on');
% %saveas(HfigureChains,'StandardSS_levels_contour','eps')
% %saveas(HfigureChains,'StandardSS_levels_contour','fig')

% %% Test new subset algorithms
% 
% [XpfSSVar,XoutSSVar]=Xpm.computeFailureProbability(XssVar);
% display(XpfSSVar)
% % plot rejection rate
% display(XoutSSVar.VrejectionRates)
% XoutSSVar.VsubsetThreshold
% 
% OpenCossan
% % The figure shows the increase of dispersion due to the proposal variance
% XoutSSVar.plotLevels('Smarker','.')
% 
% XssVar=SubSet('Nmaxlevels',10,'target_pf',0.1, ...
%     'Ninitialsamples',100, 'Nbatches',1,'VproposalVariance',[.5]);
% [XpfSSVar,XoutSSVar]=Xpm.computeFailureProbability(XssVar);
% display(XpfSSVar)
% XoutSSVar.plotLevels('Smarker','.')
% HfigureChains=XoutSSVar.plotMarkovChains('Smarker','.','Cnames',{'X1','X2'},'Lconnectchains',false);
% Haxes=get(HfigureChains,'CurrentAxes');

% %[x,y]=meshgrid(-6:0.1:3,-6:0.1:3);
% %z=(x*11709.7+78064.4).*(y*0.00156+0.0104)-146.14;
% %V=linspace(min(min(z)),max(max(z)),10);
% [C,h] =contour(Haxes,(x*11709.7+78064.4),(y*0.00156+0.0104),z,XoutSSVar.VsubsetThreshold,'ShowText','on');
% 
% 
% % Create figure for standard SS implementation
% figure
% [C,h] =contour(x,y,z,XoutSS.VsubsetThreshold,'ShowText','on');
% 
% % plot rejection rate
% display(XoutSS.VrejectionRates)
% sprinf('Rejected samples: %i',length(XoutSS.VrejectedSamplesIndices))


