%% TutorialRadialBasedImportanceSampling
%
% This tutorial shows how to use RadialBasedImportanceSampling based on some of the test cases
% listed in 'Adaptive radial-based importance sampling method for structural reliability' (Grooteman
% 2007).
%
% See also opencossan.simulations.RadialBasedImportanceSampling,
% https://doi.org/10.1016/j.strusafe.2007.10.002

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

%% Case 2
rv1 = opencossan.common.inputs.random.NormalRandomVariable('mean', 78064.4, 'std', 11709.7);
rv2 = opencossan.common.inputs.random.NormalRandomVariable('mean', 0.0104, 'std', 0.00156);

input = opencossan.common.inputs.Input('members', {rv1, rv2}, ...
    'names', ["rv1", "rv2"]);

mio = opencossan.workers.Mio('FunctionHandle', @(x) x(:, 1) .* x(:, 2) - 146.14, ....
    'OutputNames',{'out'}, 'InputNames',{'rv1','rv2'}, ...
    'IsFunction',true, 'format', 'matrix');

evaluator = opencossan.workers.Evaluator('Xmio',mio);

model = opencossan.common.Model('evaluator', evaluator, 'input', input);

performance = opencossan.reliability.PerformanceFunction('FunctionHandle', @(x) x, ...
    'InputNames', {'out'}, 'OutputName', {'Vg'}, 'IsFunction', true, 'format', 'matrix');

probModel = opencossan.reliability.ProbabilisticModel('performancefunction', performance, 'model', model);

arbis = opencossan.simulations.RadialBasedImportanceSampling('cov', 0.1, 'seed', 387971);

pf = arbis.computeFailureProbability(probModel);
exactpf = 1.46e-07;

fprintf("ARBIS pf: %d\n", pf.Value);
fprintf("Exact pf: %d\n", exactpf);

assert(abs(pf.Value - 1.490964e-07) < 1e-7, "Reference solution for case 2 does not match.");

%% Case 5
x = opencossan.common.inputs.random.NormalRandomVariable();
y = opencossan.common.inputs.random.NormalRandomVariable();

input = opencossan.common.inputs.Input('members', {x, y}, ...
    'names', ["x", "y"]);

mio = opencossan.workers.Mio('FunctionHandle', ...
    @(x) -.5 * (x(:, 1) - x(:, 2)).^2 - (x(:, 1) + x(:, 2))/sqrt(2) + 3, ....
    'OutputNames',{'z'}, 'InputNames',{'x','y'}, ...
    'IsFunction',true, 'format', 'matrix');

evaluator = opencossan.workers.Evaluator('Xmio',mio);

model = opencossan.common.Model('evaluator', evaluator, 'input', input);

performance = opencossan.reliability.PerformanceFunction('FunctionHandle', @(x) x, ...
    'InputNames', {'z'}, 'OutputName', {'g'}, 'IsFunction', true, 'format', 'matrix');

probModel = opencossan.reliability.ProbabilisticModel('performancefunction', performance, 'model', model);

arbis = opencossan.simulations.RadialBasedImportanceSampling('cov', 0.1, 'seed', 622551);

pf = arbis.computeFailureProbability(probModel);
exactpf = 1.05e-01;

fprintf("ARBIS pf: %d\n", pf.Value);
fprintf("Exact pf: %d\n", exactpf);

assert(abs(pf.Value - 1.109527e-01) < 1e-7, "Reference solution for case 5 does not match.");

%% Case 8
rv1 = opencossan.common.inputs.random.NormalRandomVariable();
rv2 = opencossan.common.inputs.random.NormalRandomVariable();

input = opencossan.common.inputs.Input('members', {rv1, rv2}, ...
    'names', ["rv1", "rv2"]);

mio = opencossan.workers.Mio('FunctionHandle', @(x) 3 - x(:, 2) + (4 * x(:,1)).^4, ....
    'OutputNames',{'out'}, 'InputNames',{'rv1','rv2'}, ...
    'IsFunction',true, 'format', 'matrix');

evaluator = opencossan.workers.Evaluator('Xmio',mio);

model = opencossan.common.Model('evaluator', evaluator, 'input', input);

performance = opencossan.reliability.PerformanceFunction('FunctionHandle', @(x) x, ...
    'InputNames', {'out'}, 'OutputName', {'Vg'}, 'IsFunction', true, 'format', 'matrix');

probModel = opencossan.reliability.ProbabilisticModel('performancefunction', performance, 'model', model);

arbis = opencossan.simulations.RadialBasedImportanceSampling('cov', 0.1, 'seed', 831633);

[pf, beta] = arbis.computeFailureProbability(probModel);
exactpf = 1.80e-4;

fprintf("ARBIS pf: %d\n", pf.Value);
fprintf("Exact pf: %d\n", exactpf);

assert(abs(pf.Value - 2.000981e-04) < 1e-7, "Reference solution for case 8 does not match.");