classdef LatinHypercubeSampling < opencossan.simulations.MonteCarlo
    %LATINHYPERCUBESSAMPLING Summary of this class goes here
    %   Detailed explanation goes here
    %
    % See also:
    % https://cossan.co.uk/wiki/index.php/@LatinHypercubeSampling
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
        Smooth(1,1) logical = true; % If is false produces points at the midpoints of the
        % above intervals: 0.5/n, 1.5/n, ..., 1-0.5/n.
        Criterion = 'none';   % iteratively generates latin hypercube samples
        % to find the best one according to the
        % criterion criterion, which can be one of the
        % following strings:
        % 'none' No iteration
        % 'maximin' Maximize minimum distance between points
        % 'correlation' Reduce correlation
        Iterations(1,1) {mustBeInteger} = 5  %  Number of iterates used in an attempt to improve
        % the design according to the specified criterion.
    end
    
    properties (Hidden, Dependent)
        Smooth_;
    end
    
    methods       
        function obj = LatinHypercubeSampling(varargin)
            %COMPUTEFAILUREPROBABILITY method. This method compute the FailureProbability associate to a
            % ProbabilisticModel/SystemReliability/MetaModel by means of a Monte Carlo
            % simulation object. It returns a FailureProbability object.
            %
            % See also:
            % https://cossan.co.uk/wiki/index.php/@LatinHypercubeSampling
            %
            % Author: Edoardo Patelli
            % Institute for Risk and Uncertainty, University of Liverpool, UK
            % email address: openengine@cossan.co.uk
            % Website: http://www.cossan.co.uk
            
            if nargin == 0
                super_args = {};
            else
                [optional, super_args] = opencossan.common.utilities.parseOptionalNameValuePairs(...
                    ["smooth", "criterion", "iterations"], {true, 'none', 5}, varargin{:});
            end
            
            obj@opencossan.simulations.MonteCarlo(super_args{:});
            
            if nargin > 0
                obj.Smooth = optional.smooth;
                obj.Criterion = optional.criterion;
                obj.Iterations = optional.iterations;
            end
        end
        
        function s = get.Smooth_(obj)
            s = 'on';
            if ~obj.Smooth
                s = 'off';
            end
        end
    end
end

