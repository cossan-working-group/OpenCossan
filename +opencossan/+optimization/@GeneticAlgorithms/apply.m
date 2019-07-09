function [Xoptimum, varargout] = apply(Xobj,varargin)
%   APPLY   This method applies the algorithm
%           GeneticAlgorithms for optimization
%
%   GeneticAlgorithms is intended for solving an optimization
%   problem using evaluations of the objective function and constraints,
%   i.e. gradients are not required.
%
%   GeneticAlgorithms is intended for solving the following
%   class of problems
%
%                       min     f_obj(x)
%                       subject to
%                               ceq(x)      =  0
%                               cineq(x)    <= 0
%                               lb <= x <= ub
%
% See also: https://cossan.co.uk/wiki/index.php/apply@GeneticAlgorithms
%
% Author: Edoardo Patelli 
% Institute for Risk and Uncertainty, University of Liverpool, UK
% email address: openengine@cossan.co.uk
% Website: http://www.cossan.co.uk

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

%% Define global variable for the objective function and the constrains
global XoptGlobal XsimOutGlobal

OpenCossan.validateCossanInputs(varargin{:});
LplotEvolution=false;

%  Check whether or not required arguments have been passed
for k=1:2:length(varargin),
    switch lower(varargin{k}),
        case {'xoptimizationproblem'},   %extract OptimizationProblem
            assert(isa(varargin{k+1},'opencossan.optimization.OptimizationProblem'),...
                'openCOSSAN:Cobyla:apply:wrongOptimizationProblem',...
                ['The variable %s must be an opencossan.optimization.OptimizationProblem\n',...
                'Provided class: %s'],inputname(k),class(varargin{k+1}))
            % Load OptimizationProblem
            Xop     = varargin{k+1};
        case {'xoptimum'},   %extract OptimizationProblem
            %check that arguments is actually an OptimizationProblem object
            assert(isa(varargin{k+1},'opencossan.optimization.Optimum'),...
                'openCOSSAN:Cobyla:apply:wrongOptimum',...
                ['The variable %s must be an opencossan.optimization.Optimum\n',...
                'Provided class: %s'],inputname(k),class(varargin{k+1}))
            Xoptimum  = varargin{k+1};
        case 'minitialsolutions',
            MinitialSolutions=varargin{k+1};
        case 'lplotevolution'
            LplotEvolution=varargin{k+1};
        otherwise
            warning('openCOSSAN:GeneticAlgorithms:apply',['the field ' varargin{k} ...
                ' is ignored when applying GeneticAlgorithms']);
    end
end

%% Check Optimization problem
assert(logical(exist('Xop','var')), 'openCOSSAN:GeneticAlgorithms:apply',...
    'Optimization problem must be defined')

% Check inputs and initialize variables
Xobj = initializeOptimizer(Xobj);


%% Check initial solution
if exist('MinitialSolution','var')
    % The initial population can also be partial! Hence, no check about
    % the size of the provides initial solutions
    Xop.VinitialSolution=MinitialSolutions;
end

%% initialize Optimum
if ~exist('Xoptimum','var')
    XoptGlobal=Xop.initializeOptimum('LgradientObjectiveFunction',false, ...
        'LgradientConstraints',false,'Xoptimizer',Xobj);
else
    %TODO: Check Optimum
    XoptGlobal=Xoptimum;
end

if isempty(Xop.Xmodel)
    % Create handle of the objective function
    hobjfun=@(x)evaluate(Xop.XobjectiveFunction,'Xoptimizationproblem',Xop,...
        'MreferencePoints',x,'Lgradient',false,...
        'scaling',Xobj.scalingFactor);
else
    % Create handle of the objective function
    hobjfun=@(x)evaluate(Xop.XobjectiveFunction,'Xoptimizationproblem',Xop,...
        'MreferencePoints',x,'Lgradient',false,'Xmodel',Xop.Xmodel,...
        'scaling',Xobj.scalingFactor);
end

if isempty(Xop.Xmodel)
    % Create handle of the objective function
    hconstrains=@(x)evaluate(Xop.Xconstraint,'Xoptimizationproblem',Xop,...
        'MreferencePoints',x,'Lgradient',false,...
        'scaling',Xobj.scalingFactor);
