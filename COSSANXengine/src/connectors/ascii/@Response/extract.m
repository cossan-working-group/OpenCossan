function [Toutput,TfileInfo,LresponseSuccess] = extract(Xresponse,varargin)
%EXTRACT This function extract the responce from the file defined in the
%Extractor.
%
% The extractor is composed by two phases. First the right position in the
% file is identified and then the values are extracted.

% Initialise parameters
LresponseSuccess=true;
Nsimulation=1;

%% Processing Inputs
OpenCossan.validateCossanInputs(varargin{:});
for iopt=1:2:length(varargin)
    switch lower(varargin{iopt})
        case {'nsimulation'}
            Nsimulation = varargin{iopt+1};
        case {'nfid'}
            Nfid = varargin{iopt+1};
        case {'tresponseposition','tfileinfo'}
            TfileInfo = varargin{iopt+1};       
        otherwise
            warning('OpenCossan:Response:extract:wrongOption',...
                ['Optional parameter ' varargin{iopt} ' not allowed']);
    end
end

assert(logical(exist('TfileInfo','var')),...
    'OpenCossan:Response:extract:noTfileInfo',...
    'It is necessary to provide the TfileInfo property')

Moutput=[];
%% Identify relative position 

nrep=1;

while nrep<=Xresponse.NrepeatAnchor

    TfileInfo = findRelativePosition(Xresponse,Nfid,TfileInfo);

    if strcmp(TfileInfo.status,'completed')
        break
    end
    
    if isfield(TfileInfo.out,Xresponse.Sname)  
        if isnan(TfileInfo.out.(Xresponse.Sname))
            MoutputResponse=NaN;
        else
            % Read using relative position
             [MoutputResponse,TfileInfo]= readResponse(Xresponse,Nfid,TfileInfo);
        end
    else
        % Use absolute position
       [MoutputResponse,TfileInfo]= readResponse(Xresponse,Nfid,TfileInfo);
    end  
    
    if ~isempty(Xresponse.VcoordRow)
        Moutput=[Moutput, MoutputResponse]; %#ok<AGROW>
    else
        % Merging output
        Moutput=[Moutput; MoutputResponse]; %#ok<AGROW>
    end
    
    nrep=nrep+1;
end

if any(isnan(Moutput))
    LresponseSuccess=false;
end

% Associate read value with the output parameter
try
    OpenCossan.cossanDisp(['[OpenCossan:Response:extract] Response' Xresponse.Sname ': ' ],4 )
    OpenCossan.cossanDisp('[OpenCossan:Response:extract] Value(s) extracted: ' ,4 )
    if OpenCossan.getVerbosityLevel>3
        disp(Moutput)
    end
    % check the size of Moutput to assign to the right object
    if numel(Moutput)==1
        % Moutput is a scalar, thus it is saved directly in the output
        % structure
        Toutput.(Xresponse.Sname)=Moutput;
    else
        % Moutput is a vector/matrix, thus it is saved in a Dataseries
        % according to the properties of the response object
        Toutput.(Xresponse.Sname)= Xresponse.createDataseries(Moutput);
    end
catch ME
    OpenCossan.cossanDisp(['[OpenCossan:Response:extract] Failed to associate extracted value to the output ( ' ME.message ')' ],4 )
    Toutput.(Xresponse.Sname)=NaN;
    LresponseSuccess=false;
end
% save the position of the last extracted value
TfileInfo.out.(Xresponse.Sname)=ftell(Nfid);

end

