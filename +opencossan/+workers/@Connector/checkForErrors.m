function [ LerrorFound ] = checkForErrors(Xobj)
%CHECKFORERRORS check if the FE software have returned an error
%   The private method checkForErrors of Connector search the FE output/log
%   file, of name equals to the one specified in the property
%   SmainInputFile and extension specified in SerrorFileExtension, for a
%   particular string, specified in SerrorString. The presence of this
%   string identify that the FE solver was not succeffully executed.

if ~isempty(Xobj.SerrorFileExtension)
    [~,SfileName,~] = fileparts(Xobj.Smaininputfile);
    SerrorFile = [fullfile(Xobj.SfolderTimeStamp,SfileName) '.' Xobj.SerrorFileExtension];
    
    Nfid = fopen(SerrorFile,'r');
    
    if Nfid==-1
        % Workaround for the latency of the filesystem
        OpenCossan.cossanDisp('Failing to open the file, trying again',1)
        pause(1)
        Nfid = fopen(SerrorFile,'r');
        if Nfid==-1
            OpenCossan.cossanDisp('Failed again, trying again',1)
            LerrorFound=true;
            return
        end
    end
    
    NfoundError=[];
    while isempty(NfoundError)
        tline = fgetl(Nfid);
        if ~ischar(tline),
            break
        end
        NfoundError = regexp(tline, Xobj.SerrorString, 'end');
    end
    
    if ~isempty(NfoundError)
        warning('openCOSSAN:Connector:checkForErrors','FE solver exited with an error!');
        LerrorFound = true;
    else
        LerrorFound = false;
    end
    
    fclose(Nfid);
else
    LerrorFound = false;
end

end
