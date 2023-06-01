classdef FisherSnedecorRandomVariable < opencossan.common.inputs.random.RandomVariable
    %FISHERSNEDECORRANDOMVARIABLE This class defines an Object of type FisherSnedecorRandomVariable,
    %   which extends the class RandomVariable.
    %
    %   For more detailed information, see
    %   <https://cossan.co.uk/wiki/index.php/@RandomVariable>.
    %
    %   FISHERSNEDECOR Properties:
    %       P1
    %       P2
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
        P1 double {mustBePositive} = 1;
        P2 double {mustBePositive} = 1;
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
        function obj = FisherSnedecorRandomVariable(varargin)
            % FISHERSNEDECOR Create a new object.
            %
            %   obj = FisherSnedecorRandomVariable(1,0.5) creates a new object
            %   with the parameter p1 set to 1 and p2 set to 0.5.
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
                    ["p1", "p2"], varargin{:});
            end
            obj@opencossan.common.inputs.random.RandomVariable(super_args{:});
            
            if nargin > 0
                obj.P1 = results.p1;
                obj.P2 = results.p2;
            end
        end
        
        function mean = get.Mean(obj)
            [mean, ~] = fstat(obj.P1,obj.P2);
        end
        
        function std = get.Std(obj)
            [~, var_rv] = fstat(obj.P1,obj.P2);
            std = sqrt(var_rv);
        end
        
        function VX = cdf2physical(obj,VU)
            %CDF2PHYSICAL Inverse Fisher-Snedecor cumulative distribution function.
            % VX = cdf2physical(obj,VX) returns the inverse cdf of the
            % Fisher-Snedecor distribution, evaluated at the values VU.
            VX = finv(VU,obj.P1,obj.P2);
        end
        
        function VX = map2physical(obj,VU)
            % MAP2PHYSICAL Map from standard normal into physical space.
            % VX = map2physical(obj,VU) maps the values in VU from standard
            % normal into physical space.
            VX = finv(normcdf(VU),obj.P1,obj.P2);
        end
        
        function VU = map2stdnorm(obj,VX)
            % MAP2STDNORM Map from physical into standard normal space.
            % VU = map2stdnorm(obj,VX) maps the values in VX from physical
            % into standard normal space.
            VU = norminv(fcdf(VX,obj.P1,obj.P2));
        end
        
        function VU = physical2cdf(obj,VX)
            %PHYSICAL2CDF Fisher-Snedecor cumulative distribution function.
            % VU = physical2cdf(obj,VX) returns the cdf of the 
            % Fisher-Snedecor distribution, evaluated at the values VX.
            VU =fcdf(VX,obj.P1,obj.P2);
        end
        
        function Vpdf_vX = evalpdf(obj,Vx)
            %EVALPDF Fisher-Snedecor probability density function.
            % Y = evalpdf(obj,X) returns the pdf of the Fisher-Snedecor
            % distribution, evaluated at the values X.
            Vpdf_vX = pdf('f',Vx,obj.P1,obj.P2);
        end
    end
    
    methods (Access = protected)
        function samples = getSamples(obj,size)
            samples = frnd(obj.P1,obj.P2,size);
        end
    end
    
    methods (Static)
        function obj = fromMeanAndStd(~,~,~) %#ok<STOUT>
            % FROMMEANANDSTD Create a new object from mean and std.
            %
            % This method is not supported for the
            % FisherSnedecorRandomVariable. Use the constructor instead.
            ME = MException('FisherSnedecorRandomVariable:UnsupportedOperation',...
                ['Unsupported operation.\n' ...
                'Create objects of FisherSnedecorRandomVariable using the constructor.']);
            throw(ME);
        end
        %% fit
        function obj = fit(varargin)
            ME = MException('FisherSnedecorRandomVariable:UnsupportedOperation',...
                ['Unsupported operation.\n' ...
                'Cannot fit the FisherSnedecorRandomVariable to data.']);
            throw(ME);
        end
    end
    
end
