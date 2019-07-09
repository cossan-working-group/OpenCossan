function display(Xobj)
%DISPLAY  Displays the summary of the montecarlo object
%
% =====================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2009 IfM
% =====================================================

OpenCossan.cossanDisp('==============================================',3)
OpenCossan.cossanDisp('=     LatinHypercubeSampling Object         =',2)
OpenCossan.cossanDisp('==============================================',3)
OpenCossan.cossanDisp(['Description: ' Xobj.Sdescription],2);

OpenCossan.cossanDisp('* Termination Criteria: ',3);
if ~isempty(Xobj.Nsamples)
    OpenCossan.cossanDisp(['** Number of samples: ' sprintf('%e',Xobj.Nsamples)],3);
end
if ~isempty(Xobj.CoV)
    OpenCossan.cossanDisp(['** CoV: ' sprintf('%e',Xobj.CoV)],3);
end
if ~isempty(Xobj.timeout)
    OpenCossan.cossanDisp(['** Max computational time: ' sprintf('%e',Xobj.timeout)],3);
end
OpenCossan.cossanDisp(['* Simulation will perform in ' sprintf('%d',Xobj.Nbatches) ' batches'],3);
if Xobj.Lintermediateresults
    OpenCossan.cossanDisp('* Partial results files will be stored',3);
else
    OpenCossan.cossanDisp('* Partiel results will NOT be provided',3);
end
OpenCossan.cossanDisp('* Sampling method:',2)
OpenCossan.cossanDisp(['iteration: ' num2str(Xobj.Niterations)],2);
OpenCossan.cossanDisp(['criterion: ' Xobj.Scriterion],2);
OpenCossan.cossanDisp(['smooth: ' Xobj.Ssmooth],2);
