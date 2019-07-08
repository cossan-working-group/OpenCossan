function display(Xobj)
%DISPLAY show summary of the Indentifier object
% Support array of Identifier objects
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

for n=1:length(Xobj)
    OpenCossan.cossanDisp('---------------------------------------------------------------',3)
    OpenCossan.cossanDisp(['Identifier #' num2str(n) ' Name: ' Xobj(n).Sname '    Index: ' num2str(Xobj(n).Nindex)],2) ;
    
    
    if ~isempty(Xobj(n).Slookoutfor)
        OpenCossan.cossanDisp(['* Position relative to the string: ' Xobj(n).Slookoutfor ],3)
    else
        OpenCossan.cossanDisp('* Absolute Position',3)
    end
    
    if ~isempty(Xobj(n).Nposition)
        OpenCossan.cossanDisp(['* Format: ' ...
            Xobj(n).Sfieldformat ' -> Position: ' num2str(Xobj(n).Nposition)],3) ;
    else
        OpenCossan.cossanDisp(['* Col: ' num2str(Xobj(n).Ncolnum) ' Row: '   ...
            num2str(Xobj(n).Nrownum) ' Format: ' ...
            Xobj(n).Sfieldformat],3) ;
    end
    
    if ~isempty(Xobj(n).Sregexpression)
        OpenCossan.cossanDisp([' Regular Expression: ' Xobj(n).Sregexpression],3)
    end
    OpenCossan.cossanDisp('---------------------------------------------------------------',3)
end
