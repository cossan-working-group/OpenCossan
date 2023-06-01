function Xinput = hybridInput(CN, varargin)
%HYBRIDINPUT method for the class CredalNetwork, allows to
%build the input object for the hybridSRM.
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

import opencossan.common.inputs.* 

%% Process Input
p = inputParser;
p.FunctionName = 'opencossan.bayesiannetworks.CredalNetwork.hybridInput';
p.addParameter('Node',[]);
p.addParameter('Combination',[]);
p.addParameter('CombinationNames',[]);
p.parse(varargin{:});
% Assign input
Node                = p.Results.Node;
combination         = p.Results.Combination;
CombinationNames    = p.Results.CombinationNames;
% Extract features from net
NodesNames          = CN.NodesNames;
ProbabilisticNames  = CN.ProbabilisticNodes;
DiscreteNames       = CN.DiscreteNodes;
IntervalNames       = CN.IntervalNodes;
HybridNames         = CN.IntervalNodes;
% Initialize Input object
Xinput=Input();

[~,indCombNodeNet]=intersect(NodesNames,CombinationNames,'stable');

%% PARAMETERS
[~,DInComb]=intersect(CombinationNames,DiscreteNames(ismember(DiscreteNames,Node.Parents)),'stable');
ParametersInComb = logical([CN.Nodes(indCombNodeNet(DInComb)).Lpar]);
ParNodes = CN.Nodes(indCombNodeNet(DInComb(ParametersInComb)));
%% Extract Parameters (only) from discrete nodes parents of SRM nodes
if ~isempty(ParNodes)
    Dcomb=combination(DInComb(ParametersInComb));
    for ipar=1:length(ParNodes)
        Par=Parameter('value',ParNodes(ipar).Values(Dcomb{ipar})); % collect Parameters
        Xinput=Xinput.add('Member',Par,'Name',lower(ParNodes(ipar).Name)); % add parameter to input
    end 
end

%% RVs
% tell which probabilistic node is a direct parent (extract RVs) 
LprobInNet=ismember(CN.NodesNames,intersect(ProbabilisticNames,Node.Parents));
RVNodes=CN.Nodes(LprobInNet);
[NamesOnly4Comb,Donly4Comb]=intersect(CombinationNames,DiscreteNames(ismember(DiscreteNames,[RVNodes.Parents])),'stable');
if ~isempty(RVNodes)
    CXRV        = cell(1,length(RVNodes));  % Cell array of RVs collected
    McorrRVS    = eye(length(RVNodes));
    combDonly4comb = combination(Donly4Comb);
    % Collect RVs
    for irv=1:length(RVNodes)
        combNode=combDonly4comb(ismember(NamesOnly4Comb,RVNodes(irv).Parents));
        % Collect RVs (N.B. the size of probabilistic nodes is always 1)
        CXRV(irv)=RVNodes(irv).CPD(combNode{:});       
    end
    
    if ~isempty(CN.Correlation)
        Mcorrelation=CN.Correlation;
        % Extract values of correlation among RVs involved
        McorrRVS=Mcorrelation(LprobInNet,LprobInNet);
    end
    
    % BUILD RVSET OF INDEPENDENT RVs
    Iindependent=find(sum(McorrRVS,1)==1); % Index of independent RVs
    if ~isempty(CXRV(Iindependent)) 
        NamesIndRVset=lower(RVNodes(Iindependent).Name);
        XRVSindependent=RandomVariableSet('Cxrv',CXRV(Iindependent),'Cmembers',{NamesIndRVset{:}});
        Xinput=Xinput.add('Member',XRVSindependent,'Name',"XRVSindependent"); % add the RVsets to the input object
    end
    
    % BUILD RVSET OF INDEPENDENT RVs
    % Redefine Mcorr for correlated variables
    McorrRVS(:,(Iindependent))      = []; % Exclude values in Mcorr related to independent RVs
    McorrRVS((Iindependent),:)      = [];
    CnameDependentRVs               = lower(RVNodes.Name); % Name of RVs in Input
    CnameDependentRVs(Iindependent) = [];
    CdependentRVs                   = CXRV;
    CdependentRVs(Iindependent)     = []; % Cell array of dependent RVs
    if ~isempty(CnameDependentRVs) 
        XRVSdependent=RandomVariableSet('Cxrv',CdependentRVs,'Cmembers',{CnameDependentRVs{:}},'Mcorrelation',McorrRVS,...
            'Ncopulasamples',100000,'ncopulabatches',100);
        Xinput=Xinput.add('Member',XRVSdependent,'Name',"XRVSdependent"); % Add the RVsets to the input object
    end
    
end

%% INTERVALS
LintInNet=ismember(CN.NodesNames,intersect(IntervalNames,Node.Parents));
INTNodes=CN.Nodes(LintInNet);
[IntNamesOnly4Comb,IntDonly4Comb]=intersect(CombinationNames,DiscreteNames(ismember(DiscreteNames,[INTNodes.Parents])),'stable');
if ~isempty(INTNodes) 
    % Initialize variables
    McorrCS = eye(length(INTNodes));    % Correlation matrix for ConvexSet
    CXBV    = cell(1,length(INTNodes)); % Cell array of BVs collected
    
    % Collect BVs
    for ibv=1:length(INTNodes)
        CPD=CN.CPDs{BoundedInNet(ibv)}; % Extract CPD of interval node
        [~,BPaIndexInComb,BPaIndexInNode]=intersect(CSdiscrete,Xebn.CXnodes{BoundedInNet(ibv)}.CSparents,'stable'); % Index of Discrete parents of interval nodes (identify the RV to extract from CPD)
        BPcomb=combination(CdiscreteInComb(BPaIndexInComb));
        CXBV(ibv)=CPD(BPcomb{BPaIndexInNode},1); % Collect BVs (size of continuous nodes is always 1)
        CXbvs(ibv,:)={CSbounded{ibv},CPD{BPcomb{BPaIndexInNode},1}};
        % Extract values of correlation among the BVs involved
        McorrCS(ibv,:)=Xebn.Mcorrelation(BoundedInNet(ibv),BoundedInNet);
        McorrCS= triu(McorrCS, 0) + triu(McorrCS, 1)';
        
    end
    % BUILD CSET OF INDEPENDENT BVs
    Lindependent=find(sum(McorrCS,1)==1); % Index of independent BVs
    
    if ~isempty(CXBV(Lindependent))
        XCSindependent=BoundedSet('CXint',CXBV(Lindependent),'CSmembers',lower(CSbounded(Lindependent)),'Lconvex',Lconvex);
        Xinput=Xinput.add('Xmember',XCSindependent,'Sname','XCSindependent'); % add the Csets to the input object
    end
    
    % BUILD CSET OF DEPENDENT BVs
    %Redefine Mcorr for correlated variables
    McorrCS(:,(Lindependent))       = [];   % Exclude values in Mcorr related to independent BVs
    McorrCS((Lindependent),:)       = [];
    CnameDependentBVs               = lower(CSbounded); % Name of BVs in Input
    CnameDependentBVs(Lindependent) = [];
    CdependentBVs                   = CXBV;
    CdependentBVs(Lindependent)     = [];   % Cell array of dependent BVs
    
    if ~isempty(CnameDependentBVs)
        XCSdependent=BoundedSet('CXint',CdependentBVs,'CSmembers',CnameDependentBVs,'Mcorrelation',McorrCS,'Lconvex',Lconvex);
        Xinput=Xinput.add('Xmember',XCSdependent,'Sname','XCSdependent');    % add the Cset to the input object
    end
 
end

%% HYBRID
%% Extract Uncertain RVs
if ~isempty(CShybrid)
    par = 1;
    CXRV_unc=cell(1,length(CShybrid));
    for iunc=1:length(CShybrid)
        CPD=Xebn.Ccpd{UncertainInNet(iunc)}; % Extract CPD of uncertain node
        % Index of Discrete parents of continuous nodes (identify the RV to extract from CPD)
        [~,UncPaIndexInComb,UncPaIndexInNode]=intersect(CSdiscrete,Xebn.CXnodes{UncertainInNet(iunc)}.CSparents,'stable'); 
        UNCcomb=combination(CdiscreteInComb(UncPaIndexInComb));
        if isempty(UNCcomb)
            indexUncertain=1;
        else
            indexUncertain=UNCcomb{UncPaIndexInNode};
        end
        CXRV_unc(iunc)=CPD(UNCcomb{UncPaIndexInNode},1); % Collect RVs (N.B. the size of continuous nodes is always 1)    
        CXrvs_unc(iunc,:)={CShybrid{iunc},CXRV_unc{iunc}};
        % name of the uncertain parameter is specified in the mapping
        Map=Xebn.CXnodes{UncertainInNet(iunc)}.Cmapping;
        CInt=Xebn.CXnodes{UncertainInNet(iunc)}.Chyperparameters; % Extract CPD of uncertain node
       
        for iuncPar=1:size(Map,1)
            UncertainPar=CInt{1,iuncPar};
            CXInt_unc(par,1)=Map(iuncPar,1);
            CXInt_unc(par,2)={Interval('lowerBound',UncertainPar{indexUncertain,1}.lowerBound,'upperBound',UncertainPar{indexUncertain,1}.upperBound)};
            Cmapping(par,1:3)=lower(Map(iuncPar,:));      
            par=par+1;
        end
    end
    XBSet_Unc=BoundedSet('CXintervals',CXInt_unc(:,2)','CintervalNames',lower(CXInt_unc(:,1))','Lconvex',Lconvex);
    XRVS_Unc=RandomVariableSet('Cxrv',CXRV_unc,'Cmembers',lower(CShybrid));
    Xinput=Xinput.add('Xmember',XBSet_Unc,'Sname','XBSet_Unc');   
    Xinput=Xinput.add('Xmember',XRVS_Unc,'Sname','XRVS_Unc');   
    Xinput.CinputMapping=Cmapping;
end











