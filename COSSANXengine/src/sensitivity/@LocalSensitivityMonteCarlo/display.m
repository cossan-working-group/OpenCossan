function display(Xobj)
%DISPLAY  This method displays a summary of the LocalSensitivityMonteCarlo
%object 
%
% USAGE
% display(XOBJ)
%
% See also: https://cossan.co.uk/wiki/index.php/@LocalSensitivityMonteCarlo
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

OpenCossan.cossanDisp('===================================================================',3);
OpenCossan.cossanDisp([' ' class(Xobj) ' Object  -  Description: ' Xobj.Sdescription],1);
OpenCossan.cossanDisp('===================================================================',3);

if ~isempty(Xobj.Xtarget)
    OpenCossan.cossanDisp(['* Sensitivity for model object of class ',class(Xobj.Xtarget)],1);
else
    OpenCossan.cossanDisp('* No target object defined',1);
end

if ~isempty(Xobj.Coutputnames)
    OpenCossan.cossanDisp(['* Sensitivity for output variables: ', sprintf('%s ',Xobj.Coutputnames{:})],1);
end
    
if ~isempty(Xobj.Cinputnames)
    OpenCossan.cossanDisp(['* Sensitivity for input variables ', sprintf('%s ',Xobj.Cinputnames{:})],1);
end
       
if isempty(Xobj.VreferencePoint)
    OpenCossan.cossanDisp('* Reference Point: NOT DEFINED',1);
else
    OpenCossan.cossanDisp(['* Reference Point: ' sprintf('%9.3e ',Xobj.VreferencePoint) ],1);
end

OpenCossan.cossanDisp('----------------------------------------------------',3);
OpenCossan.cossanDisp(['* Indices computed by finite difference: ',sprintf('%i ',Xobj.NindiciesFD)],2);
OpenCossan.cossanDisp(['* Maximum number of compontents wrongly computed : ',sprintf('%i ',Xobj.NmaxFailure)],2);
OpenCossan.cossanDisp(['* Increment of the sample set : ',sprintf('%i ',Xobj.NdeltaSampleSet)],2);
OpenCossan.cossanDisp(['* Maximum size of the sample set : ',sprintf('%i ',Xobj.NsamplesSize)],2);
OpenCossan.cossanDisp('----------------------------------------------------',3);
if isempty(Xobj.Valpha)
    OpenCossan.cossanDisp('* Initial direction : not available',2);
else
    OpenCossan.cossanDisp(['* Initial direction : ',sprintf('%f ',Xobj.Valpha)],2);
end

        
        
        
        
        
