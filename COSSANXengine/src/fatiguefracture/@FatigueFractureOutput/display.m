function display(Xo)
%DISPLAY  Displays the object FatigueFractureOutput
%   
%% Output to Screen
% Name and description
OpenCossan.cossanDisp('===================================================================',3);
OpenCossan.cossanDisp([' SimulationOutput Object  -  Name: ' inputname(1)],2);
OpenCossan.cossanDisp([' Description: ' Xo.Sdescription ],2);
OpenCossan.cossanDisp('===================================================================',3);
% main paramenters
OpenCossan.cossanDisp(['* Number of Variables: ' num2str(length(Xo(1).Cnames))],2)
if length(Xo(1).Cnames)<=10
    OpenCossan.cossanDisp(Xo(1).Cnames',2)
end

