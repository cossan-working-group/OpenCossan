function CN=reduceCN(CN,varargin)
% REDUCECN method of the class CredalNetwork allows to reduce the
% CN (with probabilistic, interval, hybrid and discrete nodes) to a CN
% with only discrete nodes (eventually associated with interval probabilities).
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
p.FunctionName = 'opencossan.bayesiannetworks.Credal.reduceCN';
p.addParameter('Parallelize',false); 
p.addParameter('SimulationObject',[]);
p.addParameter('useMarkovEnvelopes',false);
p.parse(varargin{:});
% Assign input 
Parallelize         = p.Results.Parallelize;               
useMarkovEnvelopes  = p.Results.useMarkovEnvelopes;
SimulationObject    = p.Results.SimulationObject;   


%% Compute Continuous Nodes children of non-discrete nodes
CN=CN.computeProbabilisticNodes;
CN=CN.computeIntervalNodes;

% discretize continuous nodes which receive evidence %TODO
ContObservedProbabilistic=intersect(CN.ObservedNodes,[CN.ProbabilisticNodes]);
for iprobEvidence=1:length(ContObservedProbabilistic) 
    CN=CN.discretizeNode('NodeName',ContObservedProbabilistic{iprobEvidence});
end
ContObservedInterval=intersect(CN.ObservedNodes,[CN.IntervalNodes]);
for iintEvidence=1:length(ContObservedInterval) 
    CN=CN.discretizeNode('NodeName',ContObservedInterval{iintEvidence});
end
% TODO
% ContObservedHybrid=intersect(CN.ObservedNodes,[CN.HybridNodes]);
% for ihybrEvidence=1:length(ContObservedHybrid) 
%     CN=CN.discretizeNode('NodeName',ContObservedHybrid{ihybrEvidence});
% end

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
CN.Nodes(ismember(CN.NodesNames,CN.barrenNodes))=[];

%% IDENTIFY THE MARKOV ENVELOPES OF INTEREST
% Initialize
i=1; % index Markov envelopes

Nodes2compute=CN.nodes2compute; % identify discrete node to compute

CnodesEnvelope=cell(1,length(Nodes2compute));  % initialise cellarray of names of nodes in each envelope

while ~isempty(Nodes2compute)
    
    % Define Markov envelope of interest
    if useMarkovEnvelopes
       CnodesEnvelope{1,i}=CN.defineMenvelope(Nodes2compute{1});
    else
       CnodesEnvelope{1,i}=intersect(CN.NodesNames(CN.TopologicalOrder),[Nodes2compute,CN.ParentNodes{ismember(CN.NodesNames,Nodes2compute)}]); 
    end
    
    
    %% ASSIGN THE TYPE OF ANALYSIS NEEDED: PROBABILISTIC OR HYBRID
    if any(ismember([CN.IntervalNodes,CN.HybridNodes],CnodesEnvelope{1,i}))
        NewNodesObj    = CN.hybridSRM('NodesNames',CnodesEnvelope{1,i},...
            'Lpar',Parallelize,'useMarkovEnvelopes',useMarkovEnvelopes,'Simulation',SimulationObject);
    else
        NewNodesObj    = CN.probabilisticSRM('NodesNames',CnodesEnvelope{1,i},...
            'Lpar',Parallelize,'useMarkovEnvelopes',useMarkovEnvelopes,'Simulation',SimulationObject);        
    end
    %TODO update correlation before updating the nodes
      
    % Remove computed nodes from CdiscreteNodes2compute
    Nodes2compute(ismember(Nodes2compute,NewNodesObj.Name))=[];
    
    % Introduce new nodes in the net
    %this if MarkovEnvelope implemented in the future
    %[~,indNet]=intersect(CN.NodesNames,NewNodesObj.Name,'stable'); use
    CN.Nodes(ismember(CN.NodesNames,NewNodesObj.Name))=NewNodesObj;

    % Remove eventual barren nodes
    CN.Nodes(ismember(CN.NodesNames,CN.barrenNodes))=[];
    
    % Update the index
    i=i+1;
end

% remove useless nodes
CN.Nodes(ismember(CN.NodesNames,CN.barrenNodes))=[];

