function [TableMarginal,TableJoint]=computeInferenceBNT(BN,varargin)
%COMPUTEINFERENCE method of the class BayesianNetwork allow to
%compute the inference on a traditional Bayesian Network (only discrete nodes) using exact
%inference algorithms. The inference is computed by the Bayes Toolbox
%for Matlab (available at:https://code.google.com/p/bnt/).
%
%
%   EXAMPLE (see tutorialBayesianNetwork)
%
%   Author: Silvia Tolo
%   Institute for Risk and Uncertainty, University of Liverpool, UK
%   email address: openengine@cossan.co.uk
%   Website: http://www.cossan.co.uk
%
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
% =====================================================================

%% Check if the Bayes' Toolbox for Matlab is installed
if ~exist('mk_bnet','file')
    error('openCOSSAN:BayesianNetwork',...
        'To compute the inference of the BN the Bayes Toolbox (available at:https://code.google.com/p/bnt/) has to be included in the Matlab path')
end

%% Process Input
p = inputParser;
p.FunctionName = 'opencossan.bayesiannetworks.BayesianNetwork.computeInferenceBNT';
p.addParameter('MarginalProbability',@(s)isstring(s));
p.addParameter('JointProbability',@(s)isstring(s));
p.addParameter('Algorithm',@(s)isstring(s));
p.addParameter('Vevidence',@(s)isnumeric(s));
p.parse(varargin{:});
% Assign input
MarginalP  = p.Results.MarginalProbability;
Vevidence       = p.Results.Vevidence;
JointP      = p.Results.JointProbability;
Algorithm       = p.Results.Algorithm;

% Exctract variables from network object



%% Build the BN (according to BNT)
TopologicalOrder    = BN.TopologicalOrder;
TopologicalNames    = BN.NodesNames(TopologicalOrder); 
TopologicalParents  = BN.ParentNodes(TopologicalOrder); 
TopologicalSize     = BN.NodesSize(TopologicalOrder); 
TopologicalEvidence = Vevidence(TopologicalOrder);
cellTopologicalEvidence = num2cell(Vevidence(TopologicalOrder));
cellTopologicalEvidence(TopologicalEvidence==0)=cell(1,sum(TopologicalEvidence==0));
% Reorganize the adjacency matrix according to the topological order
DAG            = BN.DAG(:,TopologicalOrder);
DAG            = DAG(TopologicalOrder,:);
% Build the BN structure
bnet            = mk_bnet(DAG, BN.NodesSize(TopologicalOrder),'names', TopologicalNames);
CPDs            = BN.CPDs(TopologicalOrder);

% DEFINE TRADITIONAL NODE ACCORDING TO TOOLBOX LANGUAGE
for inode=1:BN.Nnodes
    % extract the CPT of each traditional node
    tempCPD=cell2mat(CPDs{inode});
    % if the node is a root it is not required to build a named CPT
    if isempty(TopologicalParents{inode})
        bnet.CPD{inode}=tabular_CPD(bnet,inode,'CPT',tempCPD); % build tabular CPT
    else
        % specify the parents in the order they are referred to in the CPT
        CPT = mk_named_CPT([TopologicalParents{inode},TopologicalNames(inode)],...
            TopologicalNames, DAG, tempCPD);
        % specify the parents in the order they are referred to in the CPT
        bnet.CPD{inode}=tabular_CPD(bnet, inode,'CPT',CPT);
    end
end

% PREPARE JOINT PROBABILITY VARIABLES
[JointP,indJointNodes]    = intersect(TopologicalNames,JointP,'stable');

% PREPARE MARGINAL PROBABILITY VARIABLES
[MarginalP,indMarginalInNet]            = intersect(TopologicalNames,MarginalP,'stable');
[MarginalObserved,ObservedInMarginal]   = intersect(MarginalP,TopologicalNames(TopologicalEvidence~=0),'stable');


%% Compute Marginal Probabilities
% TRADITIONAL BN
TableMarginal=table;
if  ~all(MarginalP == '')
    % Build inference engine
    if strcmp(Algorithm,'Junction Tree') || strcmp(Algorithm,'JunctionTree')
        engine=jtree_inf_engine(bnet);                  % build engine
        [engine, ~]=enter_evidence(engine,cellTopologicalEvidence);   % introduce evidence in the net
    elseif strcmp(Algorithm,'Variable Elimination') || strcmp(Algorithm,'VariableElimination')
        engine=var_elim_inf_engine(bnet);     % build engine
        [engine, ~]=enter_evidence(engine,cellTopologicalEvidence);   % introduce evidence in the net
    end
    
    RowNames=cell(1,max(TopologicalSize(ismember(TopologicalNames,MarginalObserved))));
    RowNames(:)={'state'};
    RowNames=matlab.lang.makeUniqueStrings(RowNames,'state');
    % Marginal probabilities of nodes which receive evidence
    for iEv=ObservedInMarginal
        Mnode=marginal_nodes(engine,indMarginalInNet(iEv),1);% Collect marginal CPTs
        TableMarginal=[TableMarginal,table([Mnode.T;NaN(length(RowNames)-length(Mnode.T),1)],...
            'VariableNames',cellstr(MarginalObserved(iEv)),'RowNames',RowNames)];
    end
    
    % Marginal probabilities of nodes which do not receive any evidence
    indNoEvidence=1:length(MarginalP);
    indNoEvidence(ObservedInMarginal)=[];% Index marginal nodes (no evidence)  
    for imarginal=indNoEvidence
        Mnode=marginal_nodes(engine,indMarginalInNet(imarginal));
        TableMarginal=[TableMarginal,table([Mnode.T;NaN(length(RowNames)-length(Mnode.T),1)],...
        'VariableNames',cellstr(TopologicalNames(indMarginalInNet(imarginal))),'RowNames',RowNames)];
    end
    
  
end

%% ComputeJoint Probability
% TRADITIONAL BN
TableJoint=table;
if ~all(JointP == '')
    engineJoint=var_elim_inf_engine(bnet);
    [engineJoint, ~]=enter_evidence(engineJoint,cellTopologicalEvidence);
    Mjoint=marginal_nodes(engineJoint,indJointNodes',1);    
    TableJoint=cell2table({JointP,Mjoint.T},'VariableNames',{'NodesName','ProbabilityValues'});   
end
end







