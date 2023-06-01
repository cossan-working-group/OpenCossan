function [VhyperPlanePoint,lineIndex,lineIndexNext,CindexProcessedLines]=...
    projectPoints(Xobj,varargin)
%NEXTLINEINDEX
% Process the line numbers and determine the point on the orthogonal
% hyperplane to start the line from. The next line is the nearest line to
% the current line among the ones not already processed. Note that if the
% important direction is updated the distances among the lines change.

% See also: https://cossan.co.uk/wiki/index.php/AdvancedLineSampling

% Author: Marco de Angelis
% Institute for Risk and Uncertainty, University of Liverpool, UK
%% Validate input arguments
OpenCossan.validateCossanInputs(varargin{:});

for k=1:2:length(varargin)
    switch (lower(varargin{k}))
        case 'msamplesns'
            Mssns = varargin{k+1};
        case 'valpha'
            Valpha = varargin{k+1};
        case 'ldirectionalupdate'
            LupdateDirection = varargin{k+1};
        case 'iline'
            iLine = varargin{k+1};
        case 'cindexprocessedlines'
            CindexProcessedLines = varargin{k+1};
        case 'lineindexnext'
            lineIndexNext = varargin{k+1};
        otherwise
            % error, unknown property specified
            error('OpenCossan:nextLineIndex',...
                ['Field name (' varargin{k} ') not allowed']);
    end
end

%% Start processing the lines

if LupdateDirection || iLine==1
    % Project the points on the hyperplane orthogonal to the important
    % direction
    MorthHyperPlane  = transpose(Mssns - Valpha*(Valpha'*Mssns));
    
    % Start off with the nearest line to the important direction.
    [~, iSetLine]=min(sqrt(sum(MorthHyperPlane.^2,2)));
    % Compute the distance of remaining lines from the nearest one
    Vdistances = sqrt(sum((MorthHyperPlane-repmat(MorthHyperPlane(iSetLine,:),Xobj.Nlines,1)).^2,2));
    
else
    
    % Project the points on the hyperplane orthogonal to the important
    % direction. This line of code can be avoided if the variable 'MorthHyperPlane' 
    % is inputted to the method.
    MorthHyperPlane  = transpose(Mssns - Valpha*(Valpha'*Mssns));
    
    % Compute the distance of remaining lines from the current one
    Vdistances = sqrt(sum((MorthHyperPlane-repmat(MorthHyperPlane(lineIndexNext,:),Xobj.Nlines,1)).^2,2));
    
end

% Sort the lines from the nearest to the furthest from the current line.             
% Note that this order changes not only when a new direction is updated but
% also as soon as a new line is procssed.
[~, VlineOrder]=sort(Vdistances,'ascend');

% get the vector array of indexes
VindexProcessedLines=cell2mat(CindexProcessedLines);

% Remove lines that have been already processed
for iProcessedLine=1:length(VindexProcessedLines)
    posProcessedLine=find(VlineOrder==VindexProcessedLines(iProcessedLine));
    VlineOrder(posProcessedLine)=[]; %#ok<FNDSB>
end

% Select the nearest line to the current one among the ones not processed
lineIndex=VlineOrder(1);
if iLine==Xobj.Nlines
    lineIndexNext=0;
else
    lineIndexNext=VlineOrder(2);
end

% store indeces of processed lines
CindexProcessedLines{iLine}=lineIndex;

% determine the hyperplane (orthogonal to the current direction) point on the next line
VhyperPlanePoint=MorthHyperPlane(VlineOrder(1),:);