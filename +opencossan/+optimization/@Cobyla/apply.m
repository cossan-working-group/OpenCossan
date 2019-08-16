function optimum = apply(obj, varargin)
%   APPLY   This method applies the algorithm COBYLA (Costrained
%           Optimization by Linear Approximations) for optimization
%
%   APPLY This method applies the algorithm COBYLA. COBYLA was proposed by
%   M.J.D. Powell, 1994. It is a gradient-free optimization algorithm
%   capable of handling inequality constraints.
%   It solves the problem:
%
%   min f_obj(x)
%   subject to
%       cineq(x)    <= 0
%
%
%   See also: https://cossan.co.uk/wiki/index.php/Apply@Cobyla 
% http://www.damtp.cam.ac.uk/user/na/NA_papers/NA1998_04.ps.gz
%
% Author: Edoardo Patelli

%{
This file is part of OpenCossan <https://cossan.co.uk>.
Copyright (C) 2006-2019 COSSAN WORKING GROUP

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

import opencossan.optimization.OptimizationRecorder;
import opencossan.common.utilities.*;

[required, varargin] = parseRequiredNameValuePairs(...
    "optimizationproblem", varargin{:});

optProb = required.optimizationproblem;

optional = parseOptionalNameValuePairs(...
    "initialsolution", {optProb.InitialSolution}, ...
    varargin{:});

x0 = optional.initialsolution;

%% Add bounds of design variables as constraints
lowerScript = "for n=1:length(Tinput), Toutput(n).%s = %s - Tinput(n).%s; end";
upperScript = "for n=1:length(Tinput), Toutput(n).%s = + Tinput(n).%s - %s; end";

for i = 1:optProb.Input.NumberOfDesignVariables
    
    dv = optProb.Input.DesignVariables(i);
    name = optProb.Input.DesignVariableNames(i);
    
    if isfinite(dv.LowerBound)
        constraintName = name + "_lowerBound";
        constraintScript = sprintf(lowerScript,...
            constraintName,num2str(dv.LowerBound),name);
        
        constraint = opencossan.optimization.Constraint(...
        'Description', strjoin(["lower bound - current value of" name]), ...
        'Script',constraintScript,'OutputNames',{char(constraintName)},...
        'InputNames',{char(name)},'inequality',true,'Format','structure'); 
        
        optProb = optProb.addConstraint(constraint); 
        opencossan.OpenCossan.cossanDisp(...
        "Added constraint for the lower bound of: " + name, 3);
    end
    
    if isfinite(dv.UpperBound)
        constraintName = name + "_upperBound";
        constraintScript = sprintf(upperScript,...
            constraintName, name, num2str(dv.UpperBound));
        
        constraint = opencossan.optimization.Constraint(...
        'Description', strjoin(["current value of", name, "- upper bound"]), ...
        'Script',constraintScript, 'OutputNames',{char(constraintName)},...
        'InputNames',{char(name)},'inequality',true,'format','structure'); 
        
        optProb = optProb.addConstraint(constraint); 
        opencossan.OpenCossan.cossanDisp(...
        "Added constraint for the upper bound of: " + name, 3);
    end
end

assert(~isempty(optProb.Constraints),...
    'OpenCossan:cobyla:apply',...
    'It is not possible to apply COBYLA to solve UNCONSTRAINED problem')

Ndv = optProb.NumberOfDesignVariables;  % number of design variables
N_ineq = optProb.NumberOfConstraints;       % Number of constrains


objective_function_cobyla = @(x)evaluate(optProb.ObjectiveFunctions,'optimizationproblem',optProb,...
'referencepoints',x, 'transpose', true, ...
'scaling',obj.ObjectiveFunctionScalingFactor); %#ok<NASGU>

% Create handle for the constrains
constraint_cobyla= @(x)evaluate(optProb.Constraints,'optimizationproblem',optProb,...
    'referencepoints',x,'transpose', true, ...
    'scaling',obj.ConstraintScalingFactor); %#ok<NASGU>

%% Perform optimization using Cobyla

opencossan.optimization.OptimizationRecorder.clear();

startTime = tic;

[optimalSolution, exitFlag] = cobyla_matlab(obj, x0, ...
    obj.MaxFunctionEvaluations,obj.rho_ini,obj.rho_end,Ndv,N_ineq);

totalTime = toc(startTime);

optimum = opencossan.optimization.Optimum(...
    'optimalsolution', optimalSolution, ...
    'exitflag', exitFlag, ...
    'totaltime', totalTime, ...
    'optimizationproblem', optProb, ...
    'optimizer', obj, ...
    'constraints', OptimizationRecorder.getInstance().Constraints, ...
    'objectivefunction', OptimizationRecorder.getInstance().ObjectiveFunction, ...
    'modelevaluations', OptimizationRecorder.getInstance().ModelEvaluations);

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

