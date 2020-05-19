%% TUTORIALSIMULATEDANNEALING
% The optimization method Simulated Annealing is used to optimize the Himmelblau
% Function and the De Jong's fifth function is a two-dimensional function with
% many (25) local minima 
%   
%   
%   
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@Simulated Annealing
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author: Edoardo~Patelli$ 

X1      = opencossan.optimization.ContinuousDesignVariable('Description','design variable 1','value',0); 
X2      = opencossan.optimization.ContinuousDesignVariable('Description','design variable 2','value',0);

input     = opencossan.common.inputs.Input('description','Input for the Himmelblau function','names',["X1" "X2"],'members',{X1 X2});

%% Create objective function
objfun = opencossan.optimization.ObjectiveFunction('description','Himmelblau function', ...
         'IsFunction',true, ...
         'Format', 'matrix', ...
          'inputNames',{'X1','X2'},... % Define the inputs 
          'FullFileName',fullfile(opencossan.OpenCossan.getRoot,'lib','MatlabFunctions','Himmelblau.m'),...
...          'Sfile','Himmelblau',... % external file
          'OutputNames',{'fobj'}); % Define the outputs
      

%% Define OptimizationProblem
Xop     = opencossan.optimization.OptimizationProblem('Description','Himmelblau optimization problem','Input',input,...
    'objectivefunctions', objfun);

%% Create optimizer object SimulatedAnnealing
Xsa     = opencossan.optimization.SimulatedAnnealing('ObjectiveFunctionTolerance',1e-2,'StallIterLimit',100);

% Reset the random number generator in order to obtain always the same results.
% DO NOT CHANGE THE VALUES OF THE SEED
opencossan.OpenCossan.resetRandomNumberGenerator(46375)

optimum  = Xop.optimize('optimizer', Xsa);

referenceSolution = [3 2];

fprintf("Reference solution: [%d, %d]\n", referenceSolution);
fprintf("Found optimum: [%d, %d]\n", optimum.OptimalSolution);

assert(norm(referenceSolution - optimum.OptimalSolution) < 1e-3, ...
    'openCOSSAN:Tutorials:SimulatedAnnealing', ...
    'Obtained solution does not match the reference solution.')

%% Minimize  De Jong's fifth function
% This section presents an example that shows how to find the minimum of the function using simulated annealing.
% De Jong's fifth function is a two-dimensional function with many (25) local minima

%% Create objective function
objfun = opencossan.optimization.ObjectiveFunction('Description','De Jong''s fifth function function', ...
          'IsFunction',true,'Format','matrix','FunctionHandle',@dejong5fcn,...
          'Inputnames',{'X1','X2'},... % Define the inputs 
          'Outputnames',{'fobj'}); % Define the outputs

% Define OptimizationProblem
Xop = opencossan.optimization.OptimizationProblem('Description','Himmelblau optimization problem','Input',input,...
    'ObjectiveFunctions', objfun);

Xsa = opencossan.optimization.SimulatedAnnealing('AnnealingFunction','annealingfast','StallIterLimit',100);

% Reset the random number generator in order to obtain always the same results.
% DO NOT CHANGE THE VALUES OF THE SEED
opencossan.OpenCossan.resetRandomNumberGenerator(46375)
optimum  = Xop.optimize('optimizer', Xsa);

display(optimum)
