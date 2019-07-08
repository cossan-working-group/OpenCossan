function [Xout] = deterministicAnalysis(Xobj)
%deterministicAnalysis  Performe the deterministic analysis of the Model,
% i.e. evaluate the model using the default (nominal) values .
%
% See also: http://cossan.cfd.liv.ac.uk/wiki/index.php/deterministicAnalysis@MetaModel
%
% Copyright 1993-2011, COSSAN Working Group, University~of~Innsbruck, Austria

OpenCossan.setLaptime('Sdescription','[MetaModel deterministicAnalysis] Start model evaluation')
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

assert(~isempty(Xobj.XFullmodel),'openCOSSAN:MetaModel:deterministicAnalysis',...
    'Deterministic Analysis of the MetaModel can be performed only when the full model is defined')
%% Evaluator execution
Xout = Xobj.XFullmodel.Xevaluator.deterministicAnalysis(Xobj.XFullmodel.Xinput);

%% Export results
Xout.Sdescription=[Xout.Sdescription ' - deterministicAnalysis(@MetaModel)'];

% It is necessary to export the results for the GUI
% Create a dummy Simulation object
XmcDummy=MonteCarlo;
% Now export results
XmcDummy.exportResults('XsimulationOutput',Xout,'SbatchName','SimulationData_Deterministic_Analysis');

OpenCossan.setLaptime('Sdescription','[MetaModel deterministicAnalysis] Stop model evaluation')

end

