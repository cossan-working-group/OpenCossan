function display(Xobj)
%DISPLAY Show the content of the object OpenCossan
%
% See also: https://cossan.co.uk/wiki/index.php/@OpenCossan

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


Xobj.cossanDisp('',1);
Xobj.cossanDisp(['* The enviroment PATH set to: ' Xobj.SbinPath],4);
Xobj.cossanDisp(['* The enviroment LD_LIBRARY_PATH set to: ' Xobj.SlibPath],4);
Xobj.cossanDisp(['* The enviroment C_INCLUDE_PATH set to: ' Xobj.SincludePath],4);
Xobj.cossanDisp(['* The Matlab Database path set to: ' Xobj.SmatlabDatabasePath],4);
Xobj.cossanDisp(['* The Matlab Compiler Runtime path set to: ' Xobj.SmcrPath],4);
Xobj.cossanDisp(['* The Matlab Installation path set to: ' Xobj.SmatlabPath],4);
if isempty(Xobj.SdiaryFileName)
    Xobj.cossanDisp('* No Diary Log file used',1)
else
    Xobj.cossanDisp(['* Diary Log file created in: ' Xobj.SdiaryFileName],1)
end

% if Xobj.NverboseLevel>2
%     Xobj.cossanDisp('-------------------------------------------------------------',4);
%     display(Xobj.Xanalysis)
%     Xobj.cossanDisp('-------------------------------------------------------------',4);
% end

Xobj.cossanDisp('----------------------------------------------------------------------------------------',4);
if ~exist('DatabaseDriver','class')
    Xobj.cossanDisp('* DatabaseDriver not available!!! ',1)
else
if isempty(Xobj.XdatabaseDriver)
    Xobj.cossanDisp('* No Database defined. Analyses and results will NOT be automatically included into DB.',1)
else
    Xobj.cossanDisp(['* Database driver: ', Xobj.XdatabaseDriver.SjdbcDriver],3)
end
end
Xobj.cossanDisp('----------------------------------------------------------------------------------------',4);
switch Xobj.NverboseLevel
    case 0
        Xobj.cossanDisp('* Verbose level set to NONE',1)
    case 1
        Xobj.cossanDisp('* Verbose level set to INFO',1)
    case 2
        Xobj.cossanDisp('* Verbose level set to VERBOSE',1)
    case 3
        Xobj.cossanDisp('* Verbose level set to VERY VERBOSE',1)
    case 4
        Xobj.cossanDisp('* Verbose level set to DEBUG',1)
end

%Xobj.cossanDisp('----------------------------------------------------------------------------------------',3);

OpenCossan.printLogo;


