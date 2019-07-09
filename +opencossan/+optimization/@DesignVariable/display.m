function display(Xobj)
%DISPLAY  Displays the DESIGNVARIABLE object
%
%
%   Example: DISPLAY(Xobj) will output the summary of the Xpar object
% =========================================================================
import opencossan.OpenCossan
%%   Output to Screen
%  Name and description
OpenCossan.cossanDisp('===================================================================',2);
OpenCossan.cossanDisp([ class(Xobj) ' Object - Description: ' Xobj.Sdescription ],1);
OpenCossan.cossanDisp('===================================================================',2);
%   main paramenters
OpenCossan.cossanDisp([' Current Value          : ' num2str(Xobj.value) ],1);

if isempty(Xobj.Vsupport)
    OpenCossan.cossanDisp(' Continous design variable',2);
else
    OpenCossan.cossanDisp(' Discrete design variable',2);
    OpenCossan.cossanDisp([' Support points : ' num2str(Xobj.Vsupport) ],1);
end

OpenCossan.cossanDisp([' Lower Bound : ' num2str(Xobj.lowerBound) ],1);
OpenCossan.cossanDisp([' Upper Bound : ' num2str(Xobj.upperBound) ]),1;


