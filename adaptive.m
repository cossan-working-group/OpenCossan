x = opencossan.common.inputs.random.NormalRandomVariable('mean', 5, 'std', 2);
y = opencossan.common.inputs.random.NormalRandomVariable('mean', 2, 'std', 2);

demand = opencossan.common.inputs.Parameter('value', 0);

input = opencossan.common.inputs.Input('members', {x y demand}, 'names', ["x" "y" "demand"]);

mio = opencossan.workers.Mio('functionhandle', @boundary, 'isfunction', true, 'format', 'matrix', ...
    'outputnames', {'g'}, 'inputnames', {'x' 'y'});

evaluator = opencossan.workers.Evaluator('CXmembers', {mio}, 'CSmembers', {'mio'});

model = opencossan.common.Model('Input', input, 'Evaluator', evaluator);

performance = opencossan.reliability.PerformanceFunction('OutputName', 'Vg',...
    'Demand', 'demand', 'Capacity', 'g');

probModel = opencossan.reliability.ProbabilisticModel(...
    'Model', model, 'PerformanceFunction', performance);

mc = opencossan.simulations.MonteCarlo('samples', 10e6);
pf_mc = mc.computeFailureProbability(probModel);

als = opencossan.simulations.AdaptiveLineSampling('lines', 30);
pf_als = als.computeFailureProbability(probModel);

ls = opencossan.simulations.LineSampling('lines', 30, 'points', 1:7);
pf_ls = ls.computeFailureProbability(probModel);

results = table();
results.pf = [pf_mc.Value; pf_als.Value; pf_ls.Value];
results.cov = [pf_mc.CoV; pf_als.CoV; pf_ls.CoV];
results.n = [pf_mc.SimulationData.NumberOfSamples; pf_als.SimulationData.NumberOfSamples; ...
    pf_ls.SimulationData.NumberOfSamples];
results.Properties.RowNames = ["MonteCarlo" "AdaptiveLineSampling" "LineSampling"];

display(results);

function g = boundary(x)
    g = -sqrt(x(:, 1).^2 + x(:, 2).^2) + 14;
end
