%% Tutorial for the OptimizationProblem
% This tutorial shows how to define an optimization problem.
% The optimization problem is created defining one or more ObjectiveFunctions
% and Constraint. The  parameters associated with the problem are defined using
% an Input object  containing DesignVariable. 
% A model (i.e. Model, ProbabilisticModel or MetaModel) can be also use in order
% to compute variables required to evaluate an ObjectiveFunction and
% Constraints.      
%
% This example minimize the volume of a beam.
%
% See also: https://cossan.co.uk/wiki/index.php/@OptimizationProblem and
% the tutorial TutorialCantileverBeamOptimization
% 
% $Copyright~1993-2019,~COSSAN~Working~Group$
% $Author: Edoardo-Patelli$ 


%% Define preliminary object to define an Optimization Problem
% Let�s define 2 Design Variable
H=DesignVariable('Sdescription','Beam Height','lowerBound',10,'upperBound',50,'value',20);
W=DesignVariable('Sdescription','Beam Width','lowerBound',10,'upperBound',50,'value',20);
L=Parameter('Sdescription','Beam Length','value',100);

% Include the design variable in a Input object
Xinput=Input('CXmembers',{H W L},'CSmembers',{'H' 'W' 'L'});

% Define an Objective function 
Xobjfun   = ObjectiveFunction('Sdescription','objective function', ...
    'Sscript','for n=1:length(Tinput),Toutput(n).Volume=Tinput(n).H*Tinput(n).L*Tinput(n).W;end',...
    'CoutputNames',{'Volume'},...
    'CinputNames',{'W' 'H' 'L'});

%% Create object OptimizationProblem
Xop     = OptimizationProblem('Sdescription','Optimization problem', ...
    'VinitialSolution',[20 20],'XobjectiveFunction',Xobjfun,'Xinput',Xinput);

% Visualize the OptimizationProblem object
display(Xop)

%% Optimize the problem
% In this simple example the optimization is performed by COBYLA using the
% method optimize.
Xoptimum=Xop.optimize('Xoptimizer',Cobyla);
% Show results
display(Xoptimum)
% Clearly the minimum correspont to the lowest values for the two design
% variables.

%% Validate Solution
assert(all(logical((Xoptimum.VoptimalDesign-[10;10])<1e-4)),...
    'OpenCossan:TutorialOptimizationProblem','Wrong solution');

%% Constrainted Optimization problem
% Define a constraint
 Xcon=Constraint('Sscript','for n=1:length(Tinput),Toutput(n).con1=12-Tinput(n).W; end','Soutputname','con1','Cinputnames',{'W'});
 display(Xcon)
 
 % Define Optimization problem
 Xop     = OptimizationProblem('Sdescription','Optimization problem', ...
    'VinitialSolution',[20 20],'XobjectiveFunction',Xobjfun,'Xinput',Xinput, ...
    'CXconstraint',{Xcon});

% Optimize constraint problem
Xoptimum=Xop.optimize('Xoptimizer',Cobyla);
display(Xoptimum)

%% Validate Solution
assert(all(Xoptimum.VoptimalDesign==[10;12]),...
    'OpenCossan:TutorialOptimizationProblem','Wrong solution');
