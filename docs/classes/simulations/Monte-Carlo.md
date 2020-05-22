The `MonteCarlo` class is used to perfrom standard Monte Carlo simulation.

## Properties
The available properties that can be passed as name/value pairs to the constructor of `MonteCarlo` are:

 - **Description** : `string`
 - **Samples** : `double` : *The number of samples to use.*
 - **Batches** : `integer` : *The number of batches to run. Each batch will use the given number of `samples`.*
 - **ExportBatches** : `logical` : *Wether or not to export the individual batches as `.mat` files.*
 - **CoV** : `double` : *The target cov at which the simulation will be aborted, only relevant when running multiple batches.*
 - **Timeout** : `double` : *The simulation time in seconds after which the simulation will be aborted, only relevant when running multiple batches.*
 - **RandomStream** : `RandStream` : *The random stream to use during the simulation*.
 - **Seed** : `integer` : *The random seed used to construct the stream for the simulation*.

## Usage

A `MonteCarlo` object is created by
``` matlab
mc = opencossan.simulations.MonteCarlo(...
    'Description', "Monte Carlo Simulation", ...
    'Samples', 1000, ...
    'Batches', 10, ...
    'ExportBatches', false, ...
    'CoV', 1e-3, ...
    'Timeout', 360, ...
    'RandomStream', stream, ...
    'Seed', 123456);
```

## Methods

#### apply

Run Monte Carlo simulation on a `Model` and return a `SimulationData` object.

``` matlab
mc = opencossan.simulations.MonteCarlo('samples', 1000);

data = mc.apply(model);
```

#### computeFailureProbability

Compute the probability of failure of a given `ProbabilisticModel` and return a `FailureProbability` object.

``` matlab

mc = opencossan.simulations.MonteCarlo('samples', 1000);

pf = mc.computeFailureProbability(probabilisticModel);
```

#### sample

Generate samples from an `Input`. By passing a `samples` parameter to the method, the number of samples to use can be overriden.

``` matlab
mc = opencossan.simulations.MonteCarlo('samples', 1000);

samples = mc.sample('input', input, 'samples', 10);
```

!!! info
    This is identical to calling the `sample` method of the `Input` directly.

## Example

In this example we will estimate the failure probability of a simple model using Monte Carlo simulation.

### Inputs

To start we must create the necessary input objects.

``` matlab
% Create two standard normal distributed random variables
x = opencossan.common.inputs.random.NormalRandomVariable('mean', 0, 'std', 1);
y = opencossan.common.inputs.random.NormalRandomVariable('mean', 0, 'std', 1); 

% Group the random variables in a Input object
input = opencossan.common.inputs.Input('members', {x, y}, 'names', ["x", "y"]);
```

### Model

Next we create the model using a simple Matlab evaluator.

``` matlab
% Create the matlab worker
worker = opencossan.workers.Mio(...
            'FunctionHandle', @(x) sqrt(x(:, 1).^2 + x(:, 2).^2), ...
            'format', 'matrix', ...
            'outputnames', {'z'}, ...
            'inputnames', {'x','y'}, ...
            'IsFunction', true);

% Create an evaluator wrapping the worker
evaluator = opencossan.workers.Evaluator('Xmio', worker);

% Define the model by connecting the evaluator to the input.

m = opencossan.common.Model('evaluator', evaluator, 'input', input);
```

### Probabilistic Model
To run a reliability analysis we have to connect a `PerformanceFunction` to our `Model` to create a `ProbabilisticModel`.

``` matlab
% Define the performance function
g = opencossan.reliability.PerformanceFunction(...
    'FunctionHandle', @(x) 1 - x(:, 1), ...
    'Format', 'matrix', ...
    'InputNames', {'z'}, ...
    'OutputName', {'g'}, ...
    'IsFunction', true);

probModel = opencossan.reliability.ProbabilisticModel('model', m, 'performanceFunction', g);
```

### Reliability Analysis

Finally we compute the probability of failure using 10^6 samples

``` matlab
mc = opencossan.simulations.MonteCarlo('samples', 10^6);

pf = mc.computeFailureProbability(probModel)
```

which returns the `FailureProbability` object seen below.

``` matlab
pf = 
FailureProbability - Description: 

             Value: 0.6070
          Variance: 2.3855e-07
    SimulationData: [1×1 opencossan.common.outputs.SimulationData]
        Simulation: [1×1 opencossan.simulations.MonteCarlo]
          ExitFlag: "Maximum number of batches reached."
               CoV: 8.0464e-04
```

