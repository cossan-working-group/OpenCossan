classdef BetaRandomVariable < opencossan.common.inputs.random.RandomVariable
    %BETARANDOMVARIABLE This class defines an Object of type BetaRandomVariable, which
    %   extends the class RandomVariable.
    %
    %   For more detailed information, see <https://cossan.co.uk/wiki/index.php/@RandomVariable>.
    %
    %   BETA Properties:
    %       Alpha
    %       Beta
    %       Bounds[0,1] (Constant)
    
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
        Alpha(1,1) double {mustBePositive} = 0.5;
        Beta(1,1) double {mustBePositive} = 0.5;
    end
    
    properties (Dependent)
        Mean;
        Std;
    end
    
    properties (Constant)
        Bounds(1,2) double {mustBeNumeric} = [0;1];
    end
    
    methods
        %% Constructor
        function obj = BetaRandomVariable(varargin)
            % BETARANDOMVARIABLE Create a new object.
            %
            %   obj = BetaRandomVariable(1.5,2.5) creates a new object
            %   with the parameter alpha set to 1.5 and beta set to 2.5
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
                    ["alpha", "beta"], varargin{:});
            end
            
            obj@opencossan.common.inputs.random.RandomVariable(super_args{:});

            if nargin > 0
                obj.Alpha = results.alpha;
                obj.Beta = results.beta;
            end
        end
        
        function mean = get.Mean(obj)
            [mean, ~] =  betastat(obj.Alpha,obj.Beta);
            mean = mean + obj.Shift;
        end
        
        function std = get.Std(obj)
            [~, var] =  betastat(obj.Alpha,obj.Beta);
            std  = sqrt(var);
        end
        
        function VX = cdf2physical(obj,VU)
            %CDF2PHYSICAL Inverse beta cumulative distribution function.
            % VX = cdf2physical(obj,VX) returns the inverse cdf of the
            % beta distribution, evaluated at the values VU.
            VX = betainv(VU,obj.Alpha,obj.Beta) + obj.Shift;
        end
        
        function VX = map2physical(obj,VU)
            % MAP2PHYSICAL Map from standard normal into physical space.
            % VX = map2physical(obj,VU) maps the values in VU from standard
            % normal into physical space.
            VX = betainv(normcdf(VU),obj.Alpha,obj.Beta) + obj.Shift;
        end
        
        function VU = map2stdnorm(obj,VX)
            % MAP2STDNORM Map from physical into standard normal space.
            % VU = map2stdnorm(obj,VX) maps the values in VX from physical
            % into standard normal space.
            VU = norminv(betacdf(VX - obj.Shift,obj.Alpha,obj.Beta));
        end
        
        function VU = physical2cdf(obj,VX)
            %PHYSICAL2CDF Beta cumulative distribution function.
            % VU = physical2cdf(obj,VX) returns the cdf of the beta
            % distribution, evaluated at the values VX.
            VU = betacdf(VX - obj.Shift,obj.Alpha,obj.Beta);
        end
        
        function Vpdf_vX = evalpdf(obj,Vx)
            %EVALPDF Beta probability density function.
            % Y = evalpdf(obj,X) returns the pdf of the beta
            % distribution, evaluated at the values X.
            Vpdf_vX = betapdf(Vx - obj.Shift,obj.Alpha,obj.Beta);
        end
    end
    
    methods (Access = protected)
        function samples = getSamples(obj,size)
            samples = betarnd(obj.Alpha,obj.Beta,size) + obj.Shift;
        end
    end
    
    methods (Static)
        function obj = fromMeanAndStd(varargin)
            import opencossan.common.inputs.random.BetaRandomVariable
            
            [results, varargin] = opencossan.common.utilities.parseRequiredNameValuePairs(...
                ["mean", "std"], varargin{:});
            
            alpha = ((1-results.mean)/results.std^2-(1/results.mean))*results.mean^2;
            beta = alpha * ((1/results.mean)-1);
            
            varargin = [varargin {'alpha',alpha,'beta',beta}];
            
            obj = BetaRandomVariable(varargin{:});
        end
        %% fit
        function varargout = fit(varargin)
            [data, frequency, censoring, alpha, qqplotFlag] = opencossan.common.inputs.random.RandomVariable.ParseFittingInput(varargin{:});
            assert(isempty(censoring),...
                'openCOSSAN:RandomVariable:beta',...
                'Censoring can not be used for a Beta distribution.');
            a = mle(data,'distribution','beta','frequency',floor(frequency),  ...
                'alpha',alpha);
            obj = opencossan.common.inputs.random.BetaRandomVariable(...
                'alpha',a(1),'beta',a(2));
            if (qqplotFlag || nargout == 2)
                h = figure;
                qqplot(data,makedist('beta','a',obj.Alpha,'b',obj.Beta))
            end
            
            if (kstest(data,'CDF', makedist('beta','a',obj.Alpha,'b',obj.Beta)))
                warning('openCOSSAN:RandomVariable:beta:fit',...
                    'The calculated distribution fits badly to the given DATA.')
            end
            
            varargout{1} = obj;
            if (nargout == 2); varargout{2} = h; end
        end
    end
end

