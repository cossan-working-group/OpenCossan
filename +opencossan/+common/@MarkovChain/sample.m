function obj = sample(obj, points)
    %OFFSPRING   Generate offspring for Markov chains
    %  Xs = OFFSPRING(XMKV),
    %            where XMKV ... MarkovChain array and Xs is a Samples object
    %
    % See also: https://cossan.co.uk/wiki/index.php/offspring@MarkovChain
    %
    % ================================================================== Author: Edoardo Patelli
    % Institute for Risk and Uncertainty, University of Liverpool, UK email address:
    % openengine@cossan.co.uk Website: http://www.cossan.co.uk
    
    % ===================================================================== This file is part of
    % openCOSSAN.  The open general purpose matlab toolbox for numerical analysis, risk and
    % uncertainty quantification.
    %
    % openCOSSAN is free software: you can redistribute it and/or modify it under the terms of the
    % GNU General Public License as published by the Free Software Foundation, either version 3 of
    % the License.
    %
    % openCOSSAN is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    % without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
    % the GNU General Public License for more details.
    %
    %  You should have received a copy of the GNU General Public License along with openCOSSAN.  If
    %  not, see <http://www.gnu.org/licenses/>.
    % =====================================================================
    
    if nargin == 1
        points = 1;
    end
    
    validateattributes(points, {'numeric'}, {'integer'});
    
    for i = 1:points
        samples = table();
        
        for n = 1:length(obj.ProposalDistributions)
            proposalSet = obj.ProposalDistributions(n);
            targetSet = obj.TargetDistributions(n);
            
            MU_pert = sample(proposalSet, height(obj.Samples{1}));
            
            % Calculate the point in the SNS Point from the last ring of the chain + the sample
            % generated from the proposal distribution
            MUlast = map2stdnorm(targetSet, obj.ChainEnd(:, targetSet.Names)); % Retrive matrix for speed up (1 call instead of 3 calls)
            
            Mxi = MU_pert{:,:} + MUlast{:,:};
            
            % [EP] evaluate the log of the pdf
            [~, Mrvi] = evalpdf(targetSet, 'Musamples', Mxi);
            [~, Mrv0] = evalpdf(targetSet, 'Musamples', MUlast{:,:});
            
            Mrv = Mrvi./Mrv0;
            
           %% Perturb each component of w/ probability Mrv
            
           %% Sample the component to be perturbed
            MU_index = (rand(size(Mrv)) < min(Mrv,1));
            
            MU = MUlast{:,:} + MU_pert{:,:} .* MU_index;
            
            innerSamples = array2table(MU);
            innerSamples.Properties.VariableNames = targetSet.Names;
            
            samples = [samples map2physical(targetSet, innerSamples)];
        end
        
        obj.Samples{end+1} = samples;
    end
end
