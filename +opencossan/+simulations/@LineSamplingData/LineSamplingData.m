classdef LineSamplingData < opencossan.common.outputs.SimulationData
    %LINESAMPLINGOUTPUT class containing speific outputs of the
    %LineSampling simulation method
    %
    % See also: https://cossan.co.uk/wiki/index.php/@LineSamplingOutput
    %
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
    
    properties (SetAccess = protected)
        Input(1,1) opencossan.common.inputs.Input;
        NumberOfLines(1,1) {mustBeInteger, mustBePositive} = 1;
        PointsOnLine(1,:) double;
        LimitState(:, 1) double;
        PerformanceFunctionVariable(1,1) string;
        Alpha(1, :) double;
    end
    
    methods
        
        function obj = LineSamplingData(varargin)
            if nargin == 0
                super_args = {};
            else
                [required, super_args] = opencossan.common.utilities.parseRequiredNameValuePairs(...
                    ["input", "lines", "points", "alpha", "limitstate", "performance"], varargin{:});
            end
            
            obj@opencossan.common.outputs.SimulationData(super_args{:});
            
            if nargin > 0
                obj.Input = required.input;
                obj.NumberOfLines = required.lines;
                obj.PointsOnLine = required.points;
                obj.Alpha = required.alpha;
                obj.LimitState = required.limitstate;
                obj.PerformanceFunctionVariable = required.performance;
            end
        end
    end
end
