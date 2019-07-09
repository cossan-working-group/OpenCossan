 %% Tutorial for the ProbabilisticModel object 
%
% The tutorial shows how to define a ProbabilisticModel and to exaluate the 
% failure probability associeted to it.
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@ProbabilisticModel
%
% $Copyright~1993-2015,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author: Edoardo-Patelli~and~Barbara-Goller$ 
clear
close all
clc;

import reliability.*
import common.inputs.*

%% Overview
% The ProbabilisticModel requires a Model (i.e. Physical Model) and a
% PerformaceFunction
% The Model is defined used a matlab function (see Mio Tutorial)

% Import OpenCossan Packages
... importAllOpenCossanPackages

%% Define the required object
% Construct a Mio object

Xm=opencossan.workers.Mio('description', 'Performance function', ...
                'Script','for j=1:length(Tinput), Toutput(j).out1=(-2+Tinput(j).RV1+Tinput(j).RV2); end', ...
                'Format','structure',...
                'OutputNames',{'out1'},'InputNames',{'RV1','RV2'},...
				'IsFunction',false); % This flag specify if the .m file is a script or a function. 
% Construct the Evaluator
Xeval1 = opencossan.workers.Evaluator('Xmio',Xm,'Sdescription','first Evaluator');

% In order to be able to construct our Model an Input object must be
% defined

% Define an Input
% Define RVs
RV1=opencossan.common.inputs.random.NormalRandomVariable('mean',0,'std',1);  %#ok<SNASGU>
RV2=opencossan.common.inputs.random.NormalRandomVariable('mean',0,'std',1);   %#ok<SNASGU>
% Define the RVset
Xrvs1=opencossan.common.inputs.random.RandomVariableSet('names',{'RV1', 'RV2'},'members',[RV1;RV2]);  
% Define Xinput
Xin = opencossan.common.inputs.Input('description','Input satellite_inp','membersnames',{'Xrvs1'},'members',{Xrvs1});


% Define a PerformanceFunction 
Xpar=opencossan.common.inputs.Parameter('description','Define Capacity','value',1);
Xin = add(Xin,'member',Xpar,'name','Xpar');
Xin = sample(Xin,'Nsamples',10);

Xperfun=opencossan.reliability.PerformanceFunction('OutputName','Vg1','Capacity','Xpar','Demand','out1');

%% Define a probabilistic Model (compatibility mode)
% In the compompatibility mode it is necessary to define a Model and then
% add the model and probabilistic function to the ProbabilisticModel
Xmdl=opencossan.common.Model('Cmembers',{'Xin','Xeval1'}); 
% Now we can construct our first ProbabilisticModel
Xpm=ProbabilisticModel('Sdescription','my first Prob.Model',...
    'CXperformanceFunction',{Xperfun},'CXmodel',{Xmdl});
disp(Xpm)

%% Define a probabilistic Model 
% The ProbabilisticModel can be created directly from an Evaluator
% containing one Performance Function

Xev=Evaluator('CXmembers',{Xm Xperfun});
% The advantage of this method is the possibility to devine Queues, slots
% and analysis mode for the worker (i.e. the performance function).
% Please refer to the TutorialEvaluator for more detailed information 

% Now we can construct a ProbabilisticModel in the same way we can define a
% construct a Model
Xpm=ProbabilisticModel('Sdescription','my first ProbabilisticModel',...
    'Xevaluator',Xev,'Xinput',Xin);


%
%% Analysis
% Deterministic Analysis
XsimOut=Xpm.deterministicAnalysis;
display(XsimOut)


% The ProbabilisticModel can also be constructed passing the object by
% references

Xpm=ProbabilisticModel('Sdescription','my first Prob.Model','Xmodel',Xmdl,'XperformanceFunction',Xperfun);
% display(Xpm)
Xco = optimization.Cobyla('initialTrustRegion',1,'finalTrustRegion',0.01);  

Xga     = optimization.GeneticAlgorithms('NPopulationSize',10);
XdpCo=Xpm.designPointIdentification('Xoptimizer',Xco);
XdpGa=Xpm.designPointIdentification('Xoptimizer',Xco);
XdpHLRF=Xpm.designPointIdentification;

display(XdpCo)
display(XdpGa)
display(XdpHLRF)
% Let now evaluate the ProbabilisticModel
% Xout=Xpm.apply(Xin); 
% The SimulationData will contains 10 model evaluation and 10 performance
% function evaluation

% If you want compute the Failure probability, the method
% computeFailureProbability must be applied to a Simulation object
Xmc=simulations.MonteCarlo('Nsamples',10000);
Xpf=Xpm.computeFailureProbability(Xmc); 
% see turorial of Failure Probability 
display(Xpf)



