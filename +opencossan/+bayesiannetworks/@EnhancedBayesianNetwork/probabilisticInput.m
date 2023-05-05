function Xinput = probabilisticInput(EBN, varargin)
%PREPAREPROBABILISTICINPUT method for the class EnhancedBayesianNetwork, allows to
%build the input object for the probabilistic or hybrid model.
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
import opencossan.common.inputs.random.* 

%% Process Input
p = inputParser;
p.FunctionName = 'opencossan.bayesiannetworks.EnhancedBayesianNetwork.probabilisticInput';
p.addParameter('Node',[]);
p.addParameter('Combination',[]);
p.addParameter('CombinationNames',[]);
p.parse(varargin{:});
% Assign input
Node                = p.Results.Node;
combination         = p.Results.Combination;
CombinationNames    = p.Results.CombinationNames;
% Extract features from net
NodesNames          = EBN.NodesNames;
ProbabilisticNames  = EBN.ProbabilisticNodes;
DiscreteNames       = EBN.DiscreteNodes;

% Initialize Input object
Xinput=Input();

[~,indCombNodeNet]=intersect(NodesNames,CombinationNames,'stable');

%% classify nodes in combination
[~,DInComb]=intersect(CombinationNames,DiscreteNames(ismember(DiscreteNames,Node.Parents)),'stable');
ParametersInComb = logical([EBN.Nodes(indCombNodeNet(DInComb)).Lpar]);
ParNodes = EBN.Nodes(indCombNodeNet(DInComb(ParametersInComb)));
% tell which probabilistic node is a direct parent (extract RVs) and which
% prob nodes must be used only for determin the RVs to extract (discrete gran
% parents)
LprobInNet=ismember(EBN.NodesNames,intersect(ProbabilisticNames,Node.Parents));
RVNodes=EBN.Nodes(LprobInNet);
[NamesOnly4Comb,Donly4Comb]=intersect(CombinationNames,DiscreteNames(ismember(DiscreteNames,[RVNodes.Parents])),'stable');

%% Extract Parameters (only) from discrete nodes parents of SRM nodes
if ~isempty(ParNodes)
    Dcomb=combination(DInComb(ParametersInComb));
    for ipar=1:length(ParNodes)
        Par=Parameter('value',ParNodes(ipar).Values(Dcomb{ipar})); % collect Parameters
        Xinput=Xinput.add('Member',Par,'Name',lower(ParNodes(ipar).Name)); % add parameter to input
    end 
end

%% Extract Random Variables from probabilistic nodes
if ~isempty(RVNodes)
    RVS        = RandomVariable.empty(0,length(RVNodes));  % array of RVs collected
    CorrRVS    = eye(length(RVNodes));
    combDonly4comb = combination(Donly4Comb);
    % Collect RVs
    for irv=1:length(RVNodes)
        combNode=combDonly4comb(ismember(NamesOnly4Comb,RVNodes(irv).Parents));
        % Collect RVs (N.B. the size of probabilistic nodes is always 1)
        RVS(irv)=RVNodes(irv).CPD{combNode{:}};       
    end
    
    if ~isempty(EBN.Correlation)
        Correlation=EBN.Correlation;
        % Extract values of correlation among RVs involved
        CorrRVS=Correlation(LprobInNet,LprobInNet);
    end
    
    % BUILD RVSET OF INDEPENDENT RVs    
    Iindependent=find(sum(CorrRVS,1)==1); % Index of independent RVs
    if ~isempty(RVS(Iindependent)) 
        NamesIndRVset=lower(RVNodes(Iindependent).Name);
        XRVSindependent=RandomVariableSet('members',RVS(irv), 'names',{NamesIndRVset{:}}, 'correlation', CorrRVS);
        % RandomVariableSet('Members',RVS(Iindependent),'Names',{NamesIndRVset{:}});
        Xinput=Xinput.add('Member',XRVSindependent,'Name',"XRVSindependent"); % add the RVsets to the input object
    end
    
    % BUILD RVSET OF INDEPENDENT RVs
    % Redefine Mcorr for correlated variables
    CorrRVS(:,(Iindependent))      = []; % Exclude values in Mcorr related to independent RVs
    CorrRVS((Iindependent),:)      = [];
    NameDependentRVs               = lower(RVNodes.Name); % Name of RVs in Input
    NameDependentRVs(Iindependent) = [];
    DependentRVs                   = RVS;
    DependentRVs(Iindependent)     = []; % Array of dependent RVs
    if ~isempty(NameDependentRVs)
        XRVSdependent=RandomVariableSet('members',DependentRVs,'names',{NameDependentRVs{:}},'correlation',CorrRVS,...
            'copulasamples',100000,'copulabatches',100);
%         XRVSdependent=RandomVariableSet('Cxrv',DependentRVs,'Cmembers',{NameDependentRVs{:}},'Mcorrelation',CorrRVS,...
%             'Ncopulasamples',100000,'ncopulabatches',100);
        Xinput=Xinput.add('Member',XRVSdependent,'Name',"XRVSdependent"); % Add the RVsets to the input object
    end
    
end