else
    % Create handle of the objective function
    hconstrains=@(x)evaluate(Xop.Xconstraint,'Xoptimizationproblem',Xop,...
        'MreferencePoints',x,'Lgradient',false,'Xmodel',Xop.Xmodel,...
        'scaling',Xobj.scalingFactor);
end



assert(size(Xop.VinitialSolution,1)<=Xobj.NPopulationSize, ...
    'openCOSSAN:GeneticAlgorithms:apply', ...
    ['Initial population must be less the NpopulationSize (' num2str(Xobj.NPopulationSize) ')'])


assert(size(Xop.VinitialSolution,2)==length(Xop.CnamesDesignVariables), ...
    'openCOSSAN:GeneticAlgorithms:apply', ...
    'Initial solution must contain a number of columns equal to the number of design variables');



%% Prepare options structure for GeneticAlgorithms
Toptions                    = gaoptimset;                %Default optimization options
Toptions.InitialPopulation  = Xop.VinitialSolution;      % Define the initial population
Toptions.PopulationSize     = Xobj.NPopulationSize;      %scalar, number of individuals in population
Toptions.EliteCount         = Xobj.NEliteCount;          %scalar, indicates the number of elite individuals that are passed directly to the next generation
Toptions.CrossoverFraction  = Xobj.crossoverFraction;    %percentage of individuals of the next generation that are generated by means of crossover operations
Toptions.Generations        = Xobj.NmaxIterations;         %scalar defining maximum number of generations to be created
Toptions.StallGenLimit      = Xobj.NStallGenLimit;       %scalar; the optimization algorithm stops if there has been no improvement in the objective function for 'NStallGenLimit' consecutive generations
Toptions.TolFun             = Xobj.toleranceObjectiveFunction;   %Termination criterion w.r.t. objective function; algorithm is stopped if the  cumulative change of the fitness function over 'NStallGenLimit' is less than 'ToleranceObjectiveFunction'
Toptions.TolCon             = Xobj.toleranceConstraint;          %Defines tolerance w.r.t. constraints
Toptions.InitialPenalty     = Xobj.initialPenalty;               %Initial value of penalty parameter; used in constrained optimization
Toptions.PenaltyFactor      = Xobj.penaltyFactor;                %parameter for updating the penalty factor; required in constrained optimization
Toptions.FitnessScalingFcn  = str2func(Xobj.SFitnessScalingFcn); %eval(['@' SFitnessScalingFcn]);   %scaling of fitness function
Toptions.SelectionFcn       = str2func(Xobj.SSelectionFcn);      %eval(['@' SSelectionFcn]);        %function for selecting parents for crossover and mutation
Toptions.CrossoverFcn       = str2func(Xobj.SCrossoverFcn);      %eval(['@' SCrossoverFcn]);        %function for generating crossover children
Toptions.MutationFcn       = str2func(Xobj.SMutationFcn);
Toptions.CreationFcn       = str2func(Xobj.SCreationFcn);
Toptions.Display            = 'iter';    %sets level of display
Toptions.Vectorized         = 'on';     %enables possibility of calculating fitness of population using a single function callXop.VlowerBounds,Xop.VupperBounds
Toptions.TimeLimit          = Xobj.timeout; % termination criteria
Toptions.OutputFcns = @Xobj.outputFunction;

% initialize global variable
XsimOutGlobal=[];

%% Perform Real optimization

OpenCossan.setLaptime('description',['GA:' Xobj.Sdescription]);
OpenCossan.cossanDisp('Starting GeneticAlgorithms',2)

if isempty(Xop.Xconstraint)
    if LplotEvolution
        Toptions = gaoptimset('PlotFcns',{@gaplotbestf});
    end
    
    if ~Xobj.LextremeOptima
        % Run constrained optimisation
        [Vsol,Vfval,Nexitflag, ~] =ga(hobjfun,...
            Xop.NdesignVariables,[],[],[],[],Xop.VlowerBounds,Xop.VupperBounds,...
            [],Toptions);
    else
        % Run unconstrained extreme-values optimization with bounded
        % design variables
        [Vsol,Vfval,Nexitflag,~] =ga_minmax(hobjfun,...
            Xop.NdesignVariables,[],[],[],[],...
            Xop.VlowerBounds,Xop.VupperBounds,[],Toptions);
    end
    
