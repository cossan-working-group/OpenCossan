%% TUTORIALSequentialQuadraticProgramming 
%
%   Optimization of user define function with contrains by SQP 
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@SequentialQuadraticProgramming
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author: Edoardo~Patelli$ 
close all
clear
clc;
%% prepate Input objects
% The simple objective function example requires two design variables. The design variables
% are defined by means of the parameters objects.

% Create Parameter objects
X1      = opencossan.optimization.DesignVariable('Sdescription','design variable 1','value',7);
X2      = opencossan.optimization.DesignVariable('Sdescription','design variable 2','value',2);
% Create an Input object containing the design variables
Xin     = opencossan.common.inputs.Input('description','Input for the simple example function', ...
    'membersnames',{'X1' 'X2'},'members',{X1 X2});

%% Create objective function
Xobjfun   = opencossan.optimization.ObjectiveFunction('description','objective function', ...
    'Script','for n=1:length(Tinput),Toutput(n).out1=Tinput(n).X1^2+Tinput(n).X2^2;end',...
    'OutputNames',{'out1'},...
    'InputNames',{'X1' 'X2'});


%% Create (inequality) constraints
Xcon1   = opencossan.optimization.Constraint('description','constraint', ...
    'Script','for n=1:length(Tinput), Toutput(n).con1=2-Tinput(n).X1-Tinput(n).X2;end',...
    'OutputNames',{'con1'},'InputNames',{'X1' 'X2' }, 'Linequality',true );

Xcon2   = opencossan.optimization.Constraint('description','constraint', ...
    'Script',['for n=1:length(Tinput), ' ...
    'Toutput(n).con2=-Tinput(n).X1; end'],...
    'OutputNames',{'con2' },'InputNames',{'X1' 'X2' },'Linequality',true);

Xcon3   = Constraint('Sdescription','constraint', ...
    'Sscript','for n=1:length(Tinput), Toutput(n).con3=-Tinput(n).X2; end',...
    'CoutputNames',{'con3'},'CinputNames',{'X1' 'X2' },'Linequality',true);



%% Create object OptimizationProblem
Xop     = OptimizationProblem('Sdescription','Optimization problem', ...
    'Xinput',Xin,'VinitialSolution',[7 2],'XobjectiveFunction',Xobjfun);

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
Vdata = Xopt2.XobjectiveFunction.Vdata;
assert(abs(Vdata(end)-2)<1e-4,'openCOSSAN:Tutorials','wrong results')
