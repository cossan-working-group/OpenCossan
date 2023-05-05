classdef (Abstract) DesignVariable < matlab.mixin.Heterogeneous & opencossan.common.CossanObject
    %DesignVariable Abstract class representing a design variable. There exist two subclasses for
    % discrete and continuous design variables.
    %
    % See also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@DesignVariable

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
        Value(1,1) double;  % Current value of the design variable
    end

    methods
        function obj = DesignVariable(varargin)
            % DesignVariable

            if nargin == 0
                varargin = {};
            end

            obj@opencossan.common.CossanObject(varargin{:});
        end
    end

    methods (Abstract)
        samples = sample(obj, varargin);    % This method generate samples of the DesignVariable object.
        value = getValues(obj, x);           % Return the value corresponding to a specific percentile
        percentile = getPercentiles(obj, p); % Return the percentile for a value
    end
end
