classdef DiscreteDesignVariable < opencossan.optimization.DesignVariable

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
        Support(1,:) double;
    end

    properties (Dependent)
        LowerBound;
        UpperBound;
    end

    methods
        function obj = DiscreteDesignVariable(varargin)
            if nargin == 0
                super_args = {};
            else
                [required, varargin] = opencossan.common.utilities.parseRequiredNameValuePairs(...
                    "support", varargin{:});
                [optional, super_args] = opencossan.common.utilities.parseOptionalNameValuePairs(...
                    "value", {[]}, varargin{:});
            end

            obj@opencossan.optimization.DesignVariable(super_args{:});

            if nargin > 0
                obj.Support = required.support;

                if ~isempty(optional.value)
                    obj.Value = optional.value;
                else
                    obj.Value = min(obj.Support);
                end

                assert(ismember(obj.Value,obj.Support),...
                    'OpenCossan:ContinuousDesignVariable:IllegalArgument',...
                    'Value must be among the support points.');
            end
        end

        function lowerBound = get.LowerBound(obj)
            lowerBound = min(obj.Support);
        end

        function upperBound = get.UpperBound(obj)
            upperBound = max(obj.Support);
        end

        function samples = sample(obj, varargin)
            optional = opencossan.common.utilities.parseOptionalNameValuePairs(...
                "nsamples", {1}, varargin{:});

            samples = obj.Support(random('unid', length(obj.Support), optional.nsamples, 1))';
        end

        function values = getValues(obj, percentiles)
            if nargin == 1
                values = Xobj.Value;
            else
                values = obj.Support(floor(percentiles*(length(obj.Support)-1))+1);
            end
        end

        function percentiles = getPercentiles(obj, values)
            if nargin == 1
                values = Xobj.Value;
            end

            [~, pos] = find(obj.Support == values);

            assert(~isempty(pos),'OpenCOSSAN:DiscreteDesignVariable:IllegalArgument',...
                'The provided value %e is not part of the value set of design variable', values);

            percentiles = pos/length(obj.Support);
        end
    end
end