%% Tutorial for the Advanced Line Sampling Object
% This tutorial shows the basic usage of the Advanced Line Sampling
% method. The tutorial solves simple academic examples that are not
% necessarly realistic. 
%
% Advanced Line Sampling is based on the paper: 
%
% de Angelis, M.; Patelli, E. & Beer, M. 
% Advanced line sampling for efficient robust reliability analysis
% Structural safety, Elsevier, 2015, 52, 170-182 
% https://doi.org/10.1016/j.strusafe.2014.10.002
% 
%
% See Also: https://cossan.co.uk/wiki/index.php/@AdvancedLineSampling
%
% See Also:  TutorialLineSampling 
%
% $Copyright~2006-2018,~COSSAN~Working~Group$
% $Author: Marco~de~Angelis and Edoardo-Patelli$ 

%% Example Nonlinear limit state with saddle point
% The example is taken from "Der Kiureghian and Lin, 1987. J Eng Mech Div
% ASCE" (Eq.20 page 1218).
% https://ascelibrary.org/doi/pdf/10.1061/%28ASCE%290733-9399%281987%29113%3A8%281208%29
% 
% The limit state function is defined as
% $g(x_1,x_2)=2-x_2-0.1*x_1^2+0.06*x_1^3$ where $x_1$ and $x_2$ are 2
% standar normal random variables ($x_1=x_2=\sim N(0,1)$).
% The reference solution is $P_f= 3.46e-2$;

% Define the random variables of the problem
X1=RandomVariable('Sdistribution','normal', 'mean',0,'var',1);
X2=RandomVariable('Sdistribution','normal', 'mean',0,'var',1);

% Construct the RandomVariableSet
Xrvs=RandomVariableSet('CSmembers',{'X1', 'X2'},...
    'CXrandomVariables',{X1, X2});
% Define the input object
Xinput = Input('Sdescription','Input Object', ...
    'CXmembers',{Xrvs},'CSmembers',{'Xrvs'});

% Define an empty Evaluator (i.e. how our model is evaluated)
Xevaluator = Evaluator;

% Define the ProbabilisticModel
Xmodel=Model('Xevaluator',Xevaluator,'Xinput',Xinput);
%
Xmio_performance=Mio(...
    'Sdescription', 'Matlab I-O for the performance function',...
    'Sscript','Moutput=2-Minput(:,2)-0.1*Minput(:,1).^2+0.06*Minput(:,1).^3;',...
    'Liostructure',false,...
    'Liomatrix',true,...
    'Lfunction',false,...
    'Cinputnames',{'X1','X2'},...
    'Coutputnames',{'Vg'});

% Create the performance function object
Xperformance=PerformanceFunction('Sdescription','My Performance Function', ...
    'Xmio',Xmio_performance);

% Construct the Probabilisti Model object
XprobModel=ProbabilisticModel('Sdescription','Defines our reliability analysis',...
    'Xmodel',Xmodel,'XperformanceFunction',Xperformance);

%% Compute reference solution using Monte Carlo method.
% Generate 10 random realization of the input
Xmc = MonteCarlo('Nsamples',1e6,'Nbatches',10);
% Check the Model object
XpfMC = Xmc.computeFailureProbability(XprobModel);
% Show Results
display(XpfMC);

%% Here we go. 
% Line Sampling method requires the definition of an important direction.
% This is obtained by calculating the gradient in starndard normal space. 
% The LocalSensitivityFiniteDifference object provides a method to do
% compute the gradinent in standard normal space. 

%% Define an Important Direction
% Construct the Local Sensitivity by Finite Difference
Xlsfd=LocalSensitivityFiniteDifference('Xtarget',XprobModel, ...
    'Coutputnames',{'Vg'});

% Compute the Gradient
XgradSNS = Xlsfd.computeGradientStandardNormalSpace;
display(XgradSNS)
% Since all the random variables are standard normal distributed there is
% no difference between the Gradient computed in the physical space and in
% the Standard Normal Space  
XgradPhysicalSpace = Xlsfd.computeGradient;
display(XgradPhysicalSpace)

assert(all(XgradSNS.Valpha==XgradPhysicalSpace.Valpha),....
    'OpenCossan:TutorialAdvancedLineSampling:wrongDirection',...
    'The gradient in standard normal space and in physical space should be identical')

%% Create the Advanced Line Sampling object
% Advanced line sampling can be created by defining only the numeber of
% lines. The methods computes automatically the direction based on the
% gradient computed in standard normal space 
Xals1 = AdaptiveLineSampling('Nlines',50);
[XpfLS1,XoutLS1]=XprobModel.computeFailureProbability(Xals1);
display(XpfLS1)

%% Post process the results
% Create Line Data output object
SperfName=XprobModel.XperformanceFunction.Soutputname;
XlineData=LineData('Sdescription','My first Line Data object',...
    'Xals',Xals1,'LdeleteResults',false,...
    'Sperformancefunctionname',SperfName,...
    'Xinput',Xinput);
% plot limit state
XlineData.plotLimitState('XsimulationData',Xout,'Xmodel',XprobModel);
XlineData.plotLines
%%
% It is possible to specify manually the important direction an the maximum
% number of allowed direction updating 
Xals2 = AdaptiveLineSampling('Nlines',60,...
    'Vdirectionphysical',[-1,1],'NeffectiveUpdates',5);
[XpfLS2,XoutLS2]=XprobModel.computeFailureProbability(Xals2);
display(XpfLS2)

%% Reference solution
% pF_ref = 3.47e-2; (Der Kiureghian and Lin, 1987. J Eng Mech Div ASCE)
%% Estimate the Failure Probability
% Reset random number stream
OpenCossan.resetRandomNumberGenerator(51125) 
[Xpf,Xout]=XprobModel.computeFailureProbability(Xals1);
display(Xpf)

