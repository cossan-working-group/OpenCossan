function display(Xobj)
%DISPLAY  Displays the summary of the Xlinesampling object
%
% =====================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2010 IfM
% =====================================================
%% Name and description
OpenCossan.cossanDisp('===================================================================',2);
OpenCossan.cossanDisp([' Line Sampling Object  -  Description: ' Xobj.Sdescription],1);
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
if ~isempty(Xobj.Nlines)
    OpenCossan.cossanDisp(['* Max number of lines: ' sprintf('%e',Xobj.Nlines)],2);
end
OpenCossan.cossanDisp(['Number of  batches: ' sprintf('%d',Xobj.Nbatches) ],2);
if Xobj.Lintermediateresults
    OpenCossan.cossanDisp('Partial results files will be stored',3);
else
    OpenCossan.cossanDisp('Partiel results will NOT be provided',3);
end


if isempty(Xobj.Valpha)
    OpenCossan.cossanDisp('Important direction: NOT DEFINED',2)
else
    OpenCossan.cossanDisp('Important direction: ',2)
for n=1:length(Xobj.CalphaNames)
    OpenCossan.cossanDisp(['* ' sprintf('%8.3e %s',Xobj.Valpha(n)),'(', Xobj.CalphaNames{n}, ')'],2);
end
end

% Show evaluation points
OpenCossan.cossanDisp(['Evaluation points along the lines: ' sprintf('%d ',Xobj.Vset(:))],2);

