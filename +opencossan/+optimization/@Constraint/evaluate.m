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

% Define global variable to store the optimum

global XoptGlobal XsimOutGlobal

[required, varargin] = opencossan.common.utilities.parseRequiredNameValuePairs(...
    ["optimizationproblem", "referencepoints"], varargin{:});

optional = opencossan.common.utilities.parseOptionalNameValuePairs(...
    ["model", "scaling"], {[], 1}, varargin{:});

assert(isa(required.optimizationproblem, 'opencossan.optimization.OptimizationProblem'), ...
    'OpenCossan:optimization:constraint:evaluate',...
    'An OptimizationProblem must be passed using the property name optimizationproblem');

% destructure inputs
optProb = required.optimizationproblem;
x = required.referencepoints;

model = optional.model;
scaling = optional.scaling;

if isa(XoptGlobal.XOptimizer, 'opencossan.optimization.Cobyla')
    % cobyla passes the variables as a column vector
    x = x';
end

NdesignVariables = size(x,2); %number of design variables
Ncandidates = size(x,1); % Number of candidate solutions

assert(optProb.NdesignVariables == NdesignVariables, ...
    'OpenCossan:optimization:constraint:evaluate',...
    'Number of design Variables not correct');

% Prepare input object
Xinput = optProb.Xinput.setDesignVariable('CSnames',optProb.CnamesDesignVariables,'Mvalues',x);
Tinput = Xinput.getTable;

% Extract required information from the SimulationData object (evaluated in
% the Objective Function) if available

% Evaluate the model if required by the constraints
if ~isempty(model)
    XsimOutGlobal = apply(model,Tinput);
    % Update counter
    XoptGlobal.NevaluationsModel = XoptGlobal.NevaluationsModel+height(Tinput);
end

constraintValues = zeros(size(x));
for i = 1:numel(obj)
    TableInputSolver = opencossan.workers.Evaluator.addField2Table(obj(i),XsimOutGlobal,Tinput);
    
    %% Evaluate function
    TableOutConstrains = evaluate@opencossan.workers.Mio(obj(i),TableInputSolver);
    
    constraintValues(:,i) = TableOutConstrains.(obj(i).OutputNames{1});
end

%%   Apply scaling constant
constraintValues = constraintValues(1:Ncandidates,:)/scaling;

% Assign output to the inequality and equality constrains
in = constraintValues(:,[obj.IsInequality]);
eq = constraintValues(:,~[obj.IsInequality]);

%% Update function counter of the Optimiser
XoptGlobal.NevaluationsConstraints = XoptGlobal.NevaluationsConstraints+height(Tinput);  % Number of objective function evaluations

% record constraint values
for i = 1:size(constraintValues,1)
    opencossan.optimization.OptimizationRecorder.recordConstraints(...
        x(i,:), constraintValues(i,:));
end
switch class(XoptGlobal.XOptimizer)
    case 'opencossan.optimization.Cobyla'
        XoptGlobal = XoptGlobal.recordConstraints(...
        'row',XoptGlobal.Niterations,...
        'constraints', constraintValues);
    case 'opencossan.optimization.GeneticAlgorithms'
        for i = 1:size(constraintValues,1)
            XoptGlobal.Niterations=XoptGlobal.Niterations + 1;
            XoptGlobal = XoptGlobal.recordConstraints(...
                'row', XoptGlobal.Niterations,...
                'constraints', constraintValues(i,:));
        end
    case 'opencossan.optimization.StochasticRanking'
        if size(constraintValues,1)==XoptGlobal.XOptimizer.Nlambda
            XoptGlobal=XoptGlobal.addIteration('MconstraintFunction',MoutConstrains,...
                'Mdesignvariables',Minput,...
                'Viterations',repmat(max(0,XoptGlobal.Niterations),size(Minput,1),1));
        end        
end

end

