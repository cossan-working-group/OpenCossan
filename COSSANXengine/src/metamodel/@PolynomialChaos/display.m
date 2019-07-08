function display(Xobj)
%DISPLAY shows details of the PolynomialChaos
%
% ==================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% ==================================================================

%% Name and description
OpenCossan.cossanDisp('===================================================================',3);
OpenCossan.cossanDisp([ class(Xobj) ' object  -  Description: ' Xobj.Sdescription ],1);
OpenCossan.cossanDisp('===================================================================',3);

if isempty(Xobj.Xsfem)
OpenCossan.cossanDisp( 'SfemPolynomialObject      : Not assigned',2);
else
OpenCossan.cossanDisp( 'SfemPolynomialObject      : Assigned',2); 
end
OpenCossan.cossanDisp(['Order of the Exp.         : '  num2str(Xobj.Norder) ],1);
if ~isempty(Xobj.Xsfem)
OpenCossan.cossanDisp(['Dimension of the Exp.     : '  num2str(length(Xobj.Xsfem.Xmodel.Xinput.Xrvset.Xrvs.Cmembers)) ],1);
end
OpenCossan.cossanDisp(['Method                    : '  Xobj.Smethod ],1);
if isempty(Xobj.Mpccoefficients)
OpenCossan.cossanDisp( 'Coefficients              : Not calculated',2);
else
OpenCossan.cossanDisp( 'Coefficients              : Calculated',2);
OpenCossan.cossanDisp(['No of Coeffiecents        : ' num2str(Xobj.Npccoefficients) ],2);
end

end
