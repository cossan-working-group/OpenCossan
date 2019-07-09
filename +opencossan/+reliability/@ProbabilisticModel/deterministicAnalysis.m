function [Xout] = deterministicAnalysis(Xobj)
%deterministicAnalysis  Performe the deterministic analysis of the Model,
% i.e. evaluate the model using the default (nominal) values .
%
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

import opencossan.simulations.MonteCarlo

OpenCossan.setLaptime('description','[ProbabilisticModel deterministicAnalysis] Start analysis')

%% Evaluate the Model and the PerformanceFunction
% if ~isempty(Xobj.Xmodel)
%     Xout = Xobj.Xmodel.deterministicAnalysis;
%     Xout = Xobj.XperformanceFunction.apply(Xout);
% else
%     Xout = Xobj.XperformanceFunction.apply(Xobj.Xinput);
% end

Xout = Xobj.Xevaluator.apply(Xobj.Xinput);
Xout.Sdescription=[Xout.Sdescription ' - deterministicAnalysis(@ProbabilisticModel)'];

% It is necessary to export the results for the GUI
% Create a dummy Simulation object
XmcDummy=MonteCarlo;
% Now export results
XmcDummy.exportResults('XsimulationOutput',Xout,'SbatchName','SimulationData_Deterministic_Analysis');

OpenCossan.setLaptime('description','[ProbabilisticModel deterministicAnalysis] Stop model evaluation')

end

