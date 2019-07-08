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
OpenCossan.cossanDisp(' ');
OpenCossan.cossanDisp('===================================================================',1);
OpenCossan.cossanDisp([' TableInjector Object  -  Name: ' inputname(1)],1);
OpenCossan.cossanDisp([' Description: ' Xobj.Sdescription ] ,1);
OpenCossan.cossanDisp('===================================================================',1);

if strcmp(Xobj.Sdescription,'Empty Object')
    return
end

% 1.2.   main paramenters
OpenCossan.cossanDisp(['* Number of Input variables: ' num2str(Xobj.Nvariable) ],1);
OpenCossan.cossanDisp(['* ASCII file: ' Xobj.Srelativepath Xobj.Sfile ],1);
OpenCossan.cossanDisp(['* Format: ' Xobj.Stype ],1);



