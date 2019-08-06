function disp(Xobj)
%DISPLAY  Displays the object Optimum%
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@Optimum
%
% Copyright 1983-2013 COSSAN Working Group
% Author: Edoardo Patelli
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

import opencossan.OpenCossan
%%  Name and description
OpenCossan.cossanDisp('===================================================================',3);
OpenCossan.cossanDisp([ class(Xobj) ' Object  -  Description: ' Xobj.Sdescription],1);
OpenCossan.cossanDisp('===================================================================',3);

% Set default values
tolerance =1e-2;

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

return
