function [Xout] = deterministicAnalysis(Xobj)
%deterministicAnalysis  Performe the deterministic analysis of the Model,
% i.e. evaluate the model using the default (nominal) values .
%
% ==================================================================
%% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% ==================================================================

OpenCossan.setLaptime('Sdescription','[ProbabilisticModel deterministicAnalysis] Start analysis')

%% Evaluate the Model and the PerformanceFunction
if ~isempty(Xobj.Xmodel)
    Xout = Xobj.Xmodel.deterministicAnalysis;
    Xout = Xobj.XperformanceFunction.apply(Xout);
else
    Xout = Xobj.XperformanceFunction.apply(Xobj.Xinput);
end

Xout.Sdescription=[Xout.Sdescription ' - deterministicAnalysis(@ProbabilisticModel)'];

% It is necessary to export the results for the GUI
% Create a dummy Simulation object
XmcDummy=MonteCarlo;
% Now export results
XmcDummy.exportResults('XsimulationOutput',Xout,'SbatchName','SimulationData_Deterministic_Analysis');

OpenCossan.setLaptime('Sdescription','[ProbabilisticModel deterministicAnalysis] Stop model evaluation')

end

