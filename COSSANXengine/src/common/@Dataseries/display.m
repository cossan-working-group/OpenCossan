function display(Xobj)
%DISPLAY  Displays the object DataSeries
%
% See also: https://cossan.co.uk/wiki/index.php/@Dataseries
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

if size(Xobj,2)>1
    OpenCossan.cossanDisp('===================================================================',3);
    OpenCossan.cossanDisp([' Dataseries object  '],3);
    OpenCossan.cossanDisp('===================================================================',3);
    OpenCossan.cossanDisp(['* Array of ' num2str(size(Xobj,1)) 'x' num2str(size(Xobj,2)) ' Dataseries'],2);
    Vdatalengths=[Xobj.VdataLength];
    OpenCossan.cossanDisp(['  - Dataseries lengths  : ' num2str(Vdatalengths(1:size(Xobj,1):(min(10,length(Vdatalengths))))) ],2);
else    
    %% Name and description
    OpenCossan.cossanDisp('===================================================================',3);
    OpenCossan.cossanDisp([' Dataseries object  -  Description: ' Xobj(1).Sdescription ],1);
    OpenCossan.cossanDisp('===================================================================',3);
    OpenCossan.cossanDisp(['  - Dataseries lengths  : ' num2str(Xobj(1).VdataLength) ],2);
end
    OpenCossan.cossanDisp(['  - Number of Samples   : ' num2str(size(Xobj,1)) ],2);
    
return;
