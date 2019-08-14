function value = evaluate(obj, varargin)
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

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case 'xoptimizationproblem'
            XoptProb=varargin{k+1};
        case 'mreferencepoints'
            Minput=varargin{k+1};
        case 'scaling'
            scaling=varargin{k+1};
        case 'cxobjects'
            obj.Cxobjects=varargin{k+1};
        otherwise
            error('OpenCossan:ObjectiveFunction:evaluate:wrongInputArgument',...
                'PropertyName %s not valid', varargin{k});
    end
end

% Collect quantities
Coutputnames=[obj.OutputNames];

%% Check inputs
assert(logical(exist('XoptProb','var')),...
    'OpenCossan:ObjectiveFunction:evaluate',...
    'An optimizationProblem object must be defined');

if exist('Minput','var')
    % TODO: Transpose values for cobyla
    
    NdesignVariables = size(Minput,2); %number of design variables
    Ncandidates=size(Minput,1); % Number of candidate solutions
    
    assert(XoptProb.NumberOfDesignVariables == NdesignVariables, ...
        'OpenCossan:ObjectiveFunction:evaluate',...
        'Number of design Variables %i does not match with the dimension of the referece point (%i)', ...
        XoptProb.NumberOfDesignVariables,NdesignVariables);
else
    NdesignVariables=0;
end

% prepare input
Xinput = XoptProb.Input.setDesignVariable('CSnames',XoptProb.DesignVariableNames,'Mvalues',Minput);
Tinput = Xinput.getTable();

% evaluate model
modelResult = ...
    opencossan.optimization.OptimizationRecorder.getModelEvaluation(...
    XoptProb.DesignVariableNames, Minput);

if isempty(modelResult)
    modelResult = apply(XoptProb.Model,Tinput);
    modelResult = modelResult.TableValues;
    opencossan.optimization.OptimizationRecorder.recordModelEvaluations(...
        modelResult);
end

for iobj=1:length(obj)
    % Prepare Input structure
    TinputSolver = modelResult(:,obj(iobj).InputNames);
    
    % Evalutate Obj.Function
    XoutObjective = evaluate@opencossan.workers.Mio(obj(iobj),TinputSolver);
    
    % keep only the variables defined in the Coutputnames
    Mout(:,iobj) = XoutObjective.(obj(iobj).OutputNames{1});
end

%%   Apply scaling constant
value = Mout(1:Ncandidates,:)/scaling;

% record objective function values
for i = 1:size(Mout,1)
    opencossan.optimization.OptimizationRecorder.recordObjectiveFunction(...
        Minput(i,:), Mout(i,:));
end

end

