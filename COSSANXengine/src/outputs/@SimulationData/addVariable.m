function Xobj = addVariable(Xobj,varargin)
%ADDVARIABLE adds output values to SimulationData object
%
%   MANDATORY ARGUMENTS
%
%   OUTPUT
%   - Xobj: object of class SimulationData
%
%   USAGE
%   Xobj = Xobj.add(PropertyName, PropertyValue, ...)
%
%
%   EXAMPLES
%   Xobj = Xobj.add('Sname','Pippo','values',values)
%
% Copyright 2006-2017 COSSAN Working Group,
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


%% Validate input arguments
OpenCossan.validateCossanInputs(varargin{:})

%% Add samples
Xsim2=SimulationData(varargin{:});

Xobj=Xobj.merge(Xsim2);

