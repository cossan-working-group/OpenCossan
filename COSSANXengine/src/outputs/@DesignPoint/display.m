function display(Xo)
%DISPLAY  Displays the object DesignPoint
%   
%
%   Example: DISPLAY(Xo) will output the summary of the DesignPoint object
% =========================================================================
% ==================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% ==================================================================

%% 1.   Name and description
OpenCossan.cossanDisp('===================================================================',3);
OpenCossan.cossanDisp([' DesignPoint Object  -  Description: ' Xo.Sdescription],1);
OpenCossan.cossanDisp('===================================================================',3);

%% 2.   Design Point
OpenCossan.cossanDisp('* Coordinates of the Design Point ',1);
%   Standard normal space
OpenCossan.cossanDisp(['  - Standard normal space: ' sprintf('%10.3e ',Xo.VDesignPointStdNormal)],2);
%   Physical space
OpenCossan.cossanDisp(['  - Physical space       : ' sprintf('%10.3e ',Xo.VDesignPointPhysical)],1);

%% 3.   Direction of design point
OpenCossan.cossanDisp('* Unit Vector pointing in the direction of the Design Point ',1);
%   Standard normal space
OpenCossan.cossanDisp(['  - Standard normal space: ' sprintf('%10.3e ',Xo.VDirectionDesignPointStdNormal)],2);
%   Physical space
OpenCossan.cossanDisp(['  - Physical space       : ' sprintf('%10.3e ',Xo.VDirectionDesignPointPhysical)],1);

%% 4.   Euclidean norm
OpenCossan.cossanDisp(['* Euclidean norm of the Design Point - factor of safety:' sprintf('%10.3e ',Xo.ReliabilityIndex)],2);

%% 5.   FORM approximation of the probability of failure
OpenCossan.cossanDisp(['* First order approximation of the failure probability :' sprintf('%10.3e ',Xo.form)],2);

end
