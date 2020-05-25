classdef NormtRandomVariable < opencossan.common.inputs.random.RandomVariable
    %NORMTRANDOMVARIABLE This class defines an Object of type NormtRandomVariable,
    %   which extends the class RandomVariable.
    %
    %   For more detailed information, see
    %   <https://cossan.co.uk/wiki/index.php/@RandomVariable>.
    %
    %   NORMT Properties:
    %       M
    %       S
    %       Bounds[1,2]
    
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
        Mu double;           %meanUntrucatedDistribution;
        Sigma double;           %stdUntrucatedDistribution;
        Bounds(1,2) double {mustBeNumeric} = [-Inf;Inf];
    end
    
    properties (Dependent)
        Mean;
        Std;
    end
    
    methods
        %% Constructor
        function obj = NormtRandomVariable(varargin)
            % NORMTRANDOMVARIABLE Create a new object.
            %
            %   obj = NormtRandomVariable(0,2,[-10 10]) creates a new object
            %   with the parameter mu set to 0, sigma set to 2 and the
            %   bounds set to [-10 10].
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
                    ["mu", "sigma", "bounds"], varargin{:});
            end
            obj@opencossan.common.inputs.random.RandomVariable(super_args{:});
            
            if nargin > 0
                obj.Mu = results.mu;
                obj.Sigma = results.sigma;
                obj.Bounds = results.bounds;
            end
        end
        
        function mean = get.Mean(obj)
            alpha = (obj.Bounds(1) - obj.Mu)/obj.Sigma;
            beta = (obj.Bounds(2) - obj.Mu)/obj.Sigma;
            
            Z = normcdf(beta,0,1) - normcdf(alpha,0,1);
            
            mean = obj.Mu + obj.Sigma*(normpdf(alpha,0,1) - normpdf(beta,0,1))/Z;
        end
        
        function std = get.Std(obj)
            alpha = (obj.Bounds(1) - obj.Mu)/obj.Sigma;
            beta = (obj.Bounds(2) - obj.Mu)/obj.Sigma;
            
            Z = normcdf(beta,0,1) - normcdf(alpha,0,1);
            
            if alpha == -Inf
                var = obj.Sigma^2 * (1 + (-beta*normpdf(beta,0,1))/Z - ((normpdf(alpha,0,1) - normpdf(beta,0,1))/Z)^2 );
            elseif beta == Inf
                var = obj.Sigma^2 * (1 + (alpha*normpdf(alpha,0,1))/Z - ((normpdf(alpha,0,1) - normpdf(beta,0,1))/Z)^2 );
            else
                var = obj.Sigma^2 * (1 + (alpha*normpdf(alpha,0,1) - beta*normpdf(beta,0,1))/Z - ((normpdf(alpha,0,1) - normpdf(beta,0,1))/Z)^2 );
            end
            std  = sqrt(var);
        end
        
        function bounds = get.Bounds(obj)
            bounds = obj.Bounds;
        end
        
        function obj = set.Bounds(obj,bounds)
            obj.Bounds = bounds;
        end
        
        function VX = cdf2physical(obj,VU)
            %CDF2PHYSICAL Inverse truncated normal cumulative distribution function.
            % VX = cdf2physical(obj,VX) returns the inverse cdf of the 
            % truncated normal distribution, evaluated at the values VU.
            clft = normcdf(obj.Bounds(1),obj.Mu,obj.Sigma);
            crgt = normcdf(obj.Bounds(2),obj.Mu,obj.Sigma);
            VX = norminv((crgt - clft) * VU + clft, obj.Mu, obj.Sigma);
        end
        
        function VX = map2physical(obj,VU)
            % MAP2PHYSICAL Map from standard normal into physical space.
            % VX = map2physical(obj,VU) maps the values in VU from standard
            % normal into physical space.
            p = normcdf(VU);
            %invert CDF of normal truncated distribution
            clft = normcdf(obj.Bounds(1),obj.Mu,obj.Sigma);
            crgt = normcdf(obj.Bounds(2),obj.Mu,obj.Sigma);
            if length(p) == 1
                res = norminv(p*(crgt - clft) + clft,obj.Mu,obj.Sigma);
            else
                res = norminv(p.*(crgt - clft) + clft,obj.Mu,obj.Sigma);
            end
            tL = (res < obj.Bounds(1));
            tR = (res > obj.Bounds(2));
            ok = (res >= obj.Bounds(1)) & (res <= obj.Bounds(2));
            if obj.Bounds(1) == -Inf
                VX = res.*ok + obj.Bounds(2)*tR;
            elseif obj.Bounds(2) == Inf
                VX = res.*ok + obj.Bounds(1)*tL;
            else
                VX = res.*ok + obj.Bounds(1)*tL + obj.Bounds(2)*tR;
            end
        end
        
        %% map2stdnorm
        function VU = map2stdnorm(obj,VX)
            % MAP2STDNORM Map from physical into standard normal space.
            % VU = map2stdnorm(obj,VX) maps the values in VX from physical
            % into standard normal space.
            
            % truncation limits in the normal space
            alpha = (obj.Bounds(1) - obj.Mu)/obj.Sigma;
            beta = (obj.Bounds(2) - obj.Mu)/obj.Sigma;
            Z = normcdf(beta,0,1) - normcdf(alpha,0,1);
            if (VX < obj.Bounds(1))
                VU = -Inf;
            elseif (VX > obj.Bounds(2))
                VU = Inf;
            else
                VU = norminv( (normcdf((VX - obj.Mu)/obj.Sigma,0,1) - normcdf(alpha)*ones(size(VX)))/Z);
            end
        end
        
        function VU = physical2cdf(obj,VX)
            %PHYSICAL2CDF Truncated normal cumulative distribution function.
            % VU = physical2cdf(obj,VX) returns the cdf of the truncated
            % normal distribution, evaluated at the values VX.
            
            % truncation limits in the normal space
            alpha = (obj.Bounds(1) - obj.Mu)/obj.Sigma;
            beta = (obj.Bounds(2) - obj.Mu)/obj.Sigma;
            Z = normcdf(beta,0,1) - normcdf(alpha,0,1);
            if (VX < obj.Bounds(1))
                VU = 0;
            elseif (VX > obj.Bounds(2))
                VU = 1;
            else
                VU = (normcdf((VX - obj.Mu)/obj.Sigma,0,1) - normcdf(alpha)*ones(size(VX)))/Z;
            end
        end
        
        function Vpdf_vX = evalpdf(obj,Vx)
            %EVALPDF Truncated normal probability density function.
            % Y = evalpdf(obj,X) returns the pdf of the truncated normal
            % distribution, evaluated at the values X.
            alpha = (obj.Bounds(1) - obj.Mu)/obj.Sigma;
            beta = (obj.Bounds(2) - obj.Mu)/obj.Sigma;
            Z = normcdf(beta,0,1) - normcdf(alpha,0,1);
            Vpdf_vX = zeros(size(Vx));
            %analytical pdf of truncated gaussian
            for i = 1:length(Vx)
                if Vx(i) >= obj.Bounds(1) && Vx(i) <= obj.Bounds(2)
                    Vpdf_vX(i) = normpdf((Vx(i) - obj.Mu)/obj.Sigma,0,1)/Z;
                end
            end
        end
    end
    
    methods (Access = protected)
        function samples = getSamples(obj,size)
            p = unifrnd(0,1,size);
            %invert CDF of normal truncated distribution
            clft = normcdf(obj.Bounds(1),obj.Mu,obj.Sigma);
            crgt = normcdf(obj.Bounds(2),obj.Mu,obj.Sigma);
            if length(p) == 1
                samples = norminv(p*(crgt - clft) + clft,obj.Mu,obj.Sigma);
            else
                samples = norminv(p.*(crgt - clft) + clft,obj.Mu,obj.Sigma);
            end
        end
    end
    
    methods (Static)
        function obj = fromMeanAndStd(~,~,~) %#ok<STOUT>
            % FROMMEANANDSTD Create a new object from mean and std.
            %
            % This method is not supported for the
            % NormtRandomVariable. Use the constructor instead.
            ME = MException('NormtRandomVariable:UnsupportedOperation',...
                ['Unsupported operation.\n' ...
                'Create objects of NormtRandomVariable using the constructor.']);
            throw(ME);
        end
        
        function obj = fit(varargin) %#ok<STOUT>
            ME = MException('NormtRandomVariable:UnsupportedOperation',...
                ['Unsupported operation.\n' ...
                'Cannot fit NormtRandomVariable to data.']);
            throw(ME);
        end
    end
end

