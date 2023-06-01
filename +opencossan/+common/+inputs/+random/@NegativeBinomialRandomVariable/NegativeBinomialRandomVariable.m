classdef NegativeBinomialRandomVariable < opencossan.common.inputs.random.RandomVariable
    %NEGATIVEBINOMIALRANDOMVARIABLE This class defines an Object of type NegativeBinomialRandomVariable,
    %   which extends the class RandomVariable.
    %
    %   For more detailed information, see
    %   <https://cossan.co.uk/wiki/index.php/@RandomVariable>.
    %
    %   NEGATIVEBINOMIAL Properties:
    %       N
    %       P
    %       Bounds[1,2] (Constant)
    
    % Institute for Risk and Uncertainty, University of Liverpool, UK
    % email address: openengine@cossan.co.uk
    % Website: http://www.cossan.co.uk
    % =====================================================================
    % This file is part of *OpenCossan*: you can redistribute it and/or modify
    % it under the terms of the GNU General Public License as published by
    % the Free Software Foundation, either version 3 of the License.
    %
    % *OpenCossan* is distributed in the hope that it will be useful,
    % but WITHOUT ANY WARRANTY; without even the implied warranty of
    % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    % GNU General Public License for more details.
    %
    % You should have received a copy of the GNU General Public License
    % along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
    % =====================================================================
    
    properties
        R double {mustBeInteger,mustBePositive} = 1;
        P double {mustBePositive, mustBeLessThan(P,1)} = 0.1;
    end
    
    properties (Dependent)
        Mean;
        Std;
    end
    
    properties (Constant)
        Bounds(1,2) double {mustBeNumeric} = [0;Inf];
    end
    
    methods
        
        function obj = NegativeBinomialRandomVariable(varargin)
            % BINOMIALRANDOMVARIABLE Create a new object.
            %
            %   obj = BinomialRandomVariable(0.5,5) creates a new object
            %   with the parameter p set to 0.5 and r set to 5.
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
                    ["p", "r"], varargin{:});
            end
            
            obj@opencossan.common.inputs.random.RandomVariable(super_args{:});
            
            if nargin > 0
                obj.P = results.p;
                obj.R = results.r;
            end
        end
        
        function mean = get.Mean(obj)
            dist = makedist('negativebinomial','R',obj.R,'P',obj.P);
            mean = dist.mean();
        end
        
        function std = get.Std(obj)
            dist = makedist('negativebinomial','R',obj.R,'P',obj.P);
            std = dist.std();
        end
        
        function VX = cdf2physical(obj,VU)
            %CDF2PHYSICAL Inverse negative binomial cumulative distribution function.
            % VX = cdf2physical(obj,VX) returns the inverse cdf of the
            % negative binomial distribution, evaluated at the values VU.
            VX = icdf('negative binomial', VU, obj.R, obj.P);
        end
        
        function VX = map2physical(obj,VU)
            % MAP2PHYSICAL Map from standard normal into physical space.
            % VX = map2physical(obj,VU) maps the values in VU from standard
            % normal into physical space.
            VX = icdf('negative binomial', normcdf(VU),obj.R,obj.P);
        end
        
        function VU = map2stdnorm(obj,VX)
            % MAP2STDNORM Map from physical into standard normal space.
            % VU = map2stdnorm(obj,VX) maps the values in VX from physical
            % into standard normal space.
            VU = norminv(cdf('negative binomial',VX,obj.R,obj.P));
        end
        
        function VU = physical2cdf(obj,VX)
            %PHYSICAL2CDF Negative binomial cumulative distribution function.
            % VU = physical2cdf(obj,VX) returns the cdf of the negative
            % binomial distribution, evaluated at the values VX.
            VU = cdf('negative binomial',VX,obj.R,obj.P);
        end
        
        function Vpdf_vX = evalpdf(obj,Vx)
            %EVALPDF Negative binomial probability density function.
            % Y = evalpdf(obj,X) returns the pdf of the negative binomial
            % distribution, evaluated at the values X.
            Vpdf_vX = pdf('negative binomial',Vx,obj.R,obj.P);
        end
    end
    
    methods (Access = protected)
        function samples = getSamples(obj,size)
            samples = random('negative binomial',obj.R,obj.P,size);
        end
    end
    
    methods (Static)
        function obj = fromMeanAndStd(~,~,~) %#ok<STOUT>
            % FROMMEANANDSTD Create a new object from mean and std.
            %
            % This method is not supported for the
            % NegativeBinomialRandomVariable. Use the constructor instead.
            ME = MException('NegativeBinomialRandomVariable:UnsupportedOperation',...
                ['Unsupported operation.\n' ...
                'Create objects of NegativeBinomialRandomVariable using the constructor.']);
            throw(ME);
        end
        %% fit
        function varargout = fit(varargin)
            [data, frequency, censoring, alpha, qqplotFlag] = opencossan.common.inputs.random.RandomVariable.ParseFittingInput(varargin{:});
            assert(isempty(censoring),...
                'openCOSSAN:RandomVariable:negativeBinomial',...
                'Censoring can not be used for a NegativeBinomial distribution.');
            a = mle(data,'distribution','nbin','frequency',floor(frequency),  ...
                'alpha',alpha);
            obj = opencossan.common.inputs.random.NegativeBinomialRandomVariable('p',a(2),'r',round(a(1)));
            if (qqplotFlag || nargout == 2)
                h = figure;
                qqplot(data,makedist('negativebinomial','R',obj.R,'P',obj.P));
            end
            
            % TODO: testing of calculated fitting distribution to the data.
            
            varargout{1} = obj;
            if (nargout == 2); varargout{2} = h; end
        end
    end
end
