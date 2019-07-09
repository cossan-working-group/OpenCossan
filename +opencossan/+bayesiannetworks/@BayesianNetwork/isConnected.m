function [Lconnected, Unconnected] = isConnected( BN, varargin)
% ISCONNECTED method of the class EnhnacedBayesianNetwork, checks if the
% node of index nodeIndex is connected to the net (Lconnected), specifying
% which nodes are connected to it (Connected) and which are not
% (Unconnected). If Cnames is entered as input the method evaluate the
% existence of a direct path (direction:ancestor to offspring) between the
% nodeName and at least one of the nodes in Cdescendants.
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

%% Input
p = inputParser;
p.FunctionName = 'opencossan.bayesiannetworks.BayesianNetwork.isConnected';

% Initialize input
p.addParameter('NodesName', BN.NodesNames); 
p.addParameter('DAG',BN.DAG);
p.addParameter('Descendants', string);

p.parse(varargin{:});
% Assign input 
Node        = p.Results.NodesName;
DAG         = p.Results.DAG;
Descendants = p.Results.Descendants;

NodesInNet=ismember(BN.NodesNames,Node);
EventualChildren= DAG(NodesInNet,:);
EventualParents=DAG(:,NodesInNet)';

%% flag Lconnected tells if the node is connected to the network
Lconnected=sum(EventualChildren+EventualParents,2)~=0;
Unconnected=Node(Lconnected==false);
% if the search regards the whole network Lconnected tells if all the nodes
% are connected
if length(Lconnected)==BN.Nnodes
    Lconnected=true;
end


if ~(Descendants=="")
    assert(length(Node)==1 && size(DAG,1)==BN.Nnodes,...
        'To check the existence of direct path a single parent node must be introduced');
    TopologicalNodeInNet=BN.TopologicalOrder(NodesInNet);
    Nnodes2check=BN.Nnodes-TopologicalNodeInNet-length(Descendants);
    DescendantsParents=logical(sum(DAG(:,ismember(BN.NodesNames,Descendants)),2)');
    common=EventualChildren.*DescendantsParents;
    tmp=1;
    while (sum(common)==0 && tmp<= Nnodes2check)
        DescendantsParents=logical(sum(DAG(:,DescendantsParents),2)');
        common=EventualChildren.*DescendantsParents;
        tmp=tmp+1;
    end
    Lconnected=sum(common)~=0;
end
