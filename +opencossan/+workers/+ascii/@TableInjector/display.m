function display(Xobj)
% DISPLAY Show the summary of the TableInjector 
%
% See also: https://cossan.co.uk/wiki/index.php/@TableInjector
%
% Copyright~1993-2013,~COSSAN~Working~Group
%
% Author:Edoardo Patelli
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

%%   Output to Screen
%  Name and description
opencossan.OpenCossan.cossanDisp('===================================================================',2);
opencossan.OpenCossan.cossanDisp([' Object ' class(Xobj) ' -  Description: ' Xobj.Sdescription],1);
opencossan.OpenCossan.cossanDisp('===================================================================',2);

if strcmp(Xobj.Sdescription,'Empty Object')
    return
end

% 1.2.   main paramenters
opencossan.OpenCossan.cossanDisp(['* Number of Input variables: ' num2str(Xobj.Nvariable) ],1);
opencossan.OpenCossan.cossanDisp(['* ASCII file: ' Xobj.Srelativepath Xobj.Sfile ],1);
opencossan.OpenCossan.cossanDisp(['* Format: ' Xobj.Stype ],1);



