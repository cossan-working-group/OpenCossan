%% TUTORIALSIMPLEX
%
%   This tutorial show how to perform unconstrained multivaable optimization
%   using derivative-free method (the Nelder-Mead simplex direct search)
%   
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@Simplex
%
% $Copyright~1993-2015,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author: Edoardo~Patelli$ 

x1 = opencossan.optimization.ContinuousDesignVariable('Description','design variable 1','value',7);
x2 = opencossan.optimization.ContinuousDesignVariable('Description','design variable 2','value',2);

input = opencossan.common.inputs.Input('Description','Input for the simple example function',...
    'MembersNames',{'x1' 'x2'},'Members',{x1 x2});

%% Create objective function
Xobjfun   = opencossan.optimization.ObjectiveFunction('description','objective function', ...
    'FunctionHandle', @objective, ...
    'IsFunction', true, ...
    'Format', 'table', ...
    'OutputNames',{'objective'},...
    'InputNames',{'x1' 'x2'});


%% Create object OptimizationProblem
optProb = opencossan.optimization.OptimizationProblem('Description','Optimization problem', ...
    'Input',input,'initialsolution',[7 2], ...
    'objectiveFunctions',Xobjfun);

%% Define an optimization method 
spx = opencossan.optimization.Simplex();

%% Solve optimization problem
optimum = optProb.optimize('optimizer', spx);

%% Reference Solution
referenceSolution = [0 0];

fprintf("Reference solution: [%d, %d]\n", referenceSolution);
fprintf("Found optimum: [%d, %d]\n", optimum.OptimalSolution);

assert(norm(referenceSolution - optimum.OptimalSolution) < 1e-3, ...
    'openCOSSAN:Tutorials:BFGS', ...
    'Obtained solution does not match the reference solution.')

function out = objective(in)
    out = table();
    out.objective = in.x1.^2 + in.x2.^2;
end