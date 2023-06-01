classdef UniformCircularAreaRandomVariable < opencossan.common.inputs.random.RandomVariable
    %UNIFORMCIRCULARAREA This class defines an Object of type UniformCircularAreaRandomVariable,
    %   which extends the class RandomVariable.
    %
    %   For more detailed information, see
    %   <https://cossan.co.uk/wiki/index.php/@RandomVariable>.
    %
    %   UNIFORMCIRCULARAREA Properties:
    %       Bounds[-Inf,Inf]
    
    % Institute for Risk and Uncertainty, University of Liverpool, UK
    % email address: openengine@cossan.co.uk
    % Website: http://www.cossan.co.uk
    % =====================================================================
    % This file is part of *OpenCossan*: you can redistribute it and/or modify
    % it under the terms of the GNU General Public License as published by
    % the Free Software Foundation, either version 3 of the License.
    %
    % *OpenCossan* is distributed in the hope that it will be useful,
    % but WITHOUT ANY WARRANTY; without even the implied warranty of
    % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    % GNU General Public License for more details.
    %
    % You should have received a copy of the GNU General Public License
    % along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
    % =====================================================================
    
    % TODO: Implement shifting
    properties
        Bounds(1,2) double {mustBeNumeric} = [-Inf;Inf];
    end
    
    properties (Dependent)
        Mean;
        Std;
    end
    
    methods
        function obj = UniformCircularAreaRandomVariable(varargin)
            % UNIFORMCIRCULARAREARANDOMVARIABLE Create a new object.
            %
            %   obj = UniformCircularAreaRandomVariable([0.5 1]) creates a new object
            %   with the bounds set to [0.5 1]
            %
            %   Additional name-value pairs are:
            %
            %     - Description
            %     - Shift
            %
            %   See also RANDOMVARIABLE
            
            if nargin == 0
                super_args = {};
            else
                [results, super_args] = opencossan.common.utilities.parseRequiredNameValuePairs(...
                    "bounds", varargin{:});
            end
            
            obj@opencossan.common.inputs.random.RandomVariable(super_args{:});
            
            if nargin > 0
                obj.Bounds = results.bounds;
            end
        end
        
        function mean = get.Mean(obj)
            mean = (obj.Bounds(1) + obj.Bounds(2)) / 2;
        end
        
        function std = get.Std(obj)
            std = (obj.Bounds(2) - obj.Bounds(1)) / (2 * sqrt(3));
        end
        
        function VX = cdf2physical(obj,VU)
            %CDF2PHYSICAL Inverse uniform circular area cumulative distribution function.
            % VX = cdf2physical(obj,VX) returns the inverse cdf of the
            % uniform circular area distribution, evaluated at the values VU.
            Rmin = obj.Bounds(1);
            Rmax = obj.Bounds(2);
            VX = sqrt((Rmin)^2 + ((Rmax)^2 - (Rmin)^2)*VU);
        end
        
        function VX = map2physical(obj,VU)
            % MAP2PHYSICAL Map from standard normal into physical space.
            % VX = map2physical(obj,VU) maps the values in VU from standard
            % normal into physical space.
            VU1 = normcdf(VU);
            Rmin = obj.Bounds(1);
            Rmax = obj.Bounds(2);
            VX = sqrt((Rmin)^2 + ((Rmax)^2 - (Rmin)^2)*VU1);
        end
        
        function VU = map2stdnorm(obj,VX)
            % MAP2STDNORM Map from physical into standard normal space.
            % VU = map2stdnorm(obj,VX) maps the values in VX from physical
            % into standard normal space.
            Rmin = obj.Bounds(1);
            Rmax = obj.Bounds(2);
            VU = (VX.^2 - Rmin^2)/(Rmax^2 - Rmin^2);
        end
        
        function VU = physical2cdf(obj,VX)
            %PHYSICAL2CDF Uniform circular area cumulative distribution function.
            % VU = physical2cdf(obj,VX) returns the cdf of the uniform
            % circular area distribution, evaluated at the values VX.
            Rmin = obj.Bounds(1);
            Rmax = obj.Bounds(2);
            VU = (VX.^2 - Rmin^2)/(Rmax^2 - Rmin^2);
        end
        
        %% evalpdf
        function Vpdf_vX = evalpdf(~,~) %#ok<STOUT>
            %EVALPDF Uniform circular area probability density function.
            % Not supported.
            ME = MException('UniformCircularAreaRandomVariable:UnsupportedOperation',...
                ['Unsupported operation.\n' ...
                'Evalpdf is not supported for the Uniform circular area distribution.']);
            throw(ME);
        end
    end
    
    methods (Access = protected)
        function samples = getSamples(obj,size)
            samples = sqrt(unifrnd(obj.Bounds(1)^2,obj.Bounds(2)^2,size));
        end
    end
    
    methods (Static)
        function obj = fromMeanAndStd(~,~,~) %#ok<STOUT>
            % FROMMEANANDSTD Create a new object from mean and std.
            %
            % This method is not supported for the
            % ExponentialRandomVariable. Use the constructor instead.
            ME = MException('UniformCircularAreaRandomVariable:UnsupportedOperation',...
                ['Unsupported operation.\n' ...
                'Create objects of UniformCircularAreaRandomVariable using the constructor.']);
            throw(ME);
        end
        
        function obj = fit(varargin) %#ok<STOUT>
            ME = MException('UniformCircularAreaRandomVariable:UnsupportedOperation',...
                ['Unsupported operation.\n' ...
                'Cannot fit UniformCircularAreaRandomVariable to data.']);
            throw(ME);
        end
    end
end

