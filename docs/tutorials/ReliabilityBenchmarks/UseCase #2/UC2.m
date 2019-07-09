% Thi USE CASE #2 analyze a system composed by a simple Frame
%
% Author: Edoardo Patelli, 2014
% Institute for Risk and Uncertainty
% University of Liverpool 
%
%
disp('');
disp('--------------------------------------------------------------------------------------------------');
disp('USE CASE #2: Series system from Ivan Au and Jim Beck (1999))');
disp('--------------------------------------------------------------------------------------------------');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simple Frame Schueller et al, 1989 Probabilistic Engineering Mechanics, 4(1) 10-18 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Reset
OpenCossan.reset

SpathU2  = fileparts(which('UC2.m'));% returns the current folder

assert(~isempty(SpathU2),...
    'This script should be in your path')
    

%% Define the input parameters
% In this example there are 7 random variables. 
% 5 log normal distributed variable and 2 Type-I-largest 

RV1=RandomVariable('Sdistribution','lognormal','mean',60,'std',6.0); 
RV2=RandomVariable('Sdistribution','lognormal','mean',60,'std',6.0); 
RV3=RandomVariable('Sdistribution','lognormal','mean',60,'std',6.0); 
RV4=RandomVariable('Sdistribution','lognormal','mean',60,'std',6.0); 
RV5=RandomVariable('Sdistribution','lognormal','mean',60,'std',6.0); 
RV6=RandomVariable('Sdistribution','large-I','mean',20,'std',6.0); 
RV7=RandomVariable('Sdistribution','large-I','mean',20,'std',7.5); 


% Define a random variable set collecting all the above defined Random
% Variables
% The RandomVariables are imported from the base workspace
Xrvs = RandomVariableSet('Cmembers',{'RV1' 'RV2' 'RV3' 'RV4' 'RV5' 'RV6' 'RV7'});

% Define Input
Xin = Input('XRandomVariableSet',Xrvs);

%%  Definition of Mio objects
% The mio object contains the performance fucntion 
XmG2=Mio('Sdescription', 'Performance function', ...
        'Spath',SpathU2, ...
        'Sfile','performanceFunctionSimpleStructuralFrame', ...
        'Liostructure',false, ...
        'Lfunction',true, ...
        'Liomatrix',true, ...
        'Coutputnames',{'g2'},...
        'Cinputnames',{'RV1' 'RV2' 'RV3' 'RV4' 'RV5' 'RV6' 'RV7'});		

    
% Define Performance Functions
XperfunG2=PerformanceFunction('Xmio',XmG2);

% Construct the evaluators
% The evaluator is empty since there is no model to be evaluated.
Xev= Evaluator;

% Define the Models
Xmdl= Model('Xevaluator',Xev,'Xinput',Xin);

% Define Single Probabilistic Model 
% this probabilistic model contain the performance function defined by the
% intersection of the performance functions (i.e. max)
XpmALL=ProbabilisticModel('Xmodel',Xmdl,'XperformanceFunction',XperfunG2);

%% Compute the reference solution by means of the MC simulation 
% The reference solution is approximately 1.45e-4

Xmc=MonteCarlo('Nsamples',1e6);

XpfMC=XpmALL.computeFailureProbability(Xmc);

disp('====================================================================');
disp('The reference solution has been computed by means of direct MC')
display(XpfMC)

%% Perform Subset simulations
XssMCMC=SubSet('Nmaxlevels',6,'target_pf',0.1, ...
    'Ninitialsamples',450, 'Nbatches',1,'Vdeltaxi',0.2);

XssCAN=SubSet('Nmaxlevels',6,'target_pf',0.1, ...
    'Ninitialsamples',450, 'Nbatches',1,'VproposalVariance',[0.5]);

%% Test convergence
Nrepeat=20;
Mpf=zeros(Nrepeat,2);
Mcov=zeros(Nrepeat,2);

    for k=1:Nrepeat
        
        [Xpf1(k),Xout1(k)]=XpmALL.computeFailureProbability(XssMCMC);
        Mpf(k,1)=Xpf1(k).pfhat;
        Mcov(k,1)=Xpf1(k).cov;
        
        [Xpf2(k),Xout2(k)]=XpmALL.computeFailureProbability(XssCAN);
        Mpf(k,2)=Xpf2(k).pfhat;
        Mcov(k,2)=Xpf2(k).cov;
    end

    
h1=Xout1(1).plotLevels('Stitle','MCMC algorithm');
h2=Xout2(2).plotLevels('Stitle','Canonical algorithm');

exportFigure('Hfigurehandle',h1,'Sfigurename','SubSet_UC2_MCMC.fig','SfullPath',pwd);
exportFigure('Hfigurehandle',h1,'Sfigurename','SubSet_UC2_MCMC.pdf','SfullPath',pwd);
exportFigure('Hfigurehandle',h2,'Sfigurename','SubSet_UC2_Can.fig','SfullPath',pwd);
exportFigure('Hfigurehandle',h2,'Sfigurename','SubSet_UC2_Can.pdf','SfullPath',pwd);


h3=Xout1(5).plotMarkovChains('Cnames',{'RV6' 'RV7'},'Stitle','MCMC algorithm');
h4=Xout2(5).plotMarkovChains('Cnames',{'RV6' 'RV7'},'Stitle','Canonical algorithm');

%% Compute reference solution
% Compute the reference solution by means of MC simulation using only 1
% limit state function

% Compute and report summarry summary 
disp(sprintf('         | Monte Carlo   | SubSet MCMC   | SubSet Canonical'))
disp(sprintf(' Pf      |%e | %e  | %e ',XpfMC.pfhat,Xpf1(1).pfhat,Xpf2(1).pfhat))
disp(sprintf(' CoV     |%e | %e  | %e ',XpfMC.cov,Xpf1(1).cov,Xpf2(1).cov))
disp(sprintf(' Samples |%e | %e  | %e ',XpfMC.Nsamples,Xpf1(1).Nsamples,Xpf2(1).Nsamples))


Vmin=min(Mpf);
Vmax=max(Mpf);
Vmedian=median(Mpf);

disp(sprintf('      Min    | median  | Max'))
disp(sprintf('Subset MCMC      |%e %e %e | ',Vmin(1),Vmedian(1),Vmax(1)))
disp(sprintf('Subset Canonical |%e %e %e | ',Vmin(2),Vmedian(2),Vmax(2)))

%%