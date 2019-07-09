function [Xoptimum,varargout] = apply(Xobj,varargin)
%   APPLY   This method applies the algorithm
%           SequentialQuadraticProgramming (i.e. Sequential Quadratic
%           Programming) for optimization
%
%   SequentialQuadraticProgramming is intended for solving an optimization
%   problem using gradients of the objective function and constraints. When
%   generating the constructor, it is possible to select the parameters of
%   the optimization algorithm. It should be noted that default parameters
%   are provided for the algorithm; nonetheless, the user should always
%   check whether or not a particular set of parameters is appropriate for
%   the problem at hand. A poor selection on these parameters may prevent
%   finding the correct solution.
%
%   SequentialQuadraticProgramming is intended for solving the following
%   class of problems
%
%                       min     f_obj(x)
%                       subject to
%                               ceq(x)      =  0
%                               cineq(x)    <= 0
%                               lb <= x <= ub
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/apply@MiniMax
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
            if isa(varargin{k+1},'opencossan.optimization.OptimizationProblem'),    %check that arguments is actually an OptimizationProblem object
                Xop     = varargin{k+1};
            else
                error('openCOSSAN:SequentialQuadraticProgramming:apply',...
                    ['the variable  ' inputname(k) ' must be an OptimizationProblem object']);
            end
        case {'xoptimum'},   %extract OptimizationProblem
            if isa(varargin{k+1},'opencossan.optimization.Optimum'),    %check that arguments is actually an OptimizationProblem object
                Xoptimum  = varargin{k+1};
            else
                error('openCOSSAN:SequentialQuadraticProgramming:apply',...
                    ['the variable  ' inputname(k) ' must be an Optimum object']);
            end
        case 'vinitialsolution'
            VinitialSolution=varargin{k+1};
        otherwise
            error('openCOSSAN:SequentialQuadraticProgramming:apply',...
                'the field %s is not valid', varargin{k});
    end
end

%% Check Optimization problem
assert(logical(exist('Xop','var')), 'openCOSSAN:SequentialQuadraticProgramming:apply',...
    'Optimization problem must be defined')

% Check inputs and initialize variables
Xobj = initializeOptimizer(Xobj);

%% Check initial solution
if exist('VinitialSolution','var')
    Xop.VinitialSolution=VinitialSolution;
end

assert(size(Xop.VinitialSolution,1)==1, ...
    'openCOSSAN:SequentialQuadraticProgramming:apply',...
    'Only 1 initial setting point is allowed')

%% initialize Optimum
if ~exist('Xoptimum','var')
    XoptGlobal=Xop.initializeOptimum('LgradientObjectiveFunction',true,'LgradientConstraints',true,...
        'Xoptimizer',Xobj);
else
    %TODO: Check Optimum
    XoptGlobal=Xoptimum;
end


%%  Perform optimization
%   Set matlab options
Toptions            = optimset('fmincon');  %Default optimization options

Toptions.Display    = 'iter-detailed';   %Turns on intermediate information about optimization procedure
Toptions.LargeScale = 'off';                %Turns off Large-Scale optimization features
Toptions.Algorithm  = 'sqp';                %Solution strategy
Toptions.GradObj    = 'on';                 %Gradient of objective function is on
Toptions.GradConstr = 'on';                 %Gradient of constraints is on
Toptions.MaxFunEvals   = Xobj.Nmax;              %Maximum number of function evaluations that is allowed
Toptions.MaxIter       = Xobj.NmaxIterations;          %Maximum number of iterations that is allowed
Toptions.TolFun        = Xobj.toleranceObjectiveFunction;           %Termination tolerance on the value of the objective function
Toptions.TolCon        = Xobj.toleranceConstraint;            %Termination tolerance on the constraint violation
Toptions.TolX          = Xobj.toleranceDesignVariables;       %Termination tolerance on the design variable vector
Toptions.OutputFcn = @Xobj.outputFunctionOptimiser;

% initialize global variable
XsimOutGlobal=[];

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


assert(~logical(isempty(Xop.Xconstraint)) ||  ...
    ~logical(isempty(Xop.VlowerBounds)) || ...
    ~logical(isempty(Xop.VupperBounds)), ...
    'openCOSSAN:SequentialQuadraticProgramming:apply',...
    'SequentialQuadraticProgramming is a constrained Nonlinear Optimization and requires or a constrains object or design variables with bounds')


% Create handle for the constrains
if isempty(Xop.Xconstraint)
    hconstrains=[];
else
    hconstrains=@(x)evaluate(Xop.Xconstraint,'Xoptimizationproblem',Xop,...
        'MreferencePoints',x,'Lgradient',true,...
        'finiteDifferencePerturbation',Xobj.finiteDifferencePerturbation,...
        'scaling',Xobj.scalingFactor);
end

% The function that computes the nonlinear inequality constraints c(x)≤ 0
% and the nonlinear equality constraints ceq(x) = 0. hconstrains accepts a
% vector x and returns the two vectors c and ceq. c is a vector that
% contains the nonlinear inequalities evaluated at x, and ceq is a vector
% that contains the nonlinear equalities evaluated at x.  hconstrains is
% a function handle such as function


%% Perform Real optimization
[~,~,Nexitflag]  = fmincon(hobjfun,... % ObjectiveFunction
    Xop.VinitialSolution,[],[],[],[],...
    Xop.VlowerBounds,Xop.VupperBounds,... % Bounds
    hconstrains,... % Contrains
    Toptions);



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
OpenCossan.setLaptime('description','End apply@SequentialQuadraticProgramming');
