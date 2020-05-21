classdef MarkovChain < opencossan.common.CossanObject
    % MarkovChain This class allows to generate samples adopting the
    %             Metropolis-Hastings algorithm.
    %
    % See also: https://cossan.co.uk/wiki/index.php/@MarkovChain
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
    
    properties
        TargetDistributions(1,:) opencossan.common.inputs.random.RandomVariableSet
        ProposalDistributions(1,:) opencossan.common.inputs.random.RandomVariableSet
        Samples(1, :) cell
        Burnin(1,1) {mustBeInteger} = 0
        Thin(1,1) {mustBeInteger} = 1
    end    
    
    properties (Dependent)
        LengthOfChains    % Effective length of the Chains
        ChainStart        % Initial points in SNS of the Markov Chains
        ChainEnd           % Last points in SNS of the Markov Chains
    end    
    
    methods        
        function  obj = MarkovChain(varargin)
            %MARKOVCHAIN
            
            if nargin == 0
                super_args = {};
            else
                [required, varargin] = opencossan.common.utilities.parseRequiredNameValuePairs(...
                    ["targetdistributions", "proposaldistributions", "samples"], varargin{:});
                [optional, super_args] = opencossan.common.utilities.parseOptionalNameValuePairs(...
                    ["burnin", "thin"], {0, 0}, varargin{:});
            end
            
            obj@opencossan.common.CossanObject(super_args{:});
            
            if nargin > 0
                obj.ProposalDistributions = required.proposaldistributions;
                obj.TargetDistributions = required.targetdistributions;
                obj.Samples{1} = required.samples;
                
                obj.Burnin = optional.burnin;
                obj.Thin = optional.thin;
            end
            
            assert(length(obj.ProposalDistributions) == length(obj.TargetDistributions), ...
                'OpenCossan:MarkovChain:', ...
                'Must have the same number of proposal and target distributions.');
        end
        
        function outdata = get.ChainStart(obj)
            outdata = obj.Samples{1};
        end
        
        function outdata = get.ChainEnd(obj)
            outdata = obj.Samples{end};
        end

        function outdata = get.LengthOfChains(obj)
            outdata = ceil((length(obj.Samples) - obj.Burnin)/ obj.Thin);
        end
        
        obj = sample(obj, points);
        obj = reject(obj, varargin);
    end

    
end
