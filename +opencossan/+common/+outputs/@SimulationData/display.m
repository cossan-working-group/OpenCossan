function display(Xobj)
%DISPLAY  Displays the object SimulationData
%
%
% See also: https://cossan.co.uk/wiki/index.php/@SimulationData
%
% Author: Edoardo Patelli
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
import opencossan.*
% Import?

import opencossan.*

%% Output to Screen
% Name and description
opencossan.OpenCossan.cossanDisp('===================================================================',2);
opencossan.OpenCossan.cossanDisp([ class(Xobj) ' Object  - Description: ' Xobj.Sdescription ],2);
opencossan.OpenCossan.cossanDisp('===================================================================',2);
% main paramenters
opencossan.OpenCossan.cossanDisp(['* Number of Variables: ' num2str(width(Xobj.TableValues))],2)
if width(Xobj.TableValues)<=50
    opencossan.OpenCossan.cossanDisp(['**',sprintf(' %s;',Xobj.Cnames{:})], 2)
end

for iout=1:length(Xobj)
    opencossan.OpenCossan.cossanDisp(['* Batch: ' num2str(iout) ' - Number of realizations: ',  num2str(Xobj(iout).Nsamples) ],2)
end

opencossan.OpenCossan.cossanDisp(['* Exit Flag: ' Xobj.SexitFlag ],2)

if ~isempty(Xobj.SbatchFolder)
    opencossan.OpenCossan.cossanDisp(['* Batches stored in the folder: ' Xobj.SbatchFolder ],2)
end

if Xobj.NmissingData==0
    opencossan.OpenCossan.cossanDisp('* No missing Data in the object',2)
else
    opencossan.OpenCossan.cossanDisp(['* ' num2str(Xobj.NmissingData) ' missing Data in the object'],2)
end

