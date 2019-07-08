function [Xobj] = addIteration(Xobj,varargin)
%ADDITERATION This function adds a new iteration to the Optimum object
%   This function is used to store a new iteration of the Optimization
%   Process in the Optimum object.
%
% See also: TutorialOptimisationProblem
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
if OpenCossan.getChecks
    OpenCossan.validateCossanInputs(varargin{:})
end

%Predefine variables
MvaluesDesignVariables=[];
MvaluesObjectiveFunction=[];
MvaluesConstraint=[];

if isempty(Xobj.TablesValues)
    Xobj.TablesValues=initialaseTable(Xobj,varargin{:});
else
    
    for k=1:2:length(varargin)
        switch lower(varargin{k})
            case {'viterations','niteration','iteration'}
                Viteration=varargin{k+1};
            case {'mdesignvariables','vdesignvariables','designvariable'}
                MvaluesDesignVariables=varargin{k+1};
            case {'mobjectivefunction','vobjectivefunction','objectivefunction'}
                MvaluesObjectiveFunction=varargin{k+1};
            case {'mconstraintfunction','vconstraintfunction','constraintfunction'}
                MvaluesConstraint=varargin{k+1};
            otherwise
                error('Optimum:addIteration:wrongInputArgument',...
                    'PropertyName %s not valid', varargin{k});
        end
    end
    
    Nrows=length(Viteration);
    NobjFnc=size(Xobj.TablesValues.ObjectiveFnc,2);
    Ndv=size(Xobj.TablesValues.DesignVariables,2);
    Nconst=size(Xobj.TablesValues.Constraints,2);
    
    
    %% Validate inputs
    NdesignVariablesInput = size(MvaluesDesignVariables,2);  % Nmber of design variables
    NobjectiveFunctionsInput=size(MvaluesObjectiveFunction,2); %Number of Objective Functions
    NconstraintFunctionsInput=size(MvaluesConstraint,2); %Number of Contraints Functions
    
    %% Update Optimum object
    if ~isempty(MvaluesDesignVariables)
        assert(size(MvaluesDesignVariables,2)==NdesignVariablesInput, ...
            'Optimum:addIteration:wrongNumberDV',...
            'Number of design Variables %i does not match with the dimension of the Optimum object (%i)', ...
            Ndv,NdesignVariablesInput);
        OpenCossan.cossanDisp(['[Optimum:addIteration] * Iteration #' num2str(Viteration(1))],4)
    else
        MvaluesDesignVariables=NaN(Nrows,Ndv);
    end
    
    if ~isempty(MvaluesObjectiveFunction)
        assert(NobjFnc==NobjectiveFunctionsInput,...
            'Optimum:addIteration:wrongNumberObjFun',...
            'Size of Objective Function evaluation %i does not match (expected size: %i))', ...
            NobjFnc,NobjectiveFunctionsInput);
    else
        MvaluesObjectiveFunction=NaN(Nrows,NobjFnc);
    end
       
    if ~isempty(MvaluesConstraint)
        assert(NconstraintFunctionsInput==Nconst,...
            'openCOSSAN:Optimum:addIteration:wrongNumberContraints',...
            'Size of Contraints function evaluation %i does not match (expected size: %i))', ...
            NconstraintFunctionsInput,Nconst);
    else
        MvaluesConstraint=NaN(Nrows,Nconst);
    end      
    
    % Create a new table
    AddTables=table(Viteration,...
        MvaluesDesignVariables, ...
        MvaluesObjectiveFunction,...
        MvaluesConstraint);
    
    AddTables.Properties.VariableNames={...
        'Iteration','DesignVariables',...
        'ObjectiveFnc','Constraints'};
    
    %% Merge Tables
    Xobj.TablesValues = [Xobj.TablesValues; AddTables];
    
end

