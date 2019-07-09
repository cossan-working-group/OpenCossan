%% TUTORIALMINIMAX
% Tutorial for MiniMax optimization method.
% This tutorial shows a very simple example to perform multi-objective
% optimization adoptin min-max method.
%
% the Aim of this tutorial is to find x that minimize the maximum value of 5
% objective functions. 
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@MiniMax
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author:~Edoardo~Patelli$ 
clear
close all
clc;

%% prepate Input objects
% Create Parameter objects
X1      = opencossan.optimization.DesignVariable('Sdescription','design variable 1','value',0.1);
X2      = opencossan.optimization.DesignVariable('Sdescription','design variable 2','value',0.1);

% Create an Input object containing the design variables
Xin     = opencossan.common.inputs.Input('description','Input for the MinMax optimization','membersnames',{'X1' 'X2'},'members',[X1; X2]);

%% Create objective functions
Xobjfun1   = opencossan.optimization.ObjectiveFunction('description','objective function #1', ...
    'Script','for n=1:length(Tinput),Toutput(n).out1=2*Tinput(n).X1^2+Tinput(n).X2^2 - 48*Tinput(n).X1-40*Tinput(n).X2 +304;end',...
    'OutputNames',{'out1'},...
    'InputNames',{'X1' 'X2'});

Xobjfun2   = opencossan.optimization.ObjectiveFunction('description','objective function #2', ...
    'Script','for n=1:length(Tinput),Toutput(n).out2=-Tinput(n).X1^2-3*Tinput(n).X2^2;end',...
    'OutputNames',{'out2'},...
    'InputNames',{'X1' 'X2'});

Xobjfun3   = opencossan.optimization.ObjectiveFunction('description','objective function #3', ...
    'Script','for n=1:length(Tinput),Toutput(n).out3=Tinput(n).X1+3*Tinput(n).X2-18;end',...
    'OutputNames',{'out3'},...
    'InputNames',{'X1' 'X2'});

Xobjfun4   = opencossan.optimization.ObjectiveFunction('description','objective function #4', ...
    'Script','for n=1:length(Tinput),Toutput(n).out4=-Tinput(n).X1-Tinput(n).X2;end',...
    'OutputNames',{'out4'},...
    'InputNames',{'X1' 'X2'});

Xobjfun5   = opencossan.optimization.ObjectiveFunction('description','objective function #5', ...
    'Script','for n=1:length(Tinput),Toutput(n).out5=Tinput(n).X1+Tinput(n).X2-8;end',...
    'OutputNames',{'out5'},...
    'InputNames',{'X1' 'X2'});


%% Create object OptimizationProblem
Xop     = opencossan.optimization.OptimizationProblem('Sdescription','Optimization problem', ...
    'Xinput',Xin,'VinitialSolution',[0.1 0.1], ...
    'CXobjectiveFunctions',{Xobjfun1 Xobjfun2 Xobjfun3 Xobjfun4 Xobjfun5});

%% Define an optimization method 
Xmm   = MiniMax;
display(Xmm)

%% Solve optimization problem
Xopt = Xmm.apply('XOptimizationProblem',Xop);

display(Xopt)

%% Reference Solution
VreferenceSolution=[0; -64; -2; -8; 0];
Mdata = cell2mat({Xopt.XobjectiveFunction.Vdata}');
assert(max(VreferenceSolution-Mdata(:,end))<3e-3,...
    'openCOSSAN:Tutorials:BFGS','Optained solution does not match the Reference solution ')
OpenCossan.cossanDisp(' ');
OpenCossan.cossanDisp('Reference solution');
OpenCossan.cossanDisp('f(4.0,4.0) = 0 -64 -2 -8 0');

