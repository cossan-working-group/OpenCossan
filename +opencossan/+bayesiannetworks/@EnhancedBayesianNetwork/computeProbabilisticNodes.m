function EBN = computeProbabilisticNodes(EBN, varargin)
% COMPUTEPROBABILISTICNODES method of the EnhancedBayesianNetwork class,
% allows to compute the probabilistic nodes which are children of other
% probabilistic nodes. The computation is carried out by means of MonteCarlo
% methods and results in the definition of UserDefinedRandomVariables
% stored in the new CPD of the node object.
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
import opencossan.common.utilities.*
import opencossan.workers.Mio
import opencossan.common.inputs.*

p = inputParser;
p.FunctionName = 'opencossan.bayesiannetworks.EnhancedBayesianNetwork.computeProbabilisticNodes';
p.addParameter('Nodes2process',[]);
p.parse(varargin{:});
Nodes2process       = p.Results.Nodes2process;               

NodesNames          = EBN.NodesNames;
TopologicalOrder    = EBN.TopologicalOrder;
DiscreteNodes       = EBN.DiscreteNodes;
ProbabilisticNodes  = EBN.ProbabilisticNodes;
Mdag                = EBN.DAG;

% Identify nodes to compute
if isempty(Nodes2process) % If no nodes introduced  check the whole net
    LProb2Compute=ismember(NodesNames(TopologicalOrder),NodesNames(cellfun(@iscellstr,EBN.CPDs))) & ismember(NodesNames(TopologicalOrder),ProbabilisticNodes);
    Cnodes2compute=NodesNames(TopologicalOrder(LProb2Compute));
    Index2compute=TopologicalOrder(LProb2Compute);   
else
    [~,Index2compute]=intersect(NodesNames(TopologicalOrder),Nodes2process,'stable');   
end


