%% TutorialAdaptiveLineSampling
%
% This tutorial shows how to apply AdaptiveLineSampling to find the probability of failure of a
% nonlinear limit state with a saddle point defined by the following equation:
%
%     f(x1, x2) = 2 - x2 - 0.1 * x1^2 + 0.06 * x1^3.
%
% See also: opencossan.simulations.AdaptiveLineSampling

%{
This file is part of OpenCossan <https://cossan.co.uk>. Copyright (C) 2006-2018 COSSAN WORKING GROUP
OpenCossan is free software: you can redistribute it and/or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation, either version 3 of the License
or, (at your option) any later version.
	
OpenCossan is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even
the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
Public License for more details. You should have received a copy of the GNU General Public License
along with OpenCossan. If not, see <http://www.gnu.org/licenses/>.
%}

%%  Define the inputs
x1 = opencossan.common.inputs.random.NormalRandomVariable('mean',0,'std',1);
x2 = opencossan.common.inputs.random.NormalRandomVariable('mean',0,'std',1);

input = opencossan.common.inputs.Input('members',{x1 x2},'names',["x1" "x2"]);

%% Define the physical model
mio = opencossan.workers.Mio(...
    'FunctionHandle', @(x) 2 - x(:, 2) - 0.1 * x(:, 1).^2 + 0.06 * x(:, 1).^3, ...
    'Format', 'matrix', ...
    'IsFunction', true, ...
    'OutputNames', {'y'}, ...
    'InputNames', {'x1' 'x2'});

evaluator = opencossan.workers.Evaluator('Xmio', mio);

model = opencossan.common.Model('evaluator',evaluator,'input',input);

%% Define the Probabilistic Model
performance = opencossan.reliability.PerformanceFunction(...
    'FunctionHandle', @(y) y, ...
    'Format','matrix', ...
    'IsFunction', true, ...
    'Inputnames', {'y'}, ...
    'OutputName', {'Vg'});

probModel = opencossan.reliability.ProbabilisticModel('model', model, 'performancefunction', performance);

%% Estimate the failure probability using AdaptiveLineSampling
als = opencossan.simulations.AdaptiveLineSampling('lines', 60, 'tolerance', 1e-4);

pf = als.computeFailureProbability(probModel);
display(pf);

% Compare to the reference solution
reference = 3.47e-2; %(Der Kiureghian and Lin, 1987. J Eng Mech Div ASCE);
assert(norm(reference - pf.Value) < 1e-3, 'Solution does not match reference');
