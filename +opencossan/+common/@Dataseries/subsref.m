function varargout = subsref(Xobj,Tsubstruct)
%SUBSREF
%
% See also: https://cossan.co.uk/wiki/index.php/subsref@Dataseries
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

switch Tsubstruct(1).type
    case '()'
        [varargout{1:nargout}] = subsrefParens(Xobj,Tsubstruct);
    case '{}'
        error('OpenCossan:Dataseries:subsref',...
            ['No support of subsref of type ''{}'' for objects of class ' ...
            class(Xobj)])
    case '.'
        [varargout{1:nargout}] = subsrefDot(Xobj,Tsubstruct);
end

end
