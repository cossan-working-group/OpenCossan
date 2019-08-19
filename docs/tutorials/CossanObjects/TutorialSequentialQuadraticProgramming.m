%% TUTORIALSequentialQuadraticProgramming 
%
%   Optimization of user define function with contrains by SQP 
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@SequentialQuadraticProgramming
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author: Edoardo~Patelli$ 

%% prepate Input objects
% The simple objective function example requires two design variables. The design variables
% are defined by means of the parameters objects.

X1 = opencossan.optimization.ContinuousDesignVariable(...
    'Description', 'Design variable 1', 'value', 7);
X2 = opencossan.optimization.ContinuousDesignVariable(...
    'Description', 'Design variable 2', 'value',2);

% Create an Input object containing the design variables
input = opencossan.common.inputs.Input(...
    'Description', 'Input for the simple example function', ...
    'MembersNames', {'X1' 'X2'}, 'Members', {X1 X2});

%% Create objective function
Xobjfun = opencossan.optimization.ObjectiveFunction(...
    'Description', 'objective function', ...
    'Script', 'for n=1:length(Tinput),Toutput(n).out1=Tinput(n).X1^2+Tinput(n).X2^2;end',...
    'OutputNames', {'out1'}, ...
    'Format', 'structure', ...
    'InputNames', {'X1' 'X2'});

%% Create (inequality) constraints
Xcon1 = opencossan.optimization.Constraint('description','constraint', ...
    'Script','for n=1:length(Tinput), Toutput(n).con1=2-Tinput(n).X1-Tinput(n).X2;end',...
    'OutputNames',{'con1'},'InputNames',{'X1' 'X2' }, 'inequality',true, 'format', 'structure');

Xcon2 = opencossan.optimization.Constraint('description','constraint', ...
    'Script',['for n=1:length(Tinput), ' ...
    'Toutput(n).con2=-Tinput(n).X1; end'],...
    'OutputNames',{'con2' },'InputNames',{'X1' 'X2' },'inequality',true, 'format', 'structure');

Xcon3 = opencossan.optimization.Constraint('description','constraint', ...
    'script','for n=1:length(Tinput), Toutput(n).con3=-Tinput(n).X2; end',...
    'OutputNames',{'con3'},'InputNames',{'X1' 'X2' },'inequality',true, 'format', 'structure');

%% Create object OptimizationProblem
Xop = opencossan.optimization.OptimizationProblem('description','Optimization problem', ...
    'input',input,'initialsolution',[7 2],'objectivefunction',Xobjfun);

%% Create object OptimizationProblem
Xop2 = opencossan.optimization.OptimizationProblem('description','Optimization problem', ...
    'input',input,'initialsolution',[7 2], ...
    'objectivefunction',Xobjfun,'constraints',[Xcon1 Xcon2 Xcon3]);

%% Define an optimization method 
Xsqp = opencossan.optimization.SequentialQuadraticProgramming();

%% Solve unconstrainted optimization problem
Xopt = Xsqp.apply('optimizationProblem', Xop);

%% Solve constrainted optimization problem
Xopt2 = Xsqp.apply('optimizationProblem', Xop2);

%% Reference Solution
opencossan.OpenCossan.cossanDisp('Reference solution: f(1.0,1.0) = 2.0');

%% Validate solution
assert(all(abs(Xopt2.OptimalSolution - [1 1]) < 1e-4),'openCOSSAN:Tutorials','Wrong results')
assert(abs(Xopt2.OptimalObjectiveFunction - 2) < 1e-4,'openCOSSAN:Tutorials','Wrong results')