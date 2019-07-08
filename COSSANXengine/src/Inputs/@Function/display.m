function display(Xobj)
%DISPLAY  Displays the Function object
%
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


OpenCossan.cossanDisp('===================================================================',2);
OpenCossan.cossanDisp([ class(Xobj) ' -  Description: ' Xobj.Sdescription ],1);
OpenCossan.cossanDisp('===================================================================',2);
OpenCossan.cossanDisp(['* expression: ' Xobj.Sexpression ],2);
OpenCossan.cossanDisp(['* Required inputs: ' sprintf('"%s" ',Xobj.Cinputnames{:})],2);

