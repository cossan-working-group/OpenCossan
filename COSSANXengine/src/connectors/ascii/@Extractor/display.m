function display(Xobj)
%DISPLAY  Displays the object extractor
%   
%
%   Example: DISPLAY(Xe) will output the summary of the extractor
% =========================================================================


%% 1.   Output to Screen
% 1.1.   Name and description
OpenCossan.cossanDisp(' ',3);
OpenCossan.cossanDisp('===================================================================',2);
OpenCossan.cossanDisp([ class(Xobj) ' Object  -  Description: ' Xobj.Sdescription],1);
OpenCossan.cossanDisp('===================================================================',2);
% 1.2.   main paramenters
OpenCossan.cossanDisp(['* '  num2str(Xobj.Nresponse) ' responses'],3)
OpenCossan.cossanDisp(['* ASCII file: ' Xobj.Srelativepath Xobj.Sfile],3) 

% 1.3.  Response details
for i=1:length(Xobj.Coutputnames)
    OpenCossan.cossanDisp(['** Response #' num2str(i) ', Output Name: ' Xobj.Coutputnames{i} ],1) ;
end




