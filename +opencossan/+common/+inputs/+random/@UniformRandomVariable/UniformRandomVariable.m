classdef UniformRandomVariable < opencossan.common.inputs.random.RandomVariable
    %UNIFORMRANDOMVARIABLE This class defines an Object of type UniformRandomVariable,
    %   which extends the class RandomVariable.
    %
    %   For more detailed information, see
    %   <https://cossan.co.uk/wiki/index.php/@RandomVariable>.
    %
    %   UNIFORM Properties:
    %       Bounds[1,2]
    
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
        Bounds(1,2) double {mustBeNumeric} = [0, 1];
    end
    
    properties (Dependent)
        Mean;
        Std;
    end
    
    methods
        %% Constructor
        function obj = UniformRandomVariable(varargin)
            % UNIFORMRANDOMVARIABLE Create a new object.
            %
            %   obj = UniformRandomVariable([0.5 1]) creates a new object
            %   with the bounds set to 1.5
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
                    "bounds", varargin{:});
            end
            
            obj@opencossan.common.inputs.random.RandomVariable(super_args{:});
            
            if nargin > 0
                obj.Bounds = results.bounds;
            end
        end
        
        function mean = get.Mean(obj)
            mean = (obj.Bounds(1) + obj.Bounds(2)) / 2;
        end
        
        function std = get.Std(obj)
            std = (obj.Bounds(2) - obj.Bounds(1)) / (2 * sqrt(3));
        end
        
        function VX = cdf2physical(obj,VU)
            %CDF2PHYSICAL Inverse uniform cumulative distribution function.
            % VX = cdf2physical(obj,VX) returns the inverse cdf of the
            % uniform distribution, evaluated at the values VU.
            VX = unifinv(VU,obj.Bounds(1),obj.Bounds(2));
        end
        
        function VX = map2physical(obj,VU)
            % MAP2PHYSICAL Map from standard normal into physical space.
            % VX = map2physical(obj,VU) maps the values in VU from standard
            % normal into physical space.
            VX = unifinv(normcdf(VU),obj.Bounds(1),obj.Bounds(2));
        end
        
        function VU = map2stdnorm(obj,VX)
            % MAP2STDNORM Map from physical into standard normal space.
            % VU = map2stdnorm(obj,VX) maps the values in VX from physical
            % into standard normal space.
            VU = norminv(unifcdf(VX,obj.Bounds(1),obj.Bounds(2)));
        end
        
        function VU = physical2cdf(obj,VX)
            %PHYSICAL2CDF Uniform cumulative distribution function.
            % VU = physical2cdf(obj,VX) returns the cdf of the uniform
            % distribution, evaluated at the values VX.
            VU = unifcdf(VX,obj.Bounds(1),obj.Bounds(2));
        end
        
        function Vpdf_vX = evalpdf(obj,Vx)
            %EVALPDF Uniform probability density function.
            % Y = evalpdf(obj,X) returns the pdf of the uniform
            % distribution, evaluated at the values X.
            Vpdf_vX = unifpdf(Vx,obj.Bounds(1),obj.Bounds(2));
        end
    end
    
    methods (Access = protected)
        function samples = getSamples(obj,size)
            samples = unifrnd(obj.Bounds(1),obj.Bounds(2),size);
        end
    end
    
    methods (Static)
        function obj = fromMeanAndStd(varargin)
            % FROMMEANANDSTD Create a new object from mean and std.
            %
            import opencossan.common.inputs.random.UniformRandomVariable
            
            [results, varargin] = opencossan.common.utilities.parseRequiredNameValuePairs(...
                ["mean", "std"], varargin{:});
            
            a = results.mean-sqrt(3)*results.std;
            b = results.mean+sqrt(3)*results.std;
            
            varargin = [varargin {'bounds' [a b]}];
            obj = UniformRandomVariable(varargin{:});            
        end
        
        function varargout = fit(varargin)
            [data, frequency, censoring, alpha, qqplotFlag] = opencossan.common.inputs.random.RandomVariable.ParseFittingInput(varargin{:});
            assert(isempty(censoring),...
                'openCOSSAN:RandomVariable:uniform',...
                'Censoring can not be used for a Uniform distribution.');
            a = mle(data,'distribution','unif','frequency',floor(frequency),  ...
                'alpha',alpha);
            obj = opencossan.common.inputs.random.UniformRandomVariable('bounds',[a(1) a(2)]);
            if (qqplotFlag || nargout == 2)
                h = figure;
                qqplot(data,makedist('uniform','Lower',obj.Bounds(1),'upper',obj.Bounds(2)));
            end
            
            if (kstest(data,'CDF', makedist('uniform','lower',obj.Bounds(1),'Upper',obj.Bounds(2))))
                warning('openCOSSAN:RandomVariable:Uniform:fit',...
                    'The calculated distribution fits badly to the given DATA.')
            end
            
            varargout{1} = obj;
            if (nargout == 2); varargout{2} = h; end
        end
    end
end

