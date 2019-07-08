function display(Xobj)
%DISPLAY  Displays the summary of the Gradient object
%
% See also: http://cossan.co.uk/wiki/index.php/@Gradient
%
% $Copyright~1993-2014,~COSSAN~Working~Group,~University~of~Liverpool,~UK$
% $Author: Edoardo-Patelli$

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

%% Set parameters
Nmaxcomponents=5;

%  Name and description
OpenCossan.cossanDisp('===================================================================',3);
OpenCossan.cossanDisp([' Gradient Object  -  Name: ' inputname(1)],1);
OpenCossan.cossanDisp('===================================================================',3);

OpenCossan.cossanDisp(['* Function Name: ' Xobj.SfunctionName],1);
if Xobj.LstandardNormalSpace
    OpenCossan.cossanDisp('* Perturbation points defined in the Standard Normal Space ',2);
else
    OpenCossan.cossanDisp('* Perturbation points defined in the Physical Space ',2);
end
%OpenCossan.cossanDisp(['* Reference Point: ' num2str(Xobj.VreferencePoint) ],2);
OpenCossan.cossanDisp('* Gradient Components (reference coordinate): ',2);
for ik=1:min(Nmaxcomponents,length(Xobj.Cnames))
    OpenCossan.cossanDisp(['** ' Xobj.Cnames{ik} ': ' sprintf('%10.3e',Xobj.Vgradient(ik)) ' (' sprintf('%9.3e',Xobj.VreferencePoint(ik)) ')' ],2);
end

if length(Xobj.Cnames)>Nmaxcomponents
    OpenCossan.cossanDisp(['* ' num2str(length(Xobj.Cnames)) ' components presents' ],2);
end

OpenCossan.cossanDisp(['* Function evaluations: ' num2str(Xobj.Nsamples) ],2);
