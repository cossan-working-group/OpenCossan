classdef (Abstract) RandomVariable < matlab.mixin.Heterogeneous & opencossan.common.CossanObject
    %RANDOMVARIABLE This class is abstract and defines presettings for
    %   several specializations.
    %
    %   For more detailed information, see
    %   <https://cossan.co.uk/wiki/index.php/@RandomVariable>.
    %
    %   Properties:
    %       Mean
    %       Std
    %       Shift
    
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
        Shift(1,1) double {mustBeNumeric} = 0; % Distribution shift
    end
    
    properties (Dependent)
        CoV; % Coefficient of variation
    end
    
    properties (Abstract, Dependent)
        Mean; % Mean
        Std; % Standard deviation
    end
    
    methods
        %% Constructor
        function obj = RandomVariable(varargin)
            names = "Shift";
            defaults = {0};
            
            [results, super_args] = opencossan.common.utilities.parseOptionalNameValuePairs(...
                names, defaults, varargin{:});
                        
            obj@opencossan.common.CossanObject(super_args{:});
            
            obj.Shift = results.shift;
        end              
        
        function CoV = get.CoV(obj)
            if isempty(obj.Std) || isempty(obj.Mean)
                CoV = [];
            else
                CoV = obj.Std/abs(obj.Mean);
            end
        end
        
        function samples = sample(obj,size)
            %SAMPLE Create samples from this distribution.
            %
            % samples = sample(obj,size) creates samples based on the
            % dimensions given in size.
            %
            % samples = sample(obj,1) creates a single samples;
            %
            % samples = sample(obj,10) creates a column vector of 10
            % samples.
            %
            % samples = sample(obj,[10 5]) creates a 10x5 matrix of samples.
            %
            % See also getSamples
            
            if ~exist('size','var'); size = 1; end
            if numel(size) == 1; size = [size 1]; end
            
            samples = obj.getSamples(size);
        end
        
        function designVariable = transform2designVariable(obj)
            % TRANSFORM2DESIGNVARIABLE this method transforms a RandomVariable into
            % a DesignVariable
            
            designVariable = opencossan.optimization.DesignVariable();

            if ~isinf(obj.Mean) && ~isnan(obj.Mean)
                designVariable.value = obj.Mean;
            else
                error('openCOSSAN:RandomVariable:randomVariable2designVariable',...
                    'The mean of the distribution is not defined')
            end
            if ~isinf(obj.Bounds(1)) && ~isnan(obj.Bounds(1))
                designVariable.lowerBound = obj.Bounds(1);
            end
            if ~isinf(obj.Bounds(2)) && ~isnan(obj.Bounds(2))
                designVariable.upperBound = obj.Bounds(2);
            end
        end
        
        [support, pdf] = getPdf(obj,varargin)
    end
    
    methods (Static)        
        function VX = cdf2stdnorm(VU)
            %CDF2STDNORM
            
            % argument check (0 <= cdf <=1)
            res  = (VU < 0) | (VU > 1);
            if sum(res) ~= 0
                error('openCOSSAN:RandomVariable:cdf2physical',...
                    'the value of the cdf has to be in the range [0 1]');
            end
            % estimation in the SNS
            indexRightTail = VU > 0.5;
            if iscolumn(VU)
                VX(indexRightTail)  = -norminv(1 - VU(indexRightTail));
                VX(~indexRightTail) = norminv(VU(~indexRightTail));
                VX = VX(:);
            elseif isrow(VU)
                VX(indexRightTail)  = -norminv(1 - VU(indexRightTail));
                VX(~indexRightTail) = norminv(VU(~indexRightTail));
            end
        end
        
        function VU = stdnorm2cdf(VX)
            %STDNORM2CDF
            indexRightTail = VX > 0;
            if iscolumn(VX)
                VU(indexRightTail)  = 1 - normcdf(-VX(indexRightTail));
                VU(~indexRightTail) = normcdf(VX(~indexRightTail));
                VU = VU(:);
            elseif isrow(VX)
                VU(indexRightTail)  = 1 - normcdf(-VX(indexRightTail));
                VU(~indexRightTail) = normcdf(VX(~indexRightTail));
            end
        end
    end
    
    methods (Static, Access = protected)
        function  [ data, frequency, censoring, alpha, qqplotFlag ] = ParseFittingInput(varargin)
            %PARSEFITTINGINPUT
            p = inputParser;
            p.FunctionName = ['opencossan.common.inputs.random.' ...
                'RandomVariable.ParseFittingInput'];
            p.addParameter('Data',[]);
            p.addParameter('Frequency',[]);
            p.addParameter('Censoring',[]);
            p.addParameter('Alpha',0.05); % Confidence level
            p.addParameter('qqplot',false);
            p.parse(varargin{:});
                        
            data        = p.Results.Data;
            frequency   = p.Results.Frequency;
            censoring   = p.Results.Censoring;
            alpha       = p.Results.Alpha;
            qqplotFlag  = p.Results.qqplot;
        end
        
    end
    
    methods (Abstract)
        VX          = cdf2physical(obj,VU);
        VX          = map2physical(obj,VU);
        VU          = map2stdnorm(obj,VX);
        VU          = physical2cdf(obj,VX);
        Vpdf_vX     = evalpdf(obj,Vx);
    end
    
    methods (Abstract, Access = protected)
        samples = getSamples(obj,size);
    end
    
    methods (Abstract, Static)
        varargout   = fit(varargin);
        obj         = fromMeanAndStd(mean,std,varargin);
    end
end
