classdef SobolSampling < opencossan.simulations.MonteCarlo
    %SobolSampling class
    %   This class computes elements of the Sobol quasirandom sequence.
    %   This class is based on the Sobolset Matlab class
    %   Sobolset is a quasi-random point set class that produces points
    %   from the Sobol sequence. The Sobol sequence is a base-2 digital
    %   sequence that fills space in a highly uniform manner.
    %
    % See also: https://cossan.co.uk/wiki/index.php/@SobolSampling
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
        % Number of initial points in sequence to omit
        Skip(1,1) {mustBeInteger, mustBeNonnegative} = 1;
        % Interval between points
        Leap(1,1) {mustBeInteger, mustBeNonnegative} = 0;
        % Flag to apply MatousekAffineOwen scrambling
        Scramble(1,1) logical = false;
        % Point generation method ('standard' or 'graycode')
        PointOrder(1, :) char {mustBeMember(PointOrder, {'standard', 'graycode'})} = 'standard';
    end
    
    methods
        function obj = SobolSampling(varargin)
            if nargin == 0
                super_args = {};
            else
                [required, varargin] = opencossan.common.utilities.parseRequiredNameValuePairs(...
                    ["skip", "leap"], varargin{:});
                [optional, super_args] = opencossan.common.utilities.parseOptionalNameValuePairs(...
                    ["scramble", "pointorder"], {false, 'standard'}, varargin{:});
            end
            
            obj@opencossan.simulations.MonteCarlo(super_args{:});
            
            if nargin > 0
                obj.Skip = required.skip;
                obj.Leap = required.leap;
                obj.Scramble = optional.scramble;
                obj.PointOrder = optional.pointorder;
            end
        end
    end
end

