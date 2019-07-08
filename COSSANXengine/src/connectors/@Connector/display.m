function display(Xobj)
%DISPLAY  Displays the summary of the connector object
%  USAGE:  DISPLAY(Xobj)
%
%   Example: DISPLAY(Xobj) will output the summary of the
%                                connector Xobj
%

OpenCossan.cossanDisp( '----------------------------------------------------------------- ',1);
OpenCossan.cossanDisp([' Connector Object  -  Type: ' Xobj.Stype],1);   
OpenCossan.cossanDisp([' ' Xobj.Sdescription ],1);
OpenCossan.cossanDisp(' '),1;

%% show pre- and post-processors
if ~isempty(Xobj.SpreExecutionCommand)
    OpenCossan.cossanDisp([' PRE execution commands:  ' Xobj.SpreExecutionCommand],1);
end

if ~isempty(Xobj.SpostExecutionCommand)
    OpenCossan.cossanDisp([' POST execution commands: ' Xobj.SpostExecutionCommand],1);
end

OpenCossan.cossanDisp( '----------------------------------------------------------------- ',1);

%% show injectors names
if any(Xobj.Linjectors)
    OpenCossan.cossanDisp(' Injectors: ',1);
    iinjector = 1;
    for i=1:length(Xobj.CXmembers)
        if Xobj.Linjectors(i)
            OpenCossan.cossanDisp([num2str(iinjector) ') ' Xobj.CSmembersNames{i} ' - ' Xobj.CXmembers{i}.Sdescription ' File: ' Xobj.CXmembers{i}.Sfile ],1);
            iinjector = iinjector+1;
        end
    end
else
    OpenCossan.cossanDisp(' No injector defined ',1);
end


%% show Extractor names
if any(Xobj.Lextractors)
    OpenCossan.cossanDisp(' Extractors: ',1);
    iextractor = 1;
    for i=1:length(Xobj.CXmembers)
        if Xobj.Lextractors(i)
            OpenCossan.cossanDisp([num2str(iextractor) ') ' Xobj.CSmembersNames{i} ' - ' Xobj.CXmembers{i}.Sdescription ' File: ' Xobj.CXmembers{i}.Sfile ],1);
            iextractor = iextractor+1;
        end
    end
else
    OpenCossan.cossanDisp(' No extractor defined ',1);
end

