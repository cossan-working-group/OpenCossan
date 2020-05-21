%% TutorialCantileverBeamMatlabOptimization
% Perform optimization using Matlab evaluator
%
%
% See Also http://cossan.cfd.liv.ac.uk/wiki/index.php/Cantilever_Beam

%{
This file is part of OpenCossan <https://cossan.co.uk>.
Copyright (C) 2006-2019 COSSAN WORKING GROUP

OpenCossan is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free
Software Foundation, either version 3 of the License or, (at your option)
any later version.

OpenCossan is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along
with OpenCossan. If not, see <http://www.gnu.org/licenses/>.
%}

%% Preparation of the Input
% In this tutorial the random variable are replaced by two design variables
%
% The optimization analysis requires the definition of Design Variables
% (i.e. the variables that define new configurations)
b = opencossan.optimization.ContinuousDesignVariable(...
    'value', 0.12, 'lowerBound', 0.01, 'upperBound', 0.50,...
    'Description','Beam width');
h = opencossan.optimization.ContinuousDesignVariable(...
    'value', 0.54, 'lowerBound', 0.02, 'upperBound', 1,...
    'Description', 'Beam Heigth');

% In this example we do not use random variables and we only use Parameters
L = opencossan.common.inputs.Parameter('value', 1.8, 'Description', 'Beam Length');
maxDisplacement = opencossan.common.inputs.Parameter('value', 0.001, 'Description', 'Maximum allowed displacement');
P = opencossan.common.inputs.Parameter('value', 10000, 'Description', 'Load');
rho = opencossan.common.inputs.Parameter('value', 600, 'Description', 'density');
E = opencossan.common.inputs.Parameter('value', 10e9, 'Description','Young''s modulus');

% Definition of the Function
I = opencossan.common.inputs.Function('Description','Moment of Inertia','Expression','<&b&>.*<&h&>.^3/12');

%% Prepare Input Object
% The above prepared objects can be added to an Input Object
XinputOptimization = opencossan.common.inputs.Input(...
    'members', {L b P h rho E I maxDisplacement},...
    'names', ["L" "b" "P" "h" "rho" "E" "I" "MaxW"]);

%% Preparation of the Evaluator
% Use of a matlab script to compute the Beam displacement
folder = fileparts(mfilename('fullpath'));% returns the current folder
Xmio = opencossan.workers.Mio(...
    'FunctionHandle', @tipDisplacement, ...
    'IsFunction', true, ...
    'Format', 'table', ...
    'InputNames',{'I', 'b', 'L', 'h', 'rho', 'P', 'E'}, ...
    'OutputNames',{'w'});

% Add the MIO object to an Evaluator object
Xevaluator = opencossan.workers.Evaluator('CXmembers',{Xmio},'CSmembers',{'Xmio'});

%% Preparation of the Physical Model
% Define the Physical Model
Xmodel = opencossan.common.Model('Input', XinputOptimization, 'Evaluator', Xevaluator);

%% Check feasibility of the optimization preoblem
% The EesignOfExperiment analysis can be used to see if a feasible solution
% is present in the bounds set for the Design Varaibles Define a user
% defined DOE object. We evaluate the model at the lower and upper bounds
% of the design variable plus the current values. Therefore for each design
% variable we have 3 values and a total of 9 model evaluations are
% required. The evaluation points are defined by means of the MdeoFactor
% matrix defined between -1 and 1.
MdoeFactors=[-1 -1;
    0 -1;
    1 -1;
    -1  0;
    0  0;
    1  0;
    -1  1;
    0  1;
    1  1];
% When the flag Lusecurrentvalues is set to true the current values of the
% design variables is used in corresponcence of the MdoeFactors=0.

Xdoe = opencossan.simulations.DesignOfExperiments('Designtype','UserDefined',...
    'Factors',MdoeFactors,'usecurrentvalues',true);

% Show summary of the design of experimemts
display(Xdoe)

% and now, evaluate the model at the points defined by the
% DesignOfExperiment
XoutDoe=Xdoe.apply(Xmodel);

