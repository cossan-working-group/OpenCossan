function output = deterministicAnalysis(obj)
%DETERMINISTICANALYSIS Perform the deterministic analysis of the Model,
% i.e. evaluate the model using the default (nominal) values.

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
import opencossan.simulations.MonteCarlo

OpenCossan.getInstance().getTimer().lap('description','[Model deterministicAnalysis] Start model evaluation')
% set the analyis ID
% OpenCossan.setAnalysisId;
% set the Analysis name if not already set
if ~isdeployed && isempty(OpenCossan.getAnalysisName)
    OpenCossan.setAnalysisName('DeterministicAnalysis');
end
% insert entry in Analysis DB
if ~isempty(OpenCossan.getDatabaseDriver)
    insertRecord(OpenCossan.getDatabaseDriver,'StableType','Analysis',...
        'Nid',OpenCossan.getAnalysisID);
end
%% Evaluator execution
output = obj.Evaluator.deterministicAnalysis(obj.Input);

%% Export results
output.Sdescription = [output.Sdescription ' - deterministicAnalysis(@Model)'];

% It is necessary to export the results for the GUI
if isdeployed
    % TODO: Is this still required? Can we not call a method on the output to
    % export it if needed?
    
    % Create a dummy Simulation object
    XmcDummy=MonteCarlo;
    % Now export results
    XmcDummy.exportResults('XsimulationOutput',output,'SbatchName','SimulationData_Deterministic_Analysis');
end

OpenCossan.getTimer().lap('description','[Model deterministicAnalysis] Stop model evaluation')

end

