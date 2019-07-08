%% Tutorial for the Importance Sampling method
% This tutorial is focus on the use and definition of the Importance Samplincg
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@ImportanceSampling
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
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
RV1=RandomVariable('Sdistribution','normal', 'mean',2,'std',1);
RV2=RandomVariable('Sdistribution','normal', 'mean',0,'std',2);
% Define the RandomVariableSet
Xrvs1=RandomVariableSet('Cmembers',{'RV1', 'RV2'});
% Construct Input Object
Xin = Input('Sdescription','Input Object of our model');
Xin = Xin.add('Xmember',Xrvs1,'Sname','Xrvs1');
Xthreshold=Parameter('value',1);
Xin = Xin.add('Xmember',Xthreshold,'Sname','Xthreshold');

%% Define the Evaluator (i.e. how our model is evaluate)
% Construct a Mio object
Xm=Mio( 'Sdescription', 'This is our Model', ...
    'Sscript','for j=1:length(Tinput), Toutput(j).out=-Tinput(j).RV1+Tinput(j).RV2; end', ...
    'Liostructure',true,...
    'Coutputnames',{'out'},...
    'Cinputnames',{'RV1','RV2'},...
    'Lfunction',false); % This flag specify if the .m file is a script or a function.
% Construct the Evaluator
Xeval = Evaluator('Xmio',Xm,'Sdescription','Evaluator for the IS tutorial');

%% Define the Physical Model based on the Input and the Evaluator
Xmdl=Model('Xevaluator',Xeval,'Xinput',Xin);

%% Define ImportanceSampling object
% The InportanceSampling object required the definition of a "Proposal
% Sampling Distribution".
% A. Define the proposal distribution
RV3=RandomVariable('Sdistribution','normal', 'mean',0,'std',1); %#ok<NASGU>
RV4=RandomVariable('Sdistribution','normal', 'mean',0,'std',1); %#ok<NASGU>
XrvsIS=RandomVariableSet('Cmembers',{'RV3';'RV4'});
% Define the mapping between the random variables present in the Importance
% Sampling distribution and the random variable defined in the problem
Cmapping={'RV3' 'RV1'; 'RV4' 'RV2'};
% Construct the Simulation object
Xis=ImportanceSampling('Nsamples',10,'Nbatches',2,'CXrvset',{XrvsIS},'Cmapping',Cmapping);

%% Perform IS simulation
Xo=Xis.apply(Xmdl);
% Show summary of the results
display(Xo)
% The simulation is performed adopting the number of samples defined in the
% object Xis. Use Xin.Nsamples to retrive the number of samples defined

Xis.Nsamples=200;
Xo=Xis.apply(Xmdl);
% Show summary of the results
display(Xo)

% If you need to define the name of variable used to store the weights use
% the field SweightsName of the ImportanceSampling object
Xis.SweightsName='myWeights';
display(Xo)
% The weights are magically stored in the SimulationData ;)

%% Redifine the proposal distribution
% it is possible to define the proposal distribution only for selected
% random variable.
% The cellarray Cmapping is used to perform this ckeck!
Cmapping={'RV3' 'RV1'}; % Now only the distribution of the RV1 is replace
% The original distribution is used for RV2

Xis=ImportanceSampling('Nsamples',10,'Nbatches',2,'CXrvset',{XrvsIS},'Cmapping',Cmapping);

% Perform IS simulation
Xo=Xis.apply(Xmdl);
display(Xo)

%% Apply the Importance sampling simulation method to a ProbabilisticModel
% Define a probabilisti model (Requires a Model object and a PerfomanceFunction object
% Construct the performance function

%% Construct the performance function
Xpf=PerformanceFunction('Scapacity','Xthreshold','Sdemand','out','Soutputname','Vg');

% Construct a ProbabilisticModel Object
Xpm=ProbabilisticModel('Xmodel',Xmdl,'XperformanceFunction',Xpf);
% now we can apply the ImportanceSampling object and estimate also
% the performance function
% ProbabilisticModel
Xopf=Xis.apply(Xpm);
display(Xopf)

Xopf.getValues('Sname',Xpf.Soutputname)


%% Check the weights
% use as Importance Sampling density the same distribution of RV1 and RV2.
% By doing so, all the weigth must be equal 1!
RV3=RV1; %#ok<SNASGU>
RV4=RV2; %#ok<SNASGU>
XrvsIS=RandomVariableSet('Cmembers',{'RV3';'RV4'});
Cmapping={'RV3' 'RV1'; 'RV4' 'RV2'};
% Construct the Simulation object
Xis=ImportanceSampling('Nsamples',10,'Nbatches',2,'CXrvset',{XrvsIS},'Cmapping',Cmapping);

XoTest=Xis.apply(Xpm);
display(XoTest)
XoTest.getValues('Sname',Xis.SweightsName)


%% Automatically compute the proposal density. 
% The flag Lcomputedesignpoint allows to (re)-computed automatically the
% desing point at run time and then to used the estimated design point to
% define the proposal distribution. 
% This feature is extremly important in the optimization procedures or in
% Reliability Based Optimization analysis. 

XisAuto=ImportanceSampling('Nsamples',10,'Nbatches',2,'LcomputeDesignPoint',true);
display(XisAuto)

% Apply Importance Sampling
XoAuto=XisAuto.apply(Xpm);
display(XoAuto)

% Compute the Failure Probability
XisAuto=ImportanceSampling('Nsamples',1000,'Nbatches',2,'LcomputeDesignPoint',true);
XpfAuto=XisAuto.computeFailureProbability(Xpm);
display(XpfAuto)

%% Estimate the Failure Probability
% Set RandomNumber stream
OpenCossan.resetRandomNumberGenerator(51125)
Xpf=Xis.computeFailureProbability(Xpm);
display(Xpf)

% Verificate the procedure
Xis.Nbatches=1;
Xis.Nsamples=20000;
Xmc=MonteCarlo('Nsamples',1e5);
XpfMC=computeFailureProbability(Xpm,Xmc);
XpfIS=computeFailureProbability(Xpm,Xis);

display(XpfMC)
display(XpfIS)

%% Validate Solutions
assert(abs(Xpf.pfhat-0.2)<1e-4,'openCOSSAN:Tutorials','Wrong results')
