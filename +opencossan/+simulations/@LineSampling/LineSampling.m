classdef LineSampling < opencossan.simulations.Simulations
    % LineSampling class
    %   This class allows to perform simulation adopting the Line Sampling
    %   strategy. Please refer to the Theory Manual and Reference Manual
    %   for more information about the Line Sampling.
    %
    % See also: https://cossan.co.uk/wiki/index.php/@LineSampling
    %
    % Author: Edoardo Patelli and Marco de Angelis
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
    
    %% Properties
    properties
        % Important Direction (pointing to the failure area)
        Alpha(:, 1) double;          
        NumberOfBatches(1,1) {mustBeInteger, mustBePositive} = 1;
        % Termination criteria for the maximum number of lines
        NumberOfLines(1,1) {mustBeInteger, mustBePositive} = 1;
        % Evaluation points along the line
        PointsOnLine(1, :) double = 1:6;
        ExportBatches(1,1) logical = false;
    end
    
    methods
        function obj = LineSampling(varargin)
            %LINESAMPLING This is the constructor of the LineSampling
            %object.
            %
            % See also: https://cossan.co.uk/wiki/index.php/@LineSampling
            %
            % Author: Edoardo Patelli
            % Institute for Risk and Uncertainty, University of Liverpool, UK
            
            if nargin == 0
                super_args = {};
            else
                [required, varargin] = opencossan.common.utilities.parseRequiredNameValuePairs(...
                    "lines", varargin{:});
                [optional, super_args] = opencossan.common.utilities.parseOptionalNameValuePairs(...
                    ["alpha", "gradient", "points", "batches", "samples", ...
                    "exportbatches"], {[], [], 1:6, 1, [], false}, varargin{:});
            end
            
            obj@opencossan.simulations.Simulations(super_args{:});
            
            if nargin > 0
                obj.NumberOfLines = required.lines;
                obj.NumberOfBatches = optional.batches;
                obj.PointsOnLine = optional.points;
                obj.ExportBatches = optional.exportbatches;
                
                if ~isempty(optional.alpha)
                    assert(isempty(optional.gradient), 'OpenCossan:LineSampling', ...
                    "Only specify either the important direction alpha or a gradient object.");
                    obj.Alpha = optional.alpha;
                elseif ~isempty(optional.gradient)
                    validateattributes(optional.gradient, {'opencossan.sensitivity.Gradient', ...
                        'opencossan.sensitivity.LocalSensitivityMeasures'}, {'scalar'});
                    % It is necessary to go in the opposite direction of the Gradient or the 
                    % SensitivityMeasure
                    obj.Alpha = -optional.gradient.Valpha;
                end
                
                if ~isempty(optional.samples)
                    warning('OpenCossan:LineSampling', ...
                        "Argument 'samples' is ignored for LineSampling. Use 'lines'.");
                end
            end
        end
    end
    
    methods (Access = protected)
        [exit, flag] = checkTermination(obj, varargin) % Check the termination criteria 
    end
end

