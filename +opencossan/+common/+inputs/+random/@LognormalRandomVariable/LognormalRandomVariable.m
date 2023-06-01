classdef LognormalRandomVariable< opencossan.common.inputs.random.RandomVariable
    %LOGNORMALRANDOMVARIABLE This class defines an Object of type LognormalRandomVariable,
    %   which extends the class RandomVariable.
    %
    %   For more detailed information, see
    %   <https://cossan.co.uk/wiki/index.php/@RandomVariable>.
    %
    %   LOGNORMAL Properties:
    %       Mu
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
        Mu double = 0;
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
        function obj = LognormalRandomVariable(varargin)
            % EXPONENTIALRANDOMVARIABLE Create a new object.
            %
            %   obj = ExponentialRandomVariable(1,0.5) creates a new object
            %   with the parameter mu set to 1 and sigma set to 0.5
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
                    ["mu", "sigma"], varargin{:});
            end
            obj@opencossan.common.inputs.random.RandomVariable(super_args{:});
            
            if nargin > 0
                obj.Mu = results.mu;
                obj.Sigma = results.sigma;
            end
        end
        
        function mean = get.Mean(obj)
            [mean, ~] = lognstat(obj.Mu,obj.Sigma);
        end
        
        function std = get.Std(obj)
            [~, var_rv] = lognstat(obj.Mu,obj.Sigma);
            std = sqrt(var_rv);
        end
        
        function VX = cdf2physical(obj,VU)
            %CDF2PHYSICAL Inverse lognormal cumulative distribution function.
            % VX = cdf2physical(obj,VX) returns the inverse cdf of the
            % lognormal distribution, evaluated at the values VU.
            VX = logninv(VU,obj.Mu,obj.Sigma);
        end
        
        function VX = map2physical(obj,VU)
            % MAP2PHYSICAL Map from standard normal into physical space.
            % VX = map2physical(obj,VU) maps the values in VU from standard
            % normal into physical space.
            VX = logninv(normcdf(VU),obj.Mu,obj.Sigma);
        end
        
        function VU = map2stdnorm(obj,VX)
            % MAP2STDNORM Map from physical into standard normal space.
            % VU = map2stdnorm(obj,VX) maps the values in VX from physical
            % into standard normal space.
            VU = norminv(logncdf(VX,obj.Mu,obj.Sigma)); % TODO is the obj.Shift missing here?  VX - obj.Shift
        end
        
        function VU = physical2cdf(obj,VX)
            %PHYSICAL2CDF Lognormal cumulative distribution function.
            % VU = physical2cdf(obj,VX) returns the cdf of the lognormal
            % distribution, evaluated at the values VX.
            VU = (logncdf(VX,obj.Mu,obj.Sigma));
        end
        
        function Vpdf_vX = evalpdf(obj,Vx)
            %EVALPDF Lognormal probability density function.
            % Y = evalpdf(obj,X) returns the pdf of the lognormal
            % distribution, evaluated at the values X.
            Vpdf_vX  = lognpdf(Vx,obj.Mu,obj.Sigma);
        end
    end
    
    methods (Access = protected)
        function samples = getSamples(obj,size)
            samples = lognrnd(obj.Mu,obj.Sigma,size);
        end
    end
    
    methods (Static)
        function obj = fromMeanAndStd(varargin)
            import opencossan.common.inputs.random.LognormalRandomVariable
            
            [results, varargin] = opencossan.common.utilities.parseRequiredNameValuePairs(...
                ["mean", "std"], varargin{:});
            var = results.std*results.std;
            mu = log(results.mean^2 / sqrt(var+results.mean^2));
            sigma = sqrt(log(var/results.mean^2 + 1));
            
            varargin = [varargin {'mu', mu, 'sigma', sigma}];
            obj = LognormalRandomVariable(varargin{:});
        end
        %% fit
        function varargout = fit(varargin)
            [data, frequency, censoring, alpha, qqplotFlag] = opencossan.common.inputs.random.RandomVariable.ParseFittingInput(varargin{:});
            a = mle(data,'distribution','logn','frequency',floor(frequency),  ...
                'censoring',censoring,'alpha',alpha);
            obj = opencossan.common.inputs.random.LognormalRandomVariable('mu',a(1),'sigma',a(2));
            if (qqplotFlag || nargout == 2)
                h = figure;
                qqplot(data,makedist('lognormal','mu',obj.Mu,'Sigma',obj.Sigma));
            end
            
            if (kstest(data,'CDF', makedist('lognormal','mu',obj.Mu,'sigma',obj.Sigma)))
                warning('openCOSSAN:RandomVariable:Lognormal:fit',...
                    'The calculated distribution fits badly to the given DATA.')
            end
            
            varargout{1} = obj;
            if (nargout == 2); varargout{2} = h; end
        end
    end
end
