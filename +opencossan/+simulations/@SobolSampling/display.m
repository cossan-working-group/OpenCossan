function display(Xobj)
%DISPLAY  Displays the summary of the SobolSampling object
%
% =====================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2009 IfM
% =====================================================
OpenCossan.cossanDisp('==============================================')
OpenCossan.cossanDisp('=          SobolSampling  Object             =')
OpenCossan.cossanDisp('==============================================')
OpenCossan.cossanDisp('');
OpenCossan.cossanDisp(['Description: ' Xobj.Sdescription]);

OpenCossan.cossanDisp('Termination Criteria: ');
if ~isempty(Xobj.Nsamples)
    OpenCossan.cossanDisp(['Number of samples: ' sprintf('%e',Xobj.Nsamples)]);
end
if ~isempty(Xobj.CoV)
    OpenCossan.cossanDisp(['CoV: ' sprintf('%e',Xobj.CoV)]);
end
if ~isempty(Xobj.timeout)
    OpenCossan.cossanDisp(['Max computational time: ' sprintf('%e',Xobj.timeout)]);
end
OpenCossan.cossanDisp('*')
OpenCossan.cossanDisp(['Simulation will perform in ' sprintf('%d',Xobj.Nbatches) ' batches']);
if Xobj.Lintermediateresults
    OpenCossan.cossanDisp('Partial results files will be stored');
else
    OpenCossan.cossanDisp('Partiel results will NOT be provided');
end
OpenCossan.cossanDisp('*')
OpenCossan.cossanDisp('Sampling details:')
disp ([' * Scramble settings                = ' Xobj.ScrambleMethod])
disp ([' * Point Order method               = ' Xobj.PointOrder])
disp ([' * Interval between points          = ' num2str(Xobj.Nleap)])
disp ([' * Number of initial points omitted = ' num2str(Xobj.Nskip)])
