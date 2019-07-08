function [Tout,LsuccessfulExtract] = extract(Xc,varargin)
%  Extract the output values from OUTPUT ASCII FILE
%
% See Also: http://cossan.co.uk/wiki/index.php/extract@Connector
%
% $Copyright~1993-2014,~COSSAN~Working~Group,~University~of~Liverpool,~UK$
% $Author: Edoardo Patelli and Matteo Broggi$

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

%% Update input files

% initialize variables
Tout=struct;
VLsuccessfullExtract = true(size(Xc.Lextractors));

if ~any(Xc.Lextractors)
    OpenCossan.cossanDisp('[COSSAN-X.Connector.extract] No extractor defined',2)    
    return
end

for iext=find(Xc.Lextractors)
%    OpenCossan.cossanDisp(['[COSSAN-X.Connector.extract] Current directory is: ' pwd],3)
    OpenCossan.cossanDisp(['[COSSAN-X.Connector.extract] Extracting values from file: '...
       fullfile(Xc.SfolderTimeStamp,Xc.CXmembers{iext}.Srelativepath,Xc.CXmembers{iext}.Sfile)],3)
    
    % set the extractors working directory to the same of Connector
    Xc.CXmembers{iext}.Sworkingdirectory = Xc.SfolderTimeStamp; 
    [Ttmp, VLsuccessfullExtract(iext)]= extract(Xc.CXmembers{iext},varargin{:});
    Cfields=fieldnames(Ttmp);
    CfieldTout=fieldnames(Tout);
    if ~isempty(CfieldTout)
        if any(ismember(Cfields,CfieldTout))
            error('openCOSSAN:Connector:Extract',...
                'Different extractor can not return the same fields');
        end
    end
    if ~isempty(Cfields) % if Cfields is empty, the iext extractor has no responses
        for ij=1:length(Cfields)
            Tout.(Cfields{ij})=Ttmp.(Cfields{ij});
        end
    end
end

LsuccessfulExtract = any(VLsuccessfullExtract);

