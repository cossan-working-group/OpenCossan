%% Tutorial of subset simulation
% In this simple tutorial  the probability of having a a variable (distributed
% according to a normal distribution) less than -3 is estimated using Subset
% simulation 
% 
% The analytical sulution is equal 0.0013
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@SubSet
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author:~Edoardo~Patelli$ 

%% Probalem Definition
% Definition of Random Variable
Xrv1    = RandomVariable('Sdistribution','normal','mean',0,'std',1);

% Definition of Set of Random Variable 
Xrvs    = RandomVariableSet('Cmembers',{'Xrv1'},'Xrv',Xrv1);

% Define the parameter
% it is equal to -3 (the threshold value)
Xpar=Parameter('Sdescription','Define Capacity','value',-3);

% Define of the Input object
Xin     = Input(); 
Xin     = add(Xin,'Xmember',Xrvs,'Sname','Xrvs');
Xin = Xin.add('Xmember',Xpar,'Sname','Xpar');


% Define a Model
Xmdl= Model('Xinput',Xin,'Xevaluator',Evaluator);

% Construct the performance function
Xperfun=PerformanceFunction('Scapacity','Xrv1','Sdemand','Xpar','Soutputname','Vg1');

% Define a ProbabilisticModel
Xpm=ProbabilisticModel('Xmodel',Xmdl,'XPerformanceFunction',Xperfun);

%% Construct a SubSet simulation object
% Define the simulation object
Xss=SubSet('Nmaxlevels',10,'target_pf',0.1, ...
    'Ninitialsamples',100,'Nsamples',10000, ...
    'Nbatches',1,'Vdeltaxi',[.2 .3 .4 .5 .6 .7]);

% It is not possible to apply the SubSet object to a Model but only the
% method pf is available

%% Performe subset simulation
[Xpf]=Xpm.computeFailureProbability(Xss);

display(Xpf)
% display(Xo)

%% New simulation
% Reset random number stream
OpenCossan.resetRandomNumberGenerator(51125)

Xss=SubSet('Nmaxlevels',6,'target_pf',0.1, ...
    'Ninitialsamples',500, ...
    'Nbatches',1,'Vdeltaxi',[.2 .3 .4 .5 .6 .7]);

Xpf2=Xpm.computeFailureProbability(Xss);
display(Xpf2)

%% Test new subset algorithms
Xss=SubSet('Nmaxlevels',6,'target_pf',0.1, ...
    'Ninitialsamples',500, 'Nbatches',1,'VproposalStd',1);

Xpf2=Xpm.computeFailureProbability(Xss);
display(Xpf2)

%% Analytical solutions
normcdf(-3)

%% Check Reference solution
Xmc=MonteCarlo('Nsamples',100000,'Nbatches',10);
Xrefsol=computeFailureProbability(Xpm,Xmc);
display(Xrefsol)    % Show FailureProbability object

%% Validate Solutions
assert(abs(Xrefsol.pfhat-Xpf.pfhat)<1e-3,'openCOSSAN:Tutorials','Wrong results')
