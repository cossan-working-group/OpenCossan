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
close all
clear
clc;
%% prepate Input objects
% The simple example function requires two design variables. The design variables
% are defined by means of the parameters objects.

% Create Parameter objects
X1      = opencossan.optimization.DesignVariable('Sdescription','design variable 1','value',7);
X2      = opencossan.optimization.DesignVariable('Sdescription','design variable 2','value',2);
% Create an Input object containing the design variables
Xin     = opencossan.common.inputs.Input('description','Input for the simple example function','membersnames',{'X1' 'X2'},'members',{X1 X2});

%% Create objective function
Xobjfun   = opencossan.optimization.ObjectiveFunction('description','objective function', ...
    'Script','for n=1:length(Tinput),Toutput(n).out1=Tinput(n).X1^2+Tinput(n).X2^2;end',...
    'OutputNames',{'out1'},...
    'InputNames',{'X1' 'X2'});


%% Create object OptimizationProblem
Xop     = opencossan.optimization.OptimizationProblem('Sdescription','Optimization problem', ...
    'Xinput',Xin,'VinitialSolution',[7 2], ...
    'XobjectiveFunction',Xobjfun);
display(Xop)

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
Vdata = Xopt.XobjectiveFunction.Vdata;
assert(abs(Vdata(end)-0)<1e-4,'openCOSSAN:Tutorials','wrong results')
