function setDatabaseDriver(XdatabaseDriver)
%SETDATABASEDRIVER This static method of OpenCossan sets the database driver
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

global OPENCOSSAN
assert(~isempty(OPENCOSSAN),'openCOSSAN:OpenCossan',...
    'OpenCossan has not been initialize. \n Please run OpenCossan! ')
    
if isempty(XdatabaseDriver)
    OpenCossan.cossanDisp('[OpenCossan.setDatabaseDriver] Removing database driver',4);
    OPENCOSSAN.XdatabaseDriver=[];
else
    OpenCossan.cossanDisp('[OpenCossan.setDatabaseDriver] Setting database driver',4);
    assert(isa(XdatabaseDriver,'DatabaseDriver'),'openCOSSAN:OpenCossan',...
            'A DatabaseDriver object is required!!! \nProvided object of type %s is not valid',...
            class(XdatabaseDriver))
    
OPENCOSSAN.XdatabaseDriver=XdatabaseDriver;

end

