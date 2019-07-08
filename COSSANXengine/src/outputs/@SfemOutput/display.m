function display(Xobj)
%DISPLAY  Displays the object SfemOutput
%
%
%   Example: DISPLAY(Xo) will output the summary of the SFEM object
% =========================================================================

Xsfem = Xobj.XSfemObject;

if isempty(Xsfem)
    OpenCossan.cossanDisp('===================================================================',1);
    OpenCossan.cossanDisp([' SFEM Output Object  -  Name: ' inputname(1)],1);
    OpenCossan.cossanDisp([' Description: ' Xobj.Sdescription ],2);
    OpenCossan.cossanDisp('===================================================================',1);
    return
end

OpenCossan.cossanDisp(' ',1);
OpenCossan.cossanDisp('===================================================================',1);
OpenCossan.cossanDisp([' SFEM Output Object  -  Name: ' inputname(1)],1);
OpenCossan.cossanDisp([' Description: ' Xobj.Sdescription ],2);
OpenCossan.cossanDisp('===================================================================',1);
OpenCossan.cossanDisp(' ',1);
if strcmp(Xobj.Sresponse,'max')
    OpenCossan.cossanDisp( ' Quantity of Interest                 : Maximum Displacement',1);
    OpenCossan.cossanDisp([' Entry no of the max displacement     : ' num2str(Xobj.maxresponseDOF)],2);
    OpenCossan.cossanDisp([' Corresponding Node no                : ' num2str(Xsfem.MmodelDOFs(Xobj.maxresponseDOF,1))],2);
    OpenCossan.cossanDisp([' Corresponding DOF no                 : ' num2str(Xsfem.MmodelDOFs(Xobj.maxresponseDOF,2))],2);
    OpenCossan.cossanDisp([' Mean of Response                     : ' num2str(Xobj.Vresponsemean)],1);
    OpenCossan.cossanDisp([' Standard Deviation of Response       : ' num2str(Xobj.Vresponsestd)],1);
    OpenCossan.cossanDisp([' Coefficient of Variation of Response : ' num2str(Xobj.Vresponsecov)],1);
elseif strcmp(Xobj.Sresponse,'specific') && strcmp(Xsfem.Sanalysis,'Static')
    for i=1:size(Xobj.MresponseDOFs,1)
        OpenCossan.cossanDisp([' Quantity of Interest                  : Node: ' num2str(Xobj.MresponseDOFs(i,1)) ' - DOF: ' num2str(Xobj.MresponseDOFs(i,2))],1);
        OpenCossan.cossanDisp([' Mean of Response                      : ' num2str(Xobj.Vresponsemean(i))],1);
        OpenCossan.cossanDisp([' Standard Deviation of Response        : ' num2str(Xobj.Vresponsestd(i))],1);
        OpenCossan.cossanDisp([' Coefficient of Variation of Response  : ' num2str(Xobj.Vresponsecov(i))],1);
        OpenCossan.cossanDisp('',1);
    end
elseif strcmp(Xsfem.Smethod,'Collocation')
    for i=1:size(Xobj.Vresponsemean,1)
        OpenCossan.cossanDisp([' Mean of Response # ' num2str(i) '                  : ' num2str(Xobj.Vresponsemean(i))],1);
        OpenCossan.cossanDisp([' Standard Deviation of Response        : ' num2str(Xobj.Vresponsestd(i))],1);
        OpenCossan.cossanDisp([' Coefficient of Variation of Response  : ' num2str(Xobj.Vresponsecov(i))],1);
        OpenCossan.cossanDisp('',1);
    end
elseif strcmp(Xobj.Sresponse,'specific') && strcmp(Xsfem.Sanalysis,'Modal')
    OpenCossan.cossanDisp([' Quantity of Interest                  : ' num2str(Xobj.Nmode) '. Natural Frequency'],1);
    % NOTE: here the eigenvalue is converted to Hz for the mean value
    %       CoV is calculated for the eigenvalue
    OpenCossan.cossanDisp([' Mean of Response                      : ' num2str(sqrt(Xobj.Vresponsemean)./(2*pi)) ' Hz'],1);
    OpenCossan.cossanDisp([' Standard Deviation of Response        : ' num2str(Xobj.Vresponsestd)],1);
    OpenCossan.cossanDisp([' Coefficient of Variation of Response  : ' num2str(Xobj.Vresponsecov)],1);
end

return