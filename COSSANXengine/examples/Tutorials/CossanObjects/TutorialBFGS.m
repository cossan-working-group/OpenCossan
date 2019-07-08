%% Tutorial BFGS 
%
% This tutorial show how to perform unconstrained multivariable optimization using
% the quasi-Newton BFGS method. This tutorial presents a simple and academic
% example. The objective function to be minimize is:
%
% $$f(x)=x_1^2+x_2^2$$
%
% where $x_1$ and $x_2$ are the design variable. The initial starting point
% used to find the minimum is (7,12) and the minimum is at (0,0)
%
% See Also: https://cossan.co.uk/wiki/index.php/@BFGS
%
% $Copyright~1993-2018,~COSSAN~Working~Group$
% $Author:~Edoardo~Patelli$ 


%% Define the problem 
% The objective function requires two design variables, defined as following:
X1      = DesignVariable('Sdescription','design variable 1','value',7);
X2      = DesignVariable('Sdescription','design variable 2','value',12);
% Create an Input object containing the design variables
Xin     = Input('Sdescription','Input for the Tutorial BFGS', ...
          'CSmembers',{'X1' 'X2'},'CXmembers',{X1 X2});

%% Create objective function
% the objective function is created using the constructor ObjectiveFunction and
% the field Sscript contains the function to be minimaze.
Xobjfun   = ObjectiveFunction('Sdescription','objective function', ...
    'Sscript','for n=1:length(Tinput),Toutput(n).out1=Tinput(n).X1^2+Tinput(n).X2^2;end',...
    'CoutputNames',{'out1'},...
    'CinputNames',{'X1' 'X2'});


%% Create object OptimizationProblem
Xop     = OptimizationProblem('Sdescription','Optimization problem', ...
    'Xinput',Xin,'XobjectiveFunction',Xobjfun);

%% Define an optimization method 
Xoptimizer    = BFGS('SfiniteDifferenceType','forward',...
                    'finiteDifferencePerturbation',1e-4);
% Summary of the optimizer object
display(Xoptimizer)

%% Perform the optimization
Xopt = Xoptimizer.apply('XOptimizationProblem',Xop);
% Show results
display(Xopt)

%% Validate solution
VreferenceSolution=[0 0];

assert(max(VreferenceSolution-Xopt.VoptimalDesign)<1e-3,...
    'OpenCossan:TutorialsBFGS:wrongReferenceSolution',...
    'Obtained solution does not match the Reference solution ')

% Check values of the first gradient
% [2X1,2X2] -> [14 24] 
VreferenceSolutionGradient=[14,24];

Vgrad=Xopt.TablesValues.ObjectiveFnc(Xopt.TablesValues.Iteration==0,:);
Vdv=Xopt.TablesValues.DesignVariables(Xopt.TablesValues.Iteration==0,:);

MdataGradient=[(Vgrad(2)-Vgrad(1))/(Vdv(2,1)-Vdv(1,1))  (Vgrad(3)-Vgrad(1))/(Vdv(3,2)-Vdv(1,2))];
assert(max(VreferenceSolutionGradient-MdataGradient(:,end)')<1e-2,...
    'openCOSSAN:Tutorials:BFGS','Obtained solution does not match the Reference solution ')

OpenCossan.cossanDisp(' ');
OpenCossan.cossanDisp('Reference solution');
OpenCossan.cossanDisp('f(0.0,0.0) = 0.0');
