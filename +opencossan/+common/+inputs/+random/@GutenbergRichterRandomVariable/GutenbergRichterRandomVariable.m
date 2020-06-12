classdef GutenbergRichterRandomVariable < opencossan.common.inputs.random.RandomVariable
    %GUTENBERGRICHTERRANDOMVARIABLE This class defines an Object of type GutenbergRichterRandomVariable,
    %   which extends the class RandomVariable.
    %
    %   For more detailed information, see
    %   <https://cossan.co.uk/wiki/index.php/@RandomVariable>.
    %
    %   GUTENBERGRICHTER Properties:
    %       Bounds[1,2]
    %       B
    
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
        B double;
        Bounds(1,2) double {mustBeNumeric} = [0;Inf];
    end
    
    properties (Dependent)
        Mean;
        Std;
    end
    
    methods
        %% Constructor
        function obj = GutenbergRichterRandomVariable(varargin)
            % GUTENBERGRICHTERRANDOMVARIABLE Create a new object.
            %
            %   obj = ExponentialRandomVariable(1,[0 2.5]) creates a new object
            %   with the parameter b set to 1 and the bounds set to [0 2.5]
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
                    ["b", "bounds"], varargin{:});
            end
            obj@opencossan.common.inputs.random.RandomVariable(super_args{:});
            
            if nargin > 0
                obj.B = results.b;
                obj.Bounds = results.bounds;
            end
        end
        
        function mean = get.Mean(obj)
            b = obj.B*log(10);
            Den = (exp(-b*(obj.Bounds(1)))-exp(-b*(obj.Bounds(2))));
            mean = 1/Den*(-(obj.Bounds(2)*exp(-b*(obj.Bounds(2)))-obj.Bounds(2)*exp(-b*(obj.Bounds(1)))) - 1/b*(exp(-b*(obj.Bounds(2)))-exp(-b*(obj.Bounds(1)))));
        end
        
        function std = get.Std(~)
            std =  sqrt(exp(1)*(1)); % TODO Someone confirm this
        end
        
        function VX = cdf2physical(obj,VU)
            %CDF2PHYSICAL Inverse Gutenberg-Richter cumulative distribution function.
            % VX = cdf2physical(obj,VX) returns the inverse cdf of the
            % Gutenberg-Richter distribution, evaluated at the values VU.
            VX = obj.Bounds(1)-1/obj.B*(log10(1-VU*(1-10^(-obj.B*(obj.Bounds(2)-obj.Bounds(1))))));
        end
        
        function VX = map2physical(obj,VU)
            % MAP2PHYSICAL Map from standard normal into physical space.
            % VX = map2physical(obj,VU) maps the values in VU from standard
            % normal into physical space.
            VX = obj.Bounds(1)-1/obj.B*(log10(1-normcdf(VU)*(1-10^(-obj.B*(obj.Bounds(2)-obj.Bounds(1))))));
        end
        
        function VU = map2stdnorm(obj,VX)
            % MAP2STDNORM Map from physical into standard normal space.
            % VU = map2stdnorm(obj,VX) maps the values in VX from physical
            % into standard normal space.
            VU = (1 - 10.^(-obj.B*(VX - obj.Bounds(1))))/(1 - 10^(-obj.B*(obj.Bounds(2) - obj.Bounds(1))));
        end
        
        function VU = physical2cdf(obj,VX)
            %PHYSICAL2CDF Gutenberg-Richter cumulative distribution function.
            % VU = physical2cdf(obj,VX) returns the cdf of the
            % Gutenberg-Richter distribution, evaluated at the values VX.
            VU=(1 - 10.^(-obj.B*(VX - obj.Bounds(1))))/(1 - 10^(-obj.B*(obj.Bounds(2) - obj.Bounds(1))));
        end
        
        function Vpdf_vX = evalpdf(~,~) %#ok<STOUT>
            %EVALPDF Gutenberg-Richter probability density function.
            % Not supported.
            ME = MException('GutenbergRichterRandomVariable:UnsupportedOperation',...
                ['Unsupported operation.\n' ...
                'Evalpdf is not supported for the Gutenberg-Richter distribution.']);
            throw(ME);
        end
    end
    
    methods (Access = protected)
        function samples = getSamples(obj,size)
            samples = obj.Bounds(1)-1/obj.B*(log10(1-rand(size)*(1-10^(-obj.B*(obj.Bounds(2)-obj.Bounds(1))))));
        end
    end
    
    methods (Static)
        function obj = fromMeanAndStd(~,~,~) %#ok<STOUT>
            % FROMMEANANDSTD Create a new object from mean and std.
            %
            % This method is not supported for the
            % ExponentialRandomVariable. Use the constructor instead.
            ME = MException('GutenbergRichterRandomVariable:UnsupportedOperation',...
                ['Unsupported operation.\n' ...
                'Create objects of GutenbergRichterRandomVariable using the constructor.']);
            throw(ME);
        end
        %% fit
        function obj = fit(varargin) %#ok<STOUT>
            ME = MException('GutenbergRichterRandomVariable:UnsupportedOperation',...
                ['Unsupported operation.\n' ...
                'Cannot fit the GutenbergRichterRandomVariable to data.']);
            throw(ME);
        end
    end
end

