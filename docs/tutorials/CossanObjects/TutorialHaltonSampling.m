%% Tutorial for the HaltonSampling class
%
% This tutorial is focus on the use and definition of the
% HaltonSampling class.
%
% See Also: http://cossan.co.uk/wiki/index.php/@DesignOfExperiment
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author: Edoardo-Patelli$ 

%% Problem Definition
% Here we define our problem. It does not represent any physical problem.

%% Define the Input
% Define RandomVariable
rv1 = opencossan.common.inputs.random.NormalRandomVariable('mean',2,'std',1);
rv2 = opencossan.common.inputs.random.NormalRandomVariable('mean',0,'std',2);

threshold = opencossan.common.inputs.Parameter('value',1);

Xin = opencossan.common.inputs.Input('Members', {rv1 rv2 threshold}, 'Names', ["rv1" "rv2" "threshold"]);

%% Define the Evaluator (i.e. how our model is evaluate)
% Construct a Mio object
Xm=opencossan.workers.Mio( 'description', 'This is our Model', ...
    'Script','for j=1:length(Tinput), Toutput(j).out=-Tinput(j).rv1+Tinput(j).rv2; end', ...
    'format','structure',...
    'OutputNames',{'out'},...
    'InputNames',{'rv1','rv2'},...
    'IsFunction',false); % This flag specify if the .m file is a script or a function.
% Construct the Evaluator

Xeval = opencossan.workers.Evaluator('Xmio',Xm,'Sdescription','Evaluator for the IS tutorial');

%% Define the Physical Model based on the Input and the Evaluator
Xmdl = opencossan.common.Model('Evaluator',Xeval,'Input',Xin);

Xhs = opencossan.simulations.HaltonSampling('samples',5,'leap',100,'skip',10, 'seed', 51125);

%% Generate samples with HaltonSampling object

Xsmp = Xhs.sample('input',Xin);
display(Xsmp)


%% Perform HaltonSampling simulation
% The simulation is performed adopting the
% number of samples defined in the object Xhs
% Use Xhs.Nsamples to retrive the number of
% samples defined
Xo=Xhs.apply(Xmdl);
display(Xo)

Xhs.NumberOfSamples = 100;
Xo=Xhs.apply(Xmdl);
display(Xo)


%% Apply the HaltonSampling simulation method to a ProbabilisticModel
% Define a probabilistic model (Requires a Model object and a PerfomanceFunction object
% Construct the performance function
%% Construct the performance function
Xpf = opencossan.reliability.PerformanceFunction('OutputName','Vg','Capacity','threshold','Demand','out');

% Construct a ProbabilisticModel Object
Xpm = opencossan.reliability.ProbabilisticModel('model',Xmdl,'performanceFunction',Xpf);
% now we can apply the ImportanceSampling object to the
% ProbabilisticModel
Xo=Xhs.apply(Xpm);
% The object Xo contains now also the estimation of the performance
% function.
display(Xo)

% In order to estimate the failure probability the method pf of the
% ProbabilisticModel object should be used
pf = Xpm.computeFailureProbability(Xhs);
display(pf)

% Change Flag of the generation of the samples
Xhs.Skip = 25;

% Set RandomNumber stream
pf = Xpm.computeFailureProbability(Xhs);
display(pf)

%% Validate Solutions
assert(abs(pf.Value-0.08) < 1e-4,'openCOSSAN:Tutorials','Wrong results')
