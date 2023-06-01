classdef NormalRandomVariable < opencossan.common.inputs.random.RandomVariable
    %NORMALRANDOMVARIABLE This class defines an Object of type NormalRandomVariable,
    %   which extends the class RandomVariable.
    %
    %   For more detailed information, see
    %   <https://cossan.co.uk/wiki/index.php/@RandomVariable>.
    %
    %   NORMAL Properties:
    %       Mean
    %       Std
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
    
    properties (Access = private)
        Mean_ double = 1;
        Std_ double  {mustBeNonnegative} = 0;
    end
    
    properties (Dependent)
        Mean;
        Std;
    end
    
    properties (Constant)
        Bounds(1,2) double {mustBeNumeric} = [-Inf;Inf];
    end
    
    methods
        function obj = NormalRandomVariable(varargin)
            % NORMALRANDOMVARIABLE Create a new object.
            %
            %   obj = NormalRandomVariable(1,0.5) creates a new object
            %   with the mean set to 1 and the standard deviation set to
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
        
        function std = get.Std(obj)
            std = obj.Std_;
        end
        
        function VX = cdf2physical(obj,VU)
            %CDF2PHYSICAL Inverse normal cumulative distribution function.
            % VX = cdf2physical(obj,VX) returns the inverse cdf of the
            % normal distribution, evaluated at the values VU.
            VX = norminv(VU, obj.Mean, obj.Std);
        end
        
        function VX = map2physical(obj,VU)
            % MAP2PHYSICAL Map from standard normal into physical space.
            % VX = map2physical(obj,VU) maps the values in VU from standard
            % normal into physical space.
            VX = VU * obj.Std + obj.Mean;
        end
        
        function VU = map2stdnorm(obj,VX)
            % MAP2STDNORM Map from physical into standard normal space.
            % VU = map2stdnorm(obj,VX) maps the values in VX from physical
            % into standard normal space.
            VU = (VX - obj.Mean)/obj.Std;
        end
        
        function VU = physical2cdf(obj,VX)
            %PHYSICAL2CDF Normal cumulative distribution function.
            % VU = physical2cdf(obj,VX) returns the cdf of the normal
            % distribution, evaluated at the values VX.
            VU = normcdf(VX,obj.Mean,obj.Std);
        end
        
        function Vpdf_vX = evalpdf(obj,Vx)
            %EVALPDF Normal probability density function.
            % Y = evalpdf(obj,X) returns the pdf of the normal
            % distribution, evaluated at the values X.
            Vpdf_vX  = normpdf(Vx,obj.Mean,obj.Std);
        end
    end
    
    methods (Access = protected)
        function samples = getSamples(obj,size)
            samples = normrnd(obj.Mean,obj.Std,size);
        end
    end
    
    methods (Static)
        function obj = fromMeanAndStd(varargin)
            % FROMMEANANDSTD Create a new object from mean and std.
            %
            import opencossan.common.inputs.random.NormalRandomVariable
            
            obj = NormalRandomVariable(varargin{:});
        end
        
        function varargout = fit(varargin)
            [data, frequency, censoring, alpha, qqplotFlag] = opencossan.common.inputs.random.RandomVariable.ParseFittingInput(varargin{:});
            a = mle(data,'distribution','norm','frequency',floor(frequency),  ...
                'censoring',censoring,'alpha',alpha);
            obj = opencossan.common.inputs.random.NormalRandomVariable('mean',a(1),'std',a(2));
            if (qqplotFlag || nargout == 2)
                h = figure;
                qqplot(data,makedist('normal','Mu',obj.Mean,'sigma',obj.Std));
            end
            
            if (kstest(data,'CDF', makedist('normal','Mu',obj.Mean,'sigma',obj.Std)))
                warning('openCOSSAN:RandomVariable:Normal:fit',...
                    'The calculated distribution fits badly to the given DATA.')
            end
            
            varargout{1} = obj;
            if (nargout == 2); varargout{2} = h; end
        end
    end
end
