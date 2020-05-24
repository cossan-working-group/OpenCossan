%% Tutorial for the GeneticAlgorithms object
% This tutorial shows how to optimize the Rastrigin's function using
% GeneticAlgorithms
%
% See Also: GeneticAlgorithms
%
% $Copyright~1993-2020,~COSSAN~Working~Group$
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

% Create DesignVariable objects
x1 = opencossan.optimization.ContinuousDesignVariable('Description','design variable 1','value',0);
x2 = opencossan.optimization.ContinuousDesignVariable('Description','design variable 2','value',0);
% Create an Input object containing the design variables
input = opencossan.common.inputs.Input(...
    'MembersNames',{'x1' 'x2'}, 'Members',{x1 x2});

% Create objective function
% The objective function is based on the  Matlab Rastrigins defined as follows:
% scores = 10.0 * size(pop,2) + sum(pop .^2 - 10.0 * cos(2 * pi .* pop),2);
% where pop are the population of the genetic algorithms (i.e. number of inputs)

Xofun   = opencossan.optimization.ObjectiveFunction('description','Rastrigin function', ...
    'IsFunction',true, ...
    'Format', 'matrix', ...
    'InputNames',{'x1','x2'},... % Define the inputs
    'FullFileName',fullfile(matlabroot,'toolbox','globaloptim','globaloptimdemos','rastriginsfcn.m'),...
...    'Sfile','rastriginsfcn.m',... % external file
    'OutputNames',{'fobj'}); %#ok<MCTBX,MCMLR> % Define the outputs


%% Define OptimizationProblem
Xop     = opencossan.optimization.OptimizationProblem('Description','Rastrigin optimization problem','input',input,...
    'objectiveFunctions', Xofun);

%% Create initial solution
opencossan.OpenCossan.resetRandomNumberGenerator(2727)

Npopulation_size    = 100;
Mx0     = unifrnd(repmat([5 5],Npopulation_size,1),...
    repmat([10 10],Npopulation_size,1));     %Initial Population


%% Create optimizer (GeneticAlgorithms)
% Here we are using the default parameter for the Genetic Algorithms
Xga     = opencossan.optimization.GeneticAlgorithms('PopulationSize',Npopulation_size);
% Show details of the object
display(Xga)

% Please note that the initial solutions need to be passed as input
% argument to the apply method. It is not possible to "bound" the initial
% solution to the Optimizer  because the initial solution are problem
% dependent.
optimum  = Xga.apply('OptimizationProblem',Xop,'Initialsolutions',Mx0);
display(optimum)
%% Validate solution
Vreference=[0 0];
assert(max(Vreference-optimum.OptimalSolution)<1e-2,'openCOSSAN:Tutorial:TutorialGeneticAlgorithms','Reference Solution not identified')


%% Customize solver

opencossan.OpenCossan.resetRandomNumberGenerator(51125)
Npopulation_size    = 100;
Mx0     = unifrnd(repmat([5 5],Npopulation_size,1),...
    repmat([10 10],Npopulation_size,1));     %Initial Population

Xga     = opencossan.optimization.GeneticAlgorithms('FitnessScalingFcn','fitscalingtop',...
    'SelectionFcn','selectionremainder',...
    'PopulationSize',Npopulation_size, ...
    'MaxIterations',50,'StallGenLimit',5);

% Here a (partial) initial population is provided
optimum  = Xga.apply('optimizationProblem',Xop,'initialsolutions',Mx0);
display(optimum)
%%  Reference Solution
opencossan.OpenCossan.cossanDisp(' ');
opencossan.OpenCossan.cossanDisp('Reference solution');
opencossan.OpenCossan.cossanDisp('Global Minimum (0.0,0.0) = 0.0');

%% Validate solution
Vreference=[0 0];
assert(max(Vreference-optimum.OptimalSolution)<1e-3,'openCOSSAN:Tutorial:TutorialGeneticAlgorithms','Reference Solution not identified')

