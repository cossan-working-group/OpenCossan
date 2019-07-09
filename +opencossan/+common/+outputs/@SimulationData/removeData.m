function Xobj = removeData(Xobj,varargin)
%ADDDATA This method is used to remove data values from an existing
%SimulationData object
%
% See also: http://cossan.co.uk/wiki/removeData@SimulationData
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

%% Validate input arguments
OpenCossan.validateCossanInputs(varargin{:})

% Set parameters defined by the user
for k=1:2:length(varargin),
    switch lower(varargin{k})
        case {'cnames'}
            Cnames = varargin{k+1};
        case {'sname'}
            Cnames = varargin(k+1);
        otherwise
           error('openCOSSAN:SimulationData:removeData:wrongInputArgument',...
                  'Field name %s not allowed', varargin{k}); 
    end
end

assert(all(ismember(Cnames,Xobj.Cnames)), ...
    'openCOSSAN:SimulationData:removeData:wrongNames', ...
    'The following variables are not present in the SimulationData object:\n%s',...
    sprintf('"%s"; ',Cnames{~ismember(Cnames,Xobj.Cnames)}))


% Remove requested field 
Xobj.Tvalues=rmfield(Xobj.Tvalues,Cnames);
