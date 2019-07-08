function display(Xobj)
%DISPLAY  Displays the summary of the montecarlo object
%
% =====================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2009 IfM
% =====================================================

%% Name and description
OpenCossan.cossanDisp('===================================================================',2);
OpenCossan.cossanDisp([' Monte Carlo Object  -  Description: ' Xobj.Sdescription],1);
OpenCossan.cossanDisp('===================================================================',2);

OpenCossan.cossanDisp('Termination Criteria: ',2);
if ~isempty(Xobj.Nsamples)
    OpenCossan.cossanDisp(['* Number of samples: ' sprintf('%e',Xobj.Nsamples)],2);
end
if ~isempty(Xobj.CoV)
    OpenCossan.cossanDisp(['* CoV: ' sprintf('%e',Xobj.CoV)],2);
end

if ~isempty(Xobj.timeout)
    OpenCossan.cossanDisp(['* Max computational time: ' sprintf('%e',Xobj.timeout)],2);
end

OpenCossan.cossanDisp(['Number of  batches: ' sprintf('%d',Xobj.Nbatches) ],2);
if Xobj.Lintermediateresults
    OpenCossan.cossanDisp('Partial results files will be stored',3);
else
    OpenCossan.cossanDisp('Partiel results will NOT be provided',3);
end



