%% Tutorial for the COBYLA object
% The acronym COBYLA stands for Constrained Optimization by Linear
% Approximation. COBYLA is a gradient-free optimization algorithm capable of
% handling nonlinear inequality constraints. 
% COBYLA shares some common characteristics with the popular Nelder-Mead
% algorithm for optimization, i.e. in both algorithms, a polytope of N+1
% vertices is constructed (where N is the dimensionality of the design variable
% vector). In COBYLA, the value of the objective function and constraints is
% calculated at each vertex of the polytope; with this information, approximate
% linear representations of the objective function and constraints are
% generated. Using these approximations, an approximate optimization problem is
% solved over a trust region. The size of the trust region is controlled by the
% algorithm and it is decreased as convergence is achieved.    
%
% In this tutorial COBYLA is used to solve the following problem: 
% 
% $$min f(x)=x_1^2 +x_2^2 | g(x)=2-x_1+x_2 \le 0$$
% 
% where f(x) represents the objective function and g(x) the contraints.
% x1 and x2 are continuos design variables defined in (0,+Inf)
% 
%    
% 
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@Cobyla
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author: Edoardo-Patelli$ 

clear;
close all
clc;
%% Create input 
% In this tutorial we create a very simple accademic example in order to show
% how to used the optimization method. The input object must contain at least 1
% Design Variable.


X1      = opencossan.optimization.DesignVariable('Sdescription','design variable 1','value',7,'lowerBound',0);
X2      = opencossan.optimization.DesignVariable('Sdescription','design variable 2','value',2,'lowerBound',0);
Xin     = opencossan.common.inputs.Input('MembersNames',{'X1' 'X2'},'Members',{X1 X2});


%% Define a model 
Xm  = opencossan.workers.Mio('Description','objective function of optimization problem', ...
...    'Spath','./',...
    'Script','for i=1:length(Tinput),x1  = Tinput(i).X1; x2  = Tinput(i).X2; Toutput(i).mioout     = x1.^2 + x2.^2; end',...
    'Format','structure',...
    'IsFunction',false,...
    'InputNames',{'X1','X2'},...
    'OutputNames',{'mioout'});
% 
 Xe      = opencossan.workers.Evaluator('Xmio',Xm);     % Define the evaluator
 Xmdl    = opencossan.common.Model('Xevaluator',Xe,'Xinput',Xin);


%%  Create objective function
% The objective function corresponds to the output of the model. It is not
% necessary to have a Model to perform and optimization. 

Xofun1   = opencossan.optimization.ObjectiveFunction('Description','objective function', ...
    'Script','for n=1:height(TableInput), TableOutput.fobj(n)=TableInput.mioout(n); end',...
    'InputNames',{'mioout'},...
    'OutputNames',{'fobj'});

%% Create non linear inequality constraint
Xcon   = opencossan.optimization.Constraint('Description','non linear inequality constraint', ...
    'Script','for n=1:height(TableInput),TableOutput.Con1(n)=2-TableInput.X1(n)-TableInput.X2(n);end',...
    'OutputNames',{'Con1'},'InputNames',{'X1','X2'},'Linequality',true);

%% define the optimizator problem
Xop     = OptimizationProblem('Sdescription','Optimization problem', ...
    'Xmodel',Xmdl,'VinitialSolution',[-5 -1], ...
    'XobjectiveFunction',Xofun1,'Xconstraint',Xcon);

%% Create optimizer
% A COBYLA objet is a optimizer with 2 dedicate parameters:
% * initialTrustRegion = define the radious of the initial spheric trust region
% * finalTrustRegion = define the minimum radius of the spheric trust region

Xcob    = Cobyla('initialTrustRegion',1,'finalTrustRegion',0.01);

% Reset the random number generator in order to obtain always the same results.
% DO NOT CHANGE THE VALUES OF THE SEED
OpenCossan.resetRandomNumberGenerator(46354)

Xoptimum=Xop.optimize('Xoptimizer',Xcob);
display(Xoptimum)

%% Reference Solution
OpenCossan.cossanDisp(' ');
OpenCossan.cossanDisp('Reference solution');
OpenCossan.cossanDisp('f(1.0,1.0) = 2.0');

%% Validate solution
Vreference=[ 9.9084e-01; 1.0092e+00];
Mdata = [Xoptimum.XdesignVariable(1).Vdata; Xoptimum.XdesignVariable(2).Vdata];
assert(max(Vreference-Mdata(:,end))<1e-4,'openCOSSAN:Tutorial:TutorialCobyla','Reference Solution not identified')
