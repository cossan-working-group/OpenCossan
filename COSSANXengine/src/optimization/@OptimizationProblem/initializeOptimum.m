function Xoptimum=initializeOptimum(Xobj,varargin)
%INITIALIZEOPTIMUM
% This function is used to inizialize an Optimum object for the
% OptimizationProblem object.
%
% The results of the optimisation are stored in a Optimum object that
% contains the values of the design variable(s), objective function(s),
% constraint(s) and the values of the gradient(s).
%
% All the variables are stored in a field TablesValues of the Optimim
% object
% 
% See Also: TutorialOptimum TutorialOptimizer
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

OpenCossan.validateCossanInputs(varargin{:});

%set default values
LgradientObjFun=false;
LgradientConstraints=false;

%  Check whether or not required arguments have been passed
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'lgradientobjectivefunction'}
            LgradientObjFun=varargin{k+1};
        case {'lgradientconstraints'}
            LgradientConstraints=varargin{k+1};
        case {'xoptimizer'}
            Xoptimizer=varargin{k+1};
        otherwise
            error('OptimizationProblem:initializeOptimum',...
                'PropertyName %s is not a valid property name ', varargin{k});
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

%  Dataseries is used to stored the values of the design variables
for n=1:Xobj.NdesignVariables

    if LgradientObjFun

    end
    
    if LgradientConstraints
        Xobj.CconstraintsNames
    end
end

Viterations=[1  2 3 3 3 4 4 4]';
% MvaluesDesignVariables=             [1  5 2 3 4 3 1 1; ...
%                                      7  5 7 6 5 1 0 1]';
% MvaluesObjectiveFunction=           [10 5 2 3 5 1 5 0]';
% 
% MvaluesObjectiveFunctionGradient=   [2  5 5 1 2 3 4 5;...
%                                      1  4 2 0 4 5 2 1]';
%                                  
% Xoptimum=Optimum('XoptimizationProblem',Xop,...
%     'Mdesignvariable',MvaluesDesignVariables,...
%     'Vobjectivefunction',MvaluesObjectiveFunction,...
%     'Viterations',Viterations,...
%     'MobjectiveFunctionGradient',MvaluesObjectiveFunctionGradient);


%% Add the optimizer
if exist('Xoptimizer','var')
    Xoptimum.XOptimizer=Xoptimizer;
end




