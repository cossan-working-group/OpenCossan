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

%{
    This file is part of OpenCossan <https://cossan.co.uk>.
    Copyright (C) 2006-2018 COSSAN WORKING GROUP

    OpenCossan is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License or,
    (at your option) any later version.
    
    OpenCossan is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.
    
    You should have received a copy of the GNU General Public License
    along with OpenCossan. If not, see <http://www.gnu.org/licenses/>.
%}

%% Define global variable for the objective function and the constrains
global XoptGlobal XsimOutGlobal

opencossan.OpenCossan.validateCossanInputs(varargin{:});
LplotEvolution=false;

%  Check whether or not required arguments have been passed
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'xoptimizationproblem'}   %extract OptimizationProblem
            assert(isa(varargin{k+1},'opencossan.optimization.OptimizationProblem'),...
                'OpenCossan:GeneticAlgorithms:apply',...
                'The object of class %s is not allowed after the XoptimizationProblem fieldname', class(varargin{k+1}));
                Xop     = varargin{k+1};
          case {'cxoptimizationproblem'}   %extract OptimizationProblem
            if isa(varargin{k+1}{1},'OptimizationProblem')    %check that arguments is actually an OptimizationProblem object
                Xop     = varargin{k+1}{1};
            else
                error('OpenCossan:GeneticAlgorithms:apply',...
                    ['the variable  ' inputname(k) ' must be an OptimizationProblem object']);
            end  
        case {'xoptimum'}   %extract OptimizationProblem
            if isa(varargin{k+1},'Optimum')    %check that arguments is actually an OptimizationProblem object
                Xoptimum  = varargin{k+1};
            else
                error('OpenCossan:GeneticAlgorithms:apply',...
                    ['the variable  ' inputname(k) ' must be an Optimum object']);
            end
        case 'minitialsolutions'
            MinitialSolutions=varargin{k+1};
        case 'lplotevolution'
            LplotEvolution=varargin{k+1};
        otherwise
            warning('OpenCossan:GeneticAlgorithms:apply',['the field ' varargin{k} ...
                ' is ignored when applying GeneticAlgorithms']);
    end
end

