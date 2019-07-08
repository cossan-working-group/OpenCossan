function Xobj = update(Xobj,Xobj2)
% UPDATE is a method that updates the properties of a line in the object 
% "Xobj" from the properties of the line in the oject "Xobj2". This is 
% performed only if the lines have the same index.
%
%   MANDATORY ARGUMENTS
%   - Xobj : firts LineSamplingData object
%   - Xobj2: second LineSamplingData object 
%
%   OUTPUT
%   - Xobj: object of class LineSamplingData
%
%   USAGE
%   Xobj = Xobj.update(Xobj2);
%   Xobj = update(Xobj,Xobj2);

% update
% - 2 lsd objects

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
    error('openCOSSAN:LineSamplingData:update',...
        [ Xobj2 ' is not a LineSamplingData object']);
end


VlineIndexes=[Xobj.Tdata.lineIndex];
VlineIndexes2=[Xobj2.Tdata.lineIndex];


if ~any(VlineIndexes==VlineIndexes2)
   error('openCOSSAN:LineSamplingData:update',...
        'The object %i can only be updated if its indexes already exist in the original object %i',class(Xobj2),class(Xobj));    
end


CTlines=struct2cell(Xobj.Tlines);
CSlinesNames=fieldnames(Xobj.Tlines);
CTlines2=struct2cell(Xobj2.Tlines);

% This procedure updates all the properties but keep both state points
for iIndex=1:length(VlineIndexes2)
    lineIndex=VlineIndexes2(iIndex);
    iLine= VlineIndexes==lineIndex;
    CT=CTlines(iLine);
    CT2=CTlines2(iIndex); 
    T=CT{1};
    T2=CT2{1};
    T2.CVstatePoints{2}=T.CVstatePoints{1}; % Merge the state points, if any
    T2.NlinePoints=T.NlinePoints+T2.NlinePoints;
    T2.Nreprocessed=T.Nreprocessed+1;
    CTlines(iLine)={T2};
end

% Create line structure
Xobj.Tlines=cell2struct(CTlines,CSlinesNames);
% Create data structure 
Xobj.Tdata=[CTlines{:}];

% Update the important direction
Vnorm=[Xobj.Tdata.normStatePoint];
Malpha=[Xobj.Tdata.Valpha];
[~,minPos]=min(Vnorm);
Valpha=Malpha(:,minPos);
Xobj.VimportantDirection=Valpha;


