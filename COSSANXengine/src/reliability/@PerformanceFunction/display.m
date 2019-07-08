function display(Xobj)
%display  Displays the summary of the PerformanceFunction object
%   
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@PerformanceFunction
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$


%%  Output to Screen
% Name and description
OpenCossan.cossanDisp('===================================================================',3);
OpenCossan.cossanDisp([' ' class(Xobj) ' Object  -  Description: ' Xobj.Sdescription],1);
OpenCossan.cossanDisp('===================================================================',3);

%% Display Function 
if ~isempty(Xobj.Xmio),
    OpenCossan.cossanDisp(' The performance function is calculated adopting the following Mio object:',2)
    display(Xobj.Xmio)
else
    OpenCossan.cossanDisp(' The performance function defined as CAPACITY-DEMAND',2)
    OpenCossan.cossanDisp(['* CAPACITY : ' Xobj.Scapacity ],2)
    OpenCossan.cossanDisp(['* DEMAND   : ' Xobj.Sdemand ],2);
end    

if ~isempty(Xobj.stdDeviationIndicatorFunction)
    OpenCossan.cossanDisp(['* Using smooth indicator function with a spread of : '...
        num2str(Xobj.stdDeviationIndicatorFunction) ],2);
end


