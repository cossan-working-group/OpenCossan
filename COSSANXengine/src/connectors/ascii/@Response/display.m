function display(Xobj)
%DISPLAY 
%
%
%   Example: DISPLAY(Xobj) will output the summary of the Response object
% =========================================================================
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


OpenCossan.cossanDisp([' Name: ' Xobj.Sname ]) ;

if ~isempty(Xobj.Clookoutfor)
    for ilook=1:length(Xobj.Clookoutfor)
        OpenCossan.cossanDisp([' #' num2str(ilook) ' Position relative to the string: ' Xobj.Clookoutfor{ilook}])
    end
elseif ~isempty(Xobj.Svarname)
    OpenCossan.cossanDisp([' Position relative to the response: ' Xobj.Svarname ])
else
    OpenCossan.cossanDisp(' Absolute Position')
end

OpenCossan.cossanDisp([' Col: ' num2str(Xobj.Ncolnum) '; Row: '   ...
    num2str(Xobj.Nrownum) '; Format: ' ...
    Xobj.Sfieldformat '; Repeat: ' num2str(Xobj.Nrepeat)]) ;

end