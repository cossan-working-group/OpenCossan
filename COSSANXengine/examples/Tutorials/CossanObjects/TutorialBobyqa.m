%% Tutorial for the BOBYQA object
%
% In this tutorial BOBYQA is used to find the minimum of the Rosenbrock
% function.  
% The Rosenbrock function is linked via a Mio object and the objective
% function is a copy of the Mio object. 
% X1 and X2 are continuos design variables defined in (-5,5)
%  
% See Also: http://cossan.co.uk/wiki/index.php/@Bobyqa
% $Copyright~1993-2018,~COSSAN~Working~Group$
% $Author:~Edoardo~Patelli$ 

%% Create input 
% In this tutorial we create a very simple accademic example in order to show
% how to use the optimization method. The input object must contain at least 1
% Design Variable.


X1      = DesignVariable('Sdescription','design variable 1','value',rand,...
    'lowerBound',-5,'upperBound',5);
X2      = DesignVariable('Sdescription','design variable 2','value',rand,...
    'lowerBound',-5,'upperBound',5);
Xin     = Input('CSmembers',{'X1' 'X2'},'CXmembers',{X1 X2});

%% Define a model 
SrosenbrockPath=fullfile(OpenCossan.getCossanRoot,'examples','Models','MatlabFunctions','Rosenbrock');
Xm  = Mio('Sdescription','the objective function is the Rosenbrock function', ...
    'Spath',SrosenbrockPath,...
    'Sfile','Rosenbrock.m',...
    'Liostructure',false,...
    'Lfunction',true,...
    'Liomatrix',true,...
    'Cinputnames',{'X1','X2'},...
    'Coutputnames',{'mioout'});
% 
 Xe      = Evaluator('Xmio',Xm);     % Define the evaluator
 Xmdl    = Model('Xevaluator',Xe,'Xinput',Xin);


%%  Create objective function
% The objective function corresponds to the output of the model. It is not
% necessary to have a Model to perform an optimization. 

Xofun1   = ObjectiveFunction('Sdescription','objective function', ...
    'Sscript','for n=1:length(Toutput), Toutput(n).fobj=Tinput(n).mioout; end',...
    'Cinputnames',{'mioout'},...
    'Liostructure',true,...
    'Coutputnames',{'fobj'});


%% define the optimizator problem
Xop     = OptimizationProblem('Sdescription','Optimization problem', ...
    'Xmodel',Xmdl,'VinitialSolution',[-4 1], ...
    'XobjectiveFunction',Xofun1);

%% Create optimizer
% A COBYLA object is a optimizer with 2 dedicate parameters:
% * initialTrustRegion = define the radious of the initial spheric trust region
% * finalTrustRegion = define the minimum radius of the spheric trust region

Xbob    = Bobyqa('nInterpolationConditions',0,...
    'stepSize',0.01,...
    'rhoEnd', 1e-6,...
    'xtolRel',1e-9,...
    'minfMax',1e-9,...
    'ftolRel',1e-8,...
    'ftolAbs',1e-14,...
    'verbose',1);

% % Reset the random number generator in order to obtain always the same results.
% % DO NOT CHANGE THE VALUES OF THE SEED
% OpenCossan.resetRandomNumberGenerator(46354)

Xoptimum=Xop.optimize('Xoptimizer',Xbob);
display(Xoptimum)

%% Reference Solution
OpenCossan.cossanDisp('Textbook solution');
OpenCossan.cossanDisp('f(1.0,1.0) = 0');
OpenCossan.cossanDisp('Reference solution');
OpenCossan.cossanDisp(['0.999997828110346 ','0.999995813360559'])
OpenCossan.cossanDisp('Bobyqa solution');
OpenCossan.cossanDisp(num2str(Xoptimum.VoptimalDesign,'% 10.15f'));

%% Validate solution
Vreference=[  0.999997828110346 0.999995813360559];
assert(max(Vreference-Xoptimum.VoptimalDesign)<1e-4,...
    'OpenCossan:Tutorial:TutorialBobyqaWrongReferenceSolution',...
    'Reference solution not identified!')

