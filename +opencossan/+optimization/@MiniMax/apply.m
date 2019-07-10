function [Xoptimum,varargout] = apply(Xobj,varargin)
%   APPLY   This method applies the algorithm
%           MiniMax for multi-objective optimization
%
%
% See Also: https://cossan.co.uk/wiki/apply@MiniMax
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

%XoptGlobal.Ngeneration = []; % assures that the generation nr. used by evol. algorithms is not set

OpenCossan.validateCossanInputs(varargin{:});

%  Check whether or not required arguments have been passed
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'xoptimizationproblem'}   %extract OptimizationProblem
            if isa(varargin{k+1},'OptimizationProblem')    %check that arguments is actually an OptimizationProblem object
                Xop     = varargin{k+1};
            else
                error('OpenCossan:MinMax:apply',...
                    ['the variable  ' inputname(k) ' must be an OptimizationProblem object']);
            end
        case {'cxoptimizationproblem'}   %extract OptimizationProblem
            if isa(varargin{k+1}{1},'OptimizationProblem')    %check that arguments is actually an OptimizationProblem object
                Xop     = varargin{k+1}{1};
            else
                error('OpenCossan:MinMax:apply',...
                    ['the variable  ' inputname(k) ' must be an OptimizationProblem object']);
            end  
        case {'xoptimum'}   %extract OptimizationProblem
            if isa(varargin{k+1},'Optimum')    %check that arguments is actually an OptimizationProblem object
                Xoptimum  = varargin{k+1};
            else
                error('OpenCossan:MinMax:apply',...
                    ['the variable  ' inputname(k) ' must be an Optimum object']);
            end
        case 'vinitialsolution'
            VinitialSolution=varargin{k+1};
        otherwise
            error('OpenCossan:MinMax:apply','PropertyName %s is not valid',varargin{k});
    end
end

%% Check Optimization problem
assert(logical(exist('Xop','var')), 'OpenCossan:MinMax:apply',...
    'Optimization problem must be defined')

% Check inputs and initialize variables
Xobj = initializeOptimizer(Xobj);

%% Check initial solution
if exist('VinitialSolution','var')
    Xop.VinitialSolution=VinitialSolution;
end

assert(size(Xop.VinitialSolution,1)==1, ...
    'OpenCossan:MinMax:apply',...
    'Only 1 initial setting point is allowed')

%% initialize Optimum
if ~exist('Xoptimum','var')
    XoptGlobal=Optimum('XoptimizationProblem',Xop,'Xoptimizer',Xobj);
else
    %TODO: Check Optimum
    XoptGlobal=Xoptimum;
end

%%  Perform optimization
%   Set matlab options
Toptions            = optimset('fminimax');  %Default optimization options

Toptions.Algorithm  = 'active-set';         %Solution strategy
Toptions.DerivativeCheck='off';  % compare user-supplied derivatives (gradients of objective or constraints) to finite-differencing derivatives.  
Toptions.Display    = 'iter-detailed';   %Turns on intermediate information about optimization procedure
Toptions.LargeScale = 'off';                %Turns off Large-Scale optimization features
Toptions.GradObj    = 'on';                 %Gradient of objective function is on
Toptions.GradConstr = 'on';                 %Gradient of constraints is on
Toptions.MaxFunEvals   = Xobj.Nmax;              %Maximum number of function evaluations that is allowed
Toptions.MaxIter       = Xobj.NmaxIterations;          %Maximum number of iterations that is allowed
Toptions.TolFun        = Xobj.toleranceObjectiveFunction;           %Termination tolerance on the value of the objective function
Toptions.TolCon        = Xobj.toleranceConstraint;            %Termination tolerance on the constraint violation
Toptions.TolX          = Xobj.toleranceDesignVariables;       %Termination tolerance on the design variable vector
Toptions.FinDiffType   = Xobj.SfiniteDifferenceType;
Toptions.OutputFcn = @Xobj.outputFunctionOptimiser;


% initialize global variable
XsimOutGlobal=[];

% Create handle of the objective function
if isempty(Xop.Xmodel)
    hobjfun=@(x)evaluate(Xop.XobjectiveFunction,'Xoptimizationproblem',Xop,...
        'MreferencePoints',x,'Lgradient',true,...
        'finiteDifferencePerturbation',Xobj.finiteDifferencePerturbation,...
        'scaling',Xobj.scalingFactor);
else
    hobjfun=@(x)evaluate(Xop.XobjectiveFunction,'Xoptimizationproblem',Xop,...
        'MreferencePoints',x,'Lgradient',true,'Xmodel',Xop.Xmodel,...
        'finiteDifferencePerturbation',Xobj.finiteDifferencePerturbation,...
        'scaling',Xobj.scalingFactor);
end


if isempty(Xop.Xconstraint)
    %% Perform Real optimization
    [XoptGlobal.VoptimalDesign,XoptGlobal.VoptimalScores,~,Nexitflag]  = ...
        fminimax(hobjfun,... % ObjectiveFunction
        Xop.VinitialSolution,[],[],[],[],...
        Xop.VlowerBounds,Xop.VupperBounds,... % Bounds
        [],... % Contrains
        Toptions);
else
    % Create handle for the constrains
    hconstrains=@(x)evaluate(Xop.Xconstraint,'Xoptimizationproblem',Xop,...
        'MreferencePoints',x,'Lgradient',true,...
        'finiteDifferencePerturbation',Xobj.finiteDifferencePerturbation,...
        'scaling',Xobj.scalingFactor);
    
    % The function that computes the nonlinear inequality constraints c(x)≤ 0
    % and the nonlinear equality constraints ceq(x) = 0. hconstrains accepts a
    % vector x and returns the two vectors c and ceq. c is a vector that
    % contains the nonlinear inequalities evaluated at x, and ceq is a vector
    % that contains the nonlinear equalities evaluated at x.  hconstrains is
    % a function handle such as function
    
    
    %% Perform Real optimization
    [XoptGlobal.VoptimalDesign,XoptGlobal.VoptimalScores,~,Nexitflag]  = ...
        fminimax(hobjfun,... % ObjectiveFunction
        Xop.VinitialSolution,[],[],[],[],...
        Xop.VlowerBounds,Xop.VupperBounds,... % Bounds
        hconstrains,... % Contrains
        Toptions);
end

%% Output
% All the quantities of interest are automatically stored in the Optimum
% object.

% Prepare string with reason for termination of optimization algorithm
switch Nexitflag
    case{1}
        Sexitflag   = 'Function converged to solution x';
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
varargout{1}    = XoptGlobal;

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
OpenCossan.setLaptime('Sdescription','End apply@MinMax');
