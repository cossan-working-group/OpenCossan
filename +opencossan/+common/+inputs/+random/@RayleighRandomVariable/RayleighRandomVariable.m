classdef RayleighRandomVariable< opencossan.common.inputs.random.RandomVariable
    %RAYLEIGHRANDOMVARIABLE This class defines an Object of type RayleighRandomVariable,
    %   which extends the class RandomVariable.
    %
    %   For more detailed information, see
    %   <https://cossan.co.uk/wiki/index.php/@RandomVariable>.
    %
    %   RAYLEIGH Properties:
    %       Sigma
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
        Sigma double {mustBePositive} = 0.1;
    end
    
    properties (Dependent)
        Mean;
        Std;
    end
    
    properties (Constant)
        Bounds(1,2) double {mustBeNumeric} = [0;Inf];
    end
    
    methods
        function obj = RayleighRandomVariable(varargin)
            % EXPONENTIALRANDOMVARIABLE Create a new object.
            %
            %   obj = ExponentialRandomVariable(1.5) creates a new object
            %   with the parameter sigma set to 1.5
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
                    "sigma", varargin{:});
            end
            
            obj@opencossan.common.inputs.random.RandomVariable(super_args{:});
            
            if nargin > 0
                obj.Sigma = results.sigma;
            end
        end
        
        function mean = get.Mean(obj)
            [mean,~] = raylstat(obj.Sigma);
            mean = mean + obj.Shift;
        end
        
        function std = get.Std(obj)
            [~,var] = raylstat(obj.Sigma);
            std  = sqrt(var);
        end
        
        function VX = cdf2physical(obj,VU)
            %CDF2PHYSICAL Inverse rayleigh cumulative distribution function.
            % VX = cdf2physical(obj,VX) returns the inverse cdf of the
            % rayleigh distribution, evaluated at the values VU.
            VX = raylinv(VU,obj.Sigma) + obj.Shift;
        end
        
        function VX = map2physical(obj,VU)
            % MAP2PHYSICAL Map from standard normal into physical space.
            % VX = map2physical(obj,VU) maps the values in VU from standard
            % normal into physical space.
            VX = raylinv(normcdf(VU),obj.Sigma) + obj.Shift;
        end
        
        function VU = map2stdnorm(obj,VX)
            % MAP2STDNORM Map from physical into standard normal space.
            % VU = map2stdnorm(obj,VX) maps the values in VX from physical
            % into standard normal space.
            VU = norminv(raylcdf((VX - obj.Shift - (obj.Mean - obj.Std*1.91305838027110)),obj.Std/sqrt(2 - pi/2)));
        end
        
        function VU = physical2cdf(obj,VX)
            %PHYSICAL2CDF Rayleigh cumulative distribution function.
            % VU = physical2cdf(obj,VX) returns the cdf of the rayleigh
            % distribution, evaluated at the values VX.
            VU = (raylcdf((VX - obj.Shift - (obj.Mean - obj.Std*1.91305838027110)),obj.Std/sqrt(2 - pi/2)));
        end
        
        function Vpdf_vX = evalpdf(obj,Vx)
            %EVALPDF Rayleigh probability density function.
            % Y = evalpdf(obj,X) returns the pdf of the rayleigh
            % distribution, evaluated at the values X.
            Vpdf_vX = raylpdf(Vx - obj.Shift,obj.Sigma);
        end
    end
    
    methods (Access = protected)
        function samples = getSamples(obj,size)
            samples = raylrnd(obj.Sigma,size) + obj.Shift;
        end
    end
    
    methods (Static)
        function obj = fromMeanAndStd(varargin)
            % FROMMEANANDSTD Create a new object from mean and std.
            import opencossan.common.inputs.random.RayleighRandomVariable
            
            [results, varargin] = opencossan.common.utilities.parseOptionalNameValuePairs(...,
                ["mean", "std"], {[], []}, varargin{:});
            assert(xor(~isempty(results.mean), ~isempty(results.std)),...
                'RayleighRandomVariable:IllegalArguments',...
                'For the RayleighRandomVariable provide either the mean or the std.');
            if ~isempty(results.mean)
                varargin = [varargin {'sigma', results.mean/sqrt(pi/2)}];
            else
                varargin = [varargin {'sigma', results.std/sqrt(2 - pi/2)}];
            end
            obj = RayleighRandomVariable(varargin{:});
        end
        
        function varargout = fit(varargin)
            [data, frequency, censoring, alpha, qqplotFlag] = opencossan.common.inputs.random.RandomVariable.ParseFittingInput(varargin{:});
            assert(isempty(censoring),...
                'openCOSSAN:RandomVariable:rayleigh',...
                'Censoring can not be used for a Rayleigh distribution.');
            a = mle(data,'distribution','rayl','frequency',floor(frequency),  ...
                'alpha',alpha);
            obj = opencossan.common.inputs.random.RayleighRandomVariable('sigma',a);
            if (qqplotFlag || nargout == 2)
                h = figure;
                qqplot(data,makedist('rayleigh','b',obj.Sigma));
            end
            
            if (kstest(data,'CDF', makedist('rayleigh','b',obj.Sigma)))
                warning('openCOSSAN:RandomVariable:Rayleigh:fit',...
                    'The calculated distribution fits badly to the given DATA.')
            end
            
            varargout{1} = obj;
            if (nargout == 2); varargout{2} = h; end
        end
    end
end
