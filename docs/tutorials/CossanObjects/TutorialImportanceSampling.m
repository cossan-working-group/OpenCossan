%% Tutorial for the Importance Sampling method
% This tutorial is focus on the use and definition of the Importance Samplincg
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@ImportanceSampling
%
% $Copyright~1993-2015,~COSSAN~Working~Group,~University~of~Liverpool,~UK$
% $Author: Edoardo~Patelli$

%% Importance Sampling Distribution
% Any kind of user define distribution can be used. It is always defined by
% a collection of RandomVariableSet. The Random Variable defined in the
% RandomVariableSet may be correlated.
% Any combination of mapping between the RandomVariable defined in the
% Importance Sampling Distribution and the Random Variables defined in the
% problem can be used
%
% Example:
% The model contains 2 RandomVariableSet: RVS1 and RVS2
% RVS1 contains RV1, RV2 and RV3 that may be correlated
% RVS2 contains RV4, RV5 that may be correlated.
%
% It is possible to define a Importance Sampling density defining a
% randomvariableset RVSIS that contains two RandomVariable, namely RV6 and
% RV7 that may be correlated.
% The distribution f(RV6,RV7) can be used instead RV3 and RV4 defined the
% followin mapping:
% Cmapping={'RV6' 'RV3'; 'RV7' 'RV4'}

%% Problem Definition
% Here we define our problem
% Define the Input
% Define RandomVariable
RV1 = opencossan.common.inputs.random.NormalRandomVariable('mean',2,'std',1);
RV2 = opencossan.common.inputs.random.NormalRandomVariable('mean',0,'std',2);
% Define the RandomVariableSet
Xrvs1 = opencossan.common.inputs.random.RandomVariableSet('names',{'RV1', 'RV2'},'members',[RV1;RV2]);
% Construct Input Object
Xthreshold = opencossan.common.inputs.Parameter('value',1);
Xin = opencossan.common.inputs.Input('members', {Xrvs1, Xthreshold}, 'names', ["Xrvs1" "Xthreshold"]);

%% Define the Evaluator (i.e. how our model is evaluate)
% Construct a Mio object
Xm = opencossan.workers.Mio(...
    'FunctionHandle', @(x) -x(:,1) + x(:, 2), ...
    'IsFunction', true, 'Format', 'matrix', ...
    'OutputNames',{'out'}, ...
    'InputNames',{'RV1','RV2'});
% Construct the Evaluator
Xeval = opencossan.workers.Evaluator('Xmio',Xm,'Sdescription','Evaluator for the IS tutorial');

%% Define the Physical Model based on the Input and the Evaluator
Xmdl = opencossan.common.Model('evaluator',Xeval,'input',Xin);

%% Define ImportanceSampling object
% The InportanceSampling object required the definition of a "Proposal
% Sampling Distribution".
% A. Define the proposal distribution
RV3=opencossan.common.inputs.random.NormalRandomVariable('mean',0,'std',1);
RV4=opencossan.common.inputs.random.NormalRandomVariable('mean',0,'std',1);

proposal = opencossan.common.inputs.random.RandomVariableSet('names',{'RV1';'RV2'}, 'members', [RV3;RV4]);

% Construct the Simulation object
Xis=opencossan.simulations.ImportanceSampling('samples',10,'proposaldistribution',proposal);

%% Perform IS simulation
Xo=Xis.apply(Xmdl);
% Show summary of the results
display(Xo)

%% Redefine the proposal distribution
% It is possible to define the proposal distribution only for selected random variables. The
% original distribution is used for RV2.

proposal = opencossan.common.inputs.random.RandomVariableSet('names',{'RV1'}, 'members', RV3);
Xis = opencossan.simulations.ImportanceSampling('samples', 10, 'proposaldistribution', proposal);

% Perform IS simulation
Xo=Xis.apply(Xmdl);
display(Xo)

%% Apply the Importance sampling simulation method to a ProbabilisticModel
% Define a probabilisti model (Requires a Model object and a PerfomanceFunction object
% Construct the performance function

%% Construct the performance function
Xpf = opencossan.reliability.PerformanceFunction('OutputName','Vg','Capacity','Xthreshold','Demand','out');

% Construct a ProbabilisticModel Object
Xpm = opencossan.reliability.ProbabilisticModel('model',Xmdl,'performanceFunction',Xpf);
% now we can apply the ImportanceSampling object and estimate also
% the performance function
% ProbabilisticModel
Xopf = Xis.apply(Xpm);
display(Xopf)

Xopf.Samples.Vg

%% Check the weights
% use as Importance Sampling density the same distribution of RV1 and RV2.
% By doing so, all the weigth must be equal 1!
% Construct the Simulation object
Xis = opencossan.simulations.ImportanceSampling('samples',10,'proposalDistribution',Xrvs1);

[XoTest, weights] = Xis.apply(Xpm);
assert(all(weights == 1));


%% Automatically compute the proposal density.
% The flag Lcomputedesignpoint allows to (re)-computed automatically the desing point at run time
% and then to used the estimated design point to define the proposal distribution. This feature is
% extremly important in the optimization procedures or in Reliability Based Optimization analysis.

XisAuto = opencossan.simulations.ImportanceSampling('samples',10);
display(XisAuto)

% Apply Importance Sampling
XoAuto = XisAuto.apply(Xpm);
display(XoAuto)

% Compute the Failure Probability
XpfAuto = XisAuto.computeFailureProbability(Xpm);
display(XpfAuto)

%% Estimate the Failure Probability
% Set RandomNumber stream
Xis = opencossan.simulations.ImportanceSampling('samples', 20000, 'seed', 51125);
Xmc = opencossan.simulations.MonteCarlo('samples', 1e5, 'seed', 51125);

% Verificate the procedure
XpfMC = Xmc.computeFailureProbability(Xpm);
XpfIS = Xis.computeFailureProbability(Xpm);

display(XpfMC)
display(XpfIS)
