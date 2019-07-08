%**************************************************************************
% This tutorial shows how to perform a Reliability Analysis Optimization.
% It is using the most basic component and a vary simple model 
%
%**************************************************************************
% Written by EP

% The aim of this tutorial is optimize a clmped beam under tip load considering uncertainties. 
% The performance function is defined by the maximum allowable
% stress level minus the actual stress in a clamped beam. 
%
%                                          |
% //|                                      v
% //|---------------------------------------
% //|

%% Create input 
% First at all it is necessary to define the Design Varialves. The design
% variables are those parameters that can be selected by the designer and that
% affect the performance of a system.
% In this first tutorial the deterministic Design Variable are considered

% Create Input object containing the Design Variable and the uncertatinty
% paratemters

% Define Inputs

pftarget = Parametere('Sdescription','Maximum allowed pf','value',1e-4); % yield stress
sD = RandomVariable('Sdistribution','normal','mean',8,'std',0.12*8); % yield stress
F = RandomVariable('Sdistribution','normal','mean',6000,'std',0.1*6000); % force
l = RandomVariable('Sdistribution','normal','mean',2000,'std',0.03*2000); % length of beam
b = DesignVariable('Sdescription','section width','lowerBound',150,'upperBound',170,'value',160); % section width
h = DesignVariable('Sdescription','section height','lowerBound',290,'upperBound',350,'value',320); % section %height

Xrvset = RandomVariableSet('Cmembers',{'F','l','sD'},'CXrv',{F,l,sD});   %#ok<SNASGU>

Xinp=Input('Cmembers', {'Xrvset' 'b' 'h' 'pftarget'});

%% Definition of the probabilistic model
% In order to define the probabilistic model, a matlab script that returns the
% actual stress in a clamped beam.

Xmio  = Mio('Spath','./', ...
           'Sfile','StressBeam', ...
           'Coutputnames',{'sigma'},...
           'Cinputnames',Xinp.Cnames,...
           'Liostructure',true,...
           'Lfunction',true);

% Then, the matlab script is included in an Evaluator object
Xeval=Evaluator('Xmio',Xmio);

% The evaluator and the input object are used to construct the physical model
Xm = Model('Xinput',Xinp,'Xevaluator',Xeval);

% Finally the probabilistic model is defined by means of a Performance Function
% object that compute the difference between the actual stress in a clamped beam
% (sigma) and the required demand (sD).

Xpf=PerformanceFunction('Scapacity','sigma','Sdemand','sD','Soutputname','Vg1');

Xpm=ProbabilisticModel('Xmodel',Xm,'XPerformanceFunction',Xpf);

% The above define model can be verified by performing a deterministic analysis,
% i.e. solving the problem adopting the mean (default) values for the
% DesignVariable and RandomVaribles.

Xout=Xpm.deterministicAnalysis;

% display the results of the deterministic analysis
display(Xout)



%%  Create objective function
% The objective function is to minimize the weight of the clamped beam. Since
% the weight is proportional to the Volume of the beam times the specific
% weight, the objective function can be reduce to minimize the prodoct of the
% beam section height and width. 

Xofun1   = ObjectiveFunction('Sdescription','objective function', ...
    'Sscript','for n=1:length(Tinput), Toutput(n).weight=Tinput(n).b*Tinput(n)*h; end',...
    'Cinputnames',{'b','h'},...
    'Coutputnames',{'weight'});


%% Create inequality constraint
% The constraint for this reliability optimization analysis is the reliability
% level of the clamped beam. More specifically the maximum admissible failure
% probability is defined.

Xcon   = Constrains('Sdescription','non linear inequality constraint', ...
    'Sscript','for n=1:length(Tinput),Toutput(n).Con1=2-Tinput(n).X1-Tinput(n).X2;end',...
    'Coutputnames',{'Con1'},'Cinputnames',{'pftarget','X2'},'Linequality',true);

%% define the optimizator problem
Xop     = OptimizationProblem('Sdescription','Optimization problem', ...
    'Xinput',Xin,'VinitialSolution',[-5 -1], ...
    'XobjectiveFunction',Xofun1,'Xconstrain',Xcon);

%% Create optimizer
Xcob    = Cobyla;
Xoptimum=Xop.optimize(Xcob);
display(Xoptimum)

%% 10. Reference Solution
OpenCossan.cossanDisp(' ');
OpenCossan.cossanDisp('Reference solution');
OpenCossan.cossanDisp('f(1.0,1.0) = 2.0');

