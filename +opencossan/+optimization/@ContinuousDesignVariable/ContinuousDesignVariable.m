classdef ContinuousDesignVariable < opencossan.optimization.DesignVariable

    %{
    This file is part of OpenCossan <https://cossan.co.uk>.
    Copyright (C) 2006-2019 COSSAN WORKING GROUP

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
        LowerBound = -Inf;
        UpperBound = Inf;
    end

    methods
        function obj = ContinuousDesignVariable(varargin)
            if nargin == 0
                super_args = {};
            else
                [optional, super_args] = opencossan.common.utilities.parseOptionalNameValuePairs(...
                    ["lowerbound", "upperbound", "value"], {-inf, inf, []}, varargin{:});
            end

            obj@opencossan.optimization.DesignVariable(super_args{:});

            if nargin > 0
                obj.LowerBound = optional.lowerbound;
                obj.UpperBound = optional.upperbound;

                if ~isempty(optional.value)
                    obj.Value = optional.value;
                else
                    obj.Value = (obj.UpperBound + obj.LowerBound) / 2;
                end

                assert(obj.LowerBound < obj.UpperBound,...
                    'OpenCossan:ContinuousDesignVariable:IllegalArgument',...
                    'LowerBound must be lower than UpperBound.');

                assert(obj.Value >= obj.LowerBound && obj.Value <= obj.UpperBound,...
                    'OpenCossan:ContinuousDesignVariable:IllegalArgument',...
                    'Value must be in between the bounds.');
            end
        end

        function samples = sample(obj, varargin)
            optional = opencossan.common.utilities.parseOptionalNameValuePairs(...
                ["nsamples", "perturbation"], {1, []}, varargin{:});

            if isfinite(obj.LowerBound) && isfinite(obj.UpperBound)
                samples = unifrnd(obj.LowerBound, obj.UpperBound, optional.nsamples, 1);
            else
                assert(~isempty(optional.perturbation),...
                    'OpenCossan:ContinuousDesignVariable:MissignArgument',...
                    'Parameter ''perturbation'' is required to sample from design variable with infinite support.');

                samples = unifrnd(obj.Value*(1-optional.perturbation), obj.Value*(1+optional.perturbation), optional.nsamples, 1);
            end
        end

        function values = getValues(obj, percentiles)
            if nargin == 1
                values = Xobj.Value;
            else
                values = unifinv(percentiles, obj.LowerBound, obj.UpperBound);
            end
        end

        function percentiles = getPercentiles(obj, values)
            if nargin == 1
                values = Xobj.Value;
            end

            percentiles = unifcdf(values, obj.LowerBound, obj.UpperBound);
        end
    end
end