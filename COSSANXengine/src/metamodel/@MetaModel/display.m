function display(Xobj)
%DISPLAY   Displays the information related to the MetaModel
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@MetaModel
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$


%%  Output to Screen
% Name and description
OpenCossan.cossanDisp('===================================================================',3);
OpenCossan.cossanDisp([' ' class(Xobj) ' Object  -  Description: ' Xobj.Sdescription],1);
OpenCossan.cossanDisp('===================================================================',3);

OpenCossan.cossanDisp(sprintf(' * Type of %s: %s',class(Xobj),Xobj.Stype),2);

if ~isempty(Xobj.XFullmodel)
    OpenCossan.cossanDisp(' * Reference Model has been defined',3);
end

OpenCossan.cossanDisp([' * Inputs  : ' sprintf('"%s" ',Xobj.Cinputnames{:}) ],2);
OpenCossan.cossanDisp([' * Outputs : ' sprintf('"%s" ',Xobj.Coutputnames{:}) ],2);

if ~isempty(Xobj.XcalibrationInput),
    OpenCossan.cossanDisp(' * Input data for calibration has been defined',2);
end
if ~isempty(Xobj.XcalibrationOutput),
    OpenCossan.cossanDisp(' * Output data for calibration has been defined',2)
end
%3.2.   Data on Validation
if ~isempty(Xobj.XvalidationInput),
    OpenCossan.cossanDisp('* Input data for validating has been defined',2);
end
if ~isempty(Xobj.XvalidationOutput),
    OpenCossan.cossanDisp('* Output data for validating has been defined',2);
end

%%  Status of metamodel

if Xobj.Lcalibrated,
  OpenCossan.cossanDisp([' * Metamodel calibrated: regression error R^2: ' num2str(Xobj.VcalibrationError)],2);        
end

if Xobj.Lvalidated,
  OpenCossan.cossanDisp([' * Metamodel validated: regression error R^2: ' num2str(Xobj.VvalidationError)],2);
end

