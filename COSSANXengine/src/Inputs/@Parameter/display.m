function display(Xobj)
%DISPLAY  Displays a summary of the PARAMETER object
%
% ==================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% ==================================================================

%% Name and description
OpenCossan.cossanDisp('===================================================================',2);
OpenCossan.cossanDisp([ class(Xobj) ' Object  -  Description: ' Xobj.Sdescription],1);
OpenCossan.cossanDisp('===================================================================',2);

OpenCossan.cossanDisp(['* Number of elements: ' sprintf('%i', Xobj.Nelements) ],1);

Velements=Xobj.value(1:min(10,Xobj.Nelements));
OpenCossan.cossanDisp(['* Values : ' sprintf('%8.3e ',Velements)],3);
if Xobj.Nelements>10
    OpenCossan.cossanDisp(['  ... ' num2str(Xobj.Nelements-10) ' more values'],3);
end



