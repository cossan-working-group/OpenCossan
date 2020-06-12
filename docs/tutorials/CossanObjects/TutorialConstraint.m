%% Tutorial for the Constraint object
% The Constrains object defines the constains for the
% optimization problem. It is a subclass of the Mio object and inherits all
% the methods from that class.
% Please refer to the Mio tutorial and Optimization tutorial  for more
% examples of the constraints
%
% See Also:  http://cossan.co.uk/wiki/index.php/@Constraint
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Liverpool,~UK$
% $Author:~Edoardo~Patelli$

%% Define a Constraint object
% The fieds inequality is used to define the type of constaint (equality
% or inequality constraint)

con = opencossan.optimization.Constraint('Description','non linear inequality constraint', ...
    'FunctionHandle', @(x) 2 - x(:, 1) - x(:, 2), ...
    'Format', 'matrix', 'IsFunction', true, ...
    'Outputnames',{'Con1'},'Inputnames',{'X1','X2'},'inequality',true);
% Show details of the Constraints
display(con)


%% Test a Constraint object
% evaluate the constraint using a matrix as input

in = [4, 3];
out = con.run(in);

display(out.Samples.Con1);

%% Use a Constraint object in a Optimization Problem
% Create input
X1 = opencossan.optimization.ContinuousDesignVariable('Description','design variable 1','value',7);
X2 = opencossan.optimization.ContinuousDesignVariable('Description','design variable 2','value',2);
input = opencossan.common.inputs.Input('members',{X1 X2},'names',["X1", "X2"]);

% Define an  ObjectiveFunction
objfun = opencossan.optimization.ObjectiveFunction('Description','objective function', ...
    'FunctionHandle', @(x) x, 'Format', 'matrix', 'IsFunction', true, ...
    'InputNames',{'X1','X2'}, 'OutputNames',{'fobj'});

% Define an Optimization Problem
optProb = opencossan.optimization.OptimizationProblem('Description','Optimization problem', ...
    'input',input,'objectivefunction',objfun,'constraint',con);
% Show the optimization problem
% The object contains 1 Objective Function and 1 Constraint
display(optProb)

% Evaluate the objective fuction at 2 points: 5 4 and 2 1.
out = con.evaluate('optimizationProblem',optProb,'referencePoints',[5 4; 2 1]);

% Return both inequality and equality constraints
[in, eq] = con.evaluate('optimizationProblem', optProb, 'referencePoints', [5 4]);

assert(in == -7,'CossanX:Tutorials:TutorialConstraint', ...
    'Reference Solution Inequality constraint does not match.');
assert(isempty(eq),'CossanX:Tutorials:TutorialConstraint',...
    'Reference Solution Equality constraintdoes not match.');

%% More constrains can be defined using the multiple Constraints object.
con = opencossan.optimization.Constraint('Description','non linear inequality constraint', ...
    'FunctionHandle', @(x) 2 - x(:, 1) - x(:, 2), ...
    'Format', 'matrix', 'IsFunction', true, ...
    'Outputnames',{'Con1'},'Inputnames',{'X1','X2'},'inequality',true);

con(2) = opencossan.optimization.Constraint('Description','non linear inequality constraint', ...
    'FunctionHandle', @(x) x(:, 1), ...
    'Format', 'matrix', 'IsFunction', true, ...
    'Outputnames',{'Con2'},'Inputnames',{'X1','X2'},'inequality',true);

con(3) = opencossan.optimization.Constraint('Description','non linear inequality constraint', ...
    'FunctionHandle', @(x) x(:, 2), ...
    'Format', 'matrix', 'IsFunction', true, ...
    'Outputnames',{'Con3'},'Inputnames',{'X1','X2'},'inequality', false);

% Define a new OptimizationProblem with three Constraint objects
optProb = opencossan.optimization.OptimizationProblem('Description','Optimization problem', ...
    'input',input,'objectiveFunction',objfun,'constraint',con);
display(optProb);


