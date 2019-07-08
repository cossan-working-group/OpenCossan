%% Tutorial for the Line Sampling Object
%
% This tutorial is focus on the use and definition of the Line Sampling
% The line sampling is not applicable to simulate the Model since it
% required a performace function.
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@LineSampling
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author: Edoardo-Patelli and Marco-de-Angelis$ 

 
%% Problem Definition
% Here we define our problem

% Define RandomVariable
RV1=RandomVariable('Sdistribution','normal', 'mean',0,'std',1);  
RV2=RandomVariable('Sdistribution','normal', 'mean',0,'std',1);
% Define the RandomVariableSet
Xrvs1=RandomVariableSet('CSmembers',{'RV1', 'RV2'},'CXrandomVariables',{RV1, RV2});
% Add parameter for the performance function
Xthreshold=Parameter('value',2);
% Construct Input Object
Xin = Input('Sdescription','Input Object of our model', ...
    'CXmembers',{Xrvs1 Xthreshold},'CSmembers',{'Xrvs1' 'Xthreshold'});

%% Define the Evaluator (i.e. how our model is evaluate)
% Construct a Mio object
Xm=Mio('Sdescription', 'This define our Model', ...
    'Sscript','for j=1:length(Tinput), Toutput(j).out=-Tinput(j).RV1+Tinput(j).RV2+Tinput(j).RV2.^2; end', ...
    'Liostructure',true,...
    'Coutputnames',{'out'},...
    'Cinputnames',{'RV1' 'RV2'},...
    'Lfunction',false); % This flag specify if the .m file is a script or a function.
% Construct the Evaluator
Xeval = Evaluator('Xmio',Xm,'Sdescription','Evaluator for the IS tutorial');

%% Define the Physical Model based on the Input and the Evaluator
Xmdl=Model('Xevaluator',Xeval,'Xinput',Xin);

%% Test the Model
% Generate 10 random realization of the input
Xin = sample(Xin,'Nsamples',10);

% Check the Model object
Xo = apply(Xmdl,Xin);
% Show Resukts
display(Xo);


%% Define LineSampling object
% The LineSampling object requires an important direction defined by means
% of a Gradient object or a localSensitivityMeasures

XlsFD=LocalSensitivityFiniteDifference('Xmodel',Xmdl,'Coutputnames',{'out'});
% Compute the Gradient
Xgrad = XlsFD.computeGradient;


Xls =LineSampling('Nlines',20,'Xgradient',Xgrad);
 
%% Generate samples using LineSampling
Xsample=Xls.sample('Xinput',Xin);
display(Xsample)

%% Perform LineSampling simulation
Xo =Xls.apply(Xmdl);
display(Xo)

%% Apply the Line Sampling simulation method to a ProbabilisticModel
% Define a probabilisti model (Requires a Model object and a PerfomanceFunction object
% Construct the performance function
Xpf=PerformanceFunction('Scapacity','Xthreshold','Sdemand','out','Soutputname','Vg');
% Construct a ProbabilisticModel Object
Xpm=ProbabilisticModel('Xmodel',Xmdl,'XperformanceFunction',Xpf);


%% Compute Reference Solution
% This can take a while
Xmc=MonteCarlo('Nsamples',5e4);
XpfMC=Xpm.computeFailureProbability(Xmc);
display(XpfMC)

%% Compute important direction 
XlsFD=LocalSensitivityFiniteDifference('Xtarget',Xpm,'Coutputnames',{'Vg'});
XlsMC=LocalSensitivityMonteCarlo('Xtarget',Xpm,'Coutputnames',{'Vg'});

XgFD = XlsFD.computeGradient;
XgSNS=XlsMC.computeGradientStandardNormalSpace;


Xls1=LineSampling('Nlines',10,'Xgradient',XgFD,'Vset',[0.1 0.5 1 3]);
Xls2=LineSampling('Nlines',10,'Xgradient',XgSNS,'Vset',[0.1 0.5 1 3]);

%%
[Xpf1,Xout1]=Xpm.computeFailureProbability(Xls1);
[Xpf2,Xout2]=Xpm.computeFailureProbability(Xls2);

display(Xpf1)
display(Xpf2)

%%
Xout1.plotLines('Stitle','LineSampling + Gradient');
Xout2.plotLines('Stitle','LineSampling + LocalMonteCarlo');

% Change the important direction (defined in the Gradient object in the
% field Valpha)
Xgrad=Sensitivity.gradientFiniteDifferences('Xtarget',Xpm,'Coutputname',{'Vg'});
Xls=LineSampling('Nlines',20,'Xgradient',Xgrad);

% Change the number of batches and number of lines
Xls.Nbatches=2;
Xls.Nlines=20;
[Xpf,XlsData]=Xpm.computeFailureProbability(Xls);

XlsData.plotLines;

display(Xpf)    % Show FailureProbability object

%  use local sensitivity measures 
Xlsm=XlsFD.computeIndices;
Xls=LineSampling('Nlines',200,'XlocalSensitivityMeasures',Xlsm);

% Change the number of batches and number of lines
Xls.Nbatches=1;
Xls.Nlines=600;
[Xpf,XlsData]=Xpm.computeFailureProbability(Xls);

XlsData.plotLines;

display(Xpf)    % Show FailureProbability object
%%








%% Example 2: Hihgly non-linear limit state  (Grandhi and Wang, 1999. Comput Methods Appl Mech Eng)
% Define the random variables of the problem
X1=RandomVariable('Sdistribution','normal', 'mean',10,'std',3);
X2=RandomVariable('Sdistribution','normal', 'mean',10,'std',3);

% Define the RandomVariableSet
Xrvs=RandomVariableSet('CSmembers',{'X1', 'X2'},...
    'CXrandomVariables',{X1, X2});
% Define the input object
Xinput = Input('Sdescription','Input Object', ...
    'CXmembers',{Xrvs},...
    'CSmembers',{'Xrvs'});
%% Define the Evaluator (i.e. how our model is evaluated)
% Construct a Mio object
Xmio_model=Mio('Sdescription', 'This define the physical model of Example#2',...
    'Sscript',...
    'Moutput=2.5-0.2357*(Minput(:,1)-Minput(:,2))+0.00463*(Minput(:,1)+Minput(:,2)-20).^4;',...
    'Liostructure',false,...
    'Liomatrix',true,...
    'Lfunction',false,...
    'Coutputnames',{'performance_function'},...
    'Cinputnames',{'X1' 'X2'});
% Construct the evaluator object
Xevaluator = Evaluator('Xmio',Xmio_model);
%% Define the physical model
Xmodel=Model('Xevaluator',Xevaluator,'Xinput',Xinput);
% Test the Model
% Generate 10 random realization of the input
Xinput = sample(Xinput,'Nsamples',10);
% Check the Model object
Xo = apply(Xmodel,Xinput);
% Show Results
display(Xo);
%% Define the Probabilistic Model
Xmio_performance=Mio('Sdescription', 'Matlab I-O for the performance function',...
    'Sscript','Moutput=Minput;',...
    'Liostructure',false,...
    'Liomatrix',true,...
    'Lfunction',false,...
    'Cinputnames',{'performance_function'},...
    'Coutputnames',{'Vg'});
% Create the performance function object
Xperformance=PerformanceFunction('Sdescription','My Performance Function', ...
    'Xmio',Xmio_performance);
% Construct the Probabilisti Model object
XprobModel=ProbabilisticModel('Sdescription','Defines our reliability analysis',...
    'Xmodel',Xmodel,'XperformanceFunction',Xperformance);
%% Define an Important Direction
% Construct the Local Sensitivity by Finite Difference
Xlsfd=LocalSensitivityFiniteDifference('Xtarget',XprobModel, ...
    'Coutputnames',{'Vg'});
% Compute the Gradient
Xgrad = Xlsfd.computeGradient;
ValphaGRA= -Xgrad.Valpha;
% Compute the Indeces
Xinde = Xlsfd.computeIndices;
ValphaLSM= -Xinde.Valpha;
%% Create the Line Sampling object
% Use direction computed in the standard normal space
Xls1 = LineSampling('Nlines',30,'VimportanceDirection',ValphaLSM);
% Use direction provided by the gradient in the original space
Xls2 = LineSampling('Nlines',30,'VimportanceDirection',ValphaGRA);
%% Reference solution
% pF_ref  = 2.86e-3; (Grandhi and Wang, 1999. Comput Methods Appl Mech Eng)
%% Estimate the Failure Probability
% Reset random number stream
%OpenCossan.resetRandomNumberGenerator(51125) 
[Xpf1,XsimOut]=XprobModel.computeFailureProbability(Xls1);
display(Xpf1)
%% Plot results
% plot lines
Xout1.plotLines('Stitle','Lines of the Performance Function');
Xout1.plotLines('Stitle','Lines of the Performance Function');