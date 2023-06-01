function Xout=computeInferenceBNT(Xbn,varargin)
%COMPUTEINFERENCE method of the class EnhancedBayesianNetwork allow to
%compute the inference on a traditional Bayesian Network (only discrete nodes) using exact
%inference algorithms. The inference is computed by the Bayes Toolbox
%for Matlab (available at:https://code.google.com/p/bnt/).
%
% MANDATORY ARGUMENTS:
%   -Xbn        EnhancedBayesianNetwork object (with only discrete nodes,
%               if continuous or bounded nodes are present the network
%               has to be reduced, see method reduce2BN )
%
%  OPTIONAL ARGUMENTS:
%   -Cevidence  1xn Cell array (where n is the number of nodes of the network)
%               of the evidence values to be introduced in the network.
%               The location of the value in the cellarray has to be coherent with the
%               position of the node in the net.
%               Check find(ismemeber('NameOfTheNode',Xbn.Cnames)) if not sure.
%               The evidence can be introduced also in building EBN
%               itself or the single node
%   -CSmarginal  Cellarray of names of the nodes for which the computation of the marginal
%               distribution is required. It can be introduced also in
%               building EBN.
%               If empty, the marginal distribution of nodes without
%               children is computed.
%   -Salgorithm Exact inference algorithm preferred to compute
%               inference. If empty the junction tree algorithm is
%               used.
%
%   EXAMPLE (see tutorialBayesianNetwork)
%   Marginal=Xebn.computeInference('Cevidence',Evidence,'CSmarginal',{'Earthquake','Burglary'});
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
    error('openCOSSAN:bayesiannetworks:BayesianNetwork',...
        'To compute the inference of the BN the Bayes Toolbox (available at:https://code.google.com/p/bnt/) has to be included in the Matlab path')
end

%% Input
p = inputParser;
p.FunctionName = 'opencossan.bayesiannetworks.BayesianNetwork.computeBNInference';

% Initialize input
p.addParameter('Algorithm',''); 
p.addParameter('ObservedNodes',''); 
p.addParameter('MarginalProbability','');
p.addParameter('Evidence','');
p.addParameter('JointProbability','');
p.addParameter('useBNT',false);

p.parse(varargin{:});
% Assign input 
Salgorithm      = p.Results.Algorithm;
CSmarginal      = p.Results.MarginalProbability;
ObservedNodes   = p.Results.Evidence;
Evidence        = p.Results.Evidence;
CSjoint         = p.Results.JointProbability;
Lbnt            = p.Results.useBNT;
% validate input
validateattributes(Salgorithm,{'string'},{'2d'})
validateattributes(ObservedNodes,{'string'},{'2d'})
validateattributes([CSmarginal,CSjoint],{'string'},{'2d'})
validateattributes(Evidence,{'double'},{'2d'})
validateattributes(Lbnt,{'logical'},{'binary'})

% Validate Input
OpenCossan.validateCossanInputs(varargin{:})

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'salgorithm'} % Inference algorithm to adopt, 'VariableElimination' or 'JunctionTree' (check options at https://code.google.com/p/bnt/)
            Salgorithm=varargin{k+1};
        case {'csmarginal'}  % Names of nodes whose marginal probability is required
            CSmarginalized=varargin{k+1};
        case {'cevidence'}  % Cell array containing the evidence to be introduced
            Cevidence=varargin{k+1};
        case {'mcomblo'}    
            McombLo=varargin{k+1};
        case {'mcombup'}    
            McombUp=varargin{k+1};    
        case {'stargetjoint'}
            StargetJoint=varargin{k+1};
        case {'lnorm'}
            Lnorm=varargin{k+1};    
        case {'cjointdistribution','csjoint'}    
            Cjoint=varargin{k+1};
            
        otherwise
            error('openCOSSAN:EnhancedBayesianNetwork:computeInference',...
                ['Input argument (' varargin{k} ') not allowed'])
    end
end

%% Build the BN (according to BNT)
MarginalValues  = cell(1,length(CSmarginalized));
CnamesNet       = Xbn.CSnames(Xbn.Vorder); % Names of the net in topological order
CXnodes         = Xbn.CXnodes(Xbn.Vorder);
index           = find(Xbn.VLpbounds(Xbn.Vorder)); %topological index of non-trad nodes
% Reorganize the adjacency matrix according to the topological order
Mdag            = Xbn.Mdag(:,Xbn.Vorder);
Mdag            = Mdag(Xbn.Vorder,:);
% Build the BN structure
bnet            = mk_bnet(Mdag, Xbn.Vsize(Xbn.Vorder),'names', CnamesNet);
CPD             = Xbn.Ccpd(Xbn.Vorder);
% Initialize index
VnodeBN         = 1:Xbn.Nnodes;
VnodeBN(index)  = []; %index of tranditional discrete node in the net

% DEFINE TRADITIONAL NODE ACCORDING TO TOOLBOX LANGUAGE
for inode=VnodeBN
    % extract the CPT of each traditional node
    C=cell2mat(CPD{inode});
    % if the node is a root it is not required to build a named CPT
    if isempty(CXnodes{inode}.CSparents)
        bnet.CPD{inode}=tabular_CPD(bnet,inode,'CPT',C); % build tabular CPT
    else
        % specify the parents in the order they are referred to in the CPT
        CPT = mk_named_CPT([CXnodes{inode}.CSparents,CnamesNet{inode}],...
            CnamesNet, Mdag, C);
        % specify the parents in the order they are referred to in the CPT
        bnet.CPD{inode}=tabular_CPD(bnet, inode,'CPT',CPT); 
    end    
end

%% Check Marginal and Joint Nodes for Discretized nodes
MarginalMembers     = ismember(CSmarginalized,CnamesNet); 
if ~isempty(CSmarginalized(~MarginalMembers))
    DiscreteStr     = cell(1,length((CSmarginalized(~MarginalMembers))));
    DiscreteStr(:)  = {'discrete'}; 
    CSmarginalized(~MarginalMembers)=strcat(CSmarginalized(~MarginalMembers),DiscreteStr);
    assert(any(ismember(CSmarginalized,CnamesNet)),...
        'openCOSSAN:EnhancedBayesianNetwork:computeInference',...
        'Node %s not found in the net',CSmarginalized(~ismember(CSmarginalized,CnamesNet)))
end

JointMembers        = ismember(Cjoint,CnamesNet);
if ~isempty(Cjoint(~JointMembers))
    DiscreteStr     = cell(1,length((Cjoint(~JointMembers))));
    DiscreteStr(:)  = {'discrete'}; 
    Cjoint(~JointMembers)=strcat(Cjoint(~JointMembers),DiscreteStr);
    assert(any(ismember(Cjoint,CnamesNet)),...
        'openCOSSAN:EnhancedBayesianNetwork:computeInference',...
        'Node %s not found in the net',Cjoint(~ismember(Cjoint,CnamesNet)))
end

% PREPARE JOINT PROBABILITY VARIABLES
[Cjoint,indJointNodes]    = intersect(CnamesNet,Cjoint,'stable');
if LPbounds && ~isempty(Cjoint)
    indJointOverall     = unique(sort(indJointNodes));
    ObsInCJOINT         = ~cellfun(@isempty,Xbn.Cevidence(Xbn.Vorder(indJointOverall)));
    Vsize               = Xbn.Vsize(Xbn.Vorder(indJointOverall));
    Vsize(ObsInCJOINT)  = 1;
    MjointDistributionUpperBound    = nan(Vsize);
    MjointDistributionLowerBound    = MjointDistributionUpperBound;
end

% PREPARE MARGINAL PROBABILITY VARIABLES
[CSmarginalized,indMarginalInNet]    = intersect(CnamesNet,CSmarginalized,'stable');
[~,indObserved]         = intersect(CSmarginalized,CnamesNet(~cellfun(@isempty,Cevidence)),'stable'); 
if LPbounds && ~isempty(CSmarginalized)
        VsizeMarg               = Xbn.Vsize(Xbn.Vorder(indMarginalInNet));
        VsizeMarg(indObserved)  = 1;
        CMarginalUP=cell(1,length(CSmarginalized));
        CMarginalLO=CMarginalUP;
end


%% FOR  EACH COMBINATION OF CPTs ...
% Each CPT computed consider the upper probability for a single outcome of
% the node with p bounds: if a node has 3 outcome states and pbounds, we'll
% need to consider 3 CPTs for the combination
VpboundsNodeSizes=Xbn.VLpbounds(Xbn.Vorder).*Xbn.Vsize(Xbn.Vorder); %vector of sizes of the pbound nodes
VpboundsNodeSizes(VpboundsNodeSizes==0)=[];
cCOMB = cell(1,prod(VpboundsNodeSizes));
cvalues = cell(1,prod(VpboundsNodeSizes));
combination=cell(1,Xbn.Nnodes);
combination(:)={1};
Ncomb=prod(VpboundsNodeSizes);

if ~isempty(McombLo) 
%     McombLo(McombLo==1)=0;McombLo(McombLo==2)=1;McombLo(McombLo==0)=2;
    Mcomb=[McombLo;McombUp];
    Ncomb=size(Mcomb,1);
    Vsize=Xbn.Vsize(Xbn.Vorder);
    Vsize(~cellfun(@isempty,Xbn.Cevidence(Xbn.Vorder)))=1;
    MjointDistributionLowerBound=zeros(Vsize(indJointNodes));
    MjointDistributionUpperBound=MjointDistributionLowerBound;
    indexTargetJoint=cell(1,length(Cjoint));
    Vstate=[1,2,1,2];
    indexTargetJoint(:)={':'};
end
for ibnet=1:Ncomb
    %... Build a bn
    if isempty(McombLo)
        combination(index)=num2cell(myind2sub(VpboundsNodeSizes,ibnet));
    else
        combination(index)=num2cell(Mcomb(ibnet,:));
    end
    for i=1:length(index)
        inode=index(i);
        CPDNode=CPD{inode}; %cell with the two CPT
        % build CPT
        C=cell2mat(CPDNode{1});
        NElementsPerOutcome=numel(C)/Xbn.Vsize(Xbn.Vorder(inode));
        FirstElement=combination{index(i)}*NElementsPerOutcome-NElementsPerOutcome+1;
        C(FirstElement:FirstElement+NElementsPerOutcome-1)=[CPDNode{2}{FirstElement:FirstElement+NElementsPerOutcome-1}];
        if isempty(CXnodes{inode}.CSparents)
            bnet.CPD{inode}=tabular_CPD(bnet,inode,'CPT',C); % build tabular CPT
        else
            CPT = mk_named_CPT([CXnodes{inode}.CSparents,CnamesNet{inode}],...
                CnamesNet, Mdag, C);
            bnet.CPD{inode}=tabular_CPD(bnet, inode,'CPT',CPT); % build tabular CPT
        end
    end
    
    
    
    %% Compute Marginal Probabilities
    % TRADITIONAL BN
    if ~isempty(CSmarginalized)
        %EnterEvidence
        if strcmp(Salgorithm,'Junction Tree') || strcmp(Salgorithm,'JunctionTree')
            engine=jtree_inf_engine(bnet);                  % build engine
            [engine, ~]=enter_evidence(engine,Cevidence);   % introduce evidence in the net
        elseif strcmp(Salgorithm,'Variable Elimination') || strcmp(Salgorithm,'VariableElimination')
            engine=var_elim_inf_engine(bnet);     % build engine
            [engine, ~]=enter_evidence(engine,Cevidence);   % introduce evidence in the net
        end
        % Marginal probabilities of nodes which receive evidence
        for iEv=1:length(indObserved)
            Mnode=marginal_nodes(engine,indMarginalInNet(indObserved(iEv)),1);% Collect marginal CPTs
            MarginalValues{indObserved(iEv)}= Mnode.T;
        end
        % Marginal probabilities of nodes which do not receive any evidence
        indNoEvidence=1:length(CSmarginalized);
        indNoEvidence(indObserved)=[];% Index marginal nodes (no evidence)
        for imarginal=1:length(indNoEvidence)
            Mnode=marginal_nodes(engine,indMarginalInNet(indNoEvidence(imarginal))); 
            MarginalValues{indNoEvidence(imarginal)}=Mnode.T;
            
        end
        if ~LPbounds
            for iBNnodes=1:length(CSmarginalized)
                Xout.(CSmarginalized{iBNnodes})= MarginalValues{iBNnodes};
            end
        else
            for iquery=1:length(CSmarginalized)
                CMarginalLO{iquery}=min([CMarginalLO{iquery},MarginalValues{iquery}],[],2);
                CMarginalUP{iquery}=max([CMarginalUP{iquery},MarginalValues{iquery}],[],2);
                cCOMB{ibnet}=[combination{index}];
                cvalues{ibnet}=MarginalValues{iquery};
            end
        end
        
    end
    
    %% ComputeJoint Probability
    % TRADITIONAL BN
    if ~isempty(Cjoint) && ~LPbounds
        engineJoint=var_elim_inf_engine(bnet);
        [engineJoint, ~]=enter_evidence(engineJoint,Cevidence);
        Mjoint=marginal_nodes(engineJoint,indJointNodes',1); 
        Xout.Cjoint=Cjoint;
        Xout.('MjointDistribution')=Mjoint.T;
    elseif ~isempty(Cjoint) && LPbounds && isempty(McombLo)
        engineJoint=var_elim_inf_engine(bnet);
        [engineJoint, ~]=enter_evidence(engineJoint,Cevidence);
        Mjoint2Joint=marginal_nodes(engineJoint,indJointNodes');        
        MjointDistributionLowerBound=min(MjointDistributionLowerBound,Mjoint2Joint.T);
        MjointDistributionUpperBound=max(MjointDistributionUpperBound,Mjoint2Joint.T);
    elseif ~isempty(Cjoint) && LPbounds && ~isempty(McombLo)
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

%% PREPARE OUTPUT
if LPbounds && ~isempty(CSmarginalized)
    for imarg=1:length(CSmarginalized)
        MarginalLOtemp=CMarginalLO{imarg};
        MarginalUPtemp=CMarginalUP{imarg};
        MarginalLO=MarginalLOtemp./(sum([MarginalUPtemp(:)])-MarginalUPtemp+MarginalLOtemp);
        MarginalUP=MarginalUPtemp./(sum([MarginalLOtemp(:)])-MarginalLOtemp+MarginalUPtemp);
        RowNames=cell(1,length(MarginalLO+1));
        RowNames(:)={'state'};
        Xout.(CnamesNet{indMarginalInNet(imarg)})= table(MarginalLO(:) , MarginalUP(:),'VariableNames',{'LowerBound', 'UpperBound'},'RowNames',matlab.lang.makeUniqueStrings(RowNames,'state')) ;
        [~, indUP]=max([cvalues{:}],[],2);
        [~, indLO]=min([cvalues{:}],[],2);
     
        Xout.('CcombUp')= cell2mat(cCOMB(indUP)');
        Xout.('CcombLo')= cell2mat(cCOMB(indLO)');
        
    end
elseif LPbounds && ~isempty(Cjoint) && Lnorm   
    Xout.('MjointDistributionLowerBound')= MjointDistributionLowerBound./(sum([MjointDistributionUpperBound(:)])-MjointDistributionUpperBound+MjointDistributionLowerBound);
    Xout.('MjointDistributionUpperBound')= MjointDistributionUpperBound./(sum([MjointDistributionLowerBound(:)])-MjointDistributionLowerBound+MjointDistributionUpperBound);
    Xout.('CSnames')=Cjoint;
elseif LPbounds && ~isempty(Cjoint) && ~Lnorm   
    Xout.('MjointDistributionLowerBound')= MjointDistributionLowerBound;
    Xout.('MjointDistributionUpperBound')= MjointDistributionUpperBound;
    Xout.('CSnames')=Cjoint;
    
end

end

