function objective = evaluate(obj, varargin)
%EVALUATE The method evaluates the ObjectiveFunction
%
% The candidate solutions (i.e. Design Variables) are stored in the matrix
% Minput (Ncandidates,NdesignVariable)
%
% The objective functions are stored in Mfobj(Ncandidates,NobjectiveFunctions)
% The gradient of the objective function is store in Mdfobj(NdesignVariable,NobjectiveFunctions)
%
% See Also: https://cossan.co.uk/wiki/evaluate@ObjectiveFunction
%
% Author: Edoardo Patelli

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

% Process inputs
scaling=1;
transpose = false;
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case 'xoptimizationproblem'
            XoptProb=varargin{k+1};
        case 'mreferencepoints'
            x=varargin{k+1};
        case 'scaling'
            scaling=varargin{k+1};
        case 'transpose'
            transpose = varargin{k+1};
        otherwise
            error('OpenCossan:ObjectiveFunction:evaluate:wrongInputArgument',...
                'PropertyName %s not valid', varargin{k});
    end
end

%% Check inputs
assert(logical(exist('XoptProb','var')),...
    'OpenCossan:ObjectiveFunction:evaluate',...
    'An optimizationProblem object must be defined');

if transpose
    x = x';
end

NdesignVariables = size(x,2); % number of design variables

assert(XoptProb.NumberOfDesignVariables == NdesignVariables, ...
    'OpenCossan:ObjectiveFunction:evaluate',...
    'Number of design Variables %i does not match with the dimension of the referece point (%i)', ...
    XoptProb.NumberOfDesignVariables,NdesignVariables);

%% Evaluate objective function(s)
objective = zeros(size(x, 1), length(obj));
% Some algorithms pass multiple inputs at the same time, this loop
% evaluates the objective function(s) for all of them
for i = 1:size(x,1)
    
    input = XoptProb.Input.setDesignVariable('CSnames',XoptProb.DesignVariableNames,'Mvalues',x(i,:));
    input = input.getTable();
    
    modelResult = ...
        opencossan.optimization.OptimizationRecorder.getModelEvaluation(...
        XoptProb.DesignVariableNames, x(i,:));
    
    if isempty(modelResult)
        modelResult = apply(XoptProb.Model,input);
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
objective = objective/scaling;

% record objective function values
for i = 1:size(x,1)
    opencossan.optimization.OptimizationRecorder.recordObjectiveFunction(...
        x(i,:), objective(i,:));
end

end

