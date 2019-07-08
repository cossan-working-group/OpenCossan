function Xobj = set(Xobj,varargin)
%SET Set Function field contents.
%
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

OpenCossan.validateCossanInputs(varargin{:})
for k=1:2:length(varargin),
    switch lower(varargin{k})
        case {'expression','sexpression'}
            Xobj.Sexpression    = varargin{k+1};
            Xobj                = findToken(Xobj);
        otherwise
            error('openCOSSAN:Function:set', ...
                'The field %s of the Function object can not be changed ',varargin{k});
    end
end