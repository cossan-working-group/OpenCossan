%% TUTORIALSequentialQuadraticProgramming 
%
%   Optimization of user define function with contrains by SQP 
%
% See Also: https://cossan.co.uk/wiki/index.php/@SequentialQuadraticProgramming
%
% $Copyright~1993-2018,~COSSAN~Working~Group$
% $Author: Edoardo~Patelli$ 

%% prepate Input objects
% The simple objective function example requires two design variables. The design variables
% are defined by means of the parameters objects.

% Create Parameter objects
X1      = DesignVariable('Sdescription','design variable 1','value',7);
X2      = DesignVariable('Sdescription','design variable 2','value',2);
% Create an Input object containing the design variables
Xin     = Input('Sdescription','Input for the simple example function','CSmembers',{'X1' 'X2'},'CXmembers',{X1 X2});

%% Create objective function
Xobjfun   = ObjectiveFunction('Sdescription','objective function', ...
    'Sscript','for n=1:length(Tinput),Toutput(n).out1=Tinput(n).X1^2+Tinput(n).X2^2;end',...
    'CoutputNames',{'out1'},...
    'CinputNames',{'X1' 'X2'});


%% Create (inequality) constraints
Xcon1   = Constraint('Sdescription','constraint', ...
    'Sscript','for n=1:length(Tinput), Toutput(n).con1=2-Tinput(n).X1-Tinput(n).X2;end',...
    'CoutputNames',{'con1'},'CinputNames',{'X1' 'X2' }, 'Linequality',true );

Xcon2   = Constraint('Sdescription','constraint', ...
    'Sscript',['for n=1:length(Tinput), ' ...
    'Toutput(n).con2=-Tinput(n).X1; end'],...
    'CoutputNames',{'con2' },'CinputNames',{'X1' 'X2' },'Linequality',true);

Xcon3   = Constraint('Sdescription','constraint', ...
    'Sscript','for n=1:length(Tinput), Toutput(n).con3=-Tinput(n).X2; end',...
    'CoutputNames',{'con3'},'CinputNames',{'X1' 'X2' },'Linequality',true);



%% Create object OptimizationProblem
Xop     = OptimizationProblem('Sdescription','Optimization problem', ...
    'Xinput',Xin,'VinitialSolution',[-0 0],'XobjectiveFunction',Xobjfun);

%% Create object OptimizationProblem
Xop2     = OptimizationProblem('Sdescription','Optimization problem', ...
    'Xinput',Xin,'VinitialSolution',[7 2], ...
    'XobjectiveFunction',Xobjfun,'CXconstraint',{Xcon1 Xcon2 Xcon3});

%% Define an optimization method 
Xsqp    = SequentialQuadraticProgramming;
display(Xsqp)

%% Solve unconstrainted optimization problem
Xopt = Xsqp.apply('XOptimizationProblem',Xop);

%% Solve constrainted optimization problem
Xopt2 = Xsqp.apply('XOptimizationProblem',Xop2);
display(Xopt2)

%% Reference Solution
OpenCossan.cossanDisp('Reference solution');
OpenCossan.cossanDisp('f(1.0,1.0) = 2.0');

%% Validate solution
assert(abs(Xopt2.VoptimalScores-2)<1e-4,'OpenCossan:Tutorials','wrong results')
