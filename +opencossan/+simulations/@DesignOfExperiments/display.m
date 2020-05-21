function display(Xobj)
%DISPLAY  Displays the summary of the montecarlo object
%
% ==================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% ==================================================================
import opencossan.OpenCossan

% Name and description
OpenCossan.cossanDisp('===================================================================',2);
OpenCossan.cossanDisp([' DesignOfExperiment Object  -   Description: ' Xobj.Sdescription ],1 );
OpenCossan.cossanDisp('===================================================================',2);



OpenCossan.cossanDisp(['* Type of design of experiment : ' Xobj.SdesignType],2);
OpenCossan.cossanDisp(['* Central composite design     : ' Xobj.ScentralCompositeType],2);

OpenCossan.cossanDisp(['* Perturbation parameter       : ' num2str(Xobj.perturbanceParameter)],2);

if Xobj.LuseCurrentValues
    OpenCossan.cossanDisp('* Current values of the DesignVariable used',2);
end

OpenCossan.cossanDisp(['* Simulation will perform in ' sprintf('%d',Xobj.Nbatches) ' batches'],3);

for n=1:length(Xobj.VlevelValues)
    OpenCossan.cossanDisp(['** Input factor: ' Xobj.ClevelNames{n} '; # of levels: ' num2str(Xobj.VlevelValues(n)) ],3);
end

if ~isempty(Xobj.ClevelNames)
    OpenCossan.cossanDisp(['** Variables names: ' sprintf('"%s" ',Xobj.ClevelNames{:})],3);
end

