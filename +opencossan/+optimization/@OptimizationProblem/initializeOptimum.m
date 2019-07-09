function Xoptimum=initializeOptimum(Xobj,varargin)
%INITIALIZEOPTIMUM
% This function is used to inizialize an Optimum object for OptimizationProblem
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/initializeOptimum@OptimizationProblem
%
% Author: Edoardo Patelli and Matteo Broggi
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

import opencossan.common.Dataseries
import opencossan.optimization.Optimum

OpenCossan.validateCossanInputs(varargin{:});

%set default values
LgradientObjFun=false;
LgradientConstraints=false;

%  Check whether or not required arguments have been passed
for k=1:2:length(varargin),
    switch lower(varargin{k})
        case {'lgradientobjectivefunction'},
            LgradientObjFun=varargin{k+1};
        case {'lgradientconstraints'},
            LgradientConstraints=varargin{k+1};
        case {'xoptimizer'},
            Xoptimizer=varargin{k+1};
        otherwise
            error('openCOSSAN:OptimizationProblem:initializeOptimum',...
                'PropertyName %s is not valid',varargin{k});
    end
end

% Get population size
if exist('Xoptimizer','var')    
    OpenCossan.setAnalysisID;
    if ~isdeployed && isempty(OpenCossan.getAnalysisName)
        OpenCossan.setAnalysisName(class(Xoptimizer))
    end
    % insert entry in Analysis DB
    if ~isempty(OpenCossan.getDatabaseDriver)
        insertRecord(OpenCossan.getDatabaseDriver,'StableType','Analysis',...
            'Nid',OpenCossan.getAnalysisID);
    end    
end

for idv=1:Xobj.NdesignVariables;
    XdesignVariable(idv) = Dataseries('SindexName',['Design variable #' num2str(idv)],...
        'SindexUnit','iteration'); %#ok<AGROW>
end

for iobj=1:Xobj.NobjectiveFunctions;
    XdsObjFunction(iobj) = Dataseries('SindexName',['Objective Function #' num2str(iobj)],...
        'SindexUnit','iteration'); %#ok<AGROW>
    if LgradientObjFun
        XdsObjFunctionGradient(iobj) = Dataseries('SindexName',['Gradient of the Objective Function #' num2str(iobj)],...
            'SindexUnit','iteration'); %#ok<AGROW>
    end
    
end

if ~isempty(Xobj.Xconstraint)
    for icon=1:Xobj.Nconstraints
        XdsConstraint(icon) = Dataseries('SindexName',['Constraint #' num2str(icon)],...
            'SindexUnit','iteration'); %#ok<AGROW>
        if LgradientConstraints
            XdsConstraintGradient(icon) = ...
                Dataseries('SindexName',['Gradient of the Constraint #' num2str(icon)],...
                'SindexUnit','iteration'); %#ok<AGROW>
        end
    end
    
    if LgradientConstraints
        if LgradientObjFun
            % Full Optimum
            Xoptimum=Optimum('Xoptimizationproblem',Xobj,...
                'CdesignVariableNames',Xobj.CnamesDesignVariables, ...
                'XdesignVariableDataseries',XdesignVariable,...
                'XobjectiveFunctionDataseries',XdsObjFunction, ...
                'XobjectiveFunctionGradientDataseries',XdsObjFunctionGradient, ...
                'Xconstrainsdataseries',XdsConstraint, ...
                'Xconstrainsgradientdataseries',XdsConstraintGradient);
        else
            % No Gradient ObjFun
            Xoptimum=Optimum('Xoptimizationproblem',Xobj,...
                'CdesignVariableNames',Xobj.CnamesDesignVariables, ...
                'XdesignVariableDataseries',XdesignVariable,...
                'XobjectiveFunctionDataseries',XdsObjFunction, ...
                'Xconstrainsdataseries',XdsConstraint, ...
                'Xconstrainsgradientdataseries',XdsConstraintGradient);
        end
    else % No gradient constraints
        if LgradientObjFun
            % Full Optimum
            Xoptimum=Optimum('Xoptimizationproblem',Xobj,...
                'CdesignVariableNames',Xobj.CnamesDesignVariables, ...
                'XdesignVariableDataseries',XdesignVariable,...
                'XobjectiveFunctionDataseries',XdsObjFunction, ...
                'XobjectiveFunctionGradientDataseries',XdsObjFunctionGradient, ...
                'Xconstrainsdataseries',XdsConstraint);
        else
            % No Gradient ObjFun & No gradient Contraints
            Xoptimum=Optimum('Xoptimizationproblem',Xobj,...
                'CdesignVariableNames',Xobj.CnamesDesignVariables, ...
                'XdesignVariableDataseries',XdesignVariable,...
                'XobjectiveFunctionDataseries',XdsObjFunction, ...
                'Xconstrainsdataseries',XdsConstraint);
        end
        
    end
else
    if LgradientObjFun
        % with ObjFun gradient and no Constraints
        Xoptimum=Optimum('Xoptimizationproblem',Xobj,...
            'CdesignVariableNames',Xobj.CnamesDesignVariables, ...
            'XdesignVariableDataseries',XdesignVariable,...
            'XobjectiveFunctionDataseries',XdsObjFunction, ...
            'XobjectiveFunctionGradientDataseries',XdsObjFunctionGradient);
    else
        % No ObjFun gradient and no Constraints
        Xoptimum=Optimum('Xoptimizationproblem',Xobj,...
            'CdesignVariableNames',Xobj.CnamesDesignVariables, ...
            'XdesignVariableDataseries',XdesignVariable,...
            'Xobjectivefunctiondataseries',XdsObjFunction);
    end
end

%% Add the optimizer
if exist('Xoptimizer','var')
    Xoptimum.XOptimizer=Xoptimizer;
end




