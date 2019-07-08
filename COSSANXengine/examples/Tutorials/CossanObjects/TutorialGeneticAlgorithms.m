%% Tutorial for the GeneticAlgorithms object
% This tutorial shows how to optimize the Rastrigin's function using
% GeneticAlgorithms
%
% See Also: https://cossan.co.uk/wiki/index.php/@GeneticAlgorithms
%
% $Copyright~1993-2019,~COSSAN~Working~Group$
%
% $Author: Edoardo~Patelli$
% $email address: openengine@cossan.co.uk$

% =====================================================================
% This file is part of openCOSSAN.  The open general purpose matlab
% toolbox for numerical analysis, risk and uncertainty quantification.
%
% openCOSSAN is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License.
%
% openCOSSAN is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
% =====================================================================
%% Define Problem

% Create DesignVariable objects
X1      = DesignVariable('Sdescription','design variable 1','value',0);
X2      = DesignVariable('Sdescription','design variable 2','value',0);
% Create an Input object containing the design variables
Xin     = Input('Sdescription','Input for the Rastrigin function',...
    'CSmembers',{'X1' 'X2'},'CXmembers',{X1 X2});

% Create objective function
% The objective function is based on the  Matlab Rastrigins defined as follows:
% scores = 10.0 * size(pop,2) + sum(pop .^2 - 10.0 * cos(2 * pi .* pop),2);
% where pop are the population of the genetic algorithms (i.e. number of inputs)

Xofun   = ObjectiveFunction('Sdescription','Rastrigin function', ...
    'Lfunction',true,'Liomatrix',true,'Liostructure',false,...
    'Cinputnames',{'X1','X2'},... % Define the inputs
    'Spath',fullfile(matlabroot,'toolbox','globaloptim','globaloptimdemos'),...
    'Sfile','rastriginsfcn.m',... % external file
    'Coutputnames',{'fobj'}); %#ok<MCTBX,MCMLR> % Define the outputs


%% Define OptimizationProblem
Xop     = OptimizationProblem('Sdescription','Rastrigin optimization problem','Xinput',Xin,...
    'XobjectiveFunction', Xofun);

%% Create initial solution
OpenCossan.resetRandomNumberGenerator(2727)

Npopulation_size    = 100;
Mx0     = unifrnd(repmat([5 5],Npopulation_size,1),...
    repmat([10 10],Npopulation_size,1));     %Initial Population


%% Create optimizer (GeneticAlgorithms)
% Here we are using the default parameter for the Genetic Algorithms
Xga     = GeneticAlgorithms('NPopulationSize',Npopulation_size);
% Show details of the object
display(Xga)

% Please note that the initial solutions need to be passed as input
% argument to the apply method. It is not possible to "bound" the initial
% solution to the Optimizer  because the initial solution are problem
% dependent.
Xoptimum  = Xga.apply('XoptimizationProblem',Xop,'Minitialsolutions',Mx0);
display(Xoptimum)
%% Validate solution
Vreference=[0 0];
assert(max(Vreference-Xoptimum.VoptimalDesign)<1e-2,...
    'OpenCossan:TutorialGeneticAlgorithms:wrongRefSolution',...
    'Reference Solution not identified')


%% Customize solver

OpenCossan.resetRandomNumberGenerator(51125)
Npopulation_size    = 100;
Mx0     = unifrnd(repmat([5 5],Npopulation_size,1),...
    repmat([10 10],Npopulation_size,1));     %Initial Population

Xga     = GeneticAlgorithms('SFitnessScalingFcn','fitscalingtop',...
    'SSelectionFcn','selectionremainder',...
    'NPopulationSize',Npopulation_size, ...
    'NmaxIterations',50,'NStallGenLimit',5);

% Here a (partial) initial population is provided
Xoptimum  = Xga.apply('XoptimizationProblem',Xop,'Minitialsolutions',Mx0);
display(Xoptimum)
%%  Reference Solution
OpenCossan.cossanDisp(' ');
OpenCossan.cossanDisp('Reference solution');
OpenCossan.cossanDisp('Global Minimum (0.0,0.0) = 0.0');

%% Validate solution
Vreference=[0 0];
assert(max(Vreference-Xoptimum.VoptimalDesign)<1e-3,...
        'OpenCossan:TutorialGeneticAlgorithms:wrongRefSolution',...
        'Reference Solution not identified')

%% Compute Reference Solution
% using pure Matlab implementation of GeneticAlgorithm
% Reset the random number generator in order to obtain always the same results.
% DO NOT CHANGE THE VALUES OF THE SEED
OpenCossan.resetRandomNumberGenerator(51125)

Toptions                    = gaoptimset;                %Default optimization options
Toptions.InitialPopulation  = Xop.VinitialSolution;      % Define the initial population
Toptions.PopulationSize     = Npopulation_size;      %scalar, number of individuals in population
Toptions.Generations        = 25;         %scalar defining maximum number of generations to be created
Toptions.MutationFcn       = str2func('mutationadaptfeasible');
Toptions.Display            = 'iter';    %sets level of display
Toptions.Vectorized         = 'on';     %enables possibility of calculating fitness of population using a single function call

[xReferenceSolutions,~,~,~,~,~] = ga(@rastriginsfcn, 2,Toptions);

%% validate solutions
Vdata = Xoptimum.VoptimalDesign;
assert(max(Vdata-xReferenceSolutions)<1e-4,...
    'OpenCossan:Tutorial','Obtained solution does not match with the reference solution')

%% Constrained Minimization Using Genetic Algorithms
% Suppose you want to minimize the simple fitness function of two variables x1
% and x2:
% $$f(x)=100(x_1^2-x_2^2)^2+(1+x_1)^2$$
%
% subject to the following nonlinear inequality constraints and bounds
%
% $$x_1 \cdot x_2 + x_1 - x_2 + 1.5 \le 0$$
% $$10-x_1 \cdot x_2 \le 0$$
% $$0 \le x_1 \le 1$$
% $$0 \le x_2 \le 13$$
%
% Begin by creating the input objects required to defien the objective function
% and constraints.
% First you have to create the Design Variables limited to the allowed bounds:

X1=DesignVariable('lowerBound',0,'upperBound',1,'value',0.5);
X2=DesignVariable('lowerBound',0,'upperBound',13,'value',1);

% Create a Input object containing these DesignVariable
Xin     = Input('Sdescription','Input for the constraind minimization problem',...
    'CSmembers',{'X1' 'X2'},'CXmembers',{X1 X2});

%% Define the fittnest (i.e. Objective Function)
Xobj=ObjectiveFunction('Sdescription','simple fitness', ...
    'Lfunction',false,'Liomatrix',true,'Liostructure',false,...
    'Cinputnames',{'X1','X2'},... % Define the inputs
    'Sscript','Moutput = 100*(Minput(:,1).^2 - Minput(:,2)).^2 + (1 - Minput(:,1)).^2;',... % the real function
    'Coutputnames',{'fobj'}); % Define the outputs

Xobj2=ObjectiveFunction('Sdescription','simple fitness', ...
    'Lfunction',false,'Liomatrix',true,'Liostructure',false,...
    'Cinputnames',{'X1','X2'},... % Define the inputs
    'Sscript','Moutput = 100*(Minput(:,1).^2 - Minput(:,2)).^2 + (1 - Minput(:,1)).^2;',... % the real function
    'Coutputnames',{'fobj2'}); % Define the outputs

%% Define Constraints
Xcon1=Constraint('Sdescription','First nonlienear constraint', ...
    'Lfunction',false,'Liomatrix',true,'Liostructure',false,...
    'Cinputnames',{'X1','X2'},... % Define the inputs
    'Sscript','Moutput = 1.5 + Minput(:,1).*Minput(:,2) + Minput(:,1) - Minput(:,2);',... % the real function
    'Coutputnames',{'c1'}); % Define the name of the constaint

Xcon2=Constraint('Sdescription','First nonlienear constraint', ...
    'Lfunction',false,'Liomatrix',true,'Liostructure',false,...
    'Cinputnames',{'X1','X2'},... % Define the inputs
    'Sscript','Moutput =- Minput(:,1).*Minput(:,2) + 10;',... % the real function
    'Coutputnames',{'c2'}); % Define the name of the constaint


%% Define OptimizationProblem
Xop     = OptimizationProblem('Sdescription','Constrained Minimization','Xinput',Xin,...
    'CXobjectiveFunctions', {Xobj Xobj2} ,'Xconstraint',[Xcon1 Xcon2]);

%% Create optimizer (GeneticAlgorithms)
Xga     = GeneticAlgorithms('NPopulationSize',10,...
    'toleranceObjectiveFunction',1e-2,...
    'toleranceDesignVariables',1e-2,...
'NmaxIterations',20,'SMutationFcn','mutationadaptfeasible');

OpenCossan.resetRandomNumberGenerator(51125)

Xoptimum  = Xga.apply('XoptimizationProblem',Xop,'LplotEvolution',false);
display(Xoptimum)

Vreference=[8.123e-01  1.23202e+01];
%% Validate Solution
Vdata = Xoptimum.VoptimalDesign;
assert(sum(abs(Vdata-Vreference))<1e-3,...
    'OpenCossan:Tutorial','Obtained solution does not match with the reference solution')


