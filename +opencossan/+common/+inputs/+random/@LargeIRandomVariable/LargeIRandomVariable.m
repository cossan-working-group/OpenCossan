classdef LargeIRandomVariable < opencossan.common.inputs.random.RandomVariable
    %LARGEIRANDOMVARIABLE This class defines an Object of type LargeIRandomVariable,
    %   which extends the class RandomVariable.
    %
    %   For more detailed information, see
    %   <https://cossan.co.uk/wiki/index.php/@RandomVariable>.
    %
    %   LARGEI Properties:
    %       LowerBound
    %       UpperBound
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
    
    properties (Hidden)
        Std_ double {mustBeNonnegative};
        Mean_ double;
    end
    
    properties (Dependent)
        Mean;
        Std;
    end
    
    properties (Constant)
        Bounds(1,2) double {mustBeNumeric} = [0;Inf];
    end
    
    methods
        function obj = LargeIRandomVariable(varargin)
            % LARGEIRANDOMVARIABLE Create a new object.
            %
            %   obj = LargeIRandomVariable(2,0.5) creates a new object
            %   with the mean set to 2 and the standard deviation set to
            %   0.5
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
                    ["mean", "std"], varargin{:});
            end
            obj@opencossan.common.inputs.random.RandomVariable(super_args{:});
            
            if nargin > 0
                obj.Mean_ = results.mean;
                obj.Std_ = results.std;
            end
        end
        
        function mean = get.Mean(obj)
            mean = obj.Mean_;
        end
        
        function obj = set.Mean(obj,mean)
            obj.Mean_ = mean;
        end
        
        function std = get.Std(obj)
            std = obj.Std_;
        end
        
        function obj = set.Std(obj,std)
            obj.Std_ = std;
        end
        
        function VX = cdf2physical(obj,VU)
            %CDF2PHYSICAL Inverse large-I cumulative distribution function.
            % VX = cdf2physical(obj,VX) returns the inverse cdf of the
            % large-I distribution, evaluated at the values VU.
            large_alpha = pi/(sqrt(6)*obj.Std);
            large_u = obj.Mean - 0.5772156/large_alpha;
            VX = large_u - log(-log(VU))/large_alpha;
        end
        
        function VX = map2physical(obj,VU)
            % MAP2PHYSICAL Map from standard normal into physical space.
            % VX = map2physical(obj,VU) maps the values in VU from standard
            % normal into physical space.
            large_alpha = pi/(sqrt(6)*obj.Std);
            large_u = obj.Mean - 0.5772156/large_alpha;
            VX = large_u - log(-log(normcdf(VU)))/large_alpha;
        end
        
        function VU = map2stdnorm(obj,VX)
            % MAP2STDNORM Map from physical into standard normal space.
            % VU = map2stdnorm(obj,VX) maps the values in VX from physical
            % into standard normal space.
            large_alpha = pi/(sqrt(6)*obj.Std);
            large_u = obj.Mean - 0.5772156/large_alpha;
            VU = norminv(exp(-exp(-large_alpha*(VX - large_u))));
        end
        
        function VU = physical2cdf(obj,VX)
            %PHYSICAL2CDF Large-I cumulative distribution function.
            % VU = physical2cdf(obj,VX) returns the cdf of the large-I
            % distribution, evaluated at the values VX.
            large_alpha = pi/(sqrt(6)*obj.Std);
            large_u = obj.Mean - 0.5772156/large_alpha;
            VU = exp(-exp(-large_alpha*(VX - large_u)));
        end
        
        function Vpdf_vX = evalpdf(obj,Vx)
            %EVALPDF Large-I probability density function.
            % Y = evalpdf(obj,X) returns the pdf of the large-I
            % distribution, evaluated at the values X.
            large_alpha = pi/(sqrt(6)*obj.Std);
            large_u = obj.Mean - 0.5772156/large_alpha;
            Vpdf_vX = large_alpha * exp(-large_alpha*(Vx- large_u)) .* exp(-exp(-large_alpha*(Vx - large_u)));
        end
    end
    
    methods (Access = protected)
        function samples = getSamples(obj,size)
            large_alpha = pi/(sqrt(6)*obj.Std);
            large_u = obj.Mean - 0.5772156/large_alpha;
            samples = large_u-log(-log(rand(size)))/large_alpha;
        end
    end
    
    methods (Static)
        function obj = fromMeanAndStd(varargin)
            % FROMMEANANDSTD Create a new object from mean and std.
            %
            import opencossan.common.inputs.random.LargeIRandomVariable;
            obj = LargeIRandomVariable(varargin{:});
        end
        %% fit
        function obj = fit(varargin) %#ok<STOUT>
            ME = MException('LargeIRandomVariable:UnsupportedOperation',...
                ['Unsupported operation.\n' ...
                'Cannot fit LargeIRandomVariable to data.']);
            throw(ME);
        end
    end
end
