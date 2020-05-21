%% TUTORIALCROSSENTROPY
% This turorial shows how to perform Optimization of Himmelblau Function using
%   the Cross Entropy Method
%
% See Also:  http://cossan.cfd.liv.ac.uk/wiki/index.php/@CrossEntropy
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author:~Edoardo~Patelli$

%% prepate Input objects
% The Himmelblau function requires two design variables. The design variables
% are defined by means of the parameters objects.

x1 = opencossan.optimization.ContinuousDesignVariable('value',0, 'lowerbound', -5, 'upperbound', 5);
x2 = opencossan.optimization.ContinuousDesignVariable('value',0, 'lowerbound', -5, 'upperbound', 5);
input = opencossan.common.inputs.Input('Description','Input for the Himmelblau function','names',["X1" "X2"],'members',{x1 x2});

%% Create objective function
objfun = opencossan.optimization.ObjectiveFunction('Description','Himmelblau function', ...
    'IsFunction',true, ...
    'Format', 'matrix', ...
    'InputNames',{'X1','X2'}, ...
    'FullFileName',fullfile(opencossan.OpenCossan.getRoot,'lib','MatlabFunctions','Himmelblau.m'),...
    'OutputNames',{'fobj'});

% Reset the random number generator in order to obtain always the same results.
% DO NOT CHANGE THE VALUES OF THE SEED
opencossan.OpenCossan.resetRandomNumberGenerator(46354)

%% Define OptimizationProblem
optProb = opencossan.optimization.OptimizationProblem('Input',input,...
    'objectiveFunctions', objfun,'InitialSolution', unifrnd(-5,5,40,2));

%% Create optimizer object CrossEntropy
crossentropy = opencossan.optimization.CrossEntropy('NFunEvalsIter',40,'NUpdate',20);

%% Solve optimization problem
optimum = optProb.optimize('optimizer', crossentropy);

referenceSolution = [3.0 2.0];

fprintf("Reference solution: [%.1f, %.1f]\n", referenceSolution);
fprintf("Found optimum: [%d, %d]\n", optimum.OptimalSolution);

assert(norm(referenceSolution - optimum.OptimalSolution) < 1e-3, ...
    'openCOSSAN:Tutorials:CrossEntropy', ...
    'Obtained solution does not match the reference solution.')