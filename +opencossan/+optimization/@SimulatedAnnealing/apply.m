function [Xoptimum,varargout] = apply(Xobj,varargin)
%   APPLY   This method applies the algorithm SimulatedAnnealing for
%   optimization
%
%   Simulated Annealing (SA) can be used to found a MINIMUM of a function.
%   It is intended for solving the problem
%
%                       min f_obj(x)
%                       x in R^n
%
% See Also: https://cossan.co.uk/wiki/index.php/Apply@SimultatedAnnealing
%
% Author: Edoardo Patelli
% Website: https://www.cossan.co.uk

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

LplotEvolution=false;

OpenCossan.validateCossanInputs(varargin{:});

%  Check whether or not required arguments have been passed
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'xoptimizationproblem'}   %extract OptimizationProblem
            if isa(varargin{k+1},'OptimizationProblem')    %check that arguments is actually an OptimizationProblem object
                Xop     = varargin{k+1};
            else
                error('OpenCossan:SimulatedAnnealing:apply',...
                    ['The variable %s must be an OptimizationProblem object,' ...
                    ' provided object of type %s'],...
                    inputname(k),class(varargin{k+1}));
            end
          case {'cxoptimizationproblem'}   %extract OptimizationProblem
            if isa(varargin{k+1}{1},'OptimizationProblem')    %check that arguments is actually an OptimizationProblem object
                Xop     = varargin{k+1}{1};
            else
                error('OpenCossan:SimulatedAnnealing:apply',...
                     ['the variable  ' inputname(k) ' must be an OptimizationProblem object']);
            end  
        case {'xoptimum'}   %extract OptimizationProblem
            if isa(varargin{k+1},'Optimum')    %check that arguments is actually an OptimizationProblem object
                Xoptimum  = varargin{k+1};
            else
                error('OpenCossan:SimulatedAnnealing:apply',...
                    ['the variable  ' inputname(k) ' must be an Optimum object']);
            end
        case 'vinitialsolution'
            VinitialSolution=varargin{k+1};
        case 'lplotevolution'
            LplotEvolution=varargin{k+1};
        otherwise
            error('OpenCossan:SimulatedAnnealing:apply',...
                'The PropertyName %s is not valid', varargin{k});
    end
end

%% Check Optimization problem
assert(logical(exist('Xop','var')), 'OpenCossan:SimulatedAnnealing:apply',...
    'Optimization problem must be defined')

% Check inputs and initialize variables
Xobj = initializeOptimizer(Xobj);

if ~isempty(Xop.Xconstraint)
    warning('OpenCossan:SimulatedAnnealing:apply',...
        'SimulationAnnealing method is an unconstrained optimization method. Constrain defined in the OptimizationProblem are ignored')
end

%% Check initial solution
if exist('VinitialSolution','var')
    Xop.VinitialSolution=VinitialSolution;
end

assert(size(Xop.VinitialSolution,1)==1, ...
    'OpenCossan:SimulatedAnnealing:apply',...
    'Only 1 initial setting point is allowed')

%% initialize Optimum
if ~exist('Xoptimum','var')
    XoptGlobal=Optimum('XoptimizationProblem',Xop,'Xoptimizer',Xobj);
else
    %TODO: Check Optimum
    XoptGlobal=Xoptimum;
end

% Create handle of the objective function
if isempty(Xop.Xmodel)
    hobjfun=@(x)evaluate(Xop.XobjectiveFunction,'Xoptimizationproblem',Xop,...
        'MreferencePoints',x,'Lgradient',false,...
        'scaling',Xobj.scalingFactor);
else
    hobjfun=@(x)evaluate(Xop.XobjectiveFunction,'Xoptimizationproblem',Xop,...
        'MreferencePoints',x,'Lgradient',false,...
        'scaling',Xobj.scalingFactor,'Xmodel',Xop.Xmodel);
end


%% Check if the required functions exist
% Debugging compiled version only
%  which simulannealbnd
%  which saoptimset 
% feval(@simulannealbnd,'defaults')

Toptions = saoptimset(@simulannealbnd); % Default options for simulated anneling

if LplotEvolution
    	Toptions = saoptimset('PlotFcns',{@saplotbestx,...
                @saplotbestf,@saplotx,@saplotf});
end

Toptions.AnnealingFcn=str2func(Xobj.SannealingFunction); % Annealing function
Toptions.TemperatureFcn=str2func(Xobj.StemperatureFunction); % Temperature function
Toptions.TolFun=Xobj.toleranceObjectiveFunction;
Toptions.StallIterLimit=Xobj.Nmaxmoves;
Toptions.MaxFunEvals=Xobj.Nmax;
Toptions.Display='iter';
Toptions.TimeLimit=Xobj.timeout;
Toptions.MaxIter=Xobj.NmaxIterations;
Toptions.ObjectiveLimit=Xobj.objectiveLimit;
Toptions.InitialTemperature=Xobj.initialTemperature;
Toptions.ReannealInterval=Xobj.NreannealInterval;
Toptions.OutputFcns = @Xobj.outputFunction;

% Pass additional parameter using global variables since matlab does not allowed
% user defined parameters

global TuserDefinedParameters

TuserDefinedParameters.k1=Xobj.k1;
TuserDefinedParameters.k2=Xobj.k2;
TuserDefinedParameters.k3=Xobj.k3;

%% Here we go
% Perform Real optimization

OpenCossan.setLaptime('Sdescription',['SA:' Xobj.Sdescription]);

OpenCossan.cossanDisp('Starting Simulated Annealing',2)

[XoptGlobal.VoptimalDesign,XoptGlobal.VoptimalScores,Nexitflag]  = ...
    simulannealbnd(hobjfun,... % ObjectiveFunction
    Xop.VinitialSolution,... & initial solution
    Xop.VlowerBounds,Xop.VupperBounds,... % Bounds
    Toptions);

OpenCossan.setLaptime('Sdescription','End SA optimization');

%% Output
% All the quantities of interest are automatically stored in the Optimum
% object.

% Prepare string with reason for termination of optimization algorithm
switch Nexitflag
    case{1}
        Sexitflag   = 'Average change in the value of the objective function over options.StallIterLimit iterations is less than options.TolFun';
    case{5}
        Sexitflag   = 'options  objectiveLimit limit reached.';
    case{0}
        Sexitflag   = 'Number of iterations exceeded options.MaxIter or number of function evaluations exceeded options.MaxFunEvals';
    case{-1}
        Sexitflag   = 'Algorithm was terminated by the output function';
    case{-2}
        Sexitflag   = 'No feasible point was found';
    case{-5}
        Sexitflag   = ' Time limit exceeded.';
end

XoptGlobal.Sexitflag=Sexitflag;

% Assign outputs
Xoptimum=XoptGlobal;

% Export Simulation Output
%varargout{1}    = [XsimOutGlobal; XoutConstrainsGlobal];
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
clear global XoptGlobal XsimOutGlobal XoutConstrainsGlobal TuserDefinedParameters

%%  Set random number generator to state prior to running simulation
if exist('XRandomNumberGenerator','var')
    Simulations.restoreRandomNumberGenerator(XRandomNumberGenerator)
end

%% Record Time
OpenCossan.setLaptime('Sdescription','End apply@SimulatedAnnealing');

return
