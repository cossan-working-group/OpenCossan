%% Tutorial for the BOBYQA object
%
% In this tutorial BOBYQA is used to find the minimum of the Rosenbrock function 
% where f(x) represents the objective function x1 and x2 are continuos design variables defined in (-5,5)
%
% See Also: http://cossan.co.uk/wiki/index.php/@Bobyqa
% See Also:
% http://cossan.cfd.liv.ac.uk/wiki/index.php/computeFailureProbability@ProbabilisticModel

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

%% Create input 

x1 = opencossan.optimization.ContinuousDesignVariable('value',rand,...
    'lowerBound',-5,'upperBound',5);
x2 = opencossan.optimization.ContinuousDesignVariable('value',rand,...
    'lowerBound',-5,'upperBound',5);
input = opencossan.common.inputs.Input('names',["x1" "x2"], 'members',{x1 x2});

%% Define a model 
SrosenbrockPath=fullfile(opencossan.OpenCossan.getRoot(),'lib','MatlabFunctions','Rosenbrock.m');
Xm  = opencossan.workers.Mio(...
    'FullFileName', SrosenbrockPath,...
    'IsFunction', true, ...
    'Format', 'matrix', ...
    'InputNames', {'x1','x2'},...
    'OutputNames', {'out'});

evaluator = opencossan.workers.Evaluator('Xmio', Xm);
model = opencossan.common.Model('Evaluator', evaluator, 'Input', input);

%%  Create objective function
% The objective function corresponds to the output of the model. It is not
% necessary to have a Model to perform and optimization. 

objfun = opencossan.optimization.ObjectiveFunction(...
    'FunctionHandle', @objective, ...
    'IsFunction', true, ...
    'Format', 'structure', ...
    'InputNames',{'out'},...
    'OutputNames',{'fobj'});

%% define the optimizator problem
optProb = opencossan.optimization.OptimizationProblem(...
    'model',model,'initialsolution',[-4, 1], ...
    'objectivefunctions', objfun);

%% Create optimizer
% A COBYLA objet is a optimizer with 2 dedicate parameters:
% * initialTrustRegion = define the radious of the initial spheric trust region
% * finalTrustRegion = define the minimum radius of the spheric trust region

bobyqua = opencossan.optimization.Bobyqa('npt', 0,...
    'stepSize', 0.01,...
    'rhoEnd',  1e-6,...
    'xtolRel', 1e-9,...
    'minfMax', 1e-9,...
    'ftolRel', 1e-8,...
    'ftolAbs', 1e-14,...
    'verbose', 1);

optimum = optProb.optimize('Optimizer',bobyqua);

%% Validate solution
referenceSolution = [1 1];

fprintf("Reference solution: [%d, %d]\n", referenceSolution);
fprintf("Found optimum: [%d, %d]\n", optimum.OptimalSolution);

assert(norm(referenceSolution - optimum.OptimalSolution) < 1e-4, ...
    'openCOSSAN:Tutorials:BFGS', ...
    'Obtained solution does not match the reference solution.')

% To use a function handle as objective function it has to be defined at
% the end of the file.
function output = objective(input)
    output.fobj = input.out;
end
