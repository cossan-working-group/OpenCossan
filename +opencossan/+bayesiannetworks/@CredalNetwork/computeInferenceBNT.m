function Xout=computeInferenceBNT(CN,varargin)
%COMPUTEINFERENCE method of the class CredalNetwork allow to
%compute the inference using exact inference algorithms. 
% The inference is computed by the Bayes Toolbox
% for Matlab (available at:https://code.google.com/p/bnt/).
%
%   For usage see TutorialCredalNetwork
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


%% Input
p = inputParser;
p.FunctionName = 'opencossan.bayesiannetworks.CredalNetwork.computeInferenceBNT';

% Initialize input
p.addParameter('Algorithm',"JunctionTree", @(s)isstring(s)); 
p.addParameter('MarginalProbability',string,@(s)isstring(s));
p.addParameter('Vevidence',[],@(s)isnumeric(s));
p.addParameter('CombLow',[],@(s)isnumeric(s));
p.addParameter('CombUp',[],@(s)isnumeric(s));
p.addParameter('Lnorm',true,@(s)islogical(s));
p.addParameter('JointProbability',string,@(s)isstring(s));
p.parse(varargin{:});

% Assign input 
Algorithm       = p.Results.Algorithm;
MarginalNodes   = p.Results.MarginalProbability;
Evidence       = p.Results.Vevidence;
JointNodes      = p.Results.JointProbability;
CombLow         = p.Results.CombLow;
CombUp          = p.Results.CombUp;
Lnorm           = p.Results.Lnorm;

% Flag for LpBounds
LPbounds=ismember(CN.NodesNames,CN.CredalNodes);
Vevidence =Evidence(CN.TopologicalOrder);
%% Build the BN (according to BNT)
MarginalValues  = cell(1,length(MarginalNodes));
Nodes           = CN.Nodes(CN.TopologicalOrder);
Names           = [Nodes.Name];
index           = find(LPbounds(CN.TopologicalOrder)); %topological index of non-trad nodes
% Reorganize the adjacency matrix according to the topological order
Mdag            = CN.DAG(:,CN.TopologicalOrder);
Mdag            = Mdag(CN.TopologicalOrder,:);
% Build the BN structure
bnet            = mk_bnet(Mdag, CN.NodesSize(CN.TopologicalOrder),'names', Names);
CPD             = CN.CPDs(CN.TopologicalOrder);
% Initialize index
VnodeBN         = 1:CN.Nnodes;
VnodeBN(index)  = []; %index of tranditional discrete node in the net

% DEFINE TRADITIONAL NODE ACCORDING TO TOOLBOX LANGUAGE
for inode=VnodeBN
    % extract the CPT of each traditional node
    C=cell2mat(CPD{inode});
    % if the node is a root it is not required to build a named CPT
    if isempty(Nodes(inode).Parents)
        bnet.CPD{inode}=tabular_CPD(bnet,inode,'CPT',C); % build tabular CPT
    else
        % specify the parents in the order they are referred to in the CPT
        CPT = mk_named_CPT([Nodes(inode).Parents,Nodes(inode).Name],...
            Names, Mdag, C);
        % specify the parents in the order they are referred to in the CPT
        bnet.CPD{inode}=tabular_CPD(bnet, inode,'CPT',CPT); 
    end    
end

%% Check Marginal and Joint Nodes for Discretized nodes
MarginalMembers     = ismember(MarginalNodes,Names); 
if ~isempty(MarginalNodes(~MarginalMembers))
    DiscreteStr     = cell(1,length((MarginalNodes(~MarginalMembers))));
    DiscreteStr(:)  = {'discrete'}; 
    MarginalNodes(~MarginalMembers)=strcat(MarginalNodes(~MarginalMembers),DiscreteStr);
    assert(any(ismember(MarginalNodes,Names)),...
        'openCOSSAN:CredalNetwork:computeInference',...
        'Node %s not found in the net',MarginalNodes(~ismember(MarginalNodes,Names)))
end

JointMembers        = ismember(JointNodes,MarginalNodes);
if ~(JointNodes(~JointMembers)=="")
    DiscreteStr     = cell(1,length((JointNodes(~JointMembers))));
    DiscreteStr(:)  = {'discrete'}; 
    JointNodes(~JointMembers)=strcat(JointNodes(~JointMembers),DiscreteStr);
    assert(any(ismember(JointNodes,Names)),...
        'openCOSSAN:CredalNetwork:computeInference',...
        'Node %s not found in the net',JointNodes(~ismember(JointNodes,Names)))
end

% PREPARE JOINT PROBABILITY VARIABLES
[JointNodes,indJointNodes]    = intersect(Names,JointNodes,'stable');
if ~isempty(JointNodes)
    indJointOverall     = unique(sort(indJointNodes));
    ObsInCJOINT         = ~cellfun(@isempty,Vevidence(CN.TopologicalOrder(indJointOverall)));
    Vsize               = CN.NodesSize(CN.TopologicalOrder(indJointOverall));
    Vsize(ObsInCJOINT)  = 1;
    MjointDistributionUpperBound    = nan(Vsize);
    MjointDistributionLowerBound    = MjointDistributionUpperBound;
end

% PREPARE MARGINAL PROBABILITY VARIABLES
[MarginalNodes,indMarginalInNet]    = intersect(Names,MarginalNodes,'stable');
[~,indObserved]         = intersect(MarginalNodes,Names(~(Vevidence==0)),'stable'); 
if ~isempty(MarginalNodes)
        VsizeMarg               = CN.NodesSize(CN.TopologicalOrder(indMarginalInNet));
        VsizeMarg(indObserved)  = 1;
        CMarginalUP=cell(1,length(MarginalNodes));
        CMarginalLO=CMarginalUP;
end


%% FOR  EACH COMBINATION OF CPTs ...
% Each CPT computed consider the upper probability for a single outcome of
% the node with p bounds: if a node has 3 outcome states and pbounds, we'll
% need to consider 3 CPTs for the combination
VpboundsNodeSizes=LPbounds(CN.TopologicalOrder).*CN.NodesSize(CN.TopologicalOrder); %vector of sizes of the pbound nodes
VpboundsNodeSizes(VpboundsNodeSizes==0)=[];
cCOMB = cell(1,prod(VpboundsNodeSizes));
cvalues = cell(1,prod(VpboundsNodeSizes));
combination=cell(1,CN.Nnodes);
combination(:)={1};
Ncomb=prod(VpboundsNodeSizes);

if ~isempty(CombLow) 
%     McombLo(McombLo==1)=0;McombLo(McombLo==2)=1;McombLo(McombLo==0)=2;
    Mcomb=[CombLo;CombUp];
    Ncomb=size(Mcomb,1);
    Vsize=CN.NodesSize(CN.TopologicalOrder);
    Vsize(~cellfun(isempty(Vevidence(CN.TolopologicalOrder))))=1;
    MjointDistributionLowerBound=zeros(Vsize(indJointNodes));
    MjointDistributionUpperBound=MjointDistributionLowerBound;
    indexTargetJoint=cell(1,length(Cjoint));
    Vstate=[1,2,1,2];
    indexTargetJoint(:)={':'};
end

for ibnet=1:Ncomb % Probably change; multiply the dim of parents
    %... Build a bn
    if isempty(CombLow)
        combination(index)=num2cell(opencossan.common.utilities.myind2sub(VpboundsNodeSizes,ibnet));
    else
        combination(index)=num2cell(Mcomb(ibnet,:));
    end
    for i=1:length(index)
        inode=index(i);
        CPDNode=CPD{inode}; %cell with the two CPT's bounds 
        % build CPT with Extreme Points
        %================================
        lowerb_mat = cell2mat(CPDNode{1});
        upperb_mat = cell2mat(CPDNode{2});
        BoundSize = size(lowerb_mat);
        BoundElements = numel(BoundSize);
        if Nodes(inode).Lroot == 1 % when root nodes
            PermutedLowBound = lowerb_mat;
            PermutedUppBound = upperb_mat;
        else 
            PermutedLowBound = permute(lowerb_mat, [BoundElements 1:1:BoundElements-1]);
            PermutedUppBound = permute(upperb_mat, [BoundElements 1:1:BoundElements-1]);
        end
        LocalEP = prod(BoundSize(1:end-1));% Number of local EPs
        NStates = BoundSize(end);
        C = zeros(LocalEP,NStates); % Preallocation for speed
        StatesComb = 1; % Initialize States combination
        for EPComb = 1:LocalEP
            LocalLowBound = PermutedLowBound(StatesComb:1:EPComb*NStates);% Optimize these with permutedLowBound
            LocalUppBound = PermutedUppBound(StatesComb:1:EPComb*NStates);
            r = randi(10,1,1); % random restart for EPs
            [EP,EPc] = CN.extremePoints('inode',inode,'LowerBound',LocalLowBound,'UpperBound',LocalUppBound); % Extreme points of local credal set
            if r <= 5
                C(EPComb,1:1:NStates) = EP;% Extreme Point
            else
                C(EPComb,1:1:NStates) = EPc; % complement Extreme Point
            end
            StatesComb = StatesComb + NStates;
        end
        C = reshape(C,BoundSize);
        %================================
%         C=cell2mat(CPDNode{1});
%         NElementsPerOutcome=numel(C)/CN.NodesSize(CN.TopologicalOrder(inode));
%         FirstElement=combination{index(i)}*NElementsPerOutcome-NElementsPerOutcome+1;
%         C(FirstElement:FirstElement+NElementsPerOutcome-1)=[CPDNode{2}{FirstElement:FirstElement+NElementsPerOutcome-1}];
        if isempty(Nodes(inode).Parents)
            bnet.CPD{inode}=tabular_CPD(bnet,inode,'CPT',C); % build tabular CPT
        else
            CPT = mk_named_CPT([Nodes(inode).Parents,Names{inode}],...
                Names, Mdag, C);
            bnet.CPD{inode}=tabular_CPD(bnet, inode,'CPT',CPT); % build tabular CPT
        end
    end
    
    
    
    %% Compute Marginal Probabilities
    % TRADITIONAL BN
    Cevidence=num2cell(Vevidence);
    Cevidence(Vevidence==0)={[]};
    if ~isempty(MarginalNodes)
        %EnterEvidence
        if strcmp(Algorithm,'Junction Tree') || strcmp(Algorithm,'JunctionTree')
            engine=jtree_inf_engine(bnet);                  % build engine
            [engine, ~]=enter_evidence(engine,Cevidence);   % introduce evidence in the net
        elseif strcmp(Algorithm,'Variable Elimination') || strcmp(Algorithm,'VariableElimination')
            engine=var_elim_inf_engine(bnet);     % build engine
            [engine, ~]=enter_evidence(engine,Cevidence);   % introduce evidence in the net
        end
        % Marginal probabilities of nodes which receive evidence
        for iEv=1:length(indObserved)
            Mnode=marginal_nodes(engine,indMarginalInNet(indObserved(iEv)),1);% Collect marginal CPTs
            MarginalValues{indObserved(iEv)}= Mnode.T;
        end
        % Marginal probabilities of nodes which do not receive any evidence
        indNoEvidence=1:length(MarginalNodes);
        indNoEvidence(indObserved)=[];% Index marginal nodes (no evidence)
        for imarginal=1:length(indNoEvidence)
            Mnode=marginal_nodes(engine,indMarginalInNet(indNoEvidence(imarginal))); 
            MarginalValues{indNoEvidence(imarginal)}=Mnode.T;
            
        end
        
            for iquery=1:length(MarginalNodes)
                CMarginalLO{iquery}=min([CMarginalLO{iquery},MarginalValues{iquery}],[],2);
                CMarginalUP{iquery}=max([CMarginalUP{iquery},MarginalValues{iquery}],[],2);
                cCOMB{ibnet}=[combination{index}];
                cvalues{ibnet}=MarginalValues{iquery};
            end
        
        
    end
    
    %% ComputeJoint Probability
    % TRADITIONAL BN
    if ~isempty(JointNodes)
        if isempty(McombLo)
            engineJoint=var_elim_inf_engine(bnet);
            [engineJoint, ~]=enter_evidence(engineJoint,Cevidence);
            Mjoint2Joint=marginal_nodes(engineJoint,indJointNodes');
            MjointDistributionLowerBound=min(MjointDistributionLowerBound,Mjoint2Joint.T);
            MjointDistributionUpperBound=max(MjointDistributionUpperBound,Mjoint2Joint.T);
        else
            engineJoint=var_elim_inf_engine(bnet);
            [engineJoint, ~]=enter_evidence(engineJoint,Cevidence);
            Mjoint2Joint=marginal_nodes(engineJoint,indJointNodes');
            indexTargetJoint{strcmp(Cjoint,StargetJoint)}=Vstate(ibnet);
            if ibnet<=2
                MjointDistributionLowerBound(indexTargetJoint{:})=Mjoint2Joint.T(indexTargetJoint{:});
            else
                MjointDistributionUpperBound(indexTargetJoint{:})=Mjoint2Joint.T(indexTargetJoint{:});
            end
        end
    end
    
    
end

%% PREPARE OUTPUT
if ~isempty(MarginalNodes)
    for imarg=1:length(MarginalNodes)
        MarginalLOtemp=CMarginalLO{imarg};
        MarginalUPtemp=CMarginalUP{imarg};
        MarginalLO=MarginalLOtemp./(sum([MarginalUPtemp(:)])-MarginalUPtemp+MarginalLOtemp);
        MarginalUP=MarginalUPtemp./(sum([MarginalLOtemp(:)])-MarginalLOtemp+MarginalUPtemp);
        RowNames=cell(1,length(MarginalLO+1));
        RowNames(:)={'state'};
        Xout.(Names{indMarginalInNet(imarg)})= table(MarginalLO(:) , MarginalUP(:),'VariableNames',{'LowerBound', 'UpperBound'},'RowNames',matlab.lang.makeUniqueStrings(RowNames,'state')) ;
        [~, indUP]=max([cvalues{:}],[],2);
        [~, indLO]=min([cvalues{:}],[],2);
     
        Xout.('CcombUp')= cell2mat(cCOMB(indUP)');
        Xout.('CcombLo')= cell2mat(cCOMB(indLO)');
        
    end
elseif ~isempty(Cjoint) && Lnorm   
    Xout.('MjointDistributionLowerBound')= MjointDistributionLowerBound./(sum([MjointDistributionUpperBound(:)])-MjointDistributionUpperBound+MjointDistributionLowerBound);
    Xout.('MjointDistributionUpperBound')= MjointDistributionUpperBound./(sum([MjointDistributionLowerBound(:)])-MjointDistributionLowerBound+MjointDistributionUpperBound);
    Xout.('CSnames')=Cjoint;
elseif ~isempty(Cjoint) && ~Lnorm   
    Xout.('MjointDistributionLowerBound')= MjointDistributionLowerBound;
    Xout.('MjointDistributionUpperBound')= MjointDistributionUpperBound;
    Xout.('CSnames')=Cjoint;
    
end

end

