classdef StudentRandomVariable < opencossan.common.inputs.random.RandomVariable
    %STUDENTRANDOMVARIABLE This class defines an Object of type StudentRandomVariable,
    %   which extends the class RandomVariable.
    %
    %   For more detailed information, see
    %   <https://cossan.co.uk/wiki/index.php/@RandomVariable>.
    %
    %   STUDENT Properties:
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
        Nu;
    end
    
    properties (Dependent)
        Mean;
        Std;
    end
    
    properties (Constant)
        Bounds(1,2) double {mustBeNumeric} = [-Inf;Inf];
    end
    
    methods
        %% Constructor
        function obj = StudentRandomVariable(varargin)
            % STUDENTRANDOMVARIABLE Create a new object.
            %
            %   obj = StudentRandomVariable(1.5) creates a new object
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
            [mean,~] = tstat(obj.Nu);
        end
        
        function std = get.Std(obj)
            [~,Nvar] = tstat(obj.Nu);
            std  = sqrt(Nvar);
        end
        
        function VX = cdf2physical(obj,VU)
            %CDF2PHYSICAL Inverse student cumulative distribution function.
            % VX = cdf2physical(obj,VX) returns the inverse cdf of the
            % student distribution, evaluated at the values VU.
            VX = tinv(VU,obj.Nu);
        end
        
        function VX = map2physical(obj,VU)
            % MAP2PHYSICAL Map from standard normal into physical space.
            % VX = map2physical(obj,VU) maps the values in VU from standard
            % normal into physical space.
            VX = tinv(normcdf(VU),obj.Nu);
        end
        
        function VU = map2stdnorm(obj,VX)
            % MAP2STDNORM Map from physical into standard normal space.
            % VU = map2stdnorm(obj,VX) maps the values in VX from physical
            % into standard normal space.
            VU = norminv(tcdf(VX,obj.Nu));
        end
        
        function VU = physical2cdf(obj,VX)
            %PHYSICAL2CDF Student cumulative distribution function.
            % VU = physical2cdf(obj,VX) returns the cdf of the student
            % distribution, evaluated at the values VX.
            VU = tcdf(VX,obj.Nu);
        end
        
        function Vpdf_vX = evalpdf(obj,Vx)
            %EVALPDF Student probability density function.
            % Y = evalpdf(obj,X) returns the pdf of the student
            % distribution, evaluated at the values X.
            Vpdf_vX = tpdf(Vx,obj.Nu);
        end
    end
    
    methods (Access = protected)
        function samples = getSamples(obj,size)
            samples = trnd(obj.Nu,size);
        end
    end
    
    methods (Static)
        function obj = fromMeanAndStd(~,~,~) %#ok<STOUT>
            % FROMMEANANDSTD Create a new object from mean and std.
            %
            % This method is not supported for the
            % ExponentialRandomVariable. Use the constructor instead.
            ME = MException('StudentRandomVariable:UnsupportedOperation',...
                ['Unsupported operation.\n' ...
                 'Create objects of StudentRandomVariable using the constructor.']);
            throw(ME);
        end
        
        function obj = fit(varargin) %#ok<STOUT>
            ME = MException('StudentRandomVariable:NotYetImplemented',...
                'Fitting is not implemented for the StudentRandomVariable yet.');
            throw(ME);
        end
    end
end


