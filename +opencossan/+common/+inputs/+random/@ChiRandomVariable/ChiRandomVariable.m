classdef ChiRandomVariable < opencossan.common.inputs.random.RandomVariable
    %CHIRANDOMVARIABLE This class defines an Object of type ChiRandomVariable, which
    %   extends the class RandomVariable.
    %
    %   For more detailed information, see
    %   <https://cossan.co.uk/wiki/index.php/@RandomVariable>.
    %
    %   CHI Properties:
    %       Nu
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
        Nu(1,1) {mustBePositive,mustBeInteger} = 1;
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
        function obj = ChiRandomVariable(varargin)
            % CHIRANDOMVARIABLE Create a new object.
            %
            %   obj = ChiRandomVariable(1.5) creates a new object
            %   with the parameter nu set to 1.5
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
                    "nu", varargin{:});
            end
            
            obj@opencossan.common.inputs.random.RandomVariable(super_args{:});
            
            if nargin > 0
                obj.Nu = results.nu;
            end
        end
        
        function mean = get.Mean(obj)
            [mean,~] = chi2stat(obj.Nu);
        end
        
        function std = get.Std(obj)
            [~,var] = chi2stat(obj.Nu);
            std = sqrt(var);
        end
        
        function VX = cdf2physical(obj,VU)
            %CDF2PHYSICAL Inverse exponential cumulative distribution function.
            % VX = cdf2physical(obj,VX) returns the inverse cdf of the
            % chi-square distribution, evaluated at the values VU.
            VX = chi2inv(VU,obj.Nu);
        end
        
        function VX = map2physical(obj,VU)
            % MAP2PHYSICAL Map from standard normal into physical space.
            % VX = map2physical(obj,VU) maps the values in VU from standard
            % normal into physical space.
            VX = chi2inv(normcdf(VU),obj.Nu);
        end
        
        function VU = map2stdnorm(obj,VX)
            % MAP2STDNORM Map from physical into standard normal space.
            % VU = map2stdnorm(obj,VX) maps the values in VX from physical
            % into standard normal space.
            VU = norminv(chi2cdf(VX,obj.Nu));
        end
        
        function VU = physical2cdf(obj,VX)
            %PHYSICAL2CDF Chi-square cumulative distribution function.
            % VU = physical2cdf(obj,VX) returns the cdf of the chi-square
            % distribution, evaluated at the values VX.
            VU = chi2cdf(VX,obj.Nu);
        end
        
        function Vpdf_vX = evalpdf(obj,Vx)
            %EVALPDF Chi-square probability density function.
            % Y = evalpdf(obj,X) returns the pdf of the chi-square
            % distribution, evaluated at the values X.
            Vpdf_vX = pdf('CHI2',Vx,obj.Nu);
        end
    end
    
    methods (Access = protected)
        function samples = getSamples(obj,size)
            samples = chi2rnd(obj.Nu,size);
        end
    end
    
    methods (Static)
        function obj = fromMeanAndStd(~,~,~) %#ok<STOUT>
            % FROMMEANANDSTD Create a new object from mean and std.
            %
            % This method is not supported for the
            % ChiRandomVariable. Use the constructor instead.
            ME = MException('ChiRandomVariable:UnsupportedOperation',...
                ['Unsupported operation.\n' ...
                'Create objects of ChiRandomVariable using the constructor.']);
            throw(ME);
        end
        
        function obj = fit(varargin) %#ok<STOUT>
            ME = MException('ChiRandomVariable:UnsupportedOperation',...
                ['Unsupported operation.\n' ...
                'Cannot fit the ChiRandomVariable to data.']);
            throw(ME);
        end
    end
    
end
