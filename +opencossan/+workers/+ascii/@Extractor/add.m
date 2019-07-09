function Xobj = add(Xobj,varargin)
%ADD  add a response to the extract object
%
%   Arguments:
%   ==========
%
%   MANDATORY ARGUMENTS:
%      - Xobj (extractor object)
%      - Sname Name of the associate COSSAN variables
%
%   OPTIONAL ARGUMENTS:
%   - Sfieldformat:       Index of the variable (only for vector and matrix)
%   - Clookoutfor:        if present define the string to be searched inside
%                         the ASCII file in order to define the relative position  Format string
%   - Svarname:           if present Ncolnum and Nrownum are relative respect to the
%                         variable present in Cvarname
%   - Ncolnum:            Colum position in the ASCII file of the variables
%   - Nrownum:            Row  position in the ASCII file of the variables
%   - Sregexpression:     Regular expression
%   - Nrepeat:            Repeat the extraction Nrepeat times (default=1)
%   - Xresponse:          object of class Response
%
%   EXAMPLES:
%   Usage:  Xe  =add(Xe,'Sname','Out1','Sfieldformat','%8.2e','Ncolnum',1,Nrownum,2)
%       
%           Xresponse = Response('Sname','Out1','Sfieldformat','%8.2e','Ncolnum',1,Nrownum,2);
%           Xe  = add(Xe,'Xresponse',Xresponse);
%
% =====================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2008 IfM
% =====================================================
%
%   see also: add, remove, edit , extractor

%% 1. Processing Inputs

% Process all the optional arguments and assign them the corresponding
% default value if not passed as argument
% Check consistency of the input vector
if rem(length(varargin),2)~=0
    error('The optional parameters must be passed an pair (name,value)');
end


Cresponseproperties={};
for iVopt=1:2:length(varargin)
    if strcmpi(varargin{iVopt},'Xresponse')
        % if a response object is passed to the constructor
        Xresponse = varargin{iVopt+1};
    else
        % create the Response from the input parameters passed in pairs
        switch lower(varargin{iVopt})
            case {'sname','sfieldformat','clookoutfor','svarname',...
                    'sregexpression','ncolnum','nrownum','nrepeat'}
                warning('openCOSSAN:Extractor','Passing response information to Extractor add is deprecated and will be discontinued. Please add a Response object instead')
                Cresponseproperties{end+1} = varargin{iVopt};    %#ok<AGROW>
                Cresponseproperties{end+1} = varargin{iVopt+1};  %#ok<AGROW>
            otherwise
                warning('openCOSSAN:Extractor',['optional parameter ' num2str(varargin{iVopt}) ' ignored']);
        end
        Xresponse = Response(Cresponseproperties{:});
    end
end

%% 2. Add the response to the extractor
% Check if the output is already present in the connector
for i=1:Xobj.Nresponse
    if strcmpi(Xresponse.Sname,Xobj.Xresponse(i).Sname)
        error('openCOSSAN:Extractor:add',['Output ' Xobj.Xresponse(i).Sname ' is already present in Extractor'])
    end
end

if isempty(Xobj.Xresponse)
    Xobj.Xresponse = Xresponse;
else
    Xobj.Xresponse(end+1) = Xresponse;
end

end
