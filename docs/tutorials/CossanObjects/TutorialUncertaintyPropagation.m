%% Tutorial for the UncertaintyPropagation
% This tutorial shows how to define an uncertainty propagation analysis.
% The  parameters associated with the problem are defined using an Input
% object  containing Interval (variables) and Imprecise Random Variables.
% A probabilistic model is required to perform the uncertainty propagation
% on the failure probability.
%
% This example computes the reliability bounds for the tip displacement of a beam.
%
% See also:
% http://cossan.cfd.liv.ac.uk/wiki/index.php/@TutorialUncertaintyPropagation
%
% $Author:~Marco~de~Angelis$
close all
clear
clc;
clear('global','NiterationsUP','Lmaximize')
%% Uncertainty propagation analysis on a simple probabilistic model
% The inputs of this example are defined by Intervals and Random Variables.
% See next section for the uncertainty propagation with imprecise random
% variables

% Construct a Mio object
Sfolder=fileparts(which('TutorialCantileverBeamMatlab.m'));     % returns the current folder
Xm=opencossan.workers.Mio('FullFileName',fullfile(Sfolder,'MatlabModel','tipDisplacement.m'), ... 
...    'Sfile','tipDisplacement.m',...
    'InputNames',{'I' 'b' 'L' 'h' 'rho' 'P' 'E'}, ...
    'OutputNames',{'w'} ... 
...    'Liostructure',true 
    );
% Construct the Evaluator
Xeval = opencossan.workers.Evaluator('Xmio',Xm,'Sdescription','myEvaluator');

%% Problem definition
% Define the uncertainty in terms of intervals only
LuseIntervalsOnly=true;
% Define the uncertainty in terms of interval random variables only
LuseIntervalHyperOnly=true;
% Define the uncertainty in terms of both intervals and interval random
% variables
LuseIntervalBoth=and(LuseIntervalsOnly,LuseIntervalHyperOnly);
%% Define the input
% Preparation of the Input
% Definition of the Parameters
maxTipDispl=opencossan.common.inputs.Parameter('value',0.0074,'description','Maximum allowed displacement');

if LuseIntervalBoth
    
        % Definition of the Interval Variables
    L=opencossan.intervals.Interval('centre',1.8,'radius',1.8*0.001,'description','Beam Length');
    b=opencossan.intervals.Interval('centre',0.12,'radius',0.12*0.01,'description','Beam width');
    h=opencossan.intervals.Interval('centre',0.24,'radius',2*0.0005,'description','Beam Heigth');
    % Define the Bounded Set
    XbsetStructural=opencossan.intervals.BoundedSet('CXintervals',{L b h},...
        'CintervalNames',{'L' 'b' 'h'});
    
    % Definition of the Random Variables
    P=RandomVariable('Sdistribution','lognormal','mean',5000,'std',40,'Sdescription','Load');
    rho=RandomVariable('Sdistribution','lognormal','mean',600,'std',14,'Sdescription','density');
    E=RandomVariable('Sdistribution','lognormal','mean',10e9,'std',1.6e8,'Sdescription','Young''s modulus');
    % Define the Random Variable Set
    XrvsetStructural=RandomVariableSet('CXrandomVariables',{P rho E},...
        'CSmembers',{'P' 'rho' 'E'});
    
    % Definition of the Interval Variables
    Pmean  =Interval('centre',5000,'radius',50,'Sdescription','Interval Mean of the Load');
    Pstd   =Interval('centre',40,'radius',0.5,'Sdescription','Interval s. deviation of the Load');
    rhomean=Interval('centre',600,'radius',5,'Sdescription','Interval Mean of the Density');
    Emean  =Interval('centre',10e9,'radius',5e7,'Sdescription','Interval Mean of the Y. module');
    Estd   =Interval('centre',1.6e8,'radius',6e6,'Sdescription','Interval s. deviation of the Y. module');
    
    % Define the Bounded Set
    XbsetHyper=BoundedSet('CXintervals',{Pmean, Pstd, rhomean, Emean, Estd},...
        'CintervalNames',{'Pmean', 'Pstd', 'rhomean', 'Emean', 'Estd'});
    
    % Definition of the Function for the second moment of area
    I=Function('Sdescription','Moment of Inertia','Sexpression','<&b&>.*<&h&>.^3/12');
    
    % TO DO: try with dependence functions
    
    % Prepare Input Object
    % Input mapping for the interval random variables
    Cmapping={'Pmean','P','mean';
                'Pstd','P','std';
                'rhomean','rho','mean';
                'Emean','E','mean';
                'Estd','E','std'};
    
    % Prepare Input Object
    % The above prepared object can be added to an Input Object
    Xin=Input('CXmembers',{XbsetStructural XrvsetStructural XbsetHyper I maxTipDispl},...
        'CSmembers',{'XbsetStructural' 'XrvsetStructural' 'XbsetHyper' 'I' 'maxTipDispl'},...
        'CinputMapping',Cmapping);
    
