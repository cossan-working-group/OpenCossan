%% TUTORIALMINIMAX
% Tutorial for MiniMax optimization method.
% This tutorial shows a very simple example to perform multi-objective
% optimization adopting min-max method.
%
% the Aim of this tutorial is to find x that minimize the maximum value of 5
% objective functions. 
%
% See Also: https://cossan.co.uk/wiki/index.php/@Minimax
%
% $Copyright~1993-2018,~COSSAN~Working~Group$
% $Author:~Edoardo~Patelli$ 

%% prepate Input objects
% Create Parameter objects
X1      = DesignVariable('Sdescription','design variable 1','value',0.1);
X2      = DesignVariable('Sdescription','design variable 2','value',0.1);

% Create an Input object containing the design variables
Xin     = Input('Sdescription','Input for the MinMax optimization','CSmembers',{'X1' 'X2'},'CXmembers',{X1 X2});

%% Create objective functions
Xobjfun1   = ObjectiveFunction('Sdescription','objective function #1', ...
    'Sscript','for n=1:length(Tinput),Toutput(n).out1=2*Tinput(n).X1^2+Tinput(n).X2^2 - 48*Tinput(n).X1-40*Tinput(n).X2 +304;end',...
    'CoutputNames',{'out1'},...
    'CinputNames',{'X1' 'X2'});

Xobjfun2   = ObjectiveFunction('Sdescription','objective function #2', ...
    'Sscript','for n=1:length(Tinput),Toutput(n).out2=-Tinput(n).X1^2-3*Tinput(n).X2^2;end',...
    'CoutputNames',{'out2'},...
    'CinputNames',{'X1' 'X2'});

Xobjfun3   = ObjectiveFunction('Sdescription','objective function #3', ...
    'Sscript','for n=1:length(Tinput),Toutput(n).out3=Tinput(n).X1+3*Tinput(n).X2-18;end',...
    'CoutputNames',{'out3'},...
    'CinputNames',{'X1' 'X2'});

Xobjfun4   = ObjectiveFunction('Sdescription','objective function #4', ...
    'Sscript','for n=1:length(Tinput),Toutput(n).out4=-Tinput(n).X1-Tinput(n).X2;end',...
    'CoutputNames',{'out4'},...
    'CinputNames',{'X1' 'X2'});

Xobjfun5   = ObjectiveFunction('Sdescription','objective function #5', ...
    'Sscript','for n=1:length(Tinput),Toutput(n).out5=Tinput(n).X1+Tinput(n).X2-8;end',...
    'CoutputNames',{'out5'},...
    'CinputNames',{'X1' 'X2'});


%% Create object OptimizationProblem
Xop     = OptimizationProblem('Sdescription','Optimization problem', ...
    'Xinput',Xin,'VinitialSolution',[0.1 0.1], ...
    'CXobjectiveFunctions',{Xobjfun1 Xobjfun2 Xobjfun3 Xobjfun4 Xobjfun5});

%% Define an optimization method 
Xmm   = MiniMax;
display(Xmm)

%% Solve optimization problem
Xopt = Xmm.apply('XOptimizationProblem',Xop);

display(Xopt)

%% Reference Solution
VreferenceSolution=[0 -64 -2 -8 0];
assert(max(VreferenceSolution-Xopt.VoptimalScores)<2e-2,...
    'OpenCossan:Tutorials:BFGS','Optained solution does not match the Reference solution ')
OpenCossan.cossanDisp(' ');
OpenCossan.cossanDisp('Reference solution');
OpenCossan.cossanDisp('f(4.0,4.0) = 0 -64 -2 -8 0');

