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

if length(Xobj)>1
    opencossan.OpenCossan.cossanDisp('===================================================================',3);
    opencossan.OpenCossan.cossanDisp([' Dataseries object  '],3);
    opencossan.OpenCossan.cossanDisp('===================================================================',3);
    opencossan.OpenCossan.cossanDisp(['* Array of ' num2str(size(Xobj,2)) ' Dataseries'],2);
    Vdatalengths=[Xobj.VdataLength];
    opencossan.OpenCossan.cossanDisp(['* Dataseries lengths  : ' num2str(Vdatalengths(1:(min(10,length(Vdatalengths))))) ],2);
else    
    %% Name and description
    opencossan.OpenCossan.cossanDisp('===================================================================',3);
    opencossan.OpenCossan.cossanDisp([' Dataseries object  -  Description: ' Xobj.Sdescription ],1);
    opencossan.OpenCossan.cossanDisp('===================================================================',3);
    opencossan.OpenCossan.cossanDisp(['* Dataseries lengths  : ' num2str(Xobj.VdataLength) ],2);
end
    opencossan.OpenCossan.cossanDisp(['* Number of Samples   : ' num2str(Xobj(1).Nsamples) ],2);
    
return;
