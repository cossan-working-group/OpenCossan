function Xobj = merge(Xobj,Xobj2)
%MERGE merges 1 SimulationData and 1 Subsetoutput object
%
% See also: http://cossan.co.uk/wiki/index.php/merge@SubsetOutput
%            
%   MANDATORY ARGUMENTS
%   - Xobj2: SimulationData object
%
%   OUTPUT
%   - Xobj: object of class Subsetoutput
%
%   USAGE
%   Xobj = Xobj.merge(Xobj2)
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

% Argument Check
assert(isa(Xobj2,'opencossan.common.outputs.SimulationData')|isa(Xobj2,'reliability.SubsetOutput'),...
        'openCOSSAN:SubsetOutput:merge:wrongObject',...
        'Object of class %s can not be merged with a SubsetOutput object.',class(Xobj2));

%merge Sim.Out. data
Xobj2 = merge@opencossan.common.outputs.SimulationData(Xobj2,Xobj);

Xobj.TableValues = Xobj2.TableValues;


end

