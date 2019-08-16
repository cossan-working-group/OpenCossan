function objective = evaluate(obj, varargin)
% EVALUATE Evaluate the objective function

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

%% Evaluate objective function(s)
objective = zeros(size(x, 1), length(obj));
% Some algorithms pass multiple inputs at the same time, this loop
% evaluates the objective function(s) for all of them
for i = 1:size(x,1)
    
    input = optProb.Input.setDesignVariable('CSnames',optProb.DesignVariableNames,'Mvalues',x(i,:));
    input = input.getTable();
    
    modelResult = ...
        opencossan.optimization.OptimizationRecorder.getModelEvaluation(...
        optProb.DesignVariableNames, x(i,:));
    
    if isempty(modelResult)
        modelResult = apply(optProb.Model, input);
        modelResult = modelResult.TableValues;
        opencossan.optimization.OptimizationRecorder.recordModelEvaluations(...
            modelResult);
    end
    
    % loop over all objective functions
    for j = 1:length(obj)
        TinputSolver = modelResult(:,obj(j).InputNames);
        
        XoutObjective = evaluate@opencossan.workers.Mio(obj(j),TinputSolver);

        objective(i,j) = XoutObjective.(obj(j).OutputNames{1});
    end
    
end

%%   Apply scaling constant
objective = objective/optional.scaling;

% record objective function values
for i = 1:size(x,1)
    opencossan.optimization.OptimizationRecorder.recordObjectiveFunction(...
        x(i,:), objective(i,:));
end

end

