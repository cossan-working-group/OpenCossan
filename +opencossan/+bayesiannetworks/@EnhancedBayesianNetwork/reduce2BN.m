function EBN=reduce2BN(EBN,varargin)
% REDUCE2BN method of the class EnhancedBayesianNetwork allows to reduce the
% eBN (with continuous bounded and discrete nodes) to a traditional
% BayesianNetwork (BN) with only discrete nodes.
%
% BIBLIOGRAPHY:
%       -Bayesian Network Enhanced with Structural Reliaiblity Methods
%       (Straub & Kiureghian, 2010)
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

%% Process Input
p = inputParser;
p.FunctionName = 'opencossan.bayesiannetworks.EnhancedBayesianNetwork.reduce2BN';
p.addParameter('Parallelize',false); 
p.addParameter('SimulationObject',[]);
p.addParameter('useMarkovEnvelopes',false);
p.parse(varargin{:});
% Assign input 
Parallelize         = p.Results.Parallelize;               
useMarkovEnvelopes  = p.Results.useMarkovEnvelopes;
SimulationObject    = p.Results.SimulationObject;   




%% Compute Continuous Nodes children of non-discrete nodes
EBN=EBN.computeProbabilisticNodes;

% discretize continuous nodes which receive evidence %TODO
ContObservedNode=intersect(EBN.ObservedNodes,[EBN.ProbabilisticNodes]);
for icontEvidence=1:length(ContObservedNode) 
    EBN=EBN.discretizeNode('NodeName',ContObservedNode{icontEvidence});
end

%% Identify Simulation Object

%Initialise parallel computing 
% ListOfToolboxes=ver;
% if sum(strcmpi('Parallel Computing Toolbox',{ListOfToolboxes.Name})) && ~isa(CXsimulation{isim},'simulations.AdaptiveLineSampling')
%     Lpar=true; 
%     % start parallel pool if available
%     if isempty(gcp('nocreate'))
%         parpool;
%     end
% elseif sum(strcmpi('Parallel Computing Toolbox',{ListOfToolboxes.Name})) && isa(CXsimulation{isim},'simulations.AdaptiveLineSampling')
%     Lpar=false;
%     % shut down parallel pool (not supported by AdvancedLineSampling)
%     poolobj = gcp('nocreate');
%     delete(poolobj);
% end


%% Eliminate barren nodes (non-discrete nodes with no children neither evidence)
EBN.Nodes(ismember(EBN.NodesNames,EBN.barrenNodes))=[];

%% IDENTIFY THE MARKOV ENVELOPES OF INTEREST
% Initialize
i=1; % index Markov envelopes

Nodes2compute=EBN.nodes2compute; % identify discrete node to compute

CnodesEnvelope=cell(1,length(Nodes2compute));  % initialise cellarray of names of nodes in each envelope

while ~isempty(Nodes2compute)
    
    % Define Markov envelope of interest
    if useMarkovEnvelopes
       CnodesEnvelope{1,i}=EBN.defineMenvelope(Nodes2compute{1});
    else
       CnodesEnvelope{1,i}=intersect(EBN.NodesNames(EBN.TopologicalOrder),[Nodes2compute,EBN.ParentNodes{ismember(EBN.NodesNames,Nodes2compute)}]); 
    end
      
    NewNodesObj    = EBN.probabilisticSRM('NodesNames',CnodesEnvelope{1,i},...
        'Lpar',Parallelize,'useMarkovEnvelopes',useMarkovEnvelopes,'Simulation',SimulationObject);
    
    %TODO update correlation before updating the nodes
      
    % Remove computed nodes from CdiscreteNodes2compute
    Nodes2compute(ismember(Nodes2compute,NewNodesObj.Name))=[];
    
    % Introduce new nodes in the net
    % use this if markov envelope implemented in the future:
    %[~,indNet]=intersect(EBN.NodesNames,NewNodesObj.Name,'stable');EBN.Nodes(indNet)=NewNodesObj;
    EBN.Nodes(ismember(EBN.NodesNames,NewNodesObj.Name))=NewNodesObj;
    
    % Remove eventual barren nodes
    EBN.Nodes(ismember(EBN.NodesNames,EBN.barrenNodes))=[];
    
    % Update the index
    i=i+1;
end

% remove useless nodes
EBN.Nodes(ismember(EBN.NodesNames,EBN.barrenNodes))=[];

