%% Tutorial for MonteCarlo Simulation 
% This tutorial shows how to use the object MonteCarlo to perfrom simulation of
% the model defined by the object Model
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@MonteCarlo
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author: Edoardo-Patelli$ 
clear
close all
clc;

%% Problem Definition
% The MonteCarlo simulation requires the definition of a Model, that requires an
% Input and an Evaluator object, respectively.

% Needed to recognise the commands
Cimports=strcat(opencossan.OpenCossan.getProjectName,'.*');
PackageList=import(Cimports{:});

% Define 2 random variable
RV1=opencossan.common.inputs.random.NormalRandomVariable('mean',0,'std',1); 
RV2=opencossan.common.inputs.random.NormalRandomVariable('mean',0,'std',1); 

% Define the RVset
Xrvs1=opencossan.common.inputs.random.RandomVariableSet('names',{'RV1', 'RV2'},'Members',[RV1 RV2]); 

% Define Input object
Xin = opencossan.common.inputs.Input('Description','Input satellite_inp');
Xthreshold=opencossan.common.inputs.Parameter('value',1);
Xadditionalparameter=opencossan.common.inputs.Parameter('Value',rand(100,1));
Xin = add(Xin,'member',Xrvs1,'name','Xrvs1');
Xin = add(Xin,'member',Xthreshold,'name','Xthreshold');
Xin = add(Xin,'member',Xadditionalparameter,'name','Xadditionalparameter');

%% Define the evaluator
% Construct a Mio object
Xm=opencossan.workers.MatlabWorker('Description', 'Performance function', ...
                'script','for j=1:length(Tinput), Toutput(j).out1=sqrt(Tinput(j).RV1^2+Tinput(j).RV2^2); end', ...
                ...'Liostructure',true,...
                'format','structure',...
                'outputnames',{'out1'},...
                'inputnames',{'RV1','RV2'},...
				'function',false); % This flag specify if the .m file is a script or a function. 

            
% Construct the Evaluator
Xeval = opencossan.workers.Evaluator('Solver',Xm,'Description','Evaluator xmio');

%% Define a Model
Xmdl=opencossan.common.Model('Evaluator',Xeval,'Input',Xin);

%% Define a Monte Carlo object
% The montecarlo object defines the number of simulations to be used, the number
% of batches
Xmc=opencossan.simulations.MonteCarlo('Nsamples',10,'Nbatches',10);

%% Run simulation 
% The method apply allows to perform the simulation of the Model
% It returns a SimulationData object
Xo=Xmc.apply(Xmdl);
display(Xo)

%% Construct the Probabilistic Model
% Define performance function 
Xpf=opencossan.reliability.PerformanceFunction('OutputName','Vg','Capacity','Xthreshold','Demand','out1');
% Construct the model
Xpm=opencossan.reliability.ProbabilisticModel('Model',Xmdl,'PerformanceFunction',Xpf);

% Apply MC object to generate samples of the ProbabilisticModel
Xo=Xmc.apply(Xpm);
display(Xo)

%% Estimate failure probability
% The method pf allows to estimate the failure of probability associated to the
% probabilistic model
Xpf=Xpm.computeFailureProbability(Xmc);
display(Xpf)

%% change properties of the Xmontecarlo object 
Xmc.Nsamples=200;
Xpf=Xpm.computeFailureProbability(Xmc);
display(Xpf)

% If a SimulationData must be exported (at the end of each batch) used the following option
Xpf=Xpm.computeFailureProbability(Xmc);
display(Xpf);

% If a SimulationData must be exported used the following option
[Xpf, Xoutput]=Xpm.computeFailureProbability(Xmc);
display(Xpf)
display(Xoutput)


%% Run analysis with many more samples
tic
Xmc.Nbatches=1;
Xmc.Nsamples=10000;
Xpf=Xpm.computeFailureProbability(Xmc);
toc

opencossan.OpenCossan.cossanDisp('Expected results: Pfhat   = 0.607 and CoV  = 0.0025 in <7 s')
display(Xpf)

%% MCS using Common Random Numbers
% This section shows an important feature that can be used for the
%   calculation of failure probabilities. This feature refers to the 
%   calculation of failure probabilities using common random numbers. 
%   That is, the same stream of random numbers is used to calculate the 
%   failure probability.
%
% The field NseedRandomNumberGenerator allows to reset the Random Number
% Generator

Xmc = opencossan.simulations.MonteCarlo('Sdescription','MCS object WITH common random numbers',...
    'Nsamples',100,...  %total number of samples
    'Nbatches',1,...    %number of batches for simulation
    'Lintermediateresults',false,...     %do not store intermediate results
    'NSeedRandomNumberGenerator',0);    %by defining this field, a RandStream object is defined using the indicated seed

% Show the local random number generator
Xmc.XrandomStream % This is not the current global stream 

% Get the state of the local random number
Vstate=Xmc.XrandomStream.State;

% Compute probability of failure
Xpf1    = Xpm.computeFailureProbability(Xmc);

% Reset the local random stream 
Xmc.XrandomStream.reset
Vstate2=Xmc.XrandomStream.State;

assert(all(Vstate==Vstate2),'OpenCossan:TutorialMonteCarlo:RandomStreamNotReset',...
    'The Simulation Random Stream has not been reset')

Xpf2    = Xpm.computeFailureProbability(Xmc);


% The simulation is performed using exaclty the same random numbers. Hence the
% results shoul be the same
display(Xpf1)
display(Xpf2)

%% Validate Results

assert(abs(Xpf1.pfhat-Xpf2.pfhat)<1e-8,'openCOSSAN:Tutorials','Wrong results')

%% MCS using smooth indicator function
% This section shows an important feature of the object  "PerformanceFunction"
% that allows calculating the probability of failure using a smooth indicator
% function. 
%
%   The concept of smooth indicator function implies that the traditional
%   indicator function (which is a heaviside or step function) is replaced
%   by a smooth version. The smooth version is modeled using the CDF of a
%   Gaussian distribution. Details on the theoretical aspects of this
%   smooth indicator function can be found at:
%   
%   Taflanidis, A. and J. Beck: 2008, `An efficient framework for optimal 
%   robust stochastic system design using stochastic simulation'. Computer 
%   Methods in Applied Mechanics and Engineering, 198(1), 88-101.
%

% In order to use the smooth indicator function
XpfSmooth     = opencossan.reliability.PerformanceFunction('OutputName','Vg',...
    'Capacity','Xthreshold',...  %indicate threshold to be used
    'Demand','out1',...    %indicate parameter modeling the demand
    'stdDeviationIndicatorFunction',0.05);  %this parameter is used to define the standard
    %deviation of the Gaussian CDF used to define the indicator function

%%   Construct probabilistic model
XpmSmooth     = opencossan.reliability.ProbabilisticModel('model',Xmdl,'performanceFunction',XpfSmooth);

% In order to use the global random number stream the local random stream
% should be removed from the Simulation Object
Xmc.XrandomStream=[];

% Reset global random number stream
opencossan.OpenCossan.resetRandomNumberGenerator(51125)

% And finally compute the failure probability
Xof1    = XpmSmooth.computeFailureProbability(Xmc);
display(Xof1)

%% Validate Solutions
assert(abs(Xof1.pfhat-0.6823)<1e-4,'OpemCossan:Tutorials','Wrong results')
