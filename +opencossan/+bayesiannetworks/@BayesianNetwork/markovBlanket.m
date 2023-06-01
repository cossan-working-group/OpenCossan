function CmarkovBlanket = markovBlanket( BN, NodeName )
%MARKOVBLANKET method of the class EnhancedBayesianNetwork. Identify the
% Markov blanket (children, parents and spouses) of the node of interest.
% If more nodes are specified in CSnames, the output contains the union of
% the markov blankets
%
%
% Author: Silvia Tolo
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

%% Check the input
if ~ismember(NodeName,BN.NodesNames)
    error('openCOSSAN:bayesiannetwork:EnhancedBaeysianNetwork:markovBlanket',...
        'Please specify the name of the node of interest correctly ')
end
NodesNames=BN.NodesNames;
%% Identify node's family (Markov Blanket)
Nodeindex = ismember(NodesNames,NodeName);
Children  = BN.ChildNodes{Nodeindex};
FamilyNodes = [NodeName, BN.ParentNodes{Nodeindex},Children,BN.ParentNodes{ismember(NodesNames,Children)} ];

CmarkovBlanket =intersect(NodesNames(BN.TopologicalOrder),FamilyNodes,'stable');

end

