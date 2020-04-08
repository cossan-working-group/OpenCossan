%% TutorialDesignPointHLRF
% This tutorial shows how to compute the design point using the method HLRF 

% The tutorial uses a very simple probabilistic model since the aim here is not
% to define a realisic model but to show how to compute and use a DesignPoint
% object.
%
% The performance function of the model is $-3X_1+X_2$
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/HLRF@ProbabilisticModel
%
% $Copyright~1993-2014,~COSSAN~Working~Group,~University~of~Liverpool,~UK$
% $Author: Edoardo-Patelli$ 
%% Preparation of the Input

% Definition of the Parameters
Xmax=opencossan.common.inputs.Parameter('value',4);

% Definition of the Random Varibles
X1=opencossan.common.inputs.random.NormalRandomVariable('mean',6,'std',2);
X2=opencossan.common.inputs.random.NormalRandomVariable('mean',5,'std',3);

Xrvset=opencossan.common.inputs.random.RandomVariableSet('names',["X1" "X2"], 'members',[X1; X2]);

%% Show samples in standard normal space,
samples = sample(Xrvset,500);
samples = map2stdnorm(Xrvset, samples);

hf1=figure;
scatter(samples.X1, samples.X2)
hold on
x1 = linspace(-4,0,10);
plot(x1,2*x1+17/3);  
plot(x1,-1/2*x1,'k'); 
grid on
axis equal
title('Standard normal space')


% Definition of the Function
Xsum = opencossan.common.inputs.Function('expression','-3*<&X1&>+<&X2&>');

%% Prepare Input Object
% The above prepared object can be added to an Input Object
Xinput = opencossan.common.inputs.Input('members',{Xrvset Xsum Xmax},'names',["Xrvset" "Xsum" "Xmax"]);
% Show summary of the Input Object
display(Xinput)
%% Preparation of the Evaluator
% This example used and empty Evaluator since there is nothing to be computed.
Xevaluator = opencossan.workers.Evaluator;

%% Preparation of the Physical Model
% Define the Physical Model
Xmodel = opencossan.common.Model('input',Xinput,'evaluator',Xevaluator);


%% Define a Probabilistic Model
% Performance Function
Xperfun = opencossan.reliability.PerformanceFunction('OutputName','Vg','Demand','Xsum','Capacity','Xmax');
% Define a Probabilistic Model
XprobModel=opencossan.reliability.ProbabilisticModel('model',Xmodel,'performanceFunction',Xperfun);

%% Compute Reference solutions 
Xmc=opencossan.simulations.MonteCarlo('samples',1e5);
Xpf=XprobModel.computeFailureProbability(Xmc);

%% Here we go! Compute the DesingPoint
% The design point can be compute calling the method designPointIdentification
% of the ProbabilisticModel. If this method is called without arguments the
% DesignPoint is identified by means linear approximation of the performance
% function using the so called  method HLRF
Xdp = XprobModel.designPointIdentification();
%% Show results
display(Xdp)
% Show reliability index
fprintf('\nReliability Index: %e\n',Xdp.ReliabilityIndex)

% Compute First Order Reliability Analysis (FORM)
fprintf('First Order Reliability Analysis (FORM): %e\n',Xdp.Form)

% Show failure probability estimated by means of the Monte Carlo Simulation
fprintf('Failure probability (Monte Carlo Simulation): %e\n',Xpf.Value)

% The failure probability estimated by means of the first order reliability
% analysis is very accorate since the limit state function is linear. 

% Plot the design point
scatter(Xdp.DesignPointStdNormal.X1,Xdp.DesignPointStdNormal.X2,'pr','sizedata',96)

%% Validate resutls
assert(all(max(Xdp.DesignPointStdNormal{:,:}-[-34/15 17/15])<0.001),'openCOSSAN:TutorialDesignPoint',...
    'DesignPoint not identified correctly')

assert((Xdp.Form-0.0056)<1e-4,'openCOSSAN:TutorialDesignPoint',...
    'First Order Reliability Analysis not correct')

%% Close all the plots
close(hf1)
