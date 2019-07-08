%% TUTORIALEVOLUTIONSTRATEGY
%
%   Optimization of Himmelblau Function using 
%   Evolution Strategy
%   
%
% See Also:  https://cossan.co.uk/wiki/index.php/@EvolutionStrategy
%
% $Copyright~1993-2011,~COSSAN~Working~Group$
% $Author:~Edoardo~Patelli$ 

%% prepate Input objects
% The Himmelblau function requires two design variables. The design variables
% are defined by means of the parameters objects.

%% prepate Input objects
% The Himmelblau function requires two design variables. The design variables
% are defined by means of the parameters objects.

% Create DesignVariable objects
X1      = DesignVariable('Sdescription','design variable 1','value',0); 
X2      = DesignVariable('Sdescription','design variable 2','value',0); 
% Create an Input object containing the design variables
Xin     = Input('Sdescription','Input for the Himmelblau function',...
    'CSmembers',{'X1' 'X2'},'CXmembers',{X1 X2});

%% Create objective function
Xofun   = ObjectiveFunction('Sdescription','Himmelblau function', ...
         'Lfunction',true,'Liomatrix',true,'Liostructure',false,...
          'Cinputnames',{'X1','X2'},... % Define the inputs 
          'Spath',fullfile(OpenCossan.getCossanRoot,'examples',...
          'Models','MatlabFunctions','Himmelblau'),...
          'Sfile','Himmelblau',... % external file
          'Coutputnames',{'fobj'}); % Define the outputs
      


%% Define OptimizationProblem
Xop     = OptimizationProblem('Sdescription','Himmelblau optimization problem','Xinput',Xin,...
    'XobjectiveFunction', Xofun);%,'MinitialSolutions',Minisol);

%% Create optimizer object CrossEntropy
Xes     = EvolutionStrategy('toleranceObjectiveFunction',1e-3,'Nmaxiterations',100,...
    'Vsigma',[0.5 1],'Nmu',10,'Nlambda',70,'Nrho',2);

Xes     = EvolutionStrategy('toleranceObjectiveFunction',1e-3,'Nmaxiterations',100,...
    'Vsigma',0.5,'Nmu',10,'Nlambda',70,'Nrho',2);

% Show details of the object
display(Xes)

%% Solve optimization problem
% Reset the random number generator in order to obtain always the same results.
% DO NOT CHANGE THE VALUES OF THE SEED
OpenCossan.resetRandomNumberGenerator(8756)
Xoptimum  = Xes.apply('XoptimizationProblem',Xop);
display(Xoptimum)
%%  Reference Solution
OpenCossan.cossanDisp(' ');
OpenCossan.cossanDisp('Reference solution');
OpenCossan.cossanDisp('f(3.0,2.0) = 0.0');
OpenCossan.cossanDisp('f(-2.805118, 3.131312) = 0.0');
OpenCossan.cossanDisp('f(-3.779310, -3.283186) = 0.0');
OpenCossan.cossanDisp('f(3.584428, -1.848126) = 0.0');

%% Validate solution
Vreference=[3 2];
assert(max(Vreference-Xoptimum.VoptimalDesign)<1e-2,'OpenCossan:Tutorial:TutorialCrossEntropy','Reference Solution not identified')

