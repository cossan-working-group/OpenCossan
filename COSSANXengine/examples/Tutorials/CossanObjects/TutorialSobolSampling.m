%% Tutorial for the SobolSampling class
%
% This tutorial is focus on the use and definition of the
% SobolSampling class
%
% See Also: http://cossan.co.uk/wiki/index.php/@SobolSampling
%
% $Copyright~1993-2019,~COSSAN~Working~Group$
% $Author:~Edoardo~Patelli $ 

%% Problem Definition
% Here we define our problem. It does not represent any physical problem.

%% Define the Input
% Define RandomVariable
RV1=RandomVariable('Sdistribution','normal', 'mean',2,'std',1);
RV2=RandomVariable('Sdistribution','normal', 'mean',0,'std',2);
% Define the RandomVariableSet
Xrvs1=RandomVariableSet('Cmembers',{'RV1', 'RV2'});
Xdemand=Parameter('Sdescription','Define threshold','value',0);
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

Xo = apply(Xmdl,Xin);
% Show Results
display(Xo)

%% Here we go!!!
% Now we define the SobolSampling object and try to generate samples from
% this object

%% Define SobolSampling object
% Can the SobolSampling class be constructed and used like the
% MonteCarlo class?
try
    % Let's try
    Xss=SobolSampling('Nsamples',10,'Nbatches',2);
catch ME
    OpenCossan.cossanDisp(ME.message)
    % It is mandatory to define the field Leap and Skip
    Xss=SobolSampling('Nsamples',10,'Nbatches',2,'NLeap',100,'NSkip',10);
end

%% Generate samples with Sobol Sampling object
% The method samples accept as input also Input object or RandomVariableSet object
% These object are only used to retrieve the number of random variable
% (Nrv)

Xsmp=Xss.sample('Nsamples',5,'Xinput',Xin);
display(Xsmp);

Xsmp=Xss.sample('Nsamples',7,'Xrandomvariableset',Xrvs1);
display(Xsmp);

%% Perform HaltonSampling simulation
Xo=Xss.apply(Xmdl); % The simulation is performed adopting the
% number of samples defined in the object Xss
% Use Xss.Nsamples to retrive the number of
% samples defined
display(Xo);

Xss.Nsamples=200;
Xo=Xss.apply(Xmdl);
display(Xo);


%% Apply the SobolSampling simulation method to a ProbabilisticModel
% Define a probabilistic model (Requires a Model object and a PerfomanceFunction object
% Construct the performance function
Xpf=PerformanceFunction('Sdemand','Xdemand','Scapacity','out','SoutputName','Vg');
% Construct a ProbabilisticModel Object
Xpm=ProbabilisticModel('Xmodel',Xmdl,'XperformanceFunction',Xpf);
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

% Reset random number stream
OpenCossan.resetRandomNumberGenerator(51125)

% Change Flag of the generation of the samples
Xss.Nskip=25;
[Xpf Xo]=Xpm.computeFailureProbability(Xss);
display(Xpf);
display(Xo);

%% Validate Solutions
assert(abs(Xpf.pfhat-0.81)<1e-4,'openCOSSAN:Tutorials','Wrong results')