else
    
    if LplotEvolution
        Toptions = gaoptimset('PlotFcns',{@gaplotbestf,@gaplotmaxconstr});
    end
    
    if ~Xobj.LextremeOptima
        % Run constrained optimisation
        [Vsol,Vfval,Nexitflag, ~] =ga(hobjfun,...
            Xop.NdesignVariables,[],[],[],[],Xop.VlowerBounds,Xop.VupperBounds,...
            hconstrains,...
            Toptions);
    else
        % Run unconstrained extreme-values optimization with bounded
        % design variables
        [Vsol,Vfval,Nexitflag,~] =ga_minmax(hobjfun,...
            Xop.NdesignVariables,[],[],[],[],...
            Xop.VlowerBounds,Xop.VupperBounds,[],Toptions);
    end
    
end

%% Add the final values of the Genetic Algorithms to the Optimum object
% Be sure that the best results is always stored in the final population
VsolRep=repmat(Vsol,XoptGlobal.XdesignVariable(1).Nsamples,1);
VfvalRep=repmat(Vfval,XoptGlobal.XdesignVariable(1).Nsamples,1);

for n = 1:Xop.NdesignVariables
    XoptGlobal.XdesignVariable(n)=addData(XoptGlobal.XdesignVariable(n), ...
        'Vdata',VsolRep(:,n),'Mcoord',XoptGlobal.XdesignVariable(1).Mcoord(end)+1);
end

for n=1:Xop.NobjectiveFunctions
    XoptGlobal.XobjectiveFunction(n)=addData(XoptGlobal.XobjectiveFunction(n), ...
        'Vdata',VfvalRep(:,n),'Mcoord',XoptGlobal.XobjectiveFunction(1).Mcoord(end)+1);
end

OpenCossan.setLaptime('description','End GA optimization');

%% Output
% All the quantities of interest are automatically stored in the Optimum
% object.

% Prepare string with reason for termination of optimization algorithm
switch Nexitflag
    case{1}
        Sexitflag   = 'Average cumulative change in value of the fitness function over options.StallGenLimit generations less than options.TolFun and constraint violation less than options.TolCon';
    case{2}
        Sexitflag   = 'Fitness limit reached and constraint violation less than options.TolCon';
    case{3}
        Sexitflag   = 'The value of the fitness function did not change in options.StallGenLimit generations and constraint violation less than options.TolCon';
    case{4}
        Sexitflag   = 'Magnitude of step smaller than machine precision and constraint violation less than options.TolCon';
    case{0}
        Sexitflag   = 'Maximum number of generations exceeded';
    case{-1}
        Sexitflag   = 'Optimization terminated by the output or plot function';
    case{-2}
        Sexitflag   = 'No feasible point found';
    case{-4}
        Sexitflag   = 'Stall time limit exceeded';
    case{-5}
        Sexitflag   = 'Time limit exceeded';
end

XoptGlobal.Sexitflag=[XoptGlobal.Sexitflag; Sexitflag];

% Assign outputs
Xoptimum=XoptGlobal;

% Export Simulation Output
varargout{1}    = XsimOutGlobal;

if ~isdeployed
    % add entries in simulation and analysis database at the end of the
    % computation when not deployed. The deployed version does this with
    % the finalize command
    XdbDriver = OpenCossan.getDatabaseDriver;
    if ~isempty(XdbDriver)
        XdbDriver.insertRecord('StableType','Result',...
            'Nid',getNextPrimaryID(OpenCossan.getDatabaseDriver,'Result'),...
            'CcossanObjects',{Xoptimum},...
            'CcossanObjectsNames',{'Xoptimum'});
    end
end

%% Delete global variables
clear global XoptGlobal XsimOutGlobal

%% Record Time
OpenCossan.setLaptime('description',['End apply@' class(Xobj)]);

return
