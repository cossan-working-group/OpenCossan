function [Nodes2compute, Parents2process] = nodes2compute(EBN,varargin)
%IDENTIFYNODESTOCOMPUTE method of the class EnhancedBayesianNetwork.
%   Given a cellarray of discrete nodes and their index in the network, the
%   method identifies which among the input nodes have to be computed using
%   system reliability methods.
%
%   Author: Silvia Tolo
%   Institute for Risk and Uncertainty, University of Liverpool, UK
%   email address: openengine@cossan.co.uk
%   Website: http://www.cossan.co.uk

%   =====================================================================
%   This file is part of openCOSSAN.  The open general purpose matlab
%   toolbox for numerical analysis, risk and uncertainty quantification.
%
%   openCOSSAN is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License.
%
%   openCOSSAN is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
%   =====================================================================


p = inputParser;
p.FunctionName = 'opencossan.bayesiannetworks.EnhancedBayesianNetwork.nodes2compute';
p.addParameter('InputNodes',EBN.NodesNames); %name of nodes in the envelope
p.addParameter('DiscreteNodes',EBN.DiscreteNodes);
p.parse(varargin{:});
Names          = p.Results.InputNodes;
DiscreteNodes  = p.Results.DiscreteNodes;

DiscreteNodesInd = ismember(Names,DiscreteNodes);
TopologicalOrder = EBN.TopologicalOrder;
Nodes2ComputeInd = cellfun(@(x)any(ismember(Names(~DiscreteNodesInd),x)),EBN.ParentNodes);
Nodes2compute    = EBN.NodesNames(TopologicalOrder(Nodes2ComputeInd(TopologicalOrder)));
Parents2process  = {EBN.Nodes(TopologicalOrder(Nodes2ComputeInd(TopologicalOrder))).Parents};

end

