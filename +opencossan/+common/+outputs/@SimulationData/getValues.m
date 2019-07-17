function Mout = getValues(Xobj,varargin)
%getValues Retrieve the values of a variable present in the
%           SimulationData Object
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/getValues@SimulationData
%
% $Copyright~1993-2015,~COSSAN~Working~Group,~University~of~Liverpool,~UK$
% $Author: Edoardo-Patelli$

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
%% Validate input arguments

Cnames=Xobj.Cnames;

for k=1:2:nargin-1
    switch lower(varargin{k})
        case {'sname'}
            Cnames = varargin(k+1);
             case {'cnames','csnames','cvariablename'}
            Cnames = varargin{k+1};
        otherwise
            error('openCOSSAN:outputs:SimulationData:getValues', ...
                'PropertyName %s is not valid',varargin{k})
    end
end

assert(all(ismember(Cnames,Xobj.Cnames)),...
    'openCOSSAN:outputs:SimulationData:getValue', ...
    'Variable(s) not present in the SimulationData object!\n Required variables: %s\nAvailable variables: %s',...
    sprintf('"%s" ',Cnames{:}),sprintf('"%s" ',Xobj.Cnames{:}))

Vfield=ismember(Xobj.Cnames,Cnames);

Mout=table2array(Xobj.TableValues(:,Vfield));

end
