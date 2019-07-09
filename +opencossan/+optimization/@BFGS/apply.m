function [Xoptimum,varargout] = apply(Xobj,varargin)
%APPLY  This method applies the algorithm BFGS for solvind an unconstrained
%       optimization problem.
%
% See also: http://cossan.cfd.liv.ac.uk/wiki/apply@Optimizer
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

%  Check whether or not required arguments have been passed
for k=1:2:length(varargin),
    switch lower(varargin{k}),
        case {'xoptimizationproblem'},   %extract OptimizationProblem
            assert(isa(varargin{k+1},'opencossan.optimization.OptimizationProblem'),...
                'openCOSSAN:BFGS:apply:wrongOptimizationProblem',...
                 'the object of class %s is not valid! Expected class optimization.OptimizationProblem',...
                 class(varargin{k+1}) );
                Xop     = varargin{k+1};
        case {'xoptimum'},   %extract OptimizationProblem
             assert(isa(varargin{k+1},'output.Optimum'),...
                'openCOSSAN:BFGS:apply:wrongOptimum',...
                 'the object of class %s is not valid! Expected class output.Optimum',...
                 class(varargin{k+1}) );
             Xoptimum  = varargin{k+1};
        case {'vinitialsolution'}
            VinitialSolution=varargin{k+1};
        otherwise
            error('openCOSSAN:BFGS:apply:wrongArgument', ...
                'The PropertyName %s is not valid',varargin{k});
    end
end

%% Check Optimization problem
assert(logical(exist('Xop','var')), 'openCOSSAN:BFGS:apply:noOptimizationProblem',...
    'Optimization problem must be defined')

% Check inputs and initialize variables
Xobj = initializeOptimizer(Xobj);

%% Check initial solution
if exist('VinitialSolution','var')
    Xop.VinitialSolution=VinitialSolution;
end

assert(size(Xop.VinitialSolution,1)==1, ...
    'openCOSSAN::apply',...
    'Only 1 initial setting point is allowed')

assert(logical(isempty(Xop.Xconstraint)), ...
    'openCOSSAN:BFGS:apply',...
    'BFGS is an UNconstrained Nonlinear Optimization.')

%% initialise Global Variables
% initialise SimulationData object
%XsimOutGlobal=[];
% initialise Optimum object
if ~exist('Xoptimum','var')
    XoptGlobal=Xop.initializeOptimum('LgradientObjectiveFunction',true,...
        'LgradientConstraints',false,...
        'Xoptimizer',Xobj);
else
    %TODO: Check Optimum
    XoptGlobal=Xoptimum;
end


%%  Perform optimization
%   Set matlab options
Toptions            = optimset('fminunc');  %Default optimization options

Toptions.Display    = 'iter-detailed';   %Turns on intermediate information about optimization procedure
Toptions.LargeScale = 'on';             %Turns off Large-Scale optimization features
Toptions.GradObj    = 'on';              %Gradient of objective function is on
Toptions.MaxFunEvals   = Xobj.Nmax;              %Maximum number of function evaluations that is allowed
Toptions.MaxIter       = Xobj.NmaxIterations;          %Maximum number of iterations that is allowed
Toptions.DerivativeCheck = 'off';
Toptions.TolFun        = Xobj.toleranceObjectiveFunction;     %Termination tolerance on the value of the objective function
Toptions.TolX          = Xobj.toleranceDesignVariables;       %Termination tolerance on the design variable vector
Toptions.FinDiffType   = Xobj.SfiniteDifferenceType; % Finite differences, used to estimate gradients
Toptions.DerivativeCheck = 'off';
Toptions.OutputFcn = @Xobj.outputFunctionOptimiser;

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
[~,~,Nexitflag]  = fminunc(hobjfun,Xop.VinitialSolution,Toptions);

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
OpenCossan.setLaptime('description',['End apply@' class(Xobj)]);
