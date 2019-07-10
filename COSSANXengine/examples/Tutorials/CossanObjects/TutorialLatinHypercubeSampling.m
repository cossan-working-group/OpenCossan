%% Tutorial for the LatinHypercubeSampling class
%
% This tutorial is focus on the use and definition of the
% LatinHypercubeSampling class
%
% See Also: https://cossan.co.uk/wiki/index.php/@LatinHypercubeSampling
%
% $Copyright~1993-2019,~COSSAN~Working~Group$
% $Author: Edoardo~Patelli$ 

%% Problem Definition
% Here we define our problem

% Define RandomVariable
RV1=RandomVariable('Sdistribution','normal', 'mean',2,'std',1); %#ok<SNASGU>
RV2=RandomVariable('Sdistribution','normal', 'mean',0,'std',2); %#ok<SNASGU>
Xdemand=Parameter('Sdescription','Define threshold','value',0);

% Define the RandomVariableSet
Xrvs1=RandomVariableSet('Cmembers',{'RV1', 'RV2'});

% Construct Input Object
Xin = Input('Sdescription','Input Object of our model');
Xin = Xin.add('Xmember',Xrvs1,'Sname','Xrvs1');
Xin = Xin.add('Xmember',Xdemand,'Sname','Xdemand');

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
Xo = Xmdl.apply(Xin);

% Show Results
display(Xo);

%% Define LatinHypercubeSampling object
% The LatinHypercubeSampling class can be defined and used like the
% MonteCarlo

Xlhs=LatinHypercubeSampling('Nsamples',10,'Nbatches',2);


%% Perform LatinHypercubeSampling simulation
Xo=Xlhs.apply(Xmdl); % The simulation is performed adopting the
% number of samples defined in the object Xis
% Use Xin.Nsamples to retrive the number of
% samples defined
display(Xo)

Xlhs.Nsamples=200;
Xo=Xlhs.apply(Xmdl);
display(Xo)
%% Generate samples with Latin Hypercube sampling object
% The method samples accept as input also Input object or RandomVariableSet object
Xsmp=Xlhs.sample('Nsamples',5,'Xinput',Xin);
display(Xsmp)

Xsmp=Xlhs.sample('Nsamples',7,'Xrandomvariableset',Xrvs1);
display(Xsmp)
%% Apply the LatinHypercubeSampling simulation method to a ProbabilisticModel
% Define a probabilistic model (Requires a Model object and a PerfomanceFunction object
% Construct the performance function
Xpf=PerformanceFunction('Sdemand','Xdemand','Scapacity','out','SoutputName','Vg');
% Construct a ProbabilisticModel Object
Xpm=ProbabilisticModel('Xmodel',Xmdl,'XperformanceFunction',Xpf);
% now we can apply the ImportanceSampling object to the
% ProbabilisticModel
Xo=Xlhs.apply(Xpm);
display(Xo)
% The object Xo contains now also the estimation of the performance
% function.

% In order to estimate the failure probability the method pf of the object ImportanceSampling should
% be used
Xlhs.Lsmooth=true;
Xpf=Xpm.computeFailureProbability(Xlhs);
display(Xpf)


% Reset random number stream
OpenCossan.resetRandomNumberGenerator(51125)

% Change Flag of the generation of the samples
Xlhs.Lsmooth=false;
[Xpf, Xo]=Xpm.computeFailureProbability(Xlhs);
display(Xpf)
display(Xo)

%% Validate Solutions
assert(abs(Xpf.pfhat-0.8049)<1e-4,'openCOSSAN:Tutorials','Wrong results')
