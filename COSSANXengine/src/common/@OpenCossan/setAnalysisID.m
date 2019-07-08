function setAnalysisID(NanalysisID)
%SETANALYSISID This static method of OpenCossan sets the analysis ID 
%
% Author: Matteo Broggi
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

global OPENCOSSAN
assert(~isempty(OPENCOSSAN),'openCOSSAN:OpenCossan',...
    'OpenCossan has not been initialize. \n Please run OpenCossan! ')
    
if nargin==0
    % if no input is given, retrieve the next available ID from the
    % database and set it into the Analysis object
    if ~isempty(OpenCossan.getDatabaseDriver)
        NanalysisID = getNextPrimaryID(OpenCossan.getDatabaseDriver,'Analysis');
    else
        % leave it empty with no db
        NanalysisID =[];
    end
end

OpenCossan.cossanDisp(['[OpenCossan.setAnalysisName] Setting analysis ID to: '...
    num2str(NanalysisID)],4);
OPENCOSSAN.Xanalysis.NanalysisID=NanalysisID;

