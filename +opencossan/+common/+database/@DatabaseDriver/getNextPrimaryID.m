function NnextID = getNextPrimaryID(Xobj,Stabletype)
%GETNEXTPRIMARYID  This method is used to get the next available primary ID
% from the selected table
%
% See also:
% http://cossan.cfd.liv.ac.uk/wiki/index.php/getNextPrimaryID@DatabaseDriver
%
% Author: Matteo Broggi
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

assert(ismember(Stabletype,Xobj.CtableTypes), ...
    'openCOSSAN:DatabaseDriver:insertRecord',...
    'Not valid table type %s', Stabletype)

switch Stabletype
    case 'Analysis'
        CcolNames = Xobj.CcolnamesAnalysis;
    case 'Solver'
        CcolNames = Xobj.CcolnamesSolver;
    case 'Simulation'
        CcolNames = Xobj.CcolnamesSimulation;
    case 'Result'
        CcolNames = Xobj.CcolnamesResult;
        % no need for otherwise, validity of Stabletype already checked
end

Squery = ['SELECT ' CcolNames{1} ' FROM ' Stabletype];

try
    OpenCossan.cossanDisp(['Executing query: ' Squery],4)
    Cresults = exec(Xobj.XdatabaseConnection, Squery);
    OpenCossan.cossanDisp('Query successfully executed',4)
catch ME
    rethrow(ME);
end

if isempty(Cresults.(CcolNames{1}))
    NnextID = 1;
else
    NnextID = max(Cresults.(CcolNames{1}))+1;
end

end