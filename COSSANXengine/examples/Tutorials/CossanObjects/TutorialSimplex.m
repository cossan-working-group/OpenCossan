%% TUTORIALSIMPLEX
%
%   This tutorial show how to perform unconstrained multivaable optimization
%   using derivative-free method (the Nelder-Mead simplex direct search)
%   
%
% See Also: https://cossan.co.uk/wiki/index.php/@Simplex
%
% $Copyright~1993-2018,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author: Edoardo~Patelli$ 

%% prepate Input objects
% The simple example function requires two design variables. The design variables
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


%% Create object OptimizationProblem
Xop     = OptimizationProblem('Sdescription','Optimization problem', ...
    'Xinput',Xin,'VinitialSolution',[7 2], ...
    'XobjectiveFunction',Xobjfun);

%% Define an optimization method 
Xspx    = Simplex;
display(Xspx)

%% Solve optimization problem
Xopt = Xspx.apply('XOptimizationProblem',Xop);

display(Xopt)

%% Reference Solution
OpenCossan.cossanDisp(' ');
OpenCossan.cossanDisp('Reference solution');
OpenCossan.cossanDisp('f(0.0,0.0) = 0.0');

%% Validate solution
assert(max(abs(Xopt.VoptimalDesign-0))<3e-4,'OpenCossan:Tutorials','wrong results')