%% Results of the Design of Experiments
h = XoutDoe.Samples.h;
b = XoutDoe.Samples.b;
w = XoutDoe.Samples.w;
feasible = w < maxDisplacement.Value;

results = table(h,b,w,feasible);
format shorte; display(results); format short;

fprintf("Number of feasible solutions: %d\n", sum(feasible));

% There are 3 feasible solutions and this means the the optimization problem
% is well defined. Now we have to identify the optimal solution.

%% Define the Objective Funtion
% The aim of this optimization is to minimaze the weight of the beam. The
% weight can be easely computed using a matlab script.
Xobjfun = opencossan.optimization.ObjectiveFunction(...
    'FunctionHandle', @beamWeight, ...
    'IsFunction', true, ...
    'OutputNames',{'BeamWeight'}, ...
    'Format','table', ...
    'InputNames',{'rho' 'b' 'h' 'L'});

%% Create (inequality) constraint
% The maximum displacement of the beam tip
XconMaxStress = opencossan.optimization.Constraint(...
    'FunctionHandle', @displacementConstraint, ...
    'IsFunction', true, ...
    'OutputNames',{'Constraint'}, ...
    'Format','table', ...
    'InputNames',{'w' 'MaxW' }, ...
    'Inequality',true);

%% Create object OptimizationProblem
Xop = opencossan.optimization.OptimizationProblem(...
    'objectivefunctions', Xobjfun, ...
    'constraints', XconMaxStress, ...
    'model', Xmodel);

%% Perform optimization
% Reset the random number generator in order to obtain always the same
% results. DO NOT CHANGE THE VALUES OF THE SEED
opencossan.OpenCossan.resetRandomNumberGenerator(542727)

% Optimize using Sequential Quadratic Programming
sqpOptimizer = opencossan.optimization.SequentialQuadraticProgramming();
sqpOptimum = Xop.optimize('optimizer', sqpOptimizer);

% Optimize using COBYLA
cobylaOptimizer = opencossan.optimization.Cobyla();
cobylaOptimum = Xop.optimize('optimizer', cobylaOptimizer);

% Optimize using Genetic Algorithms
gaOptimizer = opencossan.optimization.GeneticAlgorithms(...
    'MutationFcn','mutationadaptfeasible', 'PopulationSize', 20);
gaOptimum = Xop.optimize('optimizer', gaOptimizer);

%% Compare Optimization results
sqp = [height(sqpOptimum.ModelEvaluations);
    sqpOptimum.OptimalObjectiveFunction;
    sqpOptimum.OptimalSolution';
    sqpOptimum.OptimalConstraints];

cobyla = [height(cobylaOptimum.ModelEvaluations);
    cobylaOptimum.OptimalObjectiveFunction;
    cobylaOptimum.OptimalSolution';
    cobylaOptimum.OptimalConstraints(1)];

ga = [height(gaOptimum.ModelEvaluations);
    gaOptimum.OptimalObjectiveFunction;
    gaOptimum.OptimalSolution';
    gaOptimum.OptimalConstraints];

results = table(sqp,cobyla,ga,'RowNames',{'Number of Evaluations',...
    'Objective Function', 'Design Variable b', 'Design Variable h',...
    'Constraint'});

display(results);

%% Validate Solutions
solution = [sqp(5) cobyla(5) ga(5)];
reference = [ 1.01e-07   2.6385e-05   9.9860e-04];
assert(abs(max(solution-reference))<1e-4, 'Tutorial:TutorialCantileverBeamOptimization',...
    'Solutions do not match reference values');

%% Function definitions
% Is passed to the Mio as a function handle
function out = tipDisplacement(in)
    out = table();
    out.w = (in.rho .* 9.81 .* in.b .* in.h .* in.L.^4) ./ (8 .* in.E .* in.I) + ...
        (in.P .* in.L.^3) ./ (3 .* in.E .* in.I);
end

% Is passed to the ObjectiveFunction as a function handle
function out = beamWeight(in)
    out = table();
    out.BeamWeight = in.rho .* in.b .* in.h .* in.L;
end

% Is passed to the Constraint as a function handle
function out = displacementConstraint(in)
    out = table();
    out.Constraint = in.w - in.MaxW;
end
