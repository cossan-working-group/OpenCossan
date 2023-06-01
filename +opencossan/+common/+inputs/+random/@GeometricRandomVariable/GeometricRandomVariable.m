classdef GeometricRandomVariable < opencossan.common.inputs.random.RandomVariable
    %GEOMETRICRANDOMVARIABLE This class defines an Object of type GeometricRandomVariable,
    %   which extends the class RandomVariable.
    %
    %   For more detailed information, see
    %   <https://cossan.co.uk/wiki/index.php/@RandomVariable>.
    %
    %   GEOMETRIC Properties:
    %       Lambda
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
        Lambda double {mustBePositive, mustBeLessThan(Lambda, 1)} = 0.1;
    end
    
    properties (Dependent)
        Mean;
        Std;
    end
    
    properties (Constant)
        Bounds(1,2) double {mustBeNumeric} = [0;Inf];
    end
    
    methods
        %% Constructor
        function obj = GeometricRandomVariable(varargin)
            % GEOMETRICRANDOMVARIABLE Create a new object.
            %
            %   obj = GeometricRandomVariable(0.5) creates a new object
            %   with the parameter lambda set to 1.5
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
                    "lambda", varargin{:});
            end
            
            obj@opencossan.common.inputs.random.RandomVariable(super_args{:});
            
            if nargin > 0
                obj.Lambda = results.lambda;
            end
        end
        
        function mean = get.Mean(obj)
            [mean,~] = geostat(obj.Lambda);
        end
        
        function std = get.Std(obj)
            [~,Nvar] = geostat(obj.Lambda);
            std  = sqrt(Nvar);
        end
        
        
        function VX = cdf2physical(obj,VU)
            %CDF2PHYSICAL Inverse geometric cumulative distribution function.
            % VX = cdf2physical(obj,VX) returns the inverse cdf of the
            % geometric distribution, evaluated at the values VU.
            VX = icdf('geometric', VU,obj.Lambda);
        end
        
        function VX = map2physical(obj,VU)
            % MAP2PHYSICAL Map from standard normal into physical space.
            % VX = map2physical(obj,VU) maps the values in VU from standard
            % normal into physical space.
            VX = icdf('geometric',normcdf(VU),obj.Lambda);
        end
        
        function VU = map2stdnorm(obj,VX)
            % MAP2STDNORM Map from physical into standard normal space.
            % VU = map2stdnorm(obj,VX) maps the values in VX from physical
            % into standard normal space.
            VU = norminv(cdf('geometric',VX,obj.Lambda));
        end
        
        function VU = physical2cdf(obj,VX)
            %PHYSICAL2CDF Geometric cumulative distribution function.
            % VU = physical2cdf(obj,VX) returns the cdf of the geometric
            % distribution, evaluated at the values VX.
            VU = cdf('geometric',VX,obj.Lambda);
        end
        
        function Vpdf_vX = evalpdf(obj,Vx)
            %EVALPDF Geometric probability density function.
            % Y = evalpdf(obj,X) returns the pdf of the geometric
            % distribution, evaluated at the values X.
            Vpdf_vX = pdf('geometric',Vx,obj.Lambda);
        end
    end
    
    methods (Access = protected)
        function samples = getSamples(obj,size)
            samples = random('geometric',obj.Lambda,size);
        end
    end
    
    methods (Static)
        function obj = fromMeanAndStd(~,~,~) %#ok<STOUT>
            % FROMMEANANDSTD Create a new object from mean and std.
            %
            % This method is not supported for the
            % GeometricRandomVariable. Use the constructor instead.
            ME = MException('GeometricRandomVariable:UnsupportedOperation',...
                ['Unsupported operation.\n' ...
                'Create objects of GeometricRandomVariable using the constructor.']);
            throw(ME);
        end
        
        function varargout = fit(varargin)
            [data, frequency, censoring, alpha, qqplotFlag] = opencossan.common.inputs.random.RandomVariable.ParseFittingInput(varargin{:});
            assert(isempty(censoring),...
                'openCOSSAN:RandomVariable:geometric',...
                'Censoring can not be used for a Geometric distribution.');
            a = mle(data,'distribution','geo','frequency',floor(frequency),  ...
                'alpha',alpha);
            obj = opencossan.common.inputs.random.GeometricRandomVariable('lambda',a);
            
            if (qqplotFlag || nargout > 1)
                % TODO: Add qqplot
                ME = MException('GeometricRandomVariable:UnsupportedOperation',...
                    ['Unsupported operation.\n' ...
                    'GeometricRandomVariable does not have a qqplot yet.']);
                throw(ME);
            end
            
            % TODO: Add kstest
            varargout{1} = obj;
        end
    end
end
