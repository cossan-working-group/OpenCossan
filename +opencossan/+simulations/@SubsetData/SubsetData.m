classdef SubsetData < opencossan.common.outputs.SimulationData
    %SubsetOutput class containing speific outputs of the
    %Subset simulation method
    %
    % See also:
    % http://cossan.co.uk/wiki/index.php/SubsetOutput
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
    
    properties
        FailureProbabilites(1,:) double;
        CoVs(1,:) double;
        RejectionRates(1,:) double;
        Thresholds(1,:) double;
    end
    
    properties (Dependent)
        NumberOfLevels  
    end
    
    methods
        function obj = SubsetData(varargin)
            if nargin == 0
                super_args = {};
            else
                [required, super_args] = opencossan.common.utilities.parseRequiredNameValuePairs(...
                    ["failureprobabilities", "covs", "rejectionrates", "thresholds"], varargin{:});
            end
            
            obj@opencossan.common.outputs.SimulationData(super_args{:});
            
            if nargin > 0
                obj.FailureProbabilites = required.failureprobabilities;
                obj.CoVs = required.covs;
                obj.RejectionRates = required.rejectionrates;
                obj.Thresholds = required.thresholds;
            end
        end
        
        function levels = get.NumberOfLevels(obj)
            levels = length(obj.FailureProbabilites) - 1;
        end
    end
    
end
