%% TutorialDesignPointHLRF
% This tutorial shows how to compute the design point using the method HLRF 

% The tutorial uses a very simple probabilistic model since the aim here is not
% to define a realisic model but to show how to compute and use a DesignPoint
% object.
%
% The performance function of the model is $-3X_1+X_2$
%
% See Also: http://cossan.co/wiki/index.php/HLRF@ProbabilisticModel
%
% $Copyright~1993-2014,~COSSAN~Working~Group,~University~of~Liverpool,~UK$
% $Author: Edoardo-Patelli$ 

%% Preparation of the Input

% Definition of the Parameters
Xmax=Parameter('value',4);

% Definition of the Random Varibles
X1=RandomVariable('Sdistribution','normal','mean',6,'std',2,'Sdescription','First random variable');
X2=RandomVariable('Sdistribution','normal','mean',5,'std',3,'Sdescription','Second random variable');

Xrvset=RandomVariableSet('Cmembers',{'X1' 'X2'});

%% Show samples in standard normal space,
Xsamples = sample(Xrvset,500);

hf1=figure;
scatter(Xsamples.MsamplesStandardNormalSpace(:,1),Xsamples.MsamplesStandardNormalSpace(:,2))
hold on
x1 = linspace(-4,0,10);
plot(x1,2*x1+17/3);  
plot(x1,-1/2*x1,'k'); 
grid on
axis equal
title('Standard normal space')


% Definition of the Function
Xsum=Function('Sexpression','-3*<&X1&>+<&X2&>');

%% Prepare Input Object
% The above prepared object can be added to an Input Object
Xinput=Input('CXmembers',{Xrvset Xsum Xmax},'CSmembers',{'Xrvset' 'Xsum' 'Xmax'});
% Show summary of the Input Object
display(Xinput)
%% Preparation of the Evaluator
% This example used and empty Evaluator since there is nothing to be computed.
Xevaluator=Evaluator;

%% Preparation of the Physical Model
% Define the Physical Model
Xmodel=Model('Xinput',Xinput,'Xevaluator',Xevaluator);


%% Define a Probabilistic Model
% Performance Function
Xperfun = PerformanceFunction('Sdemand','Xsum','Scapacity','Xmax','Soutputname','Vg');
% Define a Probabilistic Model
XprobModel=ProbabilisticModel('Xmodel',Xmodel,'XperformanceFunction',Xperfun);

%% Compute Reference solutions 
Xmc=MonteCarlo('Nsamples',1e5);
Xpf=XprobModel.computeFailureProbability(Xmc);

%% Here we go! Compute the DesingPoint
% The design point can be compute calling the method designPointIdentification
% of the ProbabilisticModel. If this method is called without arguments the
% DesignPoint is identified by means linear approximation of the performance
% function using the so called  method HLRF
Xdp=XprobModel.designPointIdentification;
%% Show results
display(Xdp)
% Show reliability index
fprintf('\nReliability Index: %e\n',Xdp.ReliabilityIndex)

% Compute First Order Reliability Analysis (FORM)
fprintf('First Order Reliability Analysis (FORM): %e\n',Xdp.form)

% Show failure probability estimated by means of the Monte Carlo Simulation
fprintf('Failure probability (Monte Carlo Simulation): %e\n',Xpf.pfhat)

% The failure probability estimated by means of the first order reliability
% analysis is very accorate since the limit state function is linear. 

% Plot the design point
scatter(Xdp.VDesignPointStdNormal(1),Xdp.VDesignPointStdNormal(2),'pr','sizedata',96)

%% Validate resutls
assert(all(max(Xdp.VDesignPointStdNormal-[-34/15 17/15])<0.001),'openCOSSAN:TutorialDesignPoint',...
    'DesignPoint not identified correctly')

assert((Xdp.form-0.0056)<1e-4,'openCOSSAN:TutorialDesignPoint',...
    'First Order Reliability Analysis not correct')

%% Close all the plots
close(hf1)
