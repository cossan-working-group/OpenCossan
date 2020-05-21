classdef SubsetInfinite < opencossan.simulations.Subset
    % SUBSET simulation class.  Subset Simulation is a simulation method
    % to compute small (i.e., rare event) failure probabilities encountered
    % in engineering systems.
    % The basic idea is to express a small failure probability as a product
    % of larger conditional probabilities by introducing intermediate
    % failure events. This conceptually converts the original rare event
    % problem into a series of frequent event problems that are easier to
    % solve.
    %
    % See also: https://cossan.co.uk/wiki/index.php/@Subset
    %
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
    
    properties (SetAccess = protected)
        ProposalStd = 0.5            % Vector of chosen standard deviation
        UpdateStd(1,1) logical = false;         % if true, an adaptive proposal distribution is used
    end
    
    methods

        function obj = SubsetInfinite(varargin)
            % SUBSET constructor. This function constructs a Subset Simulation
            % object.
            %
            % Subset object is used to compute small (i.e., rare event) failure
            % probabilities encountered in engineering systems.
            % The basic idea is to express a small failure probability as a
            % product of larger conditional probabilities by introducing
            % intermediate failure events.
            %
            % See also: https://cossan.co.uk/wiki/index.php/@Subset
            %
            % Author: Edoardo Patelli
            % Institute for Risk and Uncertainty, University of Liverpool, UK
            % email address: openengine@cossan.co.uk
            % Website: http://www.cossan.co.uk
            
          if nargin == 0
              super_args = {};
          else
              [optional, super_args] = opencossan.common.utilities.parseOptionalNameValuePairs(...
                  ["proposalstd", "updatestd"], {0.5, false}, varargin{:});
          end
          
          obj@opencossan.simulations.Subset(super_args{:});
          
          if nargin > 0
              obj.ProposalStd = optional.proposalstd;
              obj.UpdateStd = optional.updatestd;
          end
            
        end
        
    end
end

