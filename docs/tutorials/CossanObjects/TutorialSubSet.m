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
close all
clear
clc;
%% Probalem Definition
% Definition of Random Variable
Xrv1    = opencossan.common.inputs.random.NormalRandomVariable('mean',0,'std',1);

% Definition of Set of Random Variable 
Xrvs    = opencossan.common.inputs.random.RandomVariableSet('names',{'Xrv1'},'members',Xrv1);

% Define the parameter
% it is equal to -3 (the threshold value)
Xpar=opencossan.common.inputs.Parameter('Description','Define Capacity','value',-3);

% Define of the Input object
Xin     = opencossan.common.inputs.Input(); 
Xin     = add(Xin,'Member',Xrvs,'Name','Xrvset');
Xin = Xin.add('Member',Xpar,'Name','Xpar');


% Define a Model
Xmdl= opencossan.common.Model('Xinput',Xin,'Xevaluator',opencossan.workers.Evaluator);

% Construct the performance function
Xperfun= opencossan.reliability.PerformanceFunction('OutputName','Vg1','Capacity','Xrv1','Demand','Xpar');

% Define a ProbabilisticModel
Xpm= opencossan.reliability.ProbabilisticModel('Xmodel',Xmdl,'XPerformanceFunction',Xperfun);

%% Construct a SubSet simulation object
% Define the simulation object
Xss= opencossan.simulations.SubSet('Nmaxlevels',10,'target_pf',0.1, ...
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
    'Ninitialsamples',500, 'Nbatches',1,'VproposalVariance',[1]);

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
