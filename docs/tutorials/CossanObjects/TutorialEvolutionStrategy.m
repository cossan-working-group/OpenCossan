%% TUTORIALEVOLUTIONSTRATEGY
%
%   Optimization of Himmelblau Function using
%   Evolution Strategy
%
%
% See Also:  http://cossan.cfd.liv.ac.uk/wiki/index.php/@EvolutionStrategy
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author:~Edoardo~Patelli$

x1 = opencossan.optimization.ContinuousDesignVariable('value',0, 'lowerbound', -5, 'upperbound', 5);
x2 = opencossan.optimization.ContinuousDesignVariable('value',0, 'lowerbound', -5, 'upperbound', 5);
input = opencossan.common.inputs.Input('Description','Input for the Himmelblau function','MembersNames',{'X1' 'X2'},'Members',{x1 x2});

%% Create objective function
objfun = opencossan.optimization.ObjectiveFunction('Description','Himmelblau function', ...
    'IsFunction',true, ...
    'Format', 'matrix', ...
    'InputNames',{'X1','X2'}, ...
    'FullFileName',fullfile(opencossan.OpenCossan.getRoot,'lib','MatlabFunctions','Himmelblau.m'),...
    'OutputNames',{'fobj'});

%% Define OptimizationProblem
optProb = opencossan.optimization.OptimizationProblem('Input',input, ...
    'objectiveFunctions', objfun);

%% Create optimizer object CrossEntropy
evolutionstrategy = opencossan.optimization.EvolutionStrategy(...
    'ObjectiveFunctionTolerance',1e-3,'MaxIterations',100, 'Sigma',[0.5 1],'Nmu',10, ...
    'Nlambda',70,'Nrho',2);

%% Solve optimization problem
% Reset the random number generator in order to obtain always the same results.
% DO NOT CHANGE THE VALUES OF THE SEED
opencossan.OpenCossan.resetRandomNumberGenerator(8756)

optimum = optProb.optimize('optimizer', evolutionstrategy);

referenceSolution = [3.0 2.0];

fprintf("Reference solution: [%.1f, %.1f]\n", referenceSolution);
fprintf("Found optimum: [%d, %d]\n", optimum.OptimalSolution);

assert(norm(referenceSolution - optimum.OptimalSolution) < 1e-3, ...
    'openCOSSAN:Tutorials:EvolutionStrategy', ...
    'Obtained solution does not match the reference solution.')