%% Tutorial BFGS
%
% This tutorial show how to perform unconstrained multivariable optimization using
% the quasi-Newton BFGS method. This tutorial presents a simple and academic
% example. The objective function to be minimize is:
%
% $$f(x)=x_1^2+x_2^2$$
%
% where $x_1$ and $x_2$ are the design variable. The initial starting point
% used to find the minimum is (7,2) and the minimum is at (0,0)
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@BFGS

%{
This file is part of OpenCossan <https://cossan.co.uk>.
Copyright (C) 2006-2018 COSSAN WORKING GROUP

OpenCossan is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License or,
(at your option) any later version.

OpenCossan is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with OpenCossan. If not, see <http://www.gnu.org/licenses/>.
%}


%% Input

% Design variables
x1 = opencossan.optimization.ContinuousDesignVariable('value',7);
x2 = opencossan.optimization.ContinuousDesignVariable('value',12);

% Input
input = opencossan.common.inputs.Input(...
    'MembersNames',{'x1' 'x2'}, 'Members',{x1 x2});

%% Objective function
objfun = opencossan.optimization.ObjectiveFunction('Description','objective function', ...
    'FunctionHandle', @objective, ...
    'OutputNames',{'y'},...
    'IsFunction', true, ...
    'format', 'structure', ...
    'InputNames',{'x1' 'x2'});

%% Optimization problem
optProb = opencossan.optimization.OptimizationProblem('Sdescription','Optimization problem', ...
    'Input',input,'ObjectiveFunction',objfun);

%% Optimization method
optimizer = opencossan.optimization.BFGS();

%% Optimize
optimum = optProb.optimize('optimizer', optimizer);

%% Validate solution
referenceSolution = [0 0];

fprintf("Reference solution: [%d, %d]\n", referenceSolution);
fprintf("Found optimum: [%d, %d]\n", optimum.OptimalSolution);

assert(norm(referenceSolution - optimum.OptimalSolution) < 1e-7, ...
    'openCOSSAN:Tutorials:BFGS', ...
    'Obtained solution does not match the reference solution.')

% To use a function handle as objective function it has to be defined at
% the end of the file.
function output = objective(input)
    output.y = input.x1.^2 + input.x2.^2;
end
