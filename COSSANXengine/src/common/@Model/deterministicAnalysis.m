function [Xout] = deterministicAnalysis(Xobj)
%deterministicAnalysis  Performe the deterministic analysis of the Model,
% i.e. evaluate the model using the default (nominal) values .
%
% ==================================================================
%% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% ==================================================================

OpenCossan.setLaptime('Sdescription','[Model deterministicAnalysis] Start model evaluation')
% set the analyis ID
OpenCossan.setAnalysisID;
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
Xout = Xobj.Xevaluator.deterministicAnalysis(Xobj.Xinput);

%% Export results
Xout.Sdescription=[Xout.Sdescription ' - deterministicAnalysis(@Model)'];

% It is necessary to export the results for the GUI
% Create a dummy Simulation object
XmcDummy=MonteCarlo;
% Now export results
XmcDummy.exportResults('XsimulationOutput',Xout,'SbatchName','SimulationData_Deterministic_Analysis');

OpenCossan.setLaptime('Sdescription','[Model deterministicAnalysis] Stop model evaluation')

end

