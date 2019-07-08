function display(Xobj)
%DISPLAY  Displays the summary of the Model

% See also: https://cossan.co.uk/wiki/index.php/@Model
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

%% Name and description
OpenCossan.cossanDisp('===================================================================',2);
OpenCossan.cossanDisp([ class(Xobj) ' Object  - Description: ' Xobj.Sdescription ],2);
OpenCossan.cossanDisp('===================================================================',2);
if isempty(Xobj.Xinput)
    OpenCossan.cossanDisp('Empty Model ',1)
else
    
OpenCossan.cossanDisp(['Required Inputs  : ',sprintf(' %s;',Xobj.Cinputnames{:})], 2)
OpenCossan.cossanDisp(['Provided Outputs : ',sprintf(' %s;',Xobj.Coutputnames{:})], 2)
OpenCossan.cossanDisp(['The Model contains ', num2str(length(Xobj.Xevaluator.CXsolvers)) ' solvers' ],2)

end
