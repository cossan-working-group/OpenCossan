%% Tutorial for the RBOProblem and related methods
%
% This tutorial shows how to create and use a RBOProblem object to perform
% Reliability Based Optimization
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@RBOProblem
% http://cossan.cfd.liv.ac.uk/wiki/index.php/Reliability_Based_Optimization 
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author: Edoardo-Patelli$ 
clear
close all
clc;
%% Disclaimer
% This simple tutorial presents a very simple example that shows how to used the
% RBOproblem object and the optimize methods in order to perform RBO analysis.
% This example might be not physically meaningful, nevertheless it can be used
% as a template to prepare solution sequence for solving realistic problems.

%% Define Probabilistic Model 
% The Reliability based optimization requires the definition of a
% ProbabilisticModel. The probabilistic model it is based on a very simple input
% composed by 1 RandomVariable, and 2 parameters.

% Define the Inpur
RV1=opencossan.common.inputs.random.NormalRandomVariable('mean',0,'std',1); 
% Define the RVset
Xrvs1=opencossan.common.inputs.random.RandomVariableSet('names',{'RV1'},'members',[RV1]); 
% Define Input object
Xpar=opencossan.common.inputs.Parameter('value',4);
Xresistance=opencossan.common.inputs.Parameter('value',10);
XinA = opencossan.common.inputs.Input('description','Simply Input object', ...
    'membersnames',{'Xrvs1' 'Xpar' 'Xresistance'},'members',{Xrvs1 Xpar Xresistance });

% Define the evaluator. In this example we use a Mio object to compute the
% quantity of interest of the Model. 
% The output of the mio it is simply the sum of the realization of the random
% variable and the value of the parameter Xpar.

XmA=opencossan.workers.Mio( 'description', 'Performance function', ...
                'Script','for j=1:length(Tinput), Toutput(j).out1=Tinput(j).RV1+Tinput(j).Xpar; end', ...
...                'Liostructure',true,...
                'OutputNames',{'out1'},...
                'InputNames',{'RV1' 'Xpar'},...
				'IsFunction',false); % This flag specify if the .m file is a script or a function. 
            
% Construct the Evaluator
XevalA = opencossan.workers.Evaluator('Xmio',XmA,'Sdescription','Evaluator xmio','CSnames',{'XmA'});

% Define a Model
XmdlA=opencossan.common.Model('Xevaluator',XevalA,'Xinput',XinA);

