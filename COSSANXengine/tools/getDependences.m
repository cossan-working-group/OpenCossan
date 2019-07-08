function [CtoolboxRequired, Cfiles]=getDependences(CfileList)
% This function identify the Matlab toolboxes required by OpenCossan.
%
% Author: Edoardo Patelli
% Cossan Working Gorup
% email address: openengine@cossan.co.uk
% Website: http://www.cossan.co.uk

% =====================================================================
% This file is part of OpenCossan.  The open general purpose matlab
% toolbox for numerical analysis, risk and uncertainty quantification.
%
% OpenCossan is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License.
%
% OpenCossan is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
% =====================================================================

Cfiles=CfileList(1);
CtoolboxRequired=dependencies.toolboxDependencyAnalysis(CfileList{1});
 
for n=2:length(CfileList)
    CtoolboxTmp=dependencies.toolboxDependencyAnalysis(CfileList{n});    
    
    if any(~ismember(CtoolboxTmp,CtoolboxRequired))
        % Store the name of file requiring that specific toolbox
        Cfiles(end+1)=CfileList(n); %#ok<AGROW>
        CtoolboxRequired=[CtoolboxRequired  CtoolboxTmp(~ismember(CtoolboxTmp,CtoolboxRequired))]; %#ok<AGROW>
    end
    
    
end

