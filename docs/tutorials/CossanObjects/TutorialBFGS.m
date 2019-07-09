%% Tutorial BFGS 
%
% This tutorial show how to perform unconstrained multivaable optimization using
% the quasi-Newton BFGS method. This tutorial presents a simple and academic
% example. The objective function to be minimize is:
%
% $$f(x)=x_1^2+x_2^2$$
%
% where $x_1$ and $x_2$ are the design variable. The initial starting point
% used to find the minimum is (7,2) and the minimum is at (0,0)
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@BFGS
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author:~Edoardo~Patelli$ 

clear;
close all
clc;
%% Define the problem 
% The objective function requires two design variables, defined as following:
X1      = opencossan.optimization.DesignVariable('Sdescription','design variable 1','value',7);
X2      = opencossan.optimization.DesignVariable('Sdescription','design variable 2','value',12);
% Create an Input object containing the design variables
Xin     = opencossan.common.inputs.Input('Description','Input for the Tutorial BFGS', ...
          'MembersNames',{'X1' 'X2'},'Members',{X1 X2});

%% Create objective function
% the objective function is created using the constructor ObjectiveFunction and
% the field Sscript contains the function to be minimaze.
Xobjfun   = opencossan.optimization.ObjectiveFunction('Description','objective function', ...
    'Script','for n=1:length(Tinput),Toutput(n).out1=Tinput(n).X1^2+Tinput(n).X2^2;end',...
    'OutputNames',{'out1'},...
    'InputNames',{'X1' 'X2'});


%% Create object OptimizationProblem
Xop     = opencossan.optimization.OptimizationProblem('Sdescription','Optimization problem', ...
    'Xinput',Xin,'XobjectiveFunction',Xobjfun);

%% Define an optimization method 
Xoptimizer    = BFGS('SfiniteDifferenceType','forward','finiteDifferencePerturbation',1e-4);
% Summary of the optimizer object
display(Xoptimizer)

%% Performe the optimization
Xopt = Xoptimizer.apply('XOptimizationProblem',Xop);
% Show results
display(Xopt)

%% Validate solution
VreferenceSolution=[0;0];
Mdata = cell2mat({Xopt.XdesignVariable.Vdata}');

assert(max(VreferenceSolution-Mdata(:,end))<1e-3,...
    'openCOSSAN:Tutorials:BFGS','Optained solution does not match the Reference solution ')

% Check values of the first gradient
% [2X1,2X2] -> [14 24] 
VreferenceSolutionGradient=[12,24];
MdataGradient=Xopt.XobjectiveFunctionGradient(1).Vdata(:,1);
assert(max(VreferenceSolutionGradient-MdataGradient(:,end)')<1e-2,...
    'openCOSSAN:Tutorials:BFGS','Optained solution does not match the Reference solution ')

OpenCossan.cossanDisp(' ');
OpenCossan.cossanDisp('Reference solution');
OpenCossan.cossanDisp('f(0.0,0.0) = 0.0');