% Define PerformanceFunction
% The performance function it is defined as a difference between the value of
% the parameter Xresistance and the output (out1) of the physical model.
XpfA=PerformanceFunction('OutputName','vg','Capacity','Xresistance','Demand','out1');
% Define Probabilistic Model
XprobModelA=ProbabilisticModel('Xmodel',XmdlA','XperformanceFunction',XpfA);


%% Define an Optimization problem 
% The optimization problem requires at least 1 Design Variable.

% Define Design Variables
Xdv=DesignVariable('value',5.4,'lowerBound',2,'upperBound',10); 
% Define Input object for OptimizationProblem
Xin = Input('Sdescription','Test Input','CSmembers',{'Xdv'},'CXmember',{Xdv});

%% Define the objective function
% The objective function is the minimization of the failure probability
% associated to the ProbabilisticModel defined above.
XobjFun = ObjectiveFunction('Sdescription','Minimize Pf',...
    'Sscript','for n=1:length(Tinput), Toutput(n).fobj=Tinput(n).pf; end',...
    'Cinputnames',{'pf'},...
    'Coutputnames',{'fobj'});


%% Define the RBOproblem
% The RBO problem is defined by combining a probabilistic model, a Simulations
% object used to estimate the failure probability, Objective function and
% Constraint, an Input containing Design Variables and finally a mapping
% between  DesignVariable(s) and input(s) of the Probabilistic model.


%% Define a method to estimate the failure probability 
% The montecarlo object defines the number of simulations to be used, the number
% of batches
XmcA=MonteCarlo('Nsamples',1000,'Nbatches',1);

XrboProblem = RBOProblem('Sdescription','Simple RBO problem', ...
        'XprobabilisticModel',XprobModelA, ...
        'Xsimulator',XmcA, ...
        'Xinput',Xin, ... % input containing the Design Variable
        'XobjectiveFunction',XobjFun,...
        'SfailureProbabilityName','pf',... % Name of the failure probability 
        'CdesignvariableMapping',{'Xdv' 'RV1' 'mean'}); 
    
% The mapping between the Design Variable and Input of the Probabilistic model
% is done by means the field CdesignvariableMapping
% This field contains in the first column the name of the
% DesignVariables, in the second column the name of input in the Probabilistic
% Model and the last column the specific property that has to be replace by the
% current value of the DesignVariable 

%% Performing optimization using Direct Approach. 
% To perform RBO analysis using Direct approch use the method optimize of the
% Object RBOproblem
% The method optimize requires as input a Optimizer object used to define the
% optimization algorithm to be used.

Xoptimum=XrboProblem.optimize('Xoptimizer',Cobyla);
% Show results
display(Xoptimum)

%% Define a constraint 
% A RBOproblem can also be defined using constraints. 
% Constraint object (but also ObjectiveFunction) can use any inputs or outputs
% of the inner model (i.e. ProbabilisticModel). 
% In this example the Contraint Function has no physical meaning but shows how
% is possible to (re)-use values from the inner model. 
%
% Define ContraintFunction
Xcon   = Constraint('Sdescription','dummy constraint', ...
    'Sscript','for n=1:length(Tinput),Toutput(n).Con1=Tinput(n).Xpar(1)-max(Tinput(n).out1);end',...
    'Coutputnames',{'Con1'},'Cinputnames',{'out1','Xpar'},'Linequality',true);

XrboProblem2 = RBOProblem('Sdescription','Simple RBO problem', ...
        'XprobabilisticModel',XprobModelA, ...
        'Xsimulator',XmcA, ...
        'Xinput',Xin, ... % input containing the Design Variable
        'XobjectiveFunction',XobjFun,...
        'Xconstraint',Xcon,...
        'CSprobabilisticModelValues',{'Xpar','out1'},...
        'SfailureProbabilityName','pf',... % Name of the failure probability 
        'CdesignvariableMapping',{'Xdv' 'RV1' 'mean'}); 
    
%% Performing optimization using Direct Approach. 
% To perform RBO analysis using Direct approch use the method optimize of the
% Object RBOproblem
% The method optimize requires as input a Optimizer object used to define the
% optimization algorithm to be usedXrboProblem2.

Xoptimum=XrboProblem2.optimize('Xoptimizer',Cobyla);
% Show results
display(Xoptimum)

%% RBO using global metamodel
% The direct approach might be infeasible if the evaluation of the failure
% probability is time consuming. 
% The expensive full model can be replace by a metamodel. This can be done
% automatically by the method optimize if a metamodel type is defined and a
% Simumations object is provided in order to define the calibration points of
% the meta-model.

% Here a responseSurface metamodel is used a DesignOfExperiment using 2 levels
% factorial is used to define the calibration points.
% Any kind of meta model and Simulations object can be used.
XoptimumGlobal=XrboProblem.optimize('Xoptimizer',Cobyla, ...
        'Xsimulator',DesignOfExperiments, ...
        'Smetamodeltype','ResponseSurface');
display(XoptimumGlobal)


%% RBO using local metamodel
% Using this approach a metamodel is trained only in a subdomain defined aroung
% the current value of the design variables. 
% In order to use this method it is necessary to specify the size of such
% subdomain by using the property name 'Vperturbation'.  This property specify
% the perturbation around the current value of the design variable. It is
% expressed in term of percentile (i.e. between 0 and 1).

% Here a responseSurface metamodel is used a DesignOfExperiment using 2 levels
% factorial is used to define the calibration points. A perturbation of 0.2 is
% used a a maximum number of local metamodel created is set by the property name
% 'NmaxLocalRBOiterations'
%
% Any kind of meta model and Simulations object can be used.
% Perform optimization

XoptimumLocal=XrboProblem.optimize('Xoptimizer',Cobyla,'Xsimulator',DesignOfExperiments, ...
    'Smetamodeltype','ResponseSurface','Vperturbation',0.2,'NmaxLocalRBOiterations',5);
display(XoptimumLocal)


