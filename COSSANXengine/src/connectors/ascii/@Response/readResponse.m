function [Moutput,TfileInfo] = readResponse(Xresponse,Nfid,TfileInfo)
%READRESPONSE Summary of this function goes here
%   Detailed explanation goes here

Moutput=[]; % initialise the output matrix for each response.

% introduce countdown counter for support for both finite and infinite
% Nrepeat (infinite means repeat until the end of the file)

iRow=1;
while iRow<=Xresponse.Nrepeat
    % Read data form text file using the format specified in the
    % Response. File data might be returned as a column vector, matrix,
    % character vector or character array. However, only numerical
    % values are accepted by OpenCossan

    tline=fgetl(Nfid);
    % Store the position
    TfileInfo.Vpos(end+1)=ftell(Nfid);
    
    if ~ischar(tline) || isempty(tline)
        if ~isinf(Xresponse.Nrepeat)
            warning('OpenCossan:Response:readResponse',...
            'End of file reached or empty string identified while looking extracting values response %s repetition %i \n',...
            Xresponse.Sname,Xresponse.Nrepeat)
        
            Moutput(iRow,:)=NaN; %#ok<AGROW>
        end
        % Do not return warning if Nrepeat is Inf 
        break
    else
        
        % and now read the variable
        MDataExtracted=sscanf(tline, Xresponse.Sfieldformat);
        
        if logical(isempty(MDataExtracted))
            warning('OpenCossan:Response:readResponse',...
                ['Extracted empty string\nLine: "%s"\nFormat: "%s" \n ' ...
                'Response: %s; Required lines: %i; Extracted Lines: %i; \n '],...
                tline,Xresponse.Sfieldformat, Xresponse.Sname,Xresponse.Nrepeat,iRow-1)
            
            Moutput(iRow,:)=NaN; %#ok<AGROW>
        else
            Moutput(iRow,:)=MDataExtracted; %#ok<AGROW>
        end        
    end
    % Process next row
    iRow=iRow+1;
end


