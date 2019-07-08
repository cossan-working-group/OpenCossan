function [Sout, Stype]=getCossanRoot
%GETCOSSANROOT.  This static method of OpenCossan returns the COSSAN-X installation root path
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

Sname=which('OpenCossan');

[Spath,~,Sext]=fileparts(Sname);

switch Sext
    case '.m'
        ind= strfind(Spath, fullfile('src','common','@OpenCossan'));
    case '.p'
        ind= strfind(Spath, fullfile('@OpenCossan'));
    otherwise
        error('openCOSSAN:OpenCossan',['Unexpected file type: ' Sext])
end

assert(~isempty(ind),'openCOSSAN:OpenCossan:NoOpenCossanPath',...
    'It is not possible to find OpenCOSSAN in your path. \n Please check the path (e.g. using pathtool)!')


Sout=Spath(1:ind(1)-2);
Stype=Sext;
