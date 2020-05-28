function dos2unix(fileName)
% dos2unix
%   Detailed explanation goes here

[Nfid, Serror] = fopen(fileName,'r'); % open ASCII file
            
if Nfid<0
    error('openCOSSAN:utilities:dos2unix',...
        ['The file' fileName ' does not exist. ' Serror ])
end
            
% remove the wrong line termination that can be included in a
% file if it was created/modified in windows
Vbytes = fread(Nfid,'uint8=>uint8');
fclose(Nfid);
% remove the CR ascii character
Vbytes(Vbytes==uint8(13))=[];
% write back the file
Nfid = fopen(fileName,'w');
fwrite(Nfid,Vbytes,'uint8');
fclose(Nfid);

end