%%  COMPUTE NON-DISCRETE NODES
for indCont=1:length(Cnodes2compute)
    % Extract node object to compute and its features
    Xnode  = EBN.Nodes(Index2compute(indCont)); 
    ProbPA = ProbabilisticNodes(ismember(ProbabilisticNodes, Xnode.Parents));
    DiscPA = DiscreteNodes(ismember(DiscreteNodes, Xnode.Parents));
    LProbPA= ismember(NodesNames,ProbPA);
    
    % Find discrete grandparents 2 be inherit
    LGrandpa =   Mdag(:,LProbPA)==1;
    GrandPas =   DiscreteNodes(ismember(DiscreteNodes,NodesNames(LGrandpa)));
    % New parents of the node to compute (ALL DISCRETE)
    NewParents = NodesNames(ismember(NodesNames,[GrandPas,DiscPA]));
    
    %% CHECK IF THE COMPUTATION DISCONNECTS THE NODE FROM THE NET!
    %N.B. If there are no discrete newParents the new node is gonna be a root:
    if isempty(NewParents)
        % Simulate removal of continuous parents
        MhypotheticalDAG=Mdag;
        MhypotheticalDAG(indNodeParents(indProbParents),Index2compute(indCont))=0;
        Lconnected  = EBN.isConnected('DAG',MhypotheticalDAG,'NodeName',Cnodes2compute(indCont));
        
        % If the node is "important" (= not a barren node) keep it connected discretizing parents with discrete descendants
        if ~Lconnected && isempty(intersect(Xnode.Name,EBN.barrenNodes))
            
            % Look for "important" parents (with discrete descendants)
            for ipa=1:length(ProbPA)
                % Is the parent directly connected with discrete variables?
                Lipa = EBN.isConnected('NodeName',ProbPA{ipa},'Descendants',DiscreteNodes); 
                
                if Lipa
                    % Is the node to compute parent of more than one discrete node to compute?
                    if length(intersect(EBN.nodes2compute,EBN.ChildNodes{indNodeParents(indProbParents(ipa))}))>1
                        % Split the Markov Envelope
                        EBN = EBN.discretizeProbabilisticNode('NodeName',ProbPA{ipa},'NprobilisticNodes',length(EBN.ChildNodes{indNodeParents(indProbParents(ipa))}));
                    else
                        % Default discretization (one discrete+ one continuous)
                        EBN = EBN.discretizeProbabilisticNode('NodeName',ProbPA{ipa});
                    end
                    [~,Index2compute(indCont)]      = intersect(NodesNames,Cnodes2compute(indCont),'stable');% New index continuous2compute
                    Xnode                           = EBN.Nodes(Index2compute(indCont));                         % Exctract the node again (parents changed!)
                    [NodeParents, indNodeParents]   = intersect(NodesNames,Xnode.Parents,'stable');     % New Parents (index in the net, topological order)
                    % Classifies new parents by type
                    [ProbPA, indProbParents]        = intersect(NodeParents,ProbabilisticNodes,'stable'); % Non Discrete parents name and index in the CSparents cell
                    DiscPA                          = intersect(NodeParents,DiscreteNodes,'stable');   % Discrete parents name and index in the CSparents cell
                    [indGrandpa ,~]                 = find(EBN.Mdag(:,indNodeParents(indProbParents))==1);  % Name of grandparents of the node to compute
                    GrandPas                        = intersect(NodesNames(indGrandpa),DiscreteNodes);    % Name of discrete grandparents of the node to compute
                    % New Parents name and Index in the net (topological order)
                    NewParents                      = intersect(NodesNames,[GrandPas,DiscPA],'stable');
                    
                end
            end
        end
    end

    LoldPaInd   = ismember(NewParents,DiscPA);        % Old discrete parents index in newParents cell

    VsizeNewPa  = EBN.NodesSize(ismember(NodesNames,NewParents));                      % Vector of new parent sizes
    
    %% Initialize variables to build the Input
    newCPD          = cell([VsizeNewPa,1]);
    
    % Preallocate Script cell
    CSscript        = cell(1,3);
    CSscript(1,1)   = {'TableOutput.out='};
    CSscript(1,3)   = {';'};
    
    %% Build Input Obj & Evaluate Function
    % The analysis is carried out for each combination of new (and then discrete) parents!
    if ~isempty(VsizeNewPa)
        Vcomputations=VsizeNewPa;
    else
        Vcomputations=size(newCPD);
    end
    Parents=lower(Xnode.Parents);
    
    for icomb=1:prod(Vcomputations)
        
        combind=num2cell(myind2sub(Vcomputations,icomb)); % combination of states of nodes involved size(newCPD)
        
        % Build input
        Xinput = EBN.probabilisticInput('Combination',combind,'CombinationNames',NewParents,'Node',Xnode);
        
        % Extract Script from nodes to compute
        if sum(LoldPaInd)==1
            CPD             = reshape(Xnode.CPD,[1,VsizeNewPa(LoldPaInd)]);  % size continuous nodes always one!
            CSscript(1,2)   = CPD(combind{LoldPaInd});
        elseif  sum(LoldPaInd)>1
            CPD             = reshape(Xnode.CPD,VsizeNewPa(LoldPaInd));  % size continuous nodes always one!
            CSscript(1,2)   = CPD(combind{LoldPaInd});
        else % no discrete parents!
            CSscript(1,2)   = Xnode.CPD;
        end
        
        % Build the evaluator
        Xm=Mio('Description', 'Continuous node computation', ...
            'Script',[CSscript{1,:}], ...
            'OutputNames',{'out'},...
            'InputNames',{Parents{:}},...
            'Format','table');
        
        Xinput      = sample(Xinput,'Nsamples',10000);
        TableOutput = Xm.evaluate(Xinput.getTable);
        values      = TableOutput.out; % Results of the model evaluation on the samples
        %% TO DO: INTRODUCE TRUNCATED RANDOM VARIABLE IF REQUESTED
        newCPD{combind{:}}  = UserDefinedRandomVariable('Vdata',values,'Vtails',[1e-20,1-1e-20]); % Build UserDefRV on the results
    end
    
    %% Overwrite newCPD values and newParents
    EBN.Nodes(Index2compute(indCont)).CPD     = newCPD;
    EBN.Nodes(Index2compute(indCont)).Parents = NewParents;
    
end






