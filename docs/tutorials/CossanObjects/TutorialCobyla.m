%% Tutorial for the COBYLA object
% The acronym COBYLA stands for Constrained Optimization by Linear Approximation. COBYLA is a
% gradient-free optimization algorithm capable of handling nonlinear inequality constraints. COBYLA
% shares some common characteristics with the popular Nelder-Mead algorithm for optimization, i.e.
% in both algorithms, a polytope of N+1 vertices is constructed (where N is the dimensionality of
% the design variable vector). In COBYLA, the value of the objective function and constraints is
% calculated at each vertex of the polytope; with this information, approximate linear
% representations of the objective function and constraints are generated. Using these
% approximations, an approximate optimization problem is solved over a trust region. The size of the
% trust region is controlled by the algorithm and it is decreased as convergence is achieved.
%
% In this tutorial COBYLA is used to solve the following problem:
%
% $$min f(x)=x_1^2 +x_2^2 | g(x)=2-x_1+x_2 \le 0$$
%
% where f(x) represents the objective function and g(x) the contraints. x1 and x2 are continuos
% design variables defined in (0,+Inf)
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@Cobyla

%{
This file is part of OpenCossan <https://cossan.co.uk>. Copyright (C) 2006-2018 COSSAN WORKING GROUP

OpenCossan is free software: you can redistribute it and/or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation, either version 3 of the License
or, (at your option) any later version.

OpenCossan is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even
the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
Public License for more details.

You should have received a copy of the GNU General Public License along with OpenCossan. If not, see
<http://www.gnu.org/licenses/>.
%}

%% Input

% Design variables
x1 = opencossan.optimization.ContinuousDesignVariable('value',7,'lowerBound',0);
x2 = opencossan.optimization.ContinuousDesignVariable('value',2,'lowerBound',0);

% Input
input = opencossan.common.inputs.Input('MembersNames',{'x1' 'x2'},'Members',{x1 x2});

%% Model
mio  = opencossan.workers.MatlabWorker('Description','objective function of optimization problem', ...
    'FunctionHandle',@myModel, ...
    'Format','structure', ...
    'IsFunction', true, ...
    'InputNames',{'x1','x2'},...
    'OutputNames',{'y'});

evaluator = opencossan.workers.Evaluator('Solver',mio);
model = opencossan.common.Model('evaluator',evaluator,'input',input);

%% Objective function
% The objective function is the output of the model. It is not necessary to have a model to perform
% optimization.

objfun = opencossan.optimization.ObjectiveFunction('Description','objective function', ...
    'FunctionHandle',@myObjective, ...
    'Format', 'structure', ...
    'InputNames',{'y'}, ...
    'OutputNames',{'fobj'});

%% Create non linear inequality constraint
constraint = opencossan.optimization.Constraint('Description','non linear inequality constraint', ...
    'FunctionHandle',@myConstraint, ...
    'Format', 'structure', ...
    'OutputNames',{'con'},...
    'InputNames',{'x1','x2'},...
    'Inequality',true);

%% Optimization problem
optProb = opencossan.optimization.OptimizationProblem(...
    'model',model, ...
    'objectivefunctions',objfun,'constraints',constraint);

%% Optimizer
% A COBYLA object is a optimizer with 2 dedicate parameters:
% * initialTrustRegion = define the radious of the initial spheric trust region
% * finalTrustRegion = define the minimum radius of the spheric trust region

cobyla = opencossan.optimization.Cobyla('initialTrustRegion',1,'finalTrustRegion',0.01);
optimum = optProb.optimize('optimizer', cobyla);

%% Reference Solution
referenceSolution = [1.0 1.0];

fprintf("Reference solution: [%.1f, %.1f]\n", referenceSolution);
fprintf("Found optimum: [%d, %d]\n", optimum.OptimalSolution);

assert(norm(referenceSolution - optimum.OptimalSolution) < 1e-2, ...
    'openCOSSAN:Tutorials:BFGS', ...
    'Obtained solution does not match the reference solution.')

% To use a function handle as model/objective/constraint they have to be defined at the end of the
% file.
function out = myModel(in)
    out.y = in.x1.^2 + in.x2.^2;
end

function out = myObjective(in)
    out.fobj = in.y;
end

function out = myConstraint(in)
    out.con = 2 - in.x1 - in.x2;
end
