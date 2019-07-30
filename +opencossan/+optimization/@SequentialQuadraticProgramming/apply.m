function [Xoptimum,varargout] = apply(obj,varargin)
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
% See Also: https://cossan.co.uk/wiki/apply@MiniMax
%
% Author: Edoardo Patelli
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

%  Check whether or not required arguments have been passed
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'xoptimizationproblem'}   %extract OptimizationProblem
            if isa(varargin{k+1},'opencossan.optimization.OptimizationProblem')    %check that arguments is actually an OptimizationProblem object
                Xop     = varargin{k+1};
            else
                error('OpenCossan:SequentialQuadraticProgramming:apply',...
                    'The variable %s must be an OptimizationProblem object, provided object of type %s',...
                    inputname(k),class(varargin{k+1}));
            end
         case {'cxoptimizationproblem'}   %extract OptimizationProblem
            if isa(varargin{k+1}{1},'OptimizationProblem')    %check that arguments is actually an OptimizationProblem object
                Xop     = varargin{k+1}{1};
            else
                error('OpenCossan:SequentialQuadraticProgramming:apply',...
                                        ['the variable  ' inputname(k) ' must be an OptimizationProblem object']);
            end  
        case {'xoptimum'}   %extract OptimizationProblem
            if isa(varargin{k+1},'Optimum')    %check that arguments is actually an OptimizationProblem object
                Xoptimum  = varargin{k+1};
            else
                error('OpenCossan:SequentialQuadraticProgramming:apply',...
                    ['the variable  ' inputname(k) ' must be an Optimum object']);
            end
        case 'vinitialsolution'
            VinitialSolution=varargin{k+1};
        otherwise
            error('OpenCossan:SequentialQuadraticProgramming:apply',...
                'the field %s is not valid', varargin{k});
    end
end

%% Check Optimization problem
assert(logical(exist('Xop','var')), 'OpenCossan:SequentialQuadraticProgramming:apply',...
    'Optimization problem must be defined')

% Check inputs and initialize variables
obj = initializeOptimizer(obj);

%% Check initial solution
if exist('VinitialSolution','var')
    Xop.VinitialSolution=VinitialSolution;
end

assert(size(Xop.VinitialSolution,1)==1, ...
    'OpenCossan:SequentialQuadraticProgramming:apply',...
    'Only 1 initial setting point is allowed')

%% initialize Optimum
if ~exist('Xoptimum','var')
    XoptGlobal=opencossan.optimization.Optimum('XoptimizationProblem',Xop,'Xoptimizer',obj);
else
    %TODO: Check Optimum
    XoptGlobal=Xoptimum;
end


options = optimoptions('fmincon', 'Algorithm', 'sqp', 'Display', 'iter');
options.MaxFunctionEvaluations = obj.MaxFunctionEvaluations;
options.MaxIterations = obj.MaxIterations;

options.OptimalityTolerance = obj.ObjectiveFunctionTolerance;
options.ConstraintTolerance = obj.ConstraintTolerance;
options.StepTolerance = obj.DesignVariableTolerance;

options.FiniteDifferenceStepSize = obj.FiniteDifferenceStepSize;
options.FiniteDifferenceType = obj.FiniteDifferenceType;

options.OutputFcn = @obj.outputFunctionOptimiser;

XsimOutGlobal=[];

if isempty(Xop.Xmodel)
    % Create handle of the objective function
    hobjfun=@(x)evaluate(Xop.XobjectiveFunction,'Xoptimizationproblem',Xop,...
        'MreferencePoints',x, ...
        'scaling',obj.ObjectiveFunctionScalingFactor);
else
    % Create handle of the objective function
    hobjfun=@(x)evaluate(Xop.XobjectiveFunction,'Xoptimizationproblem',Xop,...
        'MreferencePoints',x,...
        'scaling',obj.ObjectiveFunctionScalingFactor,'Xmodel',Xop.Xmodel);
end


assert(~logical(isempty(Xop.Xconstraint)) ||  ...
    ~logical(isempty(Xop.VlowerBounds)) || ...
    ~logical(isempty(Xop.VupperBounds)), ...
    'OpenCossan:SequentialQuadraticProgramming:apply',...
    'SequentialQuadraticProgramming is a constrained Nonlinear Optimization and requires or a constrains object or design variables with bounds')


% Create handle for the constrains
if isempty(Xop.Xconstraint)
    constraints = [];
else
    constraints = @(x)evaluate(Xop.Xconstraint, ...
        'optimizationproblem', Xop, ...
        'referencepoints', x, ...
        'scaling', obj.ConstraintScalingFactor);
end

% The function that computes the nonlinear inequality constraints c(x)≤ 0
% and the nonlinear equality constraints ceq(x) = 0. hconstrains accepts a
% vector x and returns the two vectors c and ceq. c is a vector that
% contains the nonlinear inequalities evaluated at x, and ceq is a vector
% that contains the nonlinear equalities evaluated at x.  hconstrains is
% a function handle such as function

opencossan.optimization.OptimizationRecorder.clear();
%% Perform Real optimization
[XoptGlobal.VoptimalDesign,XoptGlobal.VoptimalScores,exitflag]  = ...
    fmincon(hobjfun,... % ObjectiveFunction
    Xop.VinitialSolution,[],[],[],[],...
    Xop.VlowerBounds,Xop.VupperBounds,... % Bounds
    constraints,... % Contrains
    options);

if ~isempty(Xop.Xconstraint)
    Vindex=all(XoptGlobal.TablesValues.DesignVariables==XoptGlobal.VoptimalDesign,2);
    Mdataout=XoptGlobal.TablesValues.Constraints(Vindex);
    Vpos=find(all(~isnan(Mdataout),2));
    XoptGlobal.VoptimalConstraints=Mdataout(Vpos(1),:);
end

XoptGlobal.Sexitflag = obj.ExitReasons(exitflag);

Xoptimum = XoptGlobal;

varargout{1} = XsimOutGlobal;

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
opencossan.OpenCossan.getTimer().lap('Description','End apply@SequentialQuadraticProgramming');