elseif LuseIntervalsOnly
    
    % Definition of the Interval Variables
    L=Interval('center',1.8,'radius',1.8*0.001,'Sdescription','Beam Length');
    b=Interval('center',0.12,'radius',0.12*0.01,'Sdescription','Beam width');
    h=Interval('center',0.24,'radius',2*0.0005,'Sdescription','Beam Heigth');
    % Define the Bounded Set
    Xbset=BoundedSet('CXintervals',{L b h},...
        'CintervalNames',{'L' 'b' 'h'});
    
    
    % Definition of the Random Variables
    P=RandomVariable('Sdistribution','lognormal','mean',5000,'std',40,'Sdescription','Load');
    rho=RandomVariable('Sdistribution','lognormal','mean',600,'std',14,'Sdescription','density');
    E=RandomVariable('Sdistribution','lognormal','mean',10e9,'std',1.6e8,'Sdescription','Young''s modulus');
    % Define the Random Variable Set
    Xrvset=RandomVariableSet('CXrandomVariables',{P rho E},...
        'CSmembers',{'P' 'rho' 'E'});
    
    % Definition of the Function for the second moment of area
    I=Function('Sdescription','Moment of Inertia','Sexpression','<&b&>.*<&h&>.^3/12');
    
    % TO DO: try with dependence functions
    
    % Prepare Input Object
    % The above prepared object can be added to an Input Object
    Xin=Input('CXmembers',{Xbset Xrvset I maxTipDispl},...
        'CSmembers',{'Xbset' 'Xrvset' 'I' 'maxTipDispl'});
    
elseif LuseIntervalHyperOnly
    
    % Definition of the Parameters
    L=Parameter('value',1.8,'Sdescription','Beam Length');
    b=Parameter('value',0.12,'Sdescription','Beam width');
    h=Parameter('value',0.24,'Sdescription','Beam Heigth');
    
    
    % Definition of the Random Variables
    P=RandomVariable('Sdistribution','lognormal','mean',5000,'std',40,'Sdescription','Load');
    rho=RandomVariable('Sdistribution','lognormal','mean',600,'std',14,'Sdescription','density');
    E=RandomVariable('Sdistribution','lognormal','mean',10e9,'std',1.6e8,'Sdescription','Young''s modulus');
    % Define the Random Variable Set
    Xrvset=RandomVariableSet('CXrandomVariables',{P rho E},...
        'CSmembers',{'P' 'rho' 'E'});
    
    % Definition of the Interval Variables
    Pmean  =Interval('center',5000,'radius',50,'Sdescription','Interval Mean of the Load');
    Pstd   =Interval('center',40,'radius',0.5,'Sdescription','Interval s. deviation of the Load');
    rhomean=Interval('center',600,'radius',5,'Sdescription','Interval Mean of the Density');
    Emean  =Interval('center',10e9,'radius',5e7,'Sdescription','Interval Mean of the Y. module');
    Estd   =Interval('center',1.6e8,'radius',6e6,'Sdescription','Interval s. deviation of the Y. module');
    
    % Define the Bounded Set
    Xbset=BoundedSet('CXintervals',{Pmean, Pstd, rhomean, Emean, Estd},...
        'CintervalNames',{'Pmean', 'Pstd', 'rhomean', 'Emean', 'Estd'});
    
    
    % Definition of the Function for the second moment of area
    I=Function('Sdescription','Moment of Inertia','Sexpression','<&b&>.*<&h&>.^3/12');
    
    % TO DO: introduce with dependence functions
    
    % Prepare Input Object
    % Input mapping for the interval random variables
    Cmapping={'Pmean','P','mean';
                'Pstd','P','std';
                'rhomean','rho','mean';
                'Emean','E','mean';
                'Estd','E','std'};
    % The above prepared object can be added to an Input Object
    Xin=Input('CXmembers',{Xbset, Xrvset, I, L, b, h, maxTipDispl},...
        'CSmembers',{'Xbset', 'Xrvset', 'I', 'L', 'b', 'h', 'maxTipDispl'},...
        'CinputMapping',Cmapping);
    
end

%%
% Define the Performance Function
Xperfun=PerformanceFunction('OutputName','Vg1','Capacity','maxTipDispl','Demand','w');

%  Construct the Model
Xmdl=Model('Cmembers',{'Xin','Xeval'});

% The ProbabilisticModel can also be constructed passing the object by
% references
Xpm=ProbabilisticModel('Sdescription','myProb.Model','Xmodel',Xmdl,...
    'XperformanceFunction',Xperfun);

%% Set up the uncertanty propagation analysis
% Define optimization problem
% Genetic Algorithms
XGA = GeneticAlgorithms('Npopulationsize',5,'NStallGenLimit',5,...
    'SMutationFcn','mutationadaptfeasible');

% Local optimizer
XSQP=SequentialQuadraticProgramming;

% 
XLHS=LatinHypercubeSampling('Nsamples',10);

% Define the method to compute the failure probability
XMC=MonteCarlo('Nsamples',1000);

% Define the uncertainty propagation problem
Xup=UncertaintyPropagation('Sdescription',' ',...
    'XprobabilisticModel',Xpm,...
    'Xsolver',XLHS,...
    'Xsimulator',XMC,...
    'SstatisticalQuantityName','failureProbability',...
    'LwriteTextFiles',true);

% Perform uncertainty propagation
Xextrema=Xup.computeExtrema();
display(Xextrema)

%% ONLY INTERVALS CASE
%% Results obtained with Genetic Algorithms 2000 X 10000 (Outer X Inner) 
% ==========================================================================
% Extrema object  -  Description: Solution of the Uncertainty Propagation analysis
% ==========================================================================
% ** Searching results obtained with GeneticAlgorithms method:
% ** Simulation results obtained with MonteCarlo method:
% *** [min, max] Pfhat      = [8.800e-03, 2.302e-01]
% *** CoV of the minimum    = 1.061e-01
% *** CoV of the maximum    = 1.829e-02
% ** Argument optima: 
% *** (argMin, argMax) *mean* of P   = (4.954e+03, 5.049e+03)
% *** (argMin, argMax) *std* of P   = (4.032e+01, 3.991e+01)
% *** (argMin, argMax) *mean* of rho   = (6.048e+02, 6.024e+02)
% *** (argMin, argMax) *mean* of E   = (1.004e+10, 9.954e+09)
% *** (argMin, argMax) *std* of E   = (1.627e+08, 1.635e+08)
% ** Simulation details:
% *** # samples     = 2.000e+07
% *** # iterations  =      1000
% *** # batches     =         1
% * Design variables: Pmean_dv; Pstd_dv; rhomean_dv; Emean_dv; Estd_dv; 


%% Refine the analysis using the argument optima from GA
% Xextrema=Xup.useOptima2refine(Xextrema,'NrefiningSamples',1e5); 

% The refined analysis allows computing more accurate confidence bounds for
% the failure probability estimates. Note that the argument optima have not
% changes after this second analysis. Results are as follows:
% ==========================================================================
% Extrema object  -  Description: Solution of the Uncertainty Propagation analysis
% ==========================================================================
% ** Searching results obtained with GeneticAlgorithms method:
% ** Simulation results obtained with MonteCarlo method:
% *** Pf bounds (+- 3*r)  = [4.171e-03, 2.151e-01]
% *** [min, max] Pfhat      = [6.600e-03, 2.030e-01]
% *** CoV of the minimum    = 1.227e-01
% *** CoV of the maximum    = 1.982e-02
% ** Argument optima: 
% *** (argMin, argMax) *mean* of P   = (4.952e+03, 5.046e+03)
% *** (argMin, argMax) *std* of P   = (3.974e+01, 3.990e+01)
% *** (argMin, argMax) *mean* of rho   = (6.027e+02, 6.034e+02)
% *** (argMin, argMax) *mean* of E   = (1.004e+10, 9.960e+09)
% *** (argMin, argMax) *std* of E   = (1.565e+08, 1.603e+08)
% ** Simulation details:
% *** # samples     = 1.700e+06
% *** # iterations  =       170
% *** # batches     =         1
% * Design variables: Pmean_dv; Pstd_dv; rhomean_dv; Emean_dv; Estd_dv; 
%% Results obtained with FullFactorial design (Corners Solution)
% ==========================================================================
% Extrema object  -  Description: Solution of the Uncertainty Propagation analysis
% ==========================================================================
% ** Searching results obtained with GeneticAlgorithms method:
% ** Simulation results obtained with MonteCarlo method:
% *** [min, max] Pfhat      = [5.530e-03, 2.343e-01]
% *** CoV of the minimum    = 4.241e-02
% *** CoV of the maximum    = 5.717e-03
% ** Argument optima: 
% *** (argMin, argMax) *mean* of P   = (4.950e+03, 5.050e+03)
% *** (argMin, argMax) *std* of P   = (3.950e+01, 3.950e+01)
% *** (argMin, argMax) *mean* of rho   = (5.950e+02, 6.050e+02)
% *** (argMin, argMax) *mean* of E   = (1.005e+10, 9.950e+09)
% *** (argMin, argMax) *std* of E   = (1.540e+08, 1.660e+08)
% ** Simulation details:
% *** # samples     = 3.200e+06
% *** # iterations  =        32
% *** # batches     =         1
% * Design variables: Pmean_dv; Pstd_dv; rhomean_dv; Emean_dv; Estd_dv; 
