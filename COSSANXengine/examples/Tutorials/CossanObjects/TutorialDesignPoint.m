%% TutorialDesignPoint
% This tutorial shows how to create and use an object of type DesignPoint.
% The tutorial uses two very simple probabilistic models. The first model
% considers only standar normal distribution, while the second model contains
% random variable with different means and standard deviations.
% The aim here is not to define a realisic model but to show how to compute and
% use a DesignPoint object.
%
% See Also: http://cossan.co.uk/wiki/index.php/@DesignPoint
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author: Edoardo-Patelli$ 

%% CASE A
% This first example considers standard normal distributions only. 
% This means that the samples (realizations) in the physical space and in the
% standard normal space are exatly the same.

%% Preparation of the Input
% Definition of the Parameters
XmaxSum=Parameter('value',2,'Sdescription','Maximum allowed sum of random variable');

% Definition of the Random Varibles
X1=RandomVariable('Sdistribution','normal','mean',0,'std',1,'Sdescription','First random variable');
X2=RandomVariable('Sdistribution','normal','mean',0,'std',1,'Sdescription','Second random variable');

Xrvset=RandomVariableSet('Cmembers',{'X1' 'X2'});
% Definition of the Function
Xsum=Function('Sdescription','Sum of RandomVariable','Sexpression','<&X1&>+<&X2&>');

%% Prepare Input Object
% The above prepared object can be added to an Input Object
Xinput=Input('CXmembers',{Xrvset Xsum XmaxSum},'CSmembers',{'Xrvset' 'Xsum' 'XmaxSum'});
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
Xperfun = PerformanceFunction('Sdemand','Xsum','Scapacity','XmaxSum','Soutputname','Vg');
% Define a Probabilistic Model
XprobModel=ProbabilisticModel('Xmodel',Xmodel,'XperformanceFunction',Xperfun);

%% Compute a DesingPoint
% The design point can be compute calling the method designPointIdentification
% of the ProbabilisticModel. If this method is called without arguments the
% DesignPoint is identified by means linear approximation of the performance
% function using the so called  method HLRF
Xdp=XprobModel.designPointIdentification;

%% Show results
display(Xdp)

%% Validate resutls
assert(max(Xdp.VDesignPointPhysical-[1 1]<0.001),'openCOSSAN:TutorialDesignPoint',...
    'DesignPoint not identified correctly')

%% Desing Point identified using a Optimization method (Optimizer object)
% The design point can be identified using an Optimization object. Please refer
% to the TutorialOptimizer for more details about the Optimizer objects. 
[Xdp2, Xopt2]=XprobModel.designPointIdentification('Xoptimizer',Cobyla);
display(Xdp2)
% Show results
h1=Xopt2.plotObjectiveFunction;
h2=Xopt2.plotConstraint;

Xga=GeneticAlgorithms('Npopulationsize',5,'NmaxIterations',10,'Smutationfcn','mutationadaptfeasible');
[Xdp3, Xopt3]=XprobModel.designPointIdentification('Xoptimizer',Xga);
display(Xdp3)
h3=Xopt3.plotObjectiveFunction;
h4=Xopt3.plotConstraint;

%% Close figures
close(h1),close(h2),close(h3),close(h4)

%% CASE B
% This second example considers normal distributions but with different means
% and standard deviations.


%% Preparation of the Input

% Definition of the Parameters
Xmax=Parameter('value',4);

% Definition of the Random Varibles
X1=RandomVariable('Sdistribution','normal','mean',6,'std',2,'Sdescription','First random variable');
X2=RandomVariable('Sdistribution','normal','mean',5,'std',3,'Sdescription','Second random variable');

Xrvset=RandomVariableSet('Cmembers',{'X1' 'X2'});

Xsamples = sample(Xrvset,1000);

% Plot realizations of the inputs
f1=figure;
scatter(gca(f1),Xsamples.MsamplesPhysicalSpace(:,1),Xsamples.MsamplesPhysicalSpace(:,2))
hold(gca(f1),'on');
x1 = -2:0.01:8;
x2 = 3*x1+4;
plot(gca(f1),x1,x2); 
grid(gca(f1),'on');
axis(gca(f1),'equal');
title(gca(f1),'Physical space')

f2=figure;
scatter(gca(f2),Xsamples.MsamplesStandardNormalSpace(:,1),Xsamples.MsamplesStandardNormalSpace(:,2))
hold(gca(f2),'on');
x1 = Xrvset.map2stdnorm(Xsamples.MsamplesPhysicalSpace);
plot(gca(f2),x1,2*x1+17/3);  
%plot(gca(f2),x1,-1/2*x1,'y'); 
grid(gca(f2),'on');
axis(gca(f2),[-4 4 -4 4]);
title(gca(f2),'Standard normal space')


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
Xmc=MonteCarlo('Nsamples',1e4);
Xpf=XprobModel.computeFailureProbability(Xmc);

% The estimated failure probability is around 5.1e-3.
display(Xpf)

%% Compute a DesingPoint
% The design point can be compute calling the method designPointIdentification
% of the ProbabilisticModel. If this method is called without arguments the
% DesignPoint is identified by means linear approximation of the performance
% function using the so called  method HLRF
Xdp=XprobModel.designPointIdentification;

%% Show results
display(Xdp)

% Plot identified DesignPoint in a red color
% Add design point to the figures
scatter(gca(f1),Xdp.VDesignPointPhysical(1),Xdp.VDesignPointPhysical(2),'rp','SizeData',90)
scatter(gca(f2),Xdp.VDesignPointStdNormal(1),Xdp.VDesignPointStdNormal(2),'rp','SizeData',90)

%% Validate resutls
assert(all(max(Xdp.VDesignPointStdNormal-[-34/15 17/15])<0.001),'openCOSSAN:TutorialDesignPoint',...
    'DesignPoint not identified correctly')

%% Desing Point identified usinf a Optimization method (Optimizer object)
% The design point can be identified using an Optimization object. Please refer
% to the TutorialOptimizer for more details about the Optimizer objects. 
Xdp2=XprobModel.designPointIdentification('Xoptimizer',Cobyla);
display(Xdp2)

% Plot identified DesignPoint in a magenta color
scatter(gca(f1),Xdp2.VDesignPointPhysical(1),Xdp2.VDesignPointPhysical(2),'mp','SizeData',90)
scatter(gca(f2),Xdp2.VDesignPointStdNormal(1),Xdp2.VDesignPointStdNormal(2),'mp','SizeData',90)

Xga=GeneticAlgorithms('Npopulationsize',5,'NmaxIterations',10,'Smutationfcn','mutationgaussian');
[Xdp3, Xopt]=XprobModel.designPointIdentification('Xoptimizer',Xga);
display(Xdp3)

% Plot identified DesignPoint in a black color
scatter(gca(f1),Xdp3.VDesignPointPhysical(1),Xdp2.VDesignPointPhysical(2),'kp','SizeData',90)
scatter(gca(f2),Xdp3.VDesignPointStdNormal(1),Xdp2.VDesignPointStdNormal(2),'kp','SizeData',90)

f3=Xopt.plotObjectiveFunction;
f4=Xopt.plotConstraint;

%% Close figures
close(f1),close(f2),close(f3),close(f4)
