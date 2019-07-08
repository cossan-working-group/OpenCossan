function Xobj = split(Xobj,varargin)
%SPLIT SimulationData objects
%
%   One of the following arguments must be passed
%   - Vindices: Indicies of the samples to be extracted
%   - Cmembers: Name of the variables kept in the SimulationData
%   - CremoveNames: Name of the variables removed from the SimulationData
%
%   OUTPUT
%   - Xobj: object of class SimulationData
%
%   USAGE
%   Xobj = Xobj.split(PropertyName, PropertyValue, ...)
%
%
% See Also: https://cossan.co.uk/wiki/index.php/split@SimulationData
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

Vindices=[];
VremoveNamePosition=[];

% Store list of variable names
ColdNames=Xobj.Cnames;

%% Validate input arguments
OpenCossan.validateCossanInputs(varargin{:})

%% 1.   Argument Check
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case 'vindices'
            Vindices=varargin{k+1};
        case {'cmembers', 'cnames'}
            VremoveNamePosition=~ismember(ColdNames,varargin{k+1});  
        case {'cremove', 'cremovenames'}
            VremoveNamePosition=ismember(ColdNames,varargin{k+1});  
        otherwise
            error('openCOSSAN:SimulationData:split',...
                [ varargin{k} ' is not a valid PropertyName']);
    end
end

%% Remove Realizations
if ~isempty(Vindices)
    % Remove realizations from the structure
    Xobj.Tvalues=Xobj.Tvalues(Vindices);
    
    % Remove realizations from the Mvalues
    if ~isempty(Xobj.Mvalues)
        Xobj.Mvalues=Xobj.Mvalues(Vindices,:);
    end
end

%% Remove Variables
if ~isempty(VremoveNamePosition)
    Xobj.Tvalues=rmfield(Xobj.Tvalues,ColdNames(VremoveNamePosition));
    
    if ~isempty(Xobj.Mvalues)
        % Remove variables from the Mvalues
        Xobj.Mvalues=Xobj.Mvalues(:,~VremoveNamePosition);        
    end
    
    % Update LisDataseries field
    Xobj.LisDataseries(VremoveNamePosition)=[];
end





