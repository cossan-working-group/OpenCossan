%% Tutorial for the RobustDesign and related methods
%
% This tutorial shows how to create and use a RobustDesign object to perform
% Robust Design Optimization
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@RobustDesign
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author: Matteo Broggi$ 
close all
clear
clc;
% Reset the random number generator in order to obtain always the same results.
% DO NOT CHANGE THE VALUES OF THE SEED
opencossan.OpenCossan.resetRandomNumberGenerator(51125)

%% Disclaimer
% This simple tutorial presents a very simple example that shows how to used the
% RobustDesign object and the optimize methods in order to perform a Robust design optimization.
% This example might be not physically meaningful, nevertheless it can be used
% as a template to prepare solution sequence for solving realistic problems.

%% Define an inner-loop Model 
% The Robust design optimization requires the definition of a Model. The
% model is based on a very simple input composed by 1 RandomVariable, and 1
% parameter.

% Define the Input
RV1=opencossan.common.inputs.random.NormalRandomVariable('mean',0,'std',1); 
% Define the RVset
Xrvs1=opencossan.common.inputs.random.RandomVariableSet('names',{'RV1'},'members',[RV1]); 
% Define Input object
Xpar=opencossan.common.inputs.Parameter('value',1);
XinA = opencossan.common.inputs.Input('description','Simply Input object', ...
    'membersnames',{'Xrvs1' 'Xpar'},'members',{Xrvs1 Xpar});

% Define the evaluator. In this example we use a Mio object to compute the
% quantity of interest of the Model. 
% The output of the mio it is simply the sum of the realization of the random
% variable and the value of the parameter Xpar.

XmA=opencossan.workers.Mio( 'description', 'Performance function', ...
                'Script',...
                ['for j=1:length(Tinput),' ...
                    'Toutput(j).out1=Tinput(j).RV1+Tinput(j).Xpar;' ...
                'end'], ...
                'Format','structure',...
                'OutputNames',{'out1'},...
                'InputNames',{'RV1' 'Xpar'},...
				'IsFunction',false); % This flag specify if the .m file is a script or a function. 
            
% Construct the Evaluator
XevalA = opencossan.workers.Evaluator('Xmio',XmA,'Sdescription','Evaluator xmio','CSnames',{'XmA'});

% Define a Model
XmdlA=opencossan.common.Model('Xevaluator',XevalA,'Xinput',XinA);

%% Define an Optimization problem 
% The optimization problem requires at least 1 Design Variable.

% Define Design Variables
Xdv=optimization.DesignVariable('value',0,'lowerBound',-2,'upperBound',2); 
% Define Input object for OptimizationProblem
Xin = common.inputs.Input('Sdescription','Test Input','CSmembers',{'Xdv'},'CXmember',{Xdv});

%% Define the objective function
% The objective function is the minimization of the failure probability
% associated to the ProbabilisticModel defined above.
XobjFun = optimization.ObjectiveFunction('Sscript',...
    ['for n=1:length(Tinput),'...
        ' Toutput(n).fobj=2-mean(Tinput(n).out1)-std(Tinput(n).out1);' ...
    'end'],...
    'Sformat','structure',...
    'Cinputnames',{'out1'},...
    'Coutputnames',{'fobj'});


%% Define the RobustDesign
% The RobustDesign object is defined by combining a  model, a Simulation
% object (Monte Carlo, Latin Hypercube) used to generate samples of the 
% quantity of interest, Objective function and Constraint, an Input
% containing Design Variables and finally a mapping between 
% DesignVariable(s) and input(s) of the Inner loop model.

% The montecarlo object defines the number of simulations to be used and
% the number of batches to generate samples of the inner loop model.
XmcA=simulations.MonteCarlo('Nsamples',1000,'Nbatches',1);
   
% The mapping between the Design Variable and Input of the Probabilistic 
% model is done by means the field CdesignvariableMapping.
% This field contains in the first column the name of the DesignVariables,
% in the second column the name of input in the Probabilistic Model and the
% last column the specific property that has to be replace by the current
% value of the DesignVariable 
Xrd = optimization.RobustDesign('Sdescription','Simple RBO problem', ...
        'XinnerLoopModel',XmdlA, ...
        'Xsimulator',XmcA, ...
        'Xinput',Xin, ... % input containing the Design Variable
        'XobjectiveFunction',XobjFun,...
        'CSinnerLoopOutputNames',{'out1'},... % Name of the failure probability 
        'CdesignvariableMapping',{'Xdv' 'RV1' 'mean'}); 
 

%% Performing optimization. 
% To perform Robust design optimization use the method optimize of the
% Object RobustDesign.
% The method optimize requires as input a Optimizer object used to define 
% the optimization algorithm to be used.

Xoptimum=Xrd.optimize('Xoptimizer',optimization.MiniMax);
% Show results
display(Xoptimum)


%% Validate Output
refObjectiveFunct = -2;
refDV = 2;
assert(abs((Xoptimum.XobjectiveFunction.Mdata(end)-refObjectiveFunct)/refObjectiveFunct)<0.02 & ...
    abs((Xoptimum.XdesignVariable.Mdata(end)-refDV)/refDV)<0.02,...
    'Reference solution dows not match')