function simData1 = plus(simData1,simData2)
%PLUS adds one SimulationData object to the other
%
%
%  Usage: PLUS(XSimOut1,XSimOut2) adds the values of the Output object XSimOut2
%  to the  valus of the Output object XSimOut1
%  Example:  plus(XSimOut1,XSimOut2)

assert(all(ismember(...
    simData1.Samples.Properties.VariableNames, simData2.Samples.Properties.VariableNames)), ...
    'OpenCossan:SimulationData:plus', 'Both SimulationData must contain the same variables.');

simData1.Samples = [simData1.Samples simData2.Samples];
end

