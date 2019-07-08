function Xobj = add(Xobj,varargin)
%ADD method add data to a LineSamplingData object
%
%   OPTIONAL ARGUMENTS:
%   ====================
%   - 
%
%   OUTPUT ARGUMENT:
%   ====================
%   Xobj: LineSamplingData object
%
%
%   USAGE
%   ====================
%   Xobj  =add(Xobj,'McartRand',McartRand)
%   Xobj  =Xobj.add('McartRand',McartRand)
    
%% Validate input arguments
OpenCossan.validateCossanInputs(varargin{:});

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'mrandreferencepoints'}
            McartRand=varargin{k+1};
        case 'vreferencepoint'
            VreferencePoint=varargin{k+1};
        case 'linerank'
            lineRank=varargin{k+1};   
        case 'lineindex'
            lineIndex=varargin{k+1};
        case 'ibatch'
            ibatch=varargin{k+1};
        otherwise
            error('openCOSSAN:LineSamplingData:addVariable',...
                'Field name not allowed');
    end
end %for k

%% Add properties 
if exist('McartRand','var')
    Xobj.MrandReferencePoints=McartRand;
    assert(size(Xobj.MrandReferencePoints,1)==Xobj.Nvars,...
        'openCOSSAN:LineSamplingData:addVariable',...
        'The property <<%s>> must have the number of rows equal to the number of Variables',...
        'MrandReferencePoints')
end

if exist('VreferencePoint','var')
    CTline=struct2cell(Xobj.Tlines);
    CSname=fieldnames(Xobj.Tlines);
    if length(CTline)==1
        Tline=CTline{1};
        Tline.VreferencePoint=VreferencePoint;
        Xobj.Tlines=struct(CSname{1},Tline);
    else
       error('openCOSSAN:LineSamplingData:addVariable',...
        'Property "%s" cannot be added',...
        'VreferencePoint') 
    end
end

if exist('ibatch','var')
    CTline=struct2cell(Xobj.Tlines);
    CSname=fieldnames(Xobj.Tlines);
    if length(CTline)==1
        Tline=CTline{1};
        Tline.ibatch=ibatch;
        Xobj.Tlines=struct(CSname{1},Tline);
    else
       error('openCOSSAN:LineSamplingData:addVariable',...
        'Property "%s" cannot be added',...
        'ibatch') 
    end
end


if exist('lineRank','var')
    assert(logical(exist('lineIndex','var')),...
        'openCOSSAN:LineSamplingData:addVariable',...
        'In order to add a line rank a line index is mandatory');
    
    VlineIndexes=[Xobj.Tdata.lineIndex];
    iLine= VlineIndexes==lineIndex;
    
    CTlines=struct2cell(Xobj.Tlines);
    CSlinesNames=fieldnames(Xobj.Tlines);
    
    CT=CTlines(iLine);
    T=CT{1};
    T.lineRank=lineRank;
    CTlines(iLine)={T};
    
    % Recreate line structure
    Xobj.Tlines=cell2struct(CTlines,CSlinesNames);
    % Create data structure
    Xobj.Tdata=[CTlines{:}];
end
