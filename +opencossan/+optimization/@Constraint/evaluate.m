function [in, eq] = evaluate(obj, varargin)
% EVALUATE This method evaluates the non linear inequality constraint and
% the linear equality constraint

%{
This file is part of OpenCossan <https://cossan.co.uk>. Copyright (C)
2006-2019 COSSAN WORKING GROUP

OpenCossan is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free
Software Foundation, either version 3 of the License or, (at your option)
any later version.

OpenCossan is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along
with OpenCossan. If not, see <http://www.gnu.org/licenses/>.
%}

[required, varargin] = opencossan.common.utilities.parseRequiredNameValuePairs(...
    ["optimizationproblem", "referencepoints"], varargin{:});

optional = opencossan.common.utilities.parseOptionalNameValuePairs(...
    ["scaling", "transpose"], {1, false}, varargin{:});

assert(isa(required.optimizationproblem, 'opencossan.optimization.OptimizationProblem'), ...
    'OpenCossan:optimization:constraint:evaluate',...
    'An OptimizationProblem must be passed using the property name optimizationproblem');

% destructure inputs
optProb = required.optimizationproblem;
x = required.referencepoints;

% cobyla passes the inputs transposed for some reason
if optional.transpose
    x = x';
end

assert(optProb.NumberOfDesignVariables == size(x,2), ...
    'OpenCossan:optimization:constraint:evaluate',...
    'Number of design Variables not correct');

%% Evaluate constraint(s)
constraints = zeros(size(x, 1), length(obj));
% Some algorithms pass multiple inputs at the same time, this loop
% evaluates the constraint(s) for all of them
for i = 1:size(x, 1)
    input = optProb.Input.setDesignVariable('CSnames',optProb.DesignVariableNames,'Mvalues',x(i,:));
    input = input.getTable;
    
    modelResult = ...
    opencossan.optimization.OptimizationRecorder.getModelEvaluation(...
    optProb.DesignVariableNames, x(i,:));
    
    if isempty(modelResult)
        modelResult = apply(optProb.Model, input);
        modelResult = modelResult.TableValues;
        opencossan.optimization.OptimizationRecorder.recordModelEvaluations(...
            modelResult);
    end
    
    % loop over all constraints
    for j = 1:numel(obj)
        TableInputSolver = modelResult(:,obj(j).InputNames);

        TableOutConstrains = evaluate@opencossan.workers.Mio(obj(j),TableInputSolver);

        constraints(i,j) = TableOutConstrains.(obj(j).OutputNames{1});
    end
end

% Scale constraints
constraints = constraints/optional.scaling;

% Assign output to the inequality and equality constrains
in = constraints(:,[obj.IsInequality]);
eq = constraints(:,~[obj.IsInequality]);

% record constraint values
for i = 1:size(constraints,1)
    opencossan.optimization.OptimizationRecorder.recordConstraints(...
        x(i,:), constraints(i,:));
end

end

