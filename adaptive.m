x = opencossan.common.inputs.random.NormalRandomVariable('mean', 5, 'std', 2);
y = opencossan.common.inputs.random.NormalRandomVariable('mean', 2, 'std', 2);

demand = opencossan.common.inputs.Parameter('value', 0);

input = opencossan.common.inputs.Input('members', {x y}, 'names', ["x" "y"]);

mio = opencossan.workers.Mio(...
    'functionhandle', @boundary, ...
    'isfunction', true, ...
    'format', 'matrix', ...
    'inputnames', {'x' 'y'}, ...
    'outputnames', {'g'});

evaluator = opencossan.workers.Evaluator('CXmembers', {mio}, 'CSmembers', {'mio'});

model = opencossan.common.Model('Input', input, 'Evaluator', evaluator);

performance = opencossan.reliability.PerformanceFunction(...
    'functionhandle', @(g) g, ...
    'isfunction', true, ...
    'format','matrix', ...
    'inputnames', {'g'}, ...
    'outputname', {'Vg'});

probModel = opencossan.reliability.ProbabilisticModel(...
    'Model', model, 'PerformanceFunction', performance);

mc = opencossan.simulations.MonteCarlo('samples', 10e6);
pf_mc = mc.computeFailureProbability(probModel);

als = opencossan.simulations.AdaptiveLineSampling('lines', 300);
pf_als = als.computeFailureProbability(probModel);

ls = opencossan.simulations.LineSampling('lines', 300, 'points', 0.5:.5:5);
pf_ls = ls.computeFailureProbability(probModel);

results = table();
results.pf = [pf_mc.Value; pf_als.Value; pf_ls.Value];
results.cov = [pf_mc.CoV; pf_als.CoV; pf_ls.CoV];
results.n = [pf_mc.SimulationData.NumberOfSamples; pf_als.SimulationData.NumberOfSamples; ...
    pf_ls.SimulationData.NumberOfSamples];
results.Properties.RowNames = ["MonteCarlo" "AdaptiveLineSampling" "LineSampling"];

display(results);

function g = boundary(x)
    g = -(x(:, 1).^2 + x(:, 2).^2) + 100 * (1 + 0.2 * sin(20 * atan2(x(:, 1), x(:, 2))));
end
