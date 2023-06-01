function display(Xobj)
%DISPLAY   Displays the information related to the ModelUpdating class properties
%See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@ModelUpdating
%  Output to Screen
%  This method displays the ModelUpdate class properties

if isempty(Xobj.Xmodel)
    OpenCossan.cossanDisp(' Empty ModelUpdating object',3);
    return
else
    OpenCossan.cossanDisp('===================================================================',3);
    OpenCossan.cossanDisp([' ' class(Xobj) ' Object  -  Description: ' Xobj.Sdescription],1);
    OpenCossan.cossanDisp('===================================================================',3);
    OpenCossan.cossanDisp([' * Inputs of the model that will be updated: ' sprintf('"%s" ',Xobj.Cinputnames{:}) ],2);
    OpenCossan.cossanDisp([' * Outputs of the model that will be used in the error function: ' sprintf('"%s" ',Xobj.Coutputnames{:}) ],2);    
    if isempty(Xobj.XupdatingData)
            OpenCossan.cossanDisp('No updating data available',2);
    else
            OpenCossan.cossanDisp('Updating data available',2);
            OpenCossan.cossanDisp(['Samples: ',num2str(Xobj.XupdatingData.Nsamples)],2);
    end
end