%% Tutorial for the OptimizationProblem
% This tutorial shows how to define an optimization problem.
% The optimization problem is created defining one or more ObjectiveFunctions
% and Constraint. The  parameters associated with the problem are defined using
% an Input object  containing DesignVariable. 
% A model (i.e. Model, ProbabilisticModel or MetaModel) can be also use in order
% to compute variables required to evaluate an ObjectiveFunction and
% Constraints.      
%
% This example minimaze the volume of a beam.
%
% See also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@OptimizationProblem and
% the tutorial TutorialCantileverBeamOptimization
% 
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author: Edoardo-Patelli$ 
clear
close all
clc;

%% Define preliminary object to define an Optimization Problem
% Let´s define 2 Design Variable
H=opencossan.optimization.DesignVariable('Sdescription','Beam Height','lowerBound',10,'upperBound',50,'value',20);
W=opencossan.optimization.DesignVariable('Sdescription','Beam Width','lowerBound',10,'upperBound',50,'value',20);
L=opencossan.common.inputs.Parameter('description','Beam Length','value',100);

% Include the design variable in a Input object
Xinput=opencossan.common.inputs.Input('members',{H W L},'membersnames',{'H' 'W' 'L'});

% Define an Objective function 
Xobjfun   = opencossan.optimization.ObjectiveFunction('description','objective function', ...
    'Script','for n=1:length(Tinput),Toutput(n).Volume=Tinput(n).H*Tinput(n).L*Tinput(n).W;end',...
    'OutputNames',{'Volume'},...
    'InputNames',{'W' 'H' 'L'});

%% Create object OptimizationProblem
Xop     = opencossan.optimization.OptimizationProblem('Sdescription','Optimization problem', ...
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
Mdata = vertcat(Xoptimum.XdesignVariable.Vdata);
assert(all(logical((Mdata(:,end)-[10;10])<1e-4)),...
    'openCOSSAN:TutorialOptimizationProblem','Wrong solution');

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
Vdata = Xoptimum.XdesignVariable(2).Vdata;
assert(logical(Vdata(end)-12<1e-3),...
    'openCOSSAN:TutorialOptimizationProblem','Wrong solution');
