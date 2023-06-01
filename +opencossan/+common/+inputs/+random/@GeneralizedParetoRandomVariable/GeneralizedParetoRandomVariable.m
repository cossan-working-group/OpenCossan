classdef GeneralizedParetoRandomVariable < opencossan.common.inputs.random.RandomVariable
    %GENERALIZEDPARETORANDOMVARIABLE This class defines an Object of type GeneralizedParetoRandomVariable,
    %   which extends the class RandomVariable.
    %
    %   For more detailed information, see
    %   <https://cossan.co.uk/wiki/index.php/@RandomVariable>.
    %
    %   GENERALIZEDPARETO Properties:
    %       K
    %       Sigma
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
        K double;
        Sigma double {mustBePositive} = 0.1;
        Theta double;
    end
    
    properties (Dependent)
        Mean;
        Std;
    end
    
    properties (Constant)
        Bounds(1,2) double {mustBeNumeric} = [0;Inf];
    end
    
    methods
        function obj = GeneralizedParetoRandomVariable(varargin)
            % GENERALIZEDPARETORANDOMVARIABLE Create a new object.
            %
            %   obj = GeneralizedParetoRandomVariable(1,0.5,0.8) creates a
            %   new object with the parameter k set to 1, sigma set to 0.5
            %   and theta set to 0.8
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
                    ["k", "sigma", "theta"], varargin{:});
            end
            
            obj@opencossan.common.inputs.random.RandomVariable(super_args{:});
            
            if nargin > 0
                obj.K = results.k;
                obj.Sigma = results.sigma;
                obj.Theta = results.theta;
            end
        end
        
        function mean = get.Mean(obj)
            [mean,~] = gpstat(obj.K,obj.Sigma,obj.Theta);
        end
        
        function std = get.Std(obj)
            [~,Nvar] = gpstat(obj.K,obj.Sigma,obj.Theta);
            std  = sqrt(Nvar);
        end
        
        function VX = cdf2physical(obj,VU)
            %CDF2PHYSICAL Inverse exponential cumulative distribution function.
            % VX = cdf2physical(obj,VX) returns the inverse cdf of the
            % exponential distribution, evaluated at the values VU.
            VX = gpinv(VU,obj.K,obj.Sigma,obj.Theta);
        end
        
        function VX = map2physical(obj,VU)
            % MAP2PHYSICAL Map from standard normal into physical space.
            % VX = map2physical(obj,VU) maps the values in VU from standard
            % normal into physical space.
            VX = gpinv(normcdf(VU),obj.K,obj.Sigma,obj.Theta);
        end
        
        function VU = map2stdnorm(obj,VX)
            % MAP2STDNORM Map from physical into standard normal space.
            % VU = map2stdnorm(obj,VX) maps the values in VX from physical
            % into standard normal space.
            VU = norminv(gpcdf(VX,obj.K,obj.Sigma,obj.Theta));
        end
        
        function VU = physical2cdf(obj,VX)
            %PHYSICAL2CDF Generalized pareto cumulative distribution function.
            % VU = physical2cdf(obj,VX) returns the cdf of the Generalized 
            % pareto distribution, evaluated at the values VX.
            VU = gpcdf(VX,obj.K,obj.Sigma,obj.Theta);
        end
        
        function Vpdf_vX = evalpdf(obj,Vx)
            %EVALPDF Generalized pareto probability density function.
            % Y = evalpdf(obj,X) returns the pdf of the generalized pareto
            % distribution, evaluated at the values X.
            Vpdf_vX = gppdf(Vx,obj.K,obj.Sigma,obj.Theta);
        end
    end
    
    methods (Access = protected)
        function samples = getSamples(obj,size)
            samples = gprnd(obj.K,obj.Theta,obj.Sigma,size);
        end
    end
    
    methods (Static)
                function obj = fromMeanAndStd(~,~,~) %#ok<STOUT>
            % FROMMEANANDSTD Create a new object from mean and std.
            %
            % This method is not supported for the
            % ExponentialRandomVariable. Use the constructor instead.
            ME = MException('GeneralizedParetoRandomVariable:UnsupportedOperation',...
                ['Unsupported operation.\n' ...
                 'Create objects of GeneralizedParetoRandomVariable using the constructor.']);
            throw(ME);
        end

        function varargout = fit(varargin)
            p = inputParser;
            p.FunctionName = 'opencossan.common.inputs.random.GeneralizedParetoRandomVariable.fit';
            p.KeepUnmatched = true;
            p.addParameter('Theta',[]);
            p.parse(varargin{:});
            assert(~isempty(p.Results.Theta),...
                'openCOSSAN:RandomVariable:generalizedPareto',...
                'You must provide theta as the number of the treshold for a gp fit by using. theta has to be a scalar nurmeric value.');
            unmatched_args = opencossan.common.utilities.parseUnmatchedArguments(p.Unmatched);
            [data, frequency, censoring, alpha, qqplotFlag] = opencossan.common.inputs.random.RandomVariable.ParseFittingInput(unmatched_args{:});
            assert(isempty(censoring),...
                'openCOSSAN:RandomVariable:generalizedPareto',...
                'Censoring can not be used for a GeneralizedPareto distribution.');
            a = mle(data,'distribution','gp','frequency',floor(frequency),  ...
                'alpha',alpha,'theta',p.Results.Theta);
            obj = opencossan.common.inputs.random.GeneralizedParetoRandomVariable('k',a(1),'sigma',a(2),'theta',p.Results.Theta);
            
            if (qqplotFlag || nargout == 2)
                h = figure;
                qqplot(data,makedist('gp','k',obj.K,'sigma',obj.Sigma,'theta',obj.Theta));
            end
            
            if (kstest(data,'CDF', makedist('gp','k',obj.K,'sigma',obj.Sigma,'theta',obj.Theta)))
                warning('openCOSSAN:RandomVariable:GeneralizedPareto:fit',...
                    'The calculated distribution fits badly to the given DATA.')
            end
            
            varargout{1} = obj;
            if (nargout == 2); varargout{2} = h; end
        end
    end
    
end
