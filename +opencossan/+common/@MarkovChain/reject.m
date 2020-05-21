function obj = reject(obj,varargin)
    %REMOVE  Remove samples from the Markov Chains
    %
    % This method remove samples from specific Markov Chains. The length of the
    % chains is restored comping the latest valid sample of the chain.
    %
    % The optional inputs is:
    % * Npoints  = length of the chain
    % * Vchain   = Specific with chain must be dropped
    %
    % See also: https://cossan.co.uk/wiki/index.php/remove@MarkovChain
    %
    % ==================================================================
    % Author: Edoardo Patelli
    % Institute for Risk and Uncertainty, University of Liverpool, UK
    % email address: openengine@cossan.co.uk
    % Website: http://www.cossan.co.uk
    
    % =====================================================================
    % This file is part of openCOSSAN.  The open general purpose matlab
    % toolbox for numerical analysis, risk and uncertainty quantification.
    %
    % openCOSSAN is free software: you can redistribute it and/or modify
    % it under the terms of the GNU General Public License as published by
    % the Free Software Foundation, either version 3 of the License.
    %
    % openCOSSAN is distributed in the hope that it will be useful,
    % but WITHOUT ANY WARRANTY; without even the implied warranty of
    % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    % GNU General Public License for more details.
    %
    %  You should have received a copy of the GNU General Public License
    %  along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
    % =====================================================================
    
    [required, varargin] = opencossan.common.utilities.parseRequiredNameValuePairs(...
        "chains", varargin{:});
    optional = opencossan.common.utilities.parseOptionalNameValuePairs(...
        "points", {1}, varargin{:});
    
    validateattributes(optional.points, {'numeric'}, {'integer'});
    
    chains = required.chains;
    points = optional.points;
    
    for i = 0:points-1
        % Reset the samples of the chains to the values in obj.Samples{end-points}
        obj.Samples{end-0}(chains, :) = obj.Samples{end-points}(chains, :);
    end
end
