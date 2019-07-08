function display(Xr)
%DISPLAY  show the summary of the object
%

%  Copyright 1993-2011, COSSAN Working Group
%  University of Innsbruck, Austria

OpenCossan.cossanDisp('===================================================',3);
OpenCossan.cossanDisp([' ' class(Xr) ' - (' Xr.Sdescription ') '],2)
OpenCossan.cossanDisp('===================================================',3);

if isempty(Xr.Sdistribution)
    return
else
    OpenCossan.cossanDisp([' Definition method: ' Xr.Sdefinition ],2)
end
OpenCossan.cossanDisp('===================================================',3);
OpenCossan.cossanDisp(['* Approximate mean = ' sprintf('%9.3e',Xr.mean)],2);
OpenCossan.cossanDisp(['* Approximate Std  = ' sprintf('%9.3e',Xr.std)],2);
OpenCossan.cossanDisp(['* Approximate CoV  = ' sprintf('%9.3e',Xr.CoV)],2);

OpenCossan.cossanDisp(['* Lower limit      = ' sprintf('%9.3e',Xr.lowerBound)],2);
OpenCossan.cossanDisp(['* Upper limit      = ' sprintf('%9.3e',Xr.upperBound)],2);

