classdef AdaptiveLineSampling < opencossan.simulations.LineSampling
    % ADAPTIVELINESAMPLING class
    %   This class allows to perform simulation with the Advanced Line
    %   Sampling method.
    %
    % See also: https://cossan.co.uk/wiki/index.php/@AdaptiveLineSampling
    %
    % Author: Marco de Angelis and Edoardo Patelli
    % Institute for Risk and Uncertainty, University of Liverpool, UK
    % email address: openengine@cossan.co.uk
    % Website: http://www.cossan.co.uk
    %
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
        % Function value tolerance for the line search
        Tolerance(1,1) double {mustBePositive} = eps;
    end
    
    methods
        function obj = AdaptiveLineSampling(varargin)
            if nargin == 0
                super_args = {};
            else
                [optional, super_args] = opencossan.common.utilities.parseOptionalNameValuePairs(...
                    ["tolerance", "points"], {eps, []}, varargin{:});
            end
            
            obj@opencossan.simulations.LineSampling(super_args{:});
            
            if nargin > 0
                obj.Tolerance = optional.tolerance;
                if ~isempty(optional.points)
                    warning("Input 'points' will be ignored for AdaptiveLineSampling.");
                end
            end
        end
    end
end

