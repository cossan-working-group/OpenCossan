classdef UniformDiscreteRandomVariable < opencossan.common.inputs.random.RandomVariable
    %UNIFORMDISCRETE This class defines an Object of type UniformDiscreteRandomVariable,
    %   which extends the class RandomVariable.
    %
    %   For more detailed information, see
    %   <https://cossan.co.uk/wiki/index.php/@RandomVariable>.
    %
    %   UNIFORMDISCRETE Properties:
    %       Bounds[1,2]
    
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
    
    % TODO: Implement shifting
    
    properties
        Bounds(1,2) double {mustBeNumeric} = [-Inf;Inf];
    end
    
    properties (Dependent)
        Mean;
        Std;
    end
    
    methods
        function obj = UniformDiscreteRandomVariable(varargin)
            % UNIFORMDISCRETERANDOMVARIABLE Create a new object.
            %
            %   obj = UniformDiscreteRandomVariable([0.5 1]) creates a new object
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
            [Nmean,~] = unidstat(obj.Bounds(2) - obj.Bounds(1) + 1);
            mean = Nmean + obj.Bounds(1) - 1;
        end
        
        function std = get.Std(obj)
            [~,Nvar] = unidstat(obj.Bounds(2) - obj.Bounds(1) + 1);
            std  = sqrt(Nvar);
        end
        
        function VX = cdf2physical(obj,VU)
            %CDF2PHYSICAL Inverse uniform discrete cumulative distribution function.
            % VX = cdf2physical(obj,VX) returns the inverse cdf of the
            % uniform discrete distribution, evaluated at the values VU.
            VX = obj.Bounds(1) + icdf('unid',VU,obj.Bounds(2) - obj.Bounds(1));
        end
        
        function VX = map2physical(obj,VU)
            % MAP2PHYSICAL Map from standard normal into physical space.
            % VX = map2physical(obj,VU) maps the values in VU from standard
            % normal into physical space.
            VX = obj.Bounds(1) + icdf('unid',normcdf(VU),obj.Bounds(2) - obj.Bounds(1));
        end
        
        function VU = map2stdnorm(obj,VX)
            % MAP2STDNORM Map from physical into standard normal space.
            % VU = map2stdnorm(obj,VX) maps the values in VX from physical
            % into standard normal space.
            VU = norminv(cdf('unid',VX - obj.Bounds(1),obj.Bounds(2) - obj.Bounds(1)));
        end
        
        function VU = physical2cdf(obj,VX)
            %PHYSICAL2CDF Uniform discrete cumulative distribution function.
            % VU = physical2cdf(obj,VX) returns the cdf of the uniform
            % discrete distribution, evaluated at the values VX.
            VU = cdf('unid',VX - obj.Bounds(1),obj.Bounds(2) - obj.Bounds(1));
        end
        
        function Vpdf_vX = evalpdf(obj,Vx)
            %EVALPDF Uniform discrete probability density function.
            % Y = evalpdf(obj,X) returns the pdf of the uniform discrete
            % distribution, evaluated at the values X.
            Vpdf_vX = pdf('unid',Vx - obj.Bounds(1),obj.Bounds(2) - obj.Bounds(1));
        end
    end
    
    methods (Access = protected)
        function samples = getSamples(obj,size)
            samples = obj.Bounds(1) + random('unid',obj.Bounds(2) - obj.Bounds(1),size);
        end
    end
    
    methods (Static)
        function obj = fromMeanAndStd(varargin)
            import opencossan.common.inputs.random.UniformDiscreteRandomVariable
            
            [results, varargin] = opencossan.common.utilities.parseRequiredNameValuePairs(...
                ["mean", "std"], varargin{:});
            var = results.std*results.std;
            a = (2*results.mean - sqrt(12*var + 1) + 1) / 2;
            b = 2*results.mean - a ;
            
            varargin = [varargin {'bounds', [a;b]}];
            obj = UniformDiscreteRandomVariable(varargin{:});
        end
        
        function obj = fit(varargin) %#ok<STOUT>
            ME = MException('UniformDiscreteRandomVariable:UnsupportedOperation',...
                ['Unsupported operation.\n' ...
                'Cannot fit UniformDiscreteRandomVariable to data.']);
            throw(ME);
        end
    end
end

