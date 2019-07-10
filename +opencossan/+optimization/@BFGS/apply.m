function [Xoptimum,varargout] = apply(Xobj,varargin)
%APPLY  This method applies the algorithm BFGS for solving an unconstrained
%       optimization problem.
%
% See also: https://cossan.co.uk/wiki/apply@Optimizer
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

OpenCossan.validateCossanInputs(varargin{:});

%  Check whether or not required arguments have been passed
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'xoptimizationproblem'}   %extract OptimizationProblem
            if isa(varargin{k+1},'OptimizationProblem')    %check that arguments is actually an OptimizationProblem object
                Xop     = varargin{k+1};
            else
                error('OpenCossan:BFGS:apply',...
                    ['the variable  ' inputname(k) ' must be an OptimizationProblem object']);
            end
        case {'cxoptimizationproblem'}   %extract OptimizationProblem
            if isa(varargin{k+1}{1},'OptimizationProblem')    %check that arguments is actually an OptimizationProblem object
                Xop     = varargin{k+1}{1};
            else
                error('OpenCossan:BFGS:apply',...
                    ['the variable  ' inputname(k) ' must be an OptimizationProblem object']);
            end  
        case {'xoptimum'}   %extract OptimizationProblem
            if isa(varargin{k+1},'Optimum')    %check that arguments is actually an OptimizationProblem object
                Xoptimum  = varargin{k+1};
            else
                error('openCOSSAN:BFGS:apply',...
                    ['the variable  ' inputname(k) ' must be an Optimum object']);
            end
        case {'vinitialsolution'}
            VinitialSolution=varargin{k+1};
        otherwise
            error('OpenCossan:BFGS:PropertyNameNotValid', ...
                'The PropertyName %s is not valid',varargin{k});
    end
end

%% Check Optimization problem
assert(logical(exist('Xop','var')), 'OpenCossan:BFGS:apply',...
    'Optimization problem must be defined')

% Check inputs and initialize variables
Xobj = initializeOptimizer(Xobj);

%% Check initial solution
if exist('VinitialSolution','var')
    Xop.VinitialSolution=VinitialSolution;
end

assert(size(Xop.VinitialSolution,1)==1, ...
    'OpenCossan::apply',...
    'Only 1 initial setting point is allowed')

assert(logical(isempty(Xop.Xconstraint)), ...
    'OpenCossan:BFGS:apply',...
    'BFGS is an UNconstrained Nonlinear Optimization.')

%% initialise Global Variables
% initialise SimulationData object
%XsimOutGlobal=[];
% initialise Optimum object
if ~exist('Xoptimum','var')
    XoptGlobal=Optimum('XoptimizationProblem',Xop,'Xoptimizer',Xobj);
else
    %TODO: Check Optimum
    XoptGlobal=Xoptimum;
end


%%  Perform optimization
%   Set matlab options
Xoptions = optimoptions('fminunc');  %Default optimization options

% According to Matlab documentation: if the objective function includes a
% gradient, use 'Algorithm' = 'trust-region', and set the
% SpecifyObjectiveGradient option to true. Otherwise, use 'Algorithm' =
% 'quasi-newton'. 
if Xop.XobjectiveFunction.Lgradient
    Xoptions.Algorithm    = 'trust-region';   %Turns on intermediate information about optimization procedure
    Xoptions.SpecifyObjectiveGradient=true;
else
    Xoptions.Algorithm    = 'quasi-newton';   %Turns on intermediate information about optimization procedure
end

Xoptions.Display    = 'iter-detailed';   %Turns on intermediate information about optimization procedure
Xoptions.GradObj    = 'on';              %Gradient of objective function is on
Xoptions.MaxFunEvals   = Xobj.Nmax;              %Maximum number of function evaluations that is allowed
Xoptions.MaxIter       = Xobj.NmaxIterations;          %Maximum number of iterations that is allowed
Xoptions.DerivativeCheck = 'off';
Xoptions.TolFun        = Xobj.toleranceObjectiveFunction;     %Termination tolerance on the value of the objective function
Xoptions.TolX          = Xobj.toleranceDesignVariables;       %Termination tolerance on the design variable vector
Xoptions.FinDiffType   = Xobj.SfiniteDifferenceType; % Finite differences, used to estimate gradients
Xoptions.DerivativeCheck = 'off';
Xoptions.OutputFcn = @Xobj.outputFunctionOptimiser;

if isempty(Xop.Xmodel)
    % Create handle of the objective function
    hobjfun=@(x)evaluate(Xop.XobjectiveFunction,'Xoptimizationproblem',Xop,...
        'MreferencePoints',x,'Lgradient',true,...
        'finiteDifferencePerturbation',Xobj.finiteDifferencePerturbation,...
        'scaling',Xobj.scalingFactor);
else
    % Create handle of the objective function
    hobjfun=@(x)evaluate(Xop.XobjectiveFunction,'Xoptimizationproblem',Xop,...
        'MreferencePoints',x,'Lgradient',true,...
        'finiteDifferencePerturbation',Xobj.finiteDifferencePerturbation,...
        'scaling',Xobj.scalingFactor,'Xmodel',Xop.Xmodel);
end

%% Perform Real optimization
[XoptGlobal.VoptimalDesign,XoptGlobal.VoptimalScores,Nexitflag] = ...
                            fminunc(hobjfun,Xop.VinitialSolution,Xoptions);

%% Output
% All the quantities of interest are automatically stored in the Optimum
% object.

% Prepare string with reason for termination of optimization algorithm
switch Nexitflag
    case{1}
        Sexitflag   = 'First order optimality conditions were satisfied to the specified tolerance';
    case{2}
        Sexitflag   = 'Change in x was less than the specified tolerance';
    case{3}
        Sexitflag   = 'Change in the objective function value was less than the specified tolerance';
    case{4}
        Sexitflag   = 'Magnitude of the search direction was less than the specified tolerance and constraint violation was less than options.TolCon';
    case{5}
        Sexitflag   = 'Magnitude of directional derivative was less than the specified tolerance and constraint violation was less than options.TolCon';
    case{0}
        Sexitflag   = 'Number of iterations exceeded options.MaxIter or number of function evaluations exceeded options.MaxFunEvals';
    case{-1}
        Sexitflag   = 'Algorithm was terminated by the output function';
    case{-2}
        Sexitflag   = 'No feasible point was found';
end

XoptGlobal.Sexitflag=Sexitflag;

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

%% Export results and clean up
% Export Optimum
Xoptimum    = XoptGlobal;
% Export Simulation Output
varargout{1}    = XsimOutGlobal;
% Delete global variables
clear global XoptGlobal XsimOutGlobal

%% Record Time
OpenCossan.setLaptime('Sdescription',['End apply@' class(Xobj)]);
