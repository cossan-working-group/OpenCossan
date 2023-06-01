classdef LogisticRandomVariable< opencossan.common.inputs.random.RandomVariable
    %LOGISTICRANDOMVARIABLE This class defines an Object of type LogisticRandomVariable,
    %   which extends the class RandomVariable.
    %
    %   For more detailed information, see
    %   <https://cossan.co.uk/wiki/index.php/@RandomVariable>.
    %
    %   LOGISTIC Properties:
    %       M
    %       S
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
        S double {mustBePositive} = 0.1;
        Mu double;
    end
    
    properties (Dependent)
        Mean;
        Std;
    end
    
    properties (Constant)
        Bounds(1,2) double {mustBeNumeric} = [-Inf;Inf];
    end
    
    methods
        %% Constructor
        function obj = LogisticRandomVariable(varargin)
            % EXPONENTIALRANDOMVARIABLE Create a new object.
            %
            %   obj = ExponentialRandomVariable(1.5) creates a new object
            %   with the parameter s set to 1.5
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
                    ["mu", "s"], varargin{:});
            end
            obj@opencossan.common.inputs.random.RandomVariable(super_args{:});
            
            if nargin > 0
                obj.Mu = results.mu;
                obj.S = results.s;
            end
        end
        
        function mean = get.Mean(obj)
            mean = obj.Mu;
        end
        
        function std = get.Std(obj)
            std = obj.S*pi*sqrt(1/3);
        end
        
        function VX = cdf2physical(obj,VU)
            %CDF2PHYSICAL Inverse logistic cumulative distribution function.
            % VX = cdf2physical(obj,VX) returns the inverse cdf of the
            % logistic distribution, evaluated at the values VU.
            VX = obj.Mu + obj.S * log(VU./(1-VU));
        end
        
        function VX = map2physical(obj,VU)
            % MAP2PHYSICAL Map from standard normal into physical space.
            % VX = map2physical(obj,VU) maps the values in VU from standard
            % normal into physical space.
            VX = obj.Mu + obj.S * log(normcdf(VU)./(1-normcdf(VU)));
        end
        
        function VU = map2stdnorm(obj,VX)
            % MAP2STDNORM Map from physical into standard normal space.
            % VU = map2stdnorm(obj,VX) maps the values in VX from physical
            % into standard normal space.
            VU = norminv(1./(1 + exp((-VX + obj.Mu)/obj.S)));
        end
        
        function VU = physical2cdf(obj,VX)
            %PHYSICAL2CDF Logistic cumulative distribution function.
            % VU = physical2cdf(obj,VX) returns the cdf of the logistic
            % distribution, evaluated at the values VX.
            VU = 1./(1 + exp((-VX + obj.Mu)/obj.S));
        end
        
        function Vpdf_vX = evalpdf(obj,Vx)
            %EVALPDF Logistic probability density function.
            % Y = evalpdf(obj,X) returns the pdf of the logistic
            % distribution, evaluated at the values X.
            Vpdf_vX = exp(-(Vx - obj.Mu)/obj.S)./(obj.S*(1+exp(-(Vx - obj.Mu)/obj.S)).^2);
        end
    end
    
    methods (Access = protected)
        function samples = getSamples(obj,size)
            VZ = normcdf(normrnd(0,1,size));
            samples = obj.Mu + obj.S * log(VZ./(1-VZ));
        end
    end
    
    methods (Static)
        function obj = fromMeanAndStd(varargin)
            [results, varargin] = opencossan.common.utilities.parseRequiredNameValuePairs(...
                    ["mean", "std"], varargin{:});
            import opencossan.common.inputs.random.LogisticRandomVariable
            s = results.std/(pi*sqrt(1/3));
            varargin = [varargin {'mu', results.mean, 's', s}];
            obj = LogisticRandomVariable(varargin{:});
        end
        
        %% fit
        function varargout = fit(varargin)
            import opencossan.common.inputs.random.LogisticRandomVariable;
            [data, frequency, censoring, alpha, qqplotFlag] = opencossan.common.inputs.random.RandomVariable.ParseFittingInput(varargin{:});
            a = mle(data,'distribution','logistic','frequency',floor(frequency),  ...
                'censoring',censoring,'alpha',alpha);
            obj = LogisticRandomVariable.fromMeanAndStd('mean',a(1),'std',a(2));
            
            if (qqplotFlag || nargout == 2)
                h = figure;
                qqplot(data,makedist('logistic','mu',obj.Mean,'sigma',obj.Std));
            end
            
            if (kstest(data,'CDF', makedist('logistic','mu',obj.Mean,'sigma',obj.Std)))
                warning('openCOSSAN:RandomVariable:Logistic:fit',...
                    'The calculated distribution fits badly to the given DATA.')
            end
            
            varargout{1} = obj;
            if (nargout == 2); varargout{2} = h; end
        end
    end
end
