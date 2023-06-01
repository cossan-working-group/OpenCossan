classdef WeibullRandomVariable < opencossan.common.inputs.random.RandomVariable
    %WEIBULLRANDOMVARIABLE This class defines an Object of type WeibullRandomVariable,
    %   which extends the class RandomVariable.
    %
    %   For more detailed information, see
    %   <https://cossan.co.uk/wiki/index.php/@RandomVariable>.
    %
    %   WEIBULL Properties:
    %       A
    %       B
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
        A {mustBePositive} = 0.1;
        B {mustBePositive} = 0.1;
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
        function obj = WeibullRandomVariable(varargin)
            % WEIBULLRANDOMVARIABLE Create a new object.
            %
            %   obj = WeibullRandomVariable(1,0.5) creates a new object
            %   with the parameter a set to 1 and b set to 0.5
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
                    ["a", "b"], varargin{:});
            end
            
            obj@opencossan.common.inputs.random.RandomVariable(super_args{:});
            
            if nargin > 0
                obj.A = results.a;
                obj.B = results.b;
            end
        end
        
        function mean = get.Mean(obj)
            [mean,~] = wblstat(obj.A, obj.B);
        end
        
        function std = get.Std(obj)
            [~,Nvar] = wblstat(obj.A, obj.B);
            std  = sqrt(Nvar);
        end
        
        function VX = cdf2physical(obj,VU)
            %CDF2PHYSICAL Inverse weibull cumulative distribution function.
            % VX = cdf2physical(obj,VX) returns the inverse cdf of the
            % weibull distribution, evaluated at the values VU.
            VX = wblinv(VU,obj.A,obj.B);
        end
        
        function VX = map2physical(obj,VU)
            % MAP2PHYSICAL Map from standard normal into physical space.
            % VX = map2physical(obj,VU) maps the values in VU from standard
            % normal into physical space.
            VX = wblinv(normcdf(VU),obj.A,obj.B);
        end
        
        function VU = map2stdnorm(obj,VX)
            % MAP2STDNORM Map from physical into standard normal space.
            % VU = map2stdnorm(obj,VX) maps the values in VX from physical
            % into standard normal space.
            VU = norminv(wblcdf(VX,obj.A,obj.B));
        end
        
        function VU = physical2cdf(obj,VX)
            %PHYSICAL2CDF Weibull cumulative distribution function.
            % VU = physical2cdf(obj,VX) returns the cdf of the weibull
            % distribution, evaluated at the values VX.
            VU = wblcdf(VX,obj.A,obj.B);
        end
        
        function Vpdf_vX = evalpdf(obj,Vx)
            %EVALPDF Weibull probability density function.
            % Y = evalpdf(obj,X) returns the pdf of the weibull
            % distribution, evaluated at the values X.
            Vpdf_vX = wblpdf(Vx,obj.A,obj.B);
        end
    end
    
    methods (Access = protected)
        function samples = getSamples(obj,size)
            samples = wblrnd(obj.A,obj.B,size);
        end
    end
    
    methods (Static)
        function obj = fromMeanAndStd(~,~,~) %#ok<STOUT>
            % FROMMEANANDSTD Create a new object from mean and std.
            %
            % This method is not supported for the
            % WeibullRandomVariable. Use the constructor instead.
            ME = MException('WeibullRandomVariable:UnsupportedOperation',...
                ['Unsupported operation.\n' ...
                'Create objects of WeibullRandomVariable using the constructor.']);
            throw(ME);
        end
        
        function varargout = fit(varargin)
            [data, frequency, censoring, alpha, qqplotFlag] = opencossan.common.inputs.random.RandomVariable.ParseFittingInput(varargin{:});
            assert(isempty(censoring),...
                'openCOSSAN:RandomVariable:weibull',...
                'Censoring can not be used for a Weibull distribution.');
            a = mle(data,'distribution','wbl','frequency',floor(frequency),...
                'alpha',alpha);
            obj = opencossan.common.inputs.random.WeibullRandomVariable('a',a(1),'b',a(2));
            if (qqplotFlag || nargout == 2)
                h = figure;
                qqplot(data,makedist('weibull','a',obj.A,'b',obj.B));
            end
            
            if (kstest(data,'CDF', makedist('weibull','a',obj.A,'b',obj.B)))
                warning('openCOSSAN:RandomVariable:Weibull:fit',...
                    'The calculated distribution fits badly to the given DATA.')
            end
            
            varargout{1} = obj;
            if (nargout == 2); varargout{2} = h; end
        end
    end
end