%% Check Optimization problem
assert(logical(exist('Xop','var')), 'OpenCossan:GeneticAlgorithms:apply',...
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
    XoptGlobal=opencossan.optimization.Optimum('XoptimizationProblem',Xop,'Xoptimizer',Xobj);
else
    %TODO: Check Optimum
    XoptGlobal=Xoptimum;
end

if isempty(Xop.Xmodel)
    % Create handle of the objective function
    hobjfun=@(x)evaluate(Xop.XobjectiveFunction,'Xoptimizationproblem',Xop,...
        'MreferencePoints',x,'Lgradient',false,...
        'scaling',Xobj.ObjectiveFunctionScalingFactor);
else
    % Create handle of the objective function
    hobjfun=@(x)evaluate(Xop.XobjectiveFunction,'Xoptimizationproblem',Xop,...
        'MreferencePoints',x,'Xmodel',Xop.Xmodel,...
        'scaling',Xobj.ObjectiveFunctionScalingFactor);
end

if isempty(Xop.Xmodel)
    % Create handle of the objective function
    hconstrains=@(x)evaluate(Xop.Xconstraint,'optimizationproblem',Xop,...
        'referencepoints',x,...
        'scaling',Xobj.ConstraintScalingFactor);
else
    % Create handle of the objective function
    hconstrains=@(x)evaluate(Xop.Xconstraint,'optimizationproblem',Xop,...
        'referencepoints',x,'model',Xop.Xmodel,...
        'scaling',Xobj.ConstraintScalingFactor);
end

assert(size(Xop.VinitialSolution,1)<=Xobj.NPopulationSize, ...
    'OpenCossan:GeneticAlgorithms:apply', ...
    ['Initial population must be less the NpopulationSize (' num2str(Xobj.NPopulationSize) ')'])

assert(size(Xop.VinitialSolution,2)==length(Xop.CnamesDesignVariables), ...
    'OpenCossan:GeneticAlgorithms:apply', ...
    'Initial solution must contain a number of columns equal to the number of design variables');

%% Prepare options structure for GeneticAlgorithms
Toptions                    = gaoptimset;                %Default optimization options
Toptions.InitialPopulation  = Xop.VinitialSolution;      % Define the initial population
Toptions.PopulationSize     = Xobj.NPopulationSize;      %scalar, number of individuals in population
Toptions.EliteCount         = Xobj.NEliteCount;          %scalar, indicates the number of elite individuals that are passed directly to the next generation
Toptions.CrossoverFraction  = Xobj.crossoverFraction;    %percentage of individuals of the next generation that are generated by means of crossover operations
Toptions.Generations        = Xobj.MaxIterations;         %scalar defining maximum number of generations to be created
Toptions.StallGenLimit      = Xobj.NStallGenLimit;       %scalar; the optimization algorithm stops if there has been no improvement in the objective function for 'NStallGenLimit' consecutive generations
Toptions.TolFun             = Xobj.ObjectiveFunctionTolerance;   %Termination criterion w.r.t. objective function; algorithm is stopped if the  cumulative change of the fitness function over 'NStallGenLimit' is less than 'ToleranceObjectiveFunction'
Toptions.TolCon             = Xobj.ConstraintTolerance;          %Defines tolerance w.r.t. constraints
Toptions.InitialPenalty     = Xobj.initialPenalty;               %Initial value of penalty parameter; used in constrained optimization
Toptions.PenaltyFactor      = Xobj.PenaltyFactor;                %parameter for updating the penalty factor; required in constrained optimization
Toptions.FitnessScalingFcn  = str2func(Xobj.SFitnessScalingFcn); %eval(['@' SFitnessScalingFcn]);   %scaling of fitness function
Toptions.SelectionFcn       = str2func(Xobj.SSelectionFcn);      %eval(['@' SSelectionFcn]);        %function for selecting parents for crossover and mutation
Toptions.CrossoverFcn       = str2func(Xobj.SCrossoverFcn);      %eval(['@' SCrossoverFcn]);        %function for generating crossover children
Toptions.MutationFcn       = str2func(Xobj.SMutationFcn);
Toptions.CreationFcn       = str2func(Xobj.SCreationFcn);
Toptions.Display            = 'iter';    %sets level of display
Toptions.Vectorized         = 'on';     %enables possibility of calculating fitness of population using a single function callXop.VlowerBounds,Xop.VupperBounds
Toptions.TimeLimit          = Xobj.Timeout; % termination criteria
Toptions.OutputFcns = @Xobj.outputFunction;

% initialize global variable
XsimOutGlobal=[];

%% Perform Real optimization

opencossan.OpenCossan.getTimer().lap('Description',['GA:' Xobj.Description]);
opencossan.OpenCossan.cossanDisp('Starting GeneticAlgorithms',3)

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

opencossan.OpenCossan.getTimer().lap('Description','End GA optimization');

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
XoptGlobal.VoptimalDesign=Vsol;
XoptGlobal.VoptimalScores=Vfval;
if ~isempty(Xop.Xconstraint)
    Vindex=all(XoptGlobal.TablesValues.DesignVariables==XoptGlobal.VoptimalDesign,2);
    Mdataout=XoptGlobal.TablesValues.Constraints(Vindex);
    Vpos=find(all(~isnan(Mdataout),2));
    XoptGlobal.VoptimalConstraints=Mdataout(Vpos(1),:);
end

Xoptimum=XoptGlobal;

% Export Simulation Output
varargout{1}    = XsimOutGlobal;

if ~isdeployed
    % add entries in simulation and analysis database at the end of the
    % computation when not deployed. The deployed version does this with
    % the finalize command
    XdbDriver = opencossan.OpenCossan.getDatabaseDriver;
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
opencossan.OpenCossan.getTimer().lap('Description',['End apply@' class(Xobj)]);

return
