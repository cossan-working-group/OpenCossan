classdef BinomialRandomVariable < opencossan.common.inputs.random.RandomVariable
    %BINOMIALRANDOMVARIABLE This class defines an Object of type BinomialRandomVariable,
    %   which extends the class RandomVariable.
    %
    %   For more detailed information, see
    %   <https://cossan.co.uk/wiki/index.php/@RandomVariable>.
    %
    %   BINOMIAL Properties:
    %       P
    %       N
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
        P(1,1) double {mustBePositive, mustBeLessThan(P,1)} = 0.5;
        N(1,1) {mustBeInteger, mustBePositive} = 1;
    end
    
    properties (Dependent)
        Mean;
        Std;
    end
    
    properties (Constant)
        Bounds(1,2) double {mustBeNumeric} = [0;Inf];
    end
    
    methods
        function obj = BinomialRandomVariable(varargin)
            % BINOMIALRANDOMVARIABLE Create a new object.
            %
            %   obj = BinomialRandomVariable(0.5,10) creates a new object
            %   with the parameter p set to 0.5 and n set to 10.
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
                    ["p", "n"], varargin{:});
            end
            
            obj@opencossan.common.inputs.random.RandomVariable(super_args{:});
            
            if nargin > 0
                obj.P = results.p;
                obj.N = results.n;
            end
        end
        
        function mean = get.Mean(obj)
            [mean, ~] = binostat(obj.N,obj.P);
            mean = mean + obj.Shift;
        end
        
        function std = get.Std(obj)
            [~, var] = binostat(obj.N,obj.P);
            std = sqrt(var);
        end
        
        function VX = cdf2physical(obj,VU)
            %CDF2PHYSICAL Inverse binomial cumulative distribution function.
            % VX = cdf2physical(obj,VX) returns the inverse cdf of the 
            % binomial distribution, evaluated at the values VU.            
            VX = icdf('binomial', VU, obj.N, obj.P) + obj.Shift;
        end
        
        function VX = map2physical(obj,VU)
            % MAP2PHYSICAL Map from standard normal into physical space.
            % VX = map2physical(obj,VU) maps the values in VU from standard
            % normal into physical space.
            VX = icdf('binomial', normcdf(VU),obj.N,obj.P) + obj.Shift;
        end
        
        function VU = map2stdnorm(obj,VX)
            % MAP2STDNORM Map from physical into standard normal space.
            % VU = map2stdnorm(obj,VX) maps the values in VX from physical
            % into standard normal space.
            VU = norminv(cdf('binomial',VX - obj.Shift,obj.N,obj.P));
        end
        
        function VU = physical2cdf(obj,VX)
            %PHYSICAL2CDF Binomial cumulative distribution function.
            % VU = physical2cdf(obj,VX) returns the cdf of the binomial
            % distribution, evaluated at the values VX.
            VU = cdf('binomial',VX - obj.Shift,obj.N,obj.P);
        end
        
        %% evalpdf
        function Vpdf_vX = evalpdf(obj,Vx)
            %EVALPDF Binomial probability density function.
            % Y = evalpdf(obj,X) returns the pdf of the binomial
            % distribution, evaluated at the values X.
            Vpdf_vX = pdf('binomial',Vx - obj.Shift,obj.N,obj.P);
        end
    end
    
    methods (Access = protected)
        function samples = getSamples(obj,size)
            samples = random('binomial',obj.N,obj.P,size) + obj.Shift;
        end
    end
    
    methods (Static)
        function obj = fromMeanAndStd(~,~,~) %#ok<STOUT>
            % FROMMEANANDSTD Create a new object from mean and std.
            %
            % This method is not supported for the
            % BinomialRandomVariable. Use the constructor instead.
            ME = MException('BinomialRandomVariable:UnsupportedOperation',...
                ['Unsupported operation.\n' ...
                 'Create objects of BinomialRandomVariable using the constructor.']);
            throw(ME);
        end

        function varargout = fit(varargin)
            p = inputParser;
            p.FunctionName = 'opencossan.common.inputs.random.BinomialRandomVariable.fit';
            p.KeepUnmatched = true;
            p.addParameter('ntrials',[]);
            p.parse(varargin{:});
            unmatched_args = opencossan.common.utilities.parseUnmatchedArguments(p.Unmatched);
            assert(~isempty(p.Results.ntrials),...
                'openCOSSAN:RandomVariable:binomial',...
                'You must provide the number of trials for a binomial fit. ntrials has to be a scalar or a vector with the same length as DATA.');
            [data, frequency, censoring, alpha, qqplotFlag] = opencossan.common.inputs.random.RandomVariable.ParseFittingInput(unmatched_args{:});
            assert(isempty(censoring),...
                'openCOSSAN:RandomVariable:binomial',...
                'Censoring can not be used for a Binomial distribution.');
            a = mle(data,'distribution','bino','frequency',floor(frequency),  ...
                'alpha',alpha,'ntrials', p.Results.ntrials);
            obj = opencossan.common.inputs.random.BinomialRandomVariable('p',a,'n', p.Results.ntrials);
            
            if (qqplotFlag || nargout > 1)
                h = figure;
                qqplot(data,makedist('bino','N',obj.N,'p',obj.P))
            end
            
            if (chi2gof(data,'CDF', makedist('bino','N',obj.N,'p',obj.P)))
                warning('openCOSSAN:RandomVariable:binomial:fit',...
                    'The calculated distribution fits badly to the given DATA.')
            end
                        
            varargout{1} = obj;
            if (nargout > 1); varargout{2} = h; end
        end
    end
    
end
