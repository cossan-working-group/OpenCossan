classdef MonteCarlo < opencossan.simulations.Simulations
    %MONTECARLO Monte Carlo simulation method
    %
    % See also: https://cossan.co.uk/wiki/index.php/@MonteCarlo
    %
    % Author: Edoardo Patelli
    % Institute for Risk and Uncertainty, University of Liverpool, UK
    % email address: openengine@cossan.co.uk
    % Website: http://www.cossan.co.uk
    
    % =====================================================================
    % This file is part of OpenCossan.  The open general purpose matlab
    % toolbox for numerical analysis, risk and uncertainty quantification.
    %
    % OpenCossan is free software: you can redistribute it and/or modify
    % it under the terms of the GNU General Public License as published by
    % the Free Software Foundation, either version 3 of the License.
    %
    % OpenCossan is distributed in the hope that it will be useful,
    % but WITHOUT ANY WARRANTY; without even the implied warranty of
    % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    % GNU General Public License for more details.
    %
    %  You should have received a copy of the GNU General Public License
    %  along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
    % =====================================================================
    
    properties
        NumberOfBatches(1,1) {mustBeInteger} = 1;
        ExportBatches(1,1) logical = false;
    end
    
    methods        
        function obj = MonteCarlo(varargin)
            if nargin == 0
                super_args = {};
            else
                [optional, super_args] = opencossan.common.utilities.parseOptionalNameValuePairs(...
                    ["batches", "exportbatches"], {1, false}, varargin{:});
            end
            
            obj@opencossan.simulations.Simulations(super_args{:});
            
            if nargin > 0
                obj.NumberOfBatches = optional.batches;
                obj.ExportBatches = optional.exportbatches;
            end
        end
        
        pf = computeFailureProbability(Xobj, probModel);
        samples = sample(obj, varargin);
        simData = apply(obj, model);
    end
    
    methods (Access = protected)
        [exit, flag] = checkTermination(obj, varargin) % Check the termination criteria 
        exportBatch(obj, data, batch);
    end
end

