T%% Tutorial for the HaltonSampling class
%
% This tutorial is focus on the use and definition of the
% HaltonSampling class.
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@DesignOfExperiment
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author: Edoardo-Patelli$ 

%% Problem Definition
% Here we define our problem. It does not represent any physical problem.

%% Define the Input
% Define RandomVariable
RV1=RandomVariable('Sdistribution','normal', 'mean',2,'std',1); %#ok<SNASGU>
RV2=RandomVariable('Sdistribution','normal', 'mean',0,'std',2); %#ok<SNASGU>
% Define the RandomVariableSet
Xrvs1=RandomVariableSet('Cmembers',{'RV1', 'RV2'});
% Construct Input Object
Xin = Input('Sdescription','Input Object of our model');
Xthreshold=Parameter('value',1);
Xin = Xin.add('Xmember',Xthreshold,'Sname','Xthreshold');
Xin = Xin.add('Xmember',Xrvs1,'Sname','Xrvs1');

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

%% Test the Model
% Generate 10 random realization of the input
Xin = sample(Xin,'Nsamples',10);

% Evaluate the model
Xo = apply(Xmdl,Xin);

% Show Results
display(Xo)

%% Here we go!!!
% Now we define the HaltonSampling object and try to generate samples from
% this object

%% Define HaltonSampling object
% Can the HaltonSampling class be constructed and used like the
% MonteCarlo class?

try
    % Let's try
    Xhs=HaltonSampling('Nsamples',10,'Nbatches',2);
catch ME
    OpenCossan.cossanDisp(ME.message)
    % It is mandatory to define the field Leap and Skip
    Xhs=HaltonSampling('Nsamples',10,'Nbatches',2,'NLeap',100,'NSkip',10);
end

%% Generate samples with HaltonSampling object
% The method samples accept as input also Input object or RandomVariableSet object
% These object are only used to retrieve the number of random variable
% (Nrv)

Xsmp=Xhs.sample('Nsamples',5,'Xinput',Xin);
display(Xsmp)

Xsmp=Xhs.sample('Nsamples',7,'Xrandomvariableset',Xrvs1);
display(Xsmp)


%% Perform HaltonSampling simulation
% The simulation is performed adopting the
% number of samples defined in the object Xhs
% Use Xhs.Nsamples to retrive the number of
% samples defined
Xo=Xhs.apply(Xmdl);
display(Xo)

Xhs.Nsamples=200;
Xo=Xhs.apply(Xmdl);
display(Xo)


%% Apply the HaltonSampling simulation method to a ProbabilisticModel
% Define a probabilistic model (Requires a Model object and a PerfomanceFunction object
% Construct the performance function
%% Construct the performance function
Xpf=PerformanceFunction('Scapacity','Xthreshold','Sdemand','out','Soutputname','Vg');

% Construct a ProbabilisticModel Object
Xpm=ProbabilisticModel('Xmodel',Xmdl,'XperformanceFunction',Xpf);
% now we can apply the ImportanceSampling object to the
% ProbabilisticModel
Xo=Xhs.apply(Xpm);
% The object Xo contains now also the estimation of the performance
% function.
display(Xo)

% In order to estimate the failure probability the method pf of the
% ProbabilisticModel object should be used
Xpf=Xpm.computeFailureProbability(Xhs);
display(Xpf)

% Change Flag of the generation of the samples
Xhs.Nskip=25;

% Set RandomNumber stream
OpenCossan.resetRandomNumberGenerator(51125)
[Xpf, Xo]=Xpm.computeFailureProbability(Xhs);
display(Xo)
display(Xpf)

%% Validate Solutions
assert(abs(Xpf.pfhat-0.09)<1e-4,'openCOSSAN:Tutorials','Wrong results')
