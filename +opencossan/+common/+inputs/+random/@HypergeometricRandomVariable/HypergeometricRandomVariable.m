classdef HypergeometricRandomVariable < opencossan.common.inputs.random.RandomVariable
    %HYPERGEOMETRICRANDOMVARIABLE This class defines an Object of type HypergeometricRandomVariable,
    %   which extends the class RandomVariable.
    %
    %   For more detailed information, see
    %   <https://cossan.co.uk/wiki/index.php/@RandomVariable>.
    %
    %   HYPERGEOMETRIC Properties:
    %       N
    %       M
    %       K
    %       Bounds[1,2] (Constant)
    
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
    
    properties
        N {mustBeInteger,mustBeNonnegative};
        M {mustBeInteger,mustBeNonnegative};
        K {mustBeInteger,mustBeNonnegative};
    end
    
    properties (Dependent)
        Mean;
        Std;
    end
    
    properties (Constant)
        Bounds(1,2) double {mustBeNumeric} = [0;Inf];
    end
    
    methods
        function obj = HypergeometricRandomVariable(varargin)
            % HYPERGEOMETRICRANDOMVARIABLE Create a new object.
            %
            %   obj = HypergeometricRandomVariable(1,2,3) creates a new object
            %   with the parameter k set to 1, m set to 2 and n set to 3.
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
                    ["k", "m", "n"], varargin{:});
            end
            obj@opencossan.common.inputs.random.RandomVariable(super_args{:});
            
            if nargin > 0
                obj.K = results.k;
                obj.M = results.m;
                obj.N = results.n;
            end
        end
        
        function mean = get.Mean(obj)
            [mean,~] = hygestat(obj.M,obj.K,obj.N);
            mean = mean + obj.Shift;
        end
        
        function std = get.Std(obj)
            [~,Nvar] = hygestat(obj.M,obj.K,obj.N);
            std  = sqrt(Nvar);
        end
        
        function VX = cdf2physical(obj,VU)
            %CDF2PHYSICAL Inverse hypergeometric cumulative distribution function.
            % VX = cdf2physical(obj,VX) returns the inverse cdf of the
            % hypergeometric distribution, evaluated at the values VU.
            VX = icdf('hypergeometric',VU(VU > 0),obj.M,obj.K,obj.N) + obj.Shift;
        end
        
        function VX = map2physical(obj,VU)
            % MAP2PHYSICAL Map from standard normal into physical space.
            % VX = map2physical(obj,VU) maps the values in VU from standard
            % normal into physical space.
            VX = icdf('hypergeometric',normcdf(VU),obj.M,obj.K,obj.N) + obj.Shift;
        end
        
        function VU = map2stdnorm(obj,VX)
            % MAP2STDNORM Map from physical into standard normal space.
            % VU = map2stdnorm(obj,VX) maps the values in VX from physical
            % into standard normal space.
            VU = norminv(cdf('hypergeometric',VX - obj.Shift,obj.M,obj.K,obj.N));
        end
        
        function VU = physical2cdf(obj,VX)
            %PHYSICAL2CDF Hypergeometric cumulative distribution function.
            % VU = physical2cdf(obj,VX) returns the cdf of the 
            % hypergeometric distribution, evaluated at the values VX.
            VU = cdf('hypergeometric',VX - obj.Shift,obj.M,obj.K,obj.N);
        end
        
        function Vpdf_vX = evalpdf(obj,Vx)
            %EVALPDF Hypergeometric probability density function.
            % Y = evalpdf(obj,X) returns the pdf of the hypergeometric
            % distribution, evaluated at the values X.
            Vpdf_vX = pdf('hypergeometric',Vx - obj.Shift,obj.M,obj.K,obj.N);
        end
    end
    
    methods (Access = protected)
        function samples = getSamples(obj,size)
            samples = random('hypergeometric',obj.M,obj.K,obj.N,size) + obj.Shift;
        end
    end
    
    methods (Static)
        function obj = fromMeanAndStd(~,~,~) %#ok<STOUT>
            % FROMMEANANDSTD Create a new object from mean and std.
            % This method is not supported for the
            % HypergeometricRandomVariable. Use the constructor instead.
            ME = MException('HypergeometricRandomVariable:UnsupportedOperation',...
                ['Unsupported operation.\n' ...
                'Create objects of HypergeometricRandomVariable using the constructor.']);
            throw(ME);
        end
        function obj = fit(varargin) %#ok<STOUT>
            ME = MException('HypergeometricRandomVariable:UnsupportedOperation',...
                ['Unsupported operation.\n' ...
                'Cannot fit HypergeometricRandomVariable to data.']);
            throw(ME);
        end
    end
    
end
