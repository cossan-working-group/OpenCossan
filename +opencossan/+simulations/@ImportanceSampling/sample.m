function [samples, weights] = sample(obj,varargin)
    %SAMPLE
    % This method generate a Samples object.
    % The samples are generated according the IS distribution.
    %
    % See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/sample@ImportanceSampling
    
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
    
    if ~isempty(obj.ProposalDistribution)
        [samples, weights] = obj.sampleWithProposalDistribution(varargin{:});
    elseif ~isempty(obj.DesignPoint)
        [samples, weights] = obj.sampleWithDesignPoint(varargin{:});
    else
        error('OpenCossan:ImportanceSampling:sample', ...
            'To call sampling, a ProposalDistribution or DesignPoint must be present in the object.');
    end
end