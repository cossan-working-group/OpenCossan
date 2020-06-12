classdef ExponentialRandomVariable < opencossan.common.inputs.random.RandomVariable
    %EXPONENTIALRANDOMVARIABLE This class defines an Object of type ExponentialRandomVariable,
    %   which extends the class RandomVariable.
    %
    %   For more detailed information, see
    %   <https://cossan.co.uk/wiki/index.php/@RandomVariable>.
    %
    %   Properties:
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
        % Distribution parameter
        %
        % lambda = 1/mu
        Lambda(1,1) double {mustBePositive} = 1;
    end
    
    properties (Dependent)
        Mean;
        Std;
    end
    
    properties (Constant)
        Bounds(1,2) double {mustBeNumeric} = [0;Inf];
    end
    
    methods
        function obj = ExponentialRandomVariable(varargin)
            % EXPONENTIALRANDOMVARIABLE Create a new object.
            %
            %   obj = ExponentialRandomVariable(1.5) creates a new object
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
            mean = 1/obj.Lambda;
        end
        
        function std = get.Std(obj)
            std = 1/obj.Lambda;
        end
        
        function VX = cdf2physical(obj,VU)
            %CDF2PHYSICAL Inverse exponential cumulative distribution function.
            % VX = cdf2physical(obj,VX) returns the inverse cdf of the 
            % exponential distribution, evaluated at the values VU.
            VX = expinv(VU,1/obj.Lambda);
        end

        function VX = map2physical(obj,VU)
            % MAP2PHYSICAL Map from standard normal into physical space.
            % VX = map2physical(obj,VU) maps the values in VU from standard
            % normal into physical space.
            VX = expinv(normcdf(VU),1/obj.Lambda);  
        end
        
        function VU = map2stdnorm(obj,VX)
            % MAP2STDNORM Map from physical into standard normal space.
            % VU = map2stdnorm(obj,VX) maps the values in VX from physical
            % into standard normal space.
            VU = norminv(expcdf((VX),1/obj.Lambda));
        end
        
        function VU = physical2cdf(obj,VX)
            %PHYSICAL2CDF Exponential cumulative distribution function.
            % VU = physical2cdf(obj,VX) returns the cdf of the exponential
            % distribution, evaluated at the values VX.
            VU = expcdf((VX),1/obj.Lambda); 
        end
        
        function Vpdf_vX = evalpdf(obj,Vx)
        	%EVALPDF Exponential probability density function.
            % Y = evalpdf(obj,X) returns the pdf of the exponential
            % distribution, evaluated at the values X.
            Vpdf_vX = exppdf(Vx,1/obj.Lambda);
        end
    end
    
    methods (Access = protected)
        function samples = getSamples(obj,size)
            samples = exprnd(obj.Lambda,size);
        end
    end
    
    methods (Static)
        function obj = fromMeanAndStd(~,~,~) %#ok<STOUT>
            % FROMMEANANDSTD Create a new object from mean and std.
            %
            % This method is not supported for the
            % ExponentialRandomVariable. Use the constructor instead.
            ME = MException('ExponentialRandomVariable:UnsupportedOperation',...
                ['Unsupported operation.\n' ...
                 'Create objects of ExponentialRandomVariable using the constructor.']);
            throw(ME);
        end
        
        %% fit
        function varargout = fit(varargin)
            [data, frequency, censoring, alpha, qqplotFlag] = opencossan.common.inputs.random.RandomVariable.ParseFittingInput(varargin{:});
            a = mle(data,'distribution','exp','frequency',floor(frequency),  ...
                'censoring',censoring,'alpha',alpha);
            obj = opencossan.common.inputs.random.ExponentialRandomVariable('lambda',1/a);
            
            if (qqplotFlag || nargout == 2)
                h = figure;
                qqplot(data,makedist('exp','mu',obj.Mean));
            end
            
            if (kstest(data,'CDF', makedist('exp','mu',obj.Mean)))
                warning('openCOSSAN:RandomVariable:Exponential:fit',...
                    'The calculated distribution fits badly to the given DATA.')
            end

            varargout{1} = obj;
            if (nargout == 2); varargout{2} = h; end
        end
    end    
end
