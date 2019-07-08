function display(Xobj)
%DISPLAY  Displays the summary of the ProbabilisticModel
%   DISPLAY(Xobj)
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@ProbabilisticModel
%
% $Copyright~1993-2013,~COSSAN~Working~Group,~University~of~Liverpool,~UK$
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

%% Xmodel object
% plot description of the Model
if isempty(Xobj.Xmodel)
	OpenCossan.cossanDisp('   * Empty object',2)
else
    
    if isempty(Xobj.Xmodel.Xevaluator.CXsolvers)
        OpenCossan.cossanDisp('  * No evaluators defined',2);
    else
        OpenCossan.cossanDisp(['  * Model object: ' Xobj.Xmodel.Sdescription ],2);
    end
    OpenCossan.cossanDisp(['  * PerformanceFunction object: ' Xobj.XperformanceFunction.Sdescription ],2);
end
% plot description of the PerformanceFunction
if length(Xobj.Cinputnames)<2
    OpenCossan.cossanDisp(['Required Inputs  : ',sprintf(' %s;',Xobj.Cinputnames{:})], 2)
else
    OpenCossan.cossanDisp(sprintf('Required Inputs  : %i (names not displayed) ',length(Xobj.Cinputnames)), 2)
end

if length(Xobj.Coutputnames)<20
    OpenCossan.cossanDisp(['Required Outputs : ',sprintf(' %s;',Xobj.Coutputnames{:})], 2)
else
    OpenCossan.cossanDisp(sprintf('Required Outputs : %i (names not displayed) ',length(Xobj.Coutputnames)), 2)
end


