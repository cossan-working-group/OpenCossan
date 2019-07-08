%% TUTORIALSIMULATEDANNEALING
% The optimization method Simulated Annealing is used to optimize the Himmelblau
% Function and the De Jong's fifth function is a two-dimensional function with
% many (25) local minima 
%   
%   
%   
% See Also: https://cossan.co.uk/wiki/index.php/@SimulatedAnnealing
%
% $Copyright~1993-2018,~COSSAN~Working~Group$
% $Author: Edoardo~Patelli$ 

%% prepate Input objects
% The Himmelblau function requires two design variables. The design variables
% are defined by means of the parameters objects.

% Create DesignVariable objects
X1      = DesignVariable('Sdescription','design variable 1','value',0); 
X2      = DesignVariable('Sdescription','design variable 2','value',0); 
% Create an Input object containing the design variables
Xin     = Input('Sdescription','Input for the Himmelblau function','CSmembers',{'X1' 'X2'},'CXmembers',{X1 X2});

%% Create objective function
Xofun   = ObjectiveFunction('Sdescription','Himmelblau function', ...
         'Lfunction',true,'Liomatrix',true,'Liostructure',false,...
          'Cinputnames',{'X1','X2'},... % Define the inputs 
          'Spath',fullfile(OpenCossan.getCossanRoot,'examples','Models','MatlabFunctions','Himmelblau'),...
          'Sfile','Himmelblau',... % external file
          'Coutputnames',{'fobj'}); % Define the outputs
      

%% Define OptimizationProblem
Xop     = OptimizationProblem('Sdescription','Himmelblau optimization problem','Xinput',Xin,...
    'XobjectiveFunction', Xofun);

%% Create optimizer object SimulatedAnnealing
Xsa     = SimulatedAnnealing('toleranceObjectiveFunction',1e-2,'Nmaxmoves',100);

% Show details of the object
display(Xsa)

% Solve optimization problem
%Many standard optimization algorithms get stuck in local minima. Because the
%simulated annealing algorithm performs a wide random search, the chance of
%being trapped in local minima is decreased.

% Reset the random number generator in order to obtain always the same results.
% DO NOT CHANGE THE VALUES OF THE SEED
OpenCossan.resetRandomNumberGenerator(46375)

Xoptimum  = Xsa.apply('XoptimizationProblem',Xop);
display(Xoptimum)

%% Validate solutions
assert(max(abs(Xoptimum.VoptimalScores))<1e-4,...
    'OpenCossan:TutorialSimulatingAnnealing','Wrong solution')

%% Customize solver
% Be carefull when you use the different options of SimulationAnneling, 
% This can lead to a not efficient simulation

Xsa     = SimulatedAnnealing('initialTemperature',10,'Nmaxmoves',50,...
    'StemperatureFunction','temperatureboltz');
Xoptimum2  = Xsa.apply('XoptimizationProblem',Xop);
display(Xoptimum2)

% In this case the optimization procedure remained trapped in a local minima.


%%  Reference Solution
OpenCossan.cossanDisp(' ');
OpenCossan.cossanDisp('Reference solution');
OpenCossan.cossanDisp('f(3.0,2.0) = 0.0');
OpenCossan.cossanDisp('f(-2.805118, 3.131312) = 0.0');
OpenCossan.cossanDisp('f(-3.779310, -3.283186) = 0.0');
OpenCossan.cossanDisp('f(3.584428, -1.848126) = 0.0');

%% Minimize  De Jong's fifth function
% This section presents an example that shows how to find the minimum of the function using simulated annealing.
% De Jong's fifth function is a two-dimensional function with many (25) local minima

% Show function to be minimize
dejong5fcn

%% Create objective function
Xofun   = ObjectiveFunction('Sdescription','De Jong''s fifth function function', ...
          'Lfunction',true,'Liomatrix',true,'Liostructure',false,...
          'Cinputnames',{'X1','X2'},... % Define the inputs 
          'Afunction',@dejong5fcn,... % external file
          'Coutputnames',{'fobj'}); % Define the outputs

% Define OptimizationProblem
Xop     = OptimizationProblem('Sdescription','Himmelblau optimization problem','Xinput',Xin,...
    'XobjectiveFunction', Xofun);

Xsa     = SimulatedAnnealing('SannealingFunction','annealingfast','Nmaxmoves',100);

% Reset the random number generator in order to obtain always the same results.
% DO NOT CHANGE THE VALUES OF THE SEED
OpenCossan.resetRandomNumberGenerator(46375)
Xoptimum  = Xsa.apply('Lplotevolution',true,'XoptimizationProblem',Xop, ...
    'Vinitialsolution',[0 0]);
display(Xoptimum)
