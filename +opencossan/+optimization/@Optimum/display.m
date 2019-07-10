function display(Xobj)
%DISPLAY Show the summary of an Optimum object
%
% See Also: Optimum, TutorialOptimum
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
import opencossan.OpenCossan
%%  Name and description
OpenCossan.cossanDisp('===================================================================',3);
OpenCossan.cossanDisp([ class(Xobj) ' Object  -  Description: ' Xobj.Sdescription],1);
OpenCossan.cossanDisp('===================================================================',3);

%% Design Variable
if isempty(Xobj.CdesignVariableNames)
    OpenCossan.cossanDisp('|- Design Variables not DEFINED ',2);
else
    OpenCossan.cossanDisp(['|- Design Variables: ' sprintf('%s ',Xobj.CdesignVariableNames{:})],2);
end

%% Objective Functions
if isempty(Xobj.CobjectiveFunctionNames)
    OpenCossan.cossanDisp('|- Objective Functions not DEFINED ',2);
else
    OpenCossan.cossanDisp(['|- Objective Functions: ' sprintf('%s ',Xobj.CobjectiveFunctionNames{:})],2);
end

%% Constraint Functions
if isempty(Xobj.CconstraintsNames)
    OpenCossan.cossanDisp('|- Constraint Functions not DEFINED ',2);
else
    OpenCossan.cossanDisp(['|- Constraint Functions: ' sprintf('%s ',Xobj.CconstraintsNames{:})],2);
end

%% Show values in the Table
disp(Xobj.TablesValues)

OpenCossan.cossanDisp('|',2)

%% Termination criterion of optimization algorithm
if ~isempty(Xobj.Sexitflag)
    OpenCossan.cossanDisp(['|-- Termination criterion : ' Xobj.Sexitflag],1);
end

%% CPU time
if ~isempty(Xobj.totalTime)
    OpenCossan.cossanDisp([' Total time:    ' num2str(Xobj.totalTime) ' seconds'],2);
end
