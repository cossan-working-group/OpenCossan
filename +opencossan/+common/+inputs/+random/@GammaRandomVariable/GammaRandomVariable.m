classdef GammaRandomVariable < opencossan.common.inputs.random.RandomVariable
    %GAMMARANDOMVARIABLE This class defines an Object of type GammaRandomVariable, which
    %   extends the class RandomVariable.
    %
    %   For more detailed information, see
    %   <https://cossan.co.uk/wiki/index.php/@RandomVariable>.
    %
    %   GAMMA Properties:
    %       K
    %       Theta
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
        K double {mustBePositive} = 0.1;
        Theta double {mustBePositive} = 0.1;
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
        function obj = GammaRandomVariable(varargin)
            % GAMMARANDOMVARIABLE Create a new object.
            %
            %   obj = GammaRandomVariable(0.1,0.1) creates a new object
            %   with the parameter k set to 0.1 and theta set to 0.1
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
                    ["k", "theta"], varargin{:});
            end
            obj@opencossan.common.inputs.random.RandomVariable(super_args{:});
            
            if nargin > 0
                obj.K = results.k;
                obj.Theta = results.theta;
            end
        end
        
        function mean = get.Mean(obj)
            [mean, ~] = gamstat(obj.K,obj.Theta);
        end
        
        function std = get.Std(obj)
            [~, var_rv] = gamstat(obj.K,obj.Theta);
            std = sqrt(var_rv);
        end
        
        function VX = cdf2physical(obj,VU)
            %CDF2PHYSICAL Inverse gamma cumulative distribution function.
            % VX = cdf2physical(obj,VX) returns the inverse cdf of the
            % gamma distribution, evaluated at the values VU.
            VX = gaminv(VU,obj.K,obj.Theta);
        end
        
        function VX = map2physical(obj,VU)
            % MAP2PHYSICAL Map from standard normal into physical space.
            % VX = map2physical(obj,VU) maps the values in VU from standard
            % normal into physical space.
            VX = gaminv(normcdf(VU),obj.K,obj.Theta);
        end
        
        function VU = map2stdnorm(obj,VX)
            % MAP2STDNORM Map from physical into standard normal space.
            % VU = map2stdnorm(obj,VX) maps the values in VX from physical
            % into standard normal space.
            VU = norminv(gamcdf(VX,obj.K,obj.Theta));
        end
        
        function VU = physical2cdf(obj,VX)
            %PHYSICAL2CDF Gamma cumulative distribution function.
            % VU = physical2cdf(obj,VX) returns the cdf of the gamma
            % distribution, evaluated at the values VX.
            VU = gamcdf(VX,obj.K,obj.Theta);
        end
        
        function Vpdf_vX = evalpdf(obj,Vx)
            %EVALPDF Gamma probability density function.
            % Y = evalpdf(obj,X) returns the pdf of the gamma
            % distribution, evaluated at the values X.
            Vpdf_vX = gampdf(Vx,obj.K,obj.Theta);
        end
        
    end
    
    methods (Access = protected)
        function samples = getSamples(obj,size)
            samples = gamrnd(obj.K,obj.Theta,size);
        end
    end
    
    methods (Static)
        function obj = fromMeanAndStd(varargin)
            % FROMMEANANDSTD Create a new object from mean and std.
            
            [results, varargin] = opencossan.common.utilities.parseRequiredNameValuePairs(...
                ["mean", "std"], varargin{:});
            
            k = (results.mean/results.std)^2;
            theta =  results.std^2/results.mean;
            
            varargin = [varargin {'k', k, 'theta', theta}];
            
            obj = opencossan.common.inputs.random.GammaRandomVariable(varargin{:});
        end
        
        function varargout = fit(varargin)
            [data, frequency, censoring, alpha, qqplotFlag] = opencossan.common.inputs.random.RandomVariable.ParseFittingInput(varargin{:});
            a = mle(data,'distribution','gam','frequency',floor(frequency),  ...
                'censoring',censoring,'alpha',alpha);
            obj = opencossan.common.inputs.random.GammaRandomVariable('k',a(1),'theta',a(2));
            
            if (qqplotFlag || nargout == 2)
                h = figure;
                qqplot(data,makedist('gam','a',obj.K,'b',obj.Theta));
            end
            
            if (kstest(data,'CDF', makedist('gam','a',obj.K,'b',obj.Theta)))
                warning('openCOSSAN:RandomVariable:Gamma:fit',...
                    'The calculated distribution fits badly to the given DATA.')
            end
            
            varargout{1} = obj;
            if (nargout == 2); varargout{2} = h; end
        end
    end
    
end
