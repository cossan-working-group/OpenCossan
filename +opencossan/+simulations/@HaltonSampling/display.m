function display(Xobj)
%DISPLAY  Displays the summary of the HaltonSampling object
%
% ==================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% ==================================================================

%% Name and description
OpenCossan.cossanDisp('===================================================================',3);
OpenCossan.cossanDisp([ class(Xobj) ' object  -  Description: ' Xobj.Sdescription ],1);
OpenCossan.cossanDisp('===================================================================',3);

OpenCossan.cossanDisp('Termination Criteria: ',1);
if ~isempty(Xobj.Nsamples)
    OpenCossan.cossanDisp(['Number of samples: ' sprintf('%e',Xobj.Nsamples)],1);
end
if ~isempty(Xobj.CoV)
    OpenCossan.cossanDisp(['CoV: ' sprintf('%e',Xobj.CoV)],1);
end
if ~isempty(Xobj.timeout)
    OpenCossan.cossanDisp(['Max computational time: ' sprintf('%e',Xobj.timeout)],1);
end
OpenCossan.cossanDisp('*')
OpenCossan.cossanDisp(['Simulation will perform in ' sprintf('%d',Xobj.Nbatches) ' batches'],2);
if Xobj.Lintermediateresults
    OpenCossan.cossanDisp('Partial results files will be stored',2);
else
    OpenCossan.cossanDisp('Partiel results will NOT be provided',2);
end
OpenCossan.cossanDisp('*',2)
OpenCossan.cossanDisp('Sampling details:',2)
OpenCossan.cossanDisp([' * Scramble settings                = ' Xobj.ScrambleMethod],2)
OpenCossan.cossanDisp([' * Interval between points          = ' num2str(Xobj.Nleap)],2)
OpenCossan.cossanDisp([' * Number of initial points omitted = ' num2str(Xobj.Nskip)],2)
