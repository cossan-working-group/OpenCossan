classdef ImportanceSampling < opencossan.simulations.MonteCarlo
    %IMPORTANCESAMPLING class definitoin of the ImportanceSampling
    %
    % See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@ImportanceSampling
    
    %{
    This file is part of OpenCossan <https://cossan.co.uk>.
    Copyright (C) 2006-2018 COSSAN WORKING GROUP

    OpenCossan is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License or,
    (at your option) any later version.

    OpenCossan is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with OpenCossan. If not, see <http://www.gnu.org/licenses/>.
    %}
    
    properties (SetAccess = protected)
        ProposalDistribution opencossan.common.inputs.random.RandomVariableSet = ...
            opencossan.common.inputs.random.RandomVariableSet.empty();
    end
    
    methods
        function obj = ImportanceSampling(varargin)
            %IMPORTANCESAMPLING
            
            if nargin == 0
                super_args = {};
            else
                [optional, super_args] = opencossan.common.utilities.parseOptionalNameValuePairs(...
                    "proposaldistribution", ...
                    {opencossan.common.inputs.random.RandomVariableSet.empty()}, ...
                    varargin{:});
            end
            
            obj@opencossan.simulations.MonteCarlo(super_args{:});
            
            if nargin > 0
                obj.ProposalDistribution = optional.proposaldistribution;
            end
        end
        
        [simData, weights] = apply(obj,varargin)
        [samples, weights] = sample(obj, varargin)
    end
    
end

