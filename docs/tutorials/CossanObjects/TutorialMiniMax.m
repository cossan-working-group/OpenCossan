%% TUTORIALMINIMAX
% Tutorial for MiniMax optimization method.
% This tutorial shows a very simple example to perform multi-objective
% optimization adoptin min-max method.
%
% the Aim of this tutorial is to find x that minimize the maximum value of 5
% objective functions. 
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@MiniMax

x1 = opencossan.optimization.ContinuousDesignVariable('Description','design variable 1','value',0.1);
x2 = opencossan.optimization.ContinuousDesignVariable('Description','design variable 2','value',0.1);

input = opencossan.common.inputs.Input('Description','Input for the MinMax optimization', ...
    'names',["x1" "x2"],'members',{x1 x2});

%% Create objective functions
objfun1 = opencossan.optimization.ObjectiveFunction('Description','objective function #1', ...
    'FunctionHandle', @objective1, ...
    'IsFunction', true, ...
    'Format', 'table', ...
    'OutputNames',{'out1'}, ...
    'InputNames',{'x1' 'x2'});

objfun2 = opencossan.optimization.ObjectiveFunction('Description','objective function #2', ...
    'FunctionHandle', @objective2, ...
    'IsFunction', true, ...
    'Format', 'table', ...
    'OutputNames',{'out2'}, ...
    'InputNames',{'x1' 'x2'});

objfun3 = opencossan.optimization.ObjectiveFunction('Description','objective function #3', ...
    'FunctionHandle', @objective3, ...
    'IsFunction', true, ...
    'Format', 'table', ...
    'OutputNames',{'out3'}, ...
    'InputNames',{'x1' 'x2'});

objfun4 = opencossan.optimization.ObjectiveFunction('Description','objective function #4', ...
    'FunctionHandle', @objective4, ...
    'IsFunction', true, ...
    'Format', 'table', ...
    'OutputNames',{'out4'}, ...
    'InputNames',{'x1' 'x2'});

objfun5 = opencossan.optimization.ObjectiveFunction('Description','objective function #5', ...
    'FunctionHandle', @objective5, ...
    'IsFunction', true, ...
    'Format', 'table', ...
    'OutputNames',{'out5'}, ...
    'InputNames',{'x1' 'x2'});

%% Create object OptimizationProblem
optProb = opencossan.optimization.OptimizationProblem('Description','Optimization problem', ...
    'Input',input,'InitialSolution',[0.1 0.1], ...
    'objectivefunctions',[objfun1 objfun2 objfun3 objfun4 objfun5]);

%% Define an optimization method 
minimax = opencossan.optimization.MiniMax();

optimum = optProb.optimize('optimizer', minimax);

%% Reference Solution
referenceSolution = [4 4];

fprintf("Reference solution: [%d, %d]\n", referenceSolution);
fprintf("Found optimum: [%d, %d]\n", optimum.OptimalSolution);

assert(norm(referenceSolution - optimum.OptimalSolution) < 1e-5, ...
    'openCOSSAN:Tutorials:BFGS', ...
    'Obtained solution does not match the reference solution.')

%% Objective functions

% To use a function handle as objective function it has to be defined at
% the end of the file.
function out = objective1(in)
    out = table();
    out.out1 = 2 .* in.x1.^2 + in.x2.^2 - 48 .* in.x1 - 40 .* in.x2 + 304;
end

function out = objective2(in)
    out = table();
    out.out2 = -in.x1.^2 - 3 * in.x2.^2;
end

function out = objective3(in)
    out = table();
    out.out3 = in.x1 + 3 * in.x2 - 18;
end

function out = objective4(in)
    out = table();
    out.out4 = -in.x1 - in.x2;
end

function out = objective5(in)
    out = table();
    out.out5 = in.x1 + in.x2 - 8;
end