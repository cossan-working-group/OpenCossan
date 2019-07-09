%% Tutorial for the Extreme Case analysis
% This tutorial shows how to define an extreme case analysis.
% The  parameters associated with the problem are defined using an Input
% object  containing Interval (variables) and Imprecise Random Variables.
% A probabilistic model is required to perform the uncertainty propagation
% on the failure probability, which allows computing a failure probability.
%
% This example computes the reliability bounds for the tip displacement of a beam.
%
% See also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@TutorialExtremeCase
%
% $Author:~Marco~de~Angelis$
% Institute for Risk and Uncertainty, University of Liverpool, UK
% email address: openengine@cossan.co.uk
% Website: http://www.cossan.co.uk

clear
close all
clc;

import common.inputs.*
import reliability.ProbabilisticModel.*
import reliability.PerformanceFunction.*
import intervals.*

%% Working path
% OpenCossan.setWorkingPath(fullfile('/Users','mda','Documents','MATLAB','workingPath'))
%% delete stuff
% TODO: DO NOT PRODUCE STUFF!
clear('global','NiterationsEC','NevaluationsEC','Lmaximize')
%% Uncertainty propagation analysis on a simple probabilistic model
% The inputs of this example are defined by Intervals and Random Variables.
% See next section for the uncertainty propagation with imprecise random
% variables

% Construct a Mio object
Sfolder=fileparts(which('TutorialCantileverBeamMatlab.m'));     % returns the current folder
Xm=opencossan.workers.Mio('FullFileName',fullfile(Sfolder,'MatlabModel'), ...'Sfile','tipDisplacement.m',...
    'InputNames',{'I' 'b' 'L' 'h' 'rho' 'P' 'E'}, ...
    'OutputNames',{'w'},'Format','structure');
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
% Set the optimization problem as evolutionary algorithm
LuseGeneticAlgorithms=false;
%% Define the input
% Preparation of the Input
% Definition of the Parameters
maxTipDispl=opencossan.common.inputs.Parameter('value',0.0074,'description','Maximum allowed displacement');

% TODO: Do not use if condition in the Tutorial but write different cases!
% With a mimimal explanation.

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
    L=Interval('centre',1.8,'radius',1.8*0.001,'Sdescription','Beam Length');
    b=Interval('centre',0.12,'radius',0.12*0.01,'Sdescription','Beam width');
    h=Interval('centre',0.24,'radius',2*0.0005,'Sdescription','Beam Heigth');
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
    Pmean  =Interval('centre',5000,'radius',50,'Sdescription','Interval Mean of the Load');
    Pstd   =Interval('centre',40,'radius',0.5,'Sdescription','Interval s. deviation of the Load');
    rhomean=Interval('centre',600,'radius',5,'Sdescription','Interval Mean of the Density');
    Emean  =Interval('centre',10e9,'radius',5e7,'Sdescription','Interval Mean of the Y. module');
    Estd   =Interval('centre',1.6e8,'radius',6e6,'Sdescription','Interval s. deviation of the Y. module');
    
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
Xperfun=PerformanceFunction('OutpoutName','Vg1','Capacity','maxTipDispl','Demand','w');

%  Construct the Model
Xmdl=common.Model('Cmembers',{'Xin','Xeval'});

% The ProbabilisticModel can also be constructed passing the object by
% references
Xpm=ProbabilisticModel('Sdescription','myProb.Model','Xmodel',Xmdl,...
    'XperformanceFunction',Xperfun);

%% Set up the Extreme Case analysis

%% Define an initial direction to start the analysis

% Define the Monte Carlo simulator
% TODO: This will be merged with LineSampling
Xals = simulations.AdaptiveLineSampling('Nlines',7,'NmaxPoints',10);

% TODO: Don't you think that this object requires too many inputs?

% Create the Extreme Case object
XextremeCase = ExtremeCase('Sdescription','', ...
    ...'StempPath',fullfile(OpenCossan.getCossanWorkingPath,'ExtremeCaseResults#1'),...
    'SexistingResultsPath',OpenCossan.getCossanWorkingPath,... %TODO: Remove it!!!!!!!!!!!
    'XprobabilisticModel',Xpm, ...                     % the Probabilistic Model object is mandatory here
    'XadaptiveLineSampling',Xals,...                   % TODO: This should be a simulator... the Adaptive Line Sampling object is mandatory here
    ...
    'LiniAsGradAtFirstRealisation',true,...            % gradient will be calculated at the beginning of analysis on the first epistemic realisation
    'LiniUsingMC',false,...                            % add number of MC samples if true (NiniSamples)
    'LuseExistingDirection',false,...                  % provide existing direction
    'LuserDefinedConjugateDirection',false,...          % do not search, just pick the argument optima suggested by the Conjugate Direction
    ...
    'LsearchByDoE',false,...                            % optional: specify DoE type
    'LsearchByGA',false,...                            % add optimizer object with set control parameters
    'LsearchByLHS',true,...                           % search the space of candidates with Latin Hypercube
    ...
    'LuseInfoPreviousSimulations',false,...
    ...
    'NlhsSamples',8,...
    ...
    'LuseMCtoFinalise',false,...                       % add number of MC samples if true (NfinSamples)
    ...
    ...'LdeleteSimulationResults',false,...            % delete automatically generated folders containg results of the simulation
    ...
    'LwriteTextFiles',true,...                         % save partial results in text files
    ...
    'SfailureProbabilityName','pf',...                 % name of the failure probability
    'VuserDefinedConjugateDirection',[1,1,-1,1,-1,-1],...
    'MstandardDeviationCheckPoints',[-1,1;-1,1]...
    );
%% Run the ExtremeCase analysis
%OpenCossan.resetRandomNumberGenerator(51125) 
% This will take a while
Xextremes=XextremeCase.computeExtrema();
display(Xextremes)
% %% Validate the optima
% Mvalues=[1.808931458159e+00 1.273990014808e-01 2.409366292512e-01...
%     4.627110551849e+03 4.264948849781e+01 6.108105246449e+02...
%     9.875777955180e+09 8.527902635757e+07];
% [Xpf,Xld]=XextremeCase.validateOptima('Mvalues',Mvalues);
% %% Validate the optima
% Mvalues=[1.81 0.1274 0.241...
%     4627.1105 42.6495 610.8105...
%     9.87577795e+09 8.52790e+07];
% [Xpf,Xld]=XextremeCase.validateOptima('Mvalues',Mvalues);
% %% Validate the optima (use interval endpoints)
% Mvalues=[1.801 0.1212 0.241...
%     4950 40.5 605,...
%     9.95e+09 1.54e+08];
% [Xpf,Xld]=XextremeCase.validateOptima('Mvalues',Mvalues);
%% Validate the optima (use interval endpoints)
% Mvalues=[1.7986e+00 1.212e-01 2.41e-01...
%     4950 3.95e+01 5.950,...
%     1.005e+10 1.54e+08];
% [Xpf,Xld]=XextremeCase.validateOptima('Mvalues',Mvalues);
% %1.798595799633e+00 1.211798161464e-01 2.409928606079e-01 4.950009416804e+03 3.950306143370e+01 5.950169274502e+02 1.004868095530e+10 1.575536014592e+08
%% Plot the results
