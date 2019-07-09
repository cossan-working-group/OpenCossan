function Xobj = merge(Xobj,Xobj2)
%MERGE merge 2 SimulationData objects
%
%   MANDATORY ARGUMENTS
%   - Xobj2: SimulationData object
%
%   OUTPUT
%   - Xobj: object of class SimulationData
%
%   USAGE
%   Xobj = Xobj.merge(Xobj2)
%
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


%% Check Objects
% Check if one empty Simulation Output is passed
if isempty(Xobj.Cnames)
    opencossan.OpenCossan.cossanDisp('[OpenCossan:SimulationData:merge] Merge descriptions and return the second SimulationData object',4)
    % Merge description and return the second SimulationData object
    Sdescription=[Xobj.Sdescription Xobj2.Sdescription];
    Xobj=Xobj2;
    Xobj.Sdescription=Sdescription;
    return
elseif isempty(Xobj2.Cnames)
    opencossan.OpenCossan.cossanDisp('[OpenCossan:SimulationData:merge] Merge descriptions and return the first SimulationData object',4)
    % Merge description and return the first SimulationData object
    Sdescription=[Xobj.Sdescription Xobj2.Sdescription];
    Xobj.Sdescription=Sdescription;
    return
end

% MdA: Only two otions are possible. 1) Adding rows to an existing table
% that is done using vertcat. In this case the columns have to have the 
% same names but can have different length; 2) adding a variable (column) 
% to the right of the table that is done using horzcat. In this case the
% columns have to have the same length and different variable names.
if length(Xobj.TableValues.Properties.VariableNames)==length(Xobj2.TableValues.Properties.VariableNames)...
        && all(ismember(Xobj.TableValues.Properties.VariableNames,Xobj2.TableValues.Properties.VariableNames))
    Xobj.TableValues=[Xobj.TableValues;Xobj2.TableValues];
else
    Xobj.TableValues=[Xobj.TableValues,Xobj2.TableValues];
end


