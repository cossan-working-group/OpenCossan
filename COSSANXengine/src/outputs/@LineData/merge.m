function Xobj = merge(Xobj,Xobj2)
% MERGE put together 2 LineSamplingData objects and keep the order of the
% lines to which they have been processed
%
%   MANDATORY ARGUMENTS
%   - Xobj : first LineSamplingData object
%   - Xobj2: second LineSamplingData object 
%
%   OUTPUT
%   - Xobj: object of class LineSamplingData
%
%   USAGE
%   Xobj = Xobj.merge(Xobj2);
%   Xobj = merge(Xobj,Xobj2);

% merge
% - 2 lsd objects
%
% See also: https://cossan.co.uk/wiki/index.php/merge@LineSamplingData
%
% Author: Marco de Angelis
% Institute for Risk and Uncertainty, University of Liverpool, UK
% email address: openengine@cossan.co.uk
% Website: http://www.cossan.co.uk

% =====================================================================
% This file is part of openCOSSAN.  The open general purpose matlab
% toolbox for numerical analysis, risk and uncertainty quantification.
%
% openCOSSAN is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License.
%
% openCOSSAN is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
% =====================================================================

% Argument Check
if isa(Xobj2,'LineSamplingData')
    if ~strcmp(Xobj.SperformanceFunctionName,Xobj2.SperformanceFunctionName)
        error('openCOSSAN:LineSamplingData:merge',...
            'The LineSamplingData object must have the same SperformanceFunctionName');
    end
else %isa(Xobj2,'LineSamplingOutput') || isa(Xobj2,'SimulationData')
    error('openCOSSAN:LineSamplingData:merge',...
        [ Xobj2 ' is not a LineSamplingData object']);
end

% Create structure of values Tvalues (property of the super-class)
if ~isa(Xobj.Xsimulator,'AdvancedLineSampling')
    ClineNames=fieldnames(Xobj.Tlines);
    VBatches1=[Xobj.Tdata.ibatch];
    VBatches2=[Xobj2.Tdata.ibatch];
    if strcmp(ClineNames{1},'Line_0') && length(ClineNames)==2
        Cnames=fieldnames(Xobj2.Tvalues);
        CTvalues1=struct2cell(Xobj.Tvalues(:));
        Mvalues1=transpose(cell2mat(CTvalues1));
        CTvalues2=struct2cell(Xobj2.Tvalues(:));
        Mvalues2=transpose(cell2mat(CTvalues2));
        Mvalues=[Mvalues1;Mvalues2];
        Xobj.Tvalues=...
            transpose(cell2struct(num2cell(Mvalues),Cnames,2));
    elseif VBatches1(end)~=VBatches2(end)
        Cnames=fieldnames(Xobj2.Tvalues);
        CTvalues1=struct2cell(Xobj.Tvalues(:));
        Mvalues1=transpose(cell2mat(CTvalues1));
        CTvalues2=struct2cell(Xobj2.Tvalues(:));
        Mvalues2=transpose(cell2mat(CTvalues2));
        Mvalues=[Mvalues1;Mvalues2];
        Xobj.Tvalues=...
            transpose(cell2struct(num2cell(Mvalues),Cnames,2));
    end
else
    Cnames=fieldnames(Xobj2.Tvalues);
    CTvalues1=struct2cell(Xobj.Tvalues(:));
    Mvalues1=transpose(cell2mat(CTvalues1));
    CTvalues2=struct2cell(Xobj2.Tvalues(:));
    Mvalues2=transpose(cell2mat(CTvalues2));
    Mvalues=[Mvalues1;Mvalues2];
    Xobj.Tvalues=...
        transpose(cell2struct(num2cell(Mvalues),Cnames,2));
end


% Merge the reference points
Xobj.MrandReferencePoints=...
    [Xobj.MrandReferencePoints,Xobj2.MrandReferencePoints];

% Merge state points
Xobj.CMstatePoints{end}=[Xobj.CMstatePoints{end},...
    Xobj2.CMstatePoints{1}];

% Extract names and properties from the first object
CTlines1=struct2cell(Xobj.Tlines);
Tdata1=[CTlines1{:}];
CSlinesNames1=fieldnames(Xobj.Tlines);
% Extract properties from the second object
CTlines2=struct2cell(Xobj2.Tlines);
Tdata2=vertcat(CTlines2{:});
        
% Initialise cell of names
CSlinesNames2=cell(length(CTlines2),1);
% Create sequence of names in sequential order
if ~str2double(CSlinesNames1{1}(end))
    CSlinesNames2{1}=strcat('Line_',num2str(length(CSlinesNames1)));
    for iNames2=2:length(CSlinesNames2)
        CSlinesNames2{iNames2}=strcat('Line_',num2str(length(CSlinesNames1)+iNames2-1));
    end
else
    for iNames2=1:length(CSlinesNames2)
        CSlinesNames2{iNames2}=strcat('Line_',num2str(length(CSlinesNames1)+iNames2));
    end
end


if ~isempty(Xobj2.Nlines)
    % Update the line indexes
    for iLine=1:length(CTlines2)
        if CTlines2{iLine}.lineIndex~=0
            CTlines2{iLine}.lineIndex=...
                CTlines2{iLine}.lineIndex;%+max([Tdata1.lineIndex]);
        end
    end
end


% Update the important direction
Vnorm=horzcat(Tdata1.normStatePoint,Tdata2.normStatePoint);
Malpha=horzcat(Tdata1.Valpha,Tdata2.Valpha);
[~,minPos]=min(Vnorm);
Valpha=Malpha(:,minPos);
Xobj.VimportantDirection=Valpha;

% Merge the cell arrays
CSlinesNames=[CSlinesNames1;CSlinesNames2];
CTlines=[CTlines1;CTlines2];

% Create data structure 
Xobj.Tlines=cell2struct(CTlines,CSlinesNames);
Xobj.Tdata=vertcat(CTlines{:});

% SET THESE AS DEPENDENT PRPERTIES IN CONSTRUCTOR
% Evaluate total number of lines
Xobj.NprocessedLines=length(fieldnames(Xobj.Tlines));
%Xobj.Nlines=sum([Xobj.Tdata.lineIndex]~=0);
Xobj.NeffectiveLines=sum([Xobj.Tdata.stateFlag]<3)-...
    (Xobj.NprocessedLines-Xobj.Nlines);
Xobj.NcrossingLines=sum([Xobj.Tdata.stateFlag]<3);
if isa(Xobj.Xsimulator,'AdvancedLineSampling')
    Xobj.NdirectionUpdates=sum([Xobj.Tdata.LupdateDirection]);
end
