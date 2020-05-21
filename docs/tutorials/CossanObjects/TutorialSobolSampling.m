%% Tutorial for the SobolSampling class
%
% This tutorial is focus on the use and definition of the
% SobolSampling class
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@SobolSampling
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author:~Edoardo~Patelli $ 
%% Problem Definition
% Here we define our problem. It does not represent any physical problem.

%% Define the Input
% Define RandomVariable
RV1=opencossan.common.inputs.random.NormalRandomVariable('mean',2,'std',1);
RV2=opencossan.common.inputs.random.NormalRandomVariable('mean',0,'std',2);
% Define the RandomVariableSet
Xrvs1=opencossan.common.inputs.random.RandomVariableSet('names',{'RV1', 'RV2'},'members',[RV1;RV2]);
Xdemand=opencossan.common.inputs.Parameter('description','Define threshold','value',0);
% Construct Input Object
Xin = opencossan.common.inputs.Input('members', {Xrvs1 Xdemand}, 'names', ["Xrvs1", "Xdemand"]);

%% Define the Evaluator (i.e. how our model is evaluate)
% Construct a Mio object
Xm=opencossan.workers.Mio( 'description', 'This is our Model', ...
    'Script','for j=1:length(Tinput), Toutput(j).out=-Tinput(j).RV1+Tinput(j).RV2; end', ...
    'format','structure',...
    'OutputNames',{'out'},...
    'InputNames',{'RV1','RV2'},...
    'IsFunction',false); % This flag specify if the .m file is a script or a function.
% Construct the Evaluator
Xeval = opencossan.workers.Evaluator('Xmio',Xm,'Sdescription','Evaluator for the IS tutorial');

%% Define the Physical Model based on the Input and the Evaluator
Xmdl=opencossan.common.Model('Evaluator',Xeval,'Input',Xin);

%% Test the Model
% Generate 10 random realization of the input
samples = sample(Xin,'samples',10);
% Evaluate the model

Xo = apply(Xmdl, samples);
% Show Results
display(Xo)


%% Define SobolSampling object
% Can the SobolSampling class be constructed and used like the
% MonteCarlo class?
try
    % Let's try
    Xss=SobolSampling('samples',5);
catch ME
    opencossan.OpenCossan.cossanDisp(ME.message)
    % It is mandatory to define the field Leap and Skip
    Xss=opencossan.simulations.SobolSampling('samples',5,'leap',100,'skip',10, 'seed', 51125);
end

%% Generate samples with Sobol Sampling object
% The method samples accept as input also Input object or RandomVariableSet object
% These object are only used to retrieve the number of random variable
% (Nrv)

Xsmp=Xss.sample('input',Xin);
display(Xsmp);


%% Perform HaltonSampling simulation
Xo=Xss.apply(Xmdl); % The simulation is performed adopting the
% number of samples defined in the object Xss
% Use Xss.Nsamples to retrive the number of
% samples defined
display(Xo);

Xss.NumberOfSamples=100;
Xo=Xss.apply(Xmdl);
display(Xo);


%% Apply the SobolSampling simulation method to a ProbabilisticModel
% Define a probabilistic model (Requires a Model object and a PerfomanceFunction object
% Construct the performance function
Xpf=opencossan.reliability.PerformanceFunction('OutputName','Vg','Demand','Xdemand','Capacity','out');
% Construct a ProbabilisticModel Object
Xpm=opencossan.reliability.ProbabilisticModel('model',Xmdl,'performanceFunction',Xpf);
% now we can apply the ImportanceSampling object to the
% ProbabilisticModel
Xo=Xss.apply(Xpm);
display(Xo);
% The object Xo contains now also the estimation of the performance
% function.

% In order to estimate the failure probability the method pf of the
% ProbabilisticModel object should be used

Xpf=Xpm.computeFailureProbability(Xss);
display(Xpf);

% Change Flag of the generation of the samples
Xss.Skip=25;
Xpf = Xpm.computeFailureProbability(Xss);
display(Xpf);

%% Validate Solutions
assert(abs(Xpf.Value-0.82)<1e-4,'openCOSSAN:Tutorials','Wrong results')