%% Compute Reference Solution
% using pure Matlab implementation of GeneticAlgorithm
% Reset the random number generator in order to obtain always the same results.
% DO NOT CHANGE THE VALUES OF THE SEED
opencossan.OpenCossan.resetRandomNumberGenerator(51125)

Toptions                    = optimoptions('ga');                %Default optimization options
Toptions.InitialPopulation  = Xop.InitialSolution;      % Define the initial population
Toptions.PopulationSize     = Npopulation_size;      %scalar, number of individuals in population
Toptions.Generations        = 25;         %scalar defining maximum number of generations to be created
Toptions.MutationFcn       = 'mutationadaptfeasible';
Toptions.Display            = 'iter';    %sets level of display
Toptions.Vectorized         = 'on';     %enables possibility of calculating fitness of population using a single function call

xReferenceSolutions = ga(@rastriginsfcn, 2,Toptions);

%% validate solutions
Vdata = optimum.OptimalSolution;
assert(max(Vdata-xReferenceSolutions)<1e-4,...
    'openCOSSAN:Tutorial','Obtained solution does not match with the reference solution')

%% Constrained Minimization Using Genetic Algorithms
% Suppose you want to minimize the simple fitness function of two variables x1
% and x2:getOptimalDesigngetOptimalDegetOptimalDesignsign
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

% Create DesignVariable objects
x1 = opencossan.optimization.ContinuousDesignVariable('Description','design variable 1','value',0);
x2 = opencossan.optimization.ContinuousDesignVariable('Description','design variable 2','value',0);
% Create an Input object containing the design variables
input = opencossan.common.inputs.Input(...
    'MembersNames',{'x1' 'x2'}, 'Members',{x1 x2});
%% Define the fittnest (i.e. Objective Function)
Xobj=opencossan.optimization.ObjectiveFunction('Description','simple fitness', ...
    'format','matrix',...
    'Inputnames',{'x1','x2'},... % Define the inputs
    'Script','Moutput = 100*(Minput(:,1).^2 - Minput(:,2)).^2 + (1 - Minput(:,1)).^2;',... % the real function
    'Outputnames',{'fobj'}); % Define the outputs

%% Define Constraints
Xcon1=opencossan.optimization.Constraint('Description','First nonlienear constraint', ...
    'format','matrix',...
    'Inputnames',{'x1','x2'},... % Define the inputs
    'Script','Moutput = 1.5 + Minput(:,1).*Minput(:,2) + Minput(:,1) - Minput(:,2);',... % the real function
    'Outputnames',{'c1'}); % Define the name of the constaint

Xcon2=opencossan.optimization.Constraint('Description','First nonlienear constraint', ...
    'format', 'matrix', ...
    'Inputnames',{'x1','x2'},... % Define the inputs
    'Script','Moutput =- Minput(:,1).*Minput(:,2) + 10;',... % the real function
    'Outputnames',{'c2'}); % Define the name of the constaint


%% Define OptimizationProblem
Xop     = opencossan.optimization.OptimizationProblem('Description','Constrained Minimization','Input',input,...
    'objectiveFunctions', Xobj,'constraints',[Xcon1 Xcon2]);

%% Create optimizer (GeneticAlgorithms)
Xga     = opencossan.optimization.GeneticAlgorithms('PopulationSize',10,...
    'ObjectiveFunctionTolerance',1e-2,'MaxIterations',20,'MutationFcn','mutationadaptfeasible');

opencossan.OpenCossan.resetRandomNumberGenerator(51125)

optimum  = Xop.optimize('optimizer', Xga);

Vreference=[-1.2312e+01, -8.1220e-01];
%% Validate Solution
Vdata = optimum.OptimalSolution;
assert(sum(abs(Vdata-Vreference))<1e-3,...
    'openCOSSAN:Tutorial','Obtained solution does not match with the reference solution')


