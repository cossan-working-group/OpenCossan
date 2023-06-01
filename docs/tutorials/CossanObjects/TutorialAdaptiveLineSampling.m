%% Tutorial for the Adaptive Line Sampling Object
%
% This tutorial tests the use of the Adaptive Line Sampling method.
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@AdvancedLineSampling
%
% $Author:~Marco~de~Angelis$ 

clear;
close all
clc;
%% Example 3: Nonlinear limit state with saddle point
% Define the random variables of the problem
X1=opencossan.common.inputs.random.NormalRandomVariable('mean',0,'std',1);    
X2=opencossan.common.inputs.random.NormalRandomVariable('mean',0,'std',1);

% Define the RandomVariableSet
Xrvs=opencossan.common.inputs.random.RandomVariableSet('members',[X1;X2],...
    'names',{"X1","X2"});
% Define the input object
Xinput = opencossan.common.inputs.Input('Members',{Xrvs},'MembersNames',{'Xrvs'});

%% Define the Evaluator (i.e. how our model is evaluated)
% Construct a Mio object
Xmio_model=opencossan.workers.Mio('Description', 'Matlab I-O for the performance model',...
    'Script',...
    'Moutput=2-Minput(:,2)-0.1*Minput(:,1).^2+0.06*Minput(:,1).^3;',...
    'Format','matrix',...
...    'Liostructure',false,...
...    'Liomatrix',true,...
    'IsFunction',false,...
    'OutputNames',{'performance_function'},...
    'InputNames',{'X1' 'X2'});
% Construct the evaluator object
Xevaluator = opencossan.workers.Evaluator('Xmio',Xmio_model);
%% Define the physical model
Xmodel=opencossan.common.Model('Xevaluator',Xevaluator,'Xinput',Xinput);
% Test the Model
% Generate 10 random realization of the input
Xinput = sample(Xinput,'Nsamples',10);
% Check the Model object
Xo = apply(Xmodel,Xinput);
% Show Results
display(Xo);
%% Define the Probabilistic Model
Xmio_performance=opencossan.reliability.PerformanceFunction('Description', 'Matlab I-O for the performance function',...
    'Script','Moutput=Minput;',...
    'Format','matrix',...
...     'Liostructure',false,...
...     'Liomatrix',true,...
    'IsFunction',false,...
    'Inputnames',{'performance_function'},...
    'OutputName',{'Vg'});
% % Create the performance function object
% Xperformance=PerformanceFunction('Sdescription','My Performance Function', ...
%     'Xmio',Xmio_performance);
% Construct the Probabilisti Model object
XprobModel=opencossan.reliability.ProbabilisticModel('Xmodel',Xmodel,'XperformanceFunction',Xmio_performance);
%% Define an Important Direction
% Construct the Local Sensitivity by Finite Difference
Xlsfd=opencossan.sensitivity.LocalSensitivityFiniteDifference('Xtarget',XprobModel, ...
    'Coutputnames',{'Vg'});
% Compute the Gradient
Xgrad = Xlsfd.computeGradient;
ValphaGRA= -Xgrad.Valpha;
% Compute the Indeces
Xinde = Xlsfd.computeIndices;
ValphaLSM= -Xinde.Valpha;
%% Create the Advanced Line Sampling object
% Use direction computed in the standard normal space
% Xals1 = AdaptiveLineSampling('Nlines',30,...
%     'Vdirectionstandardspace',[-1;1]);
% Xals1 = AdaptiveLineSampling('Nlines',10,...
%     'Vdirectionphysical',[-1,1]);
Xals1 = opencossan.simulations.AdaptiveLineSampling('Nlines',10,...
    'VimportantTails',[-1,1]);
%% Compute Reference Solution
% % This can take a little while
% Xmc=MonteCarlo('Nsamples',1e5);
% [Xpfmc,Xoutmc]=XprobModel.computeFailureProbability(Xmc);
% display(Xpfmc)
%% Reference solution
% pF_ref = 3.47e-2; (Der Kiureghian and Lin, 1987. J Eng Mech Div ASCE)
%% Estimate the Failure Probability
% Reset random number stream
% OpenCossan.resetRandomNumberGenerator(51125) 
[Xpf,XlsOut]=XprobModel.computeFailureProbability(Xals1);
display(Xpf)
XlsOut.plotLimitState
% %% Post process the results
% % Create Line Data output object
% SperfName=XprobModel.XperformanceFunction.Soutputname;
% XlineData=LineData('Sdescription','My first Line Data object',...
%     'Xals',Xals1,'LdeleteResults',false,...
%     'Sperformancefunctionname',SperfName,...
%     'Xinput',Xinput);
% % plot limit state
% XlineData.plotLimitState('XsimulationData',Xout,'Xmodel',XprobModel);
% XlineData.plotLines
% %% Plot results
% % plot lines
% Xout.plotLines('Stitle','Lines of the Performance Function');
% % plot limit state function
% Xout.plotLimitState('Stitle','','Vsupport',[-5,5],'Xmodel',XprobModel);