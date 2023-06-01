function CN = computeIntervalNodes(CN, varargin)
% COMPUTEINTERVALNODES method of the CredalNetwork class,
% allows to compute the probabilistic nodes which are children of other
% probabilistic nodes. The computation is carried out by means of random
% search
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
p.FunctionName = 'opencossan.bayesiannetworks.CredalNetwork.computeIntervalNodes';
p.addParameter('Nodes2process',[]);
p.parse(varargin{:});
Nodes2process       = p.Results.Nodes2process;               
NodesNames          = CN.NodesNames;
TopologicalOrder    = CN.TopologicalOrder;
DiscreteNodes       = CN.DiscreteNodes;
NonDiscreteNodes    = NodesNames(~ismember(NodesNames,DiscreteNodes));
IntervalNodes       = CN.IntervalNodes;
Mdag                = CN.DAG;

% Identify nodes to compute
if isempty(Nodes2process) % If no nodes introduced  check the whole net
    LProb2Compute=ismember(NodesNames(TopologicalOrder),NodesNames(cellfun(@iscellstr,CN.CPDs))) & ismember(NodesNames(TopologicalOrder),IntervalNodes);
    Cnodes2compute=NodesNames(TopologicalOrder(LProb2Compute));
    Index2compute=TopologicalOrder(LProb2Compute);   
else
    [~,Index2compute]=intersect(NodesNames(TopologicalOrder),Nodes2process,'stable');   
end


%%  COMPUTE NON-DISCRETE NODES
for indCont=1:length(Cnodes2compute)
    % Extract node object to compute and its features
    Xnode  = CN.Nodes(Index2compute(indCont)); 
    NonDiscPA = NonDiscreteNodes(ismember(NonDiscreteNodes, Xnode.Parents));
    DiscPA = DiscreteNodes(ismember(DiscreteNodes, Xnode.Parents));
    LNonDiscPA= ismember(NodesNames,NonDiscPA);
    
    % Find discrete grandparents 2 be inherit
    LGrandpa =   Mdag(:,LNonDiscPA)==1;
    GrandPas =   DiscreteNodes(ismember(DiscreteNodes,NodesNames(LGrandpa)));
    % New parents of the node to compute (ALL DISCRETE)
    NewParents = NodesNames(ismember(NodesNames,[GrandPas,DiscPA]));
    
    %% CHECK IF THE COMPUTATION DISCONNECTS THE NODE FROM THE NET!
    %N.B. If there are no discrete newParents the new node is gonna be a root:
    if isempty(NewParents)
        % Simulate removal of continuous parents
        MhypotheticalDAG=Mdag;
        MhypotheticalDAG(indNodeParents(indNonDiscParents),Index2compute(indCont))=0;
        Lconnected  = CN.isConnected('DAG',MhypotheticalDAG,'NodeName',Cnodes2compute(indCont));
        
        % If the node is "important" (= not a barren node) keep it connected discretizing parents with discrete descendants
        if ~Lconnected && isempty(intersect(Xnode.Name,CN.barrenNodes))
            
            % Look for "important" parents (with discrete descendants)
            for ipa=1:length(NonDiscPA)
                % Is the parent directly connected with discrete variables?
                Lipa = CN.isConnected('NodeName',NonDiscPA{ipa},'Descendants',DiscreteNodes); 
                
                if Lipa
                    % Is the node to compute parent of more than one discrete node to compute?
                    if length(intersect(CN.nodes2compute,CN.ChildNodes{indNodeParents(indNonDiscParents(ipa))}))>1
                        % Split the Markov Envelope
                        CN = CN.discretizeProbabilisticNode('NodeName',NonDiscPA{ipa},'NprobilisticNodes',length(CN.ChildNodes{indNodeParents(indNonDiscParents(ipa))}));
                    else
                        % Default discretization (one discrete+ one continuous)
                        CN = CN.discretizeProbabilisticNode('NodeName',NonDiscPA{ipa});
                    end
                    [~,Index2compute(indCont)]      = intersect(NodesNames,Cnodes2compute(indCont),'stable');% New index continuous2compute
                    Xnode                           = CN.Nodes(Index2compute(indCont));                      % Exctract the node again (parents changed!)
                    [NodeParents, indNodeParents]   = intersect(NodesNames,Xnode.Parents,'stable');          % New Parents (index in the net, topological order)
                    % Classifies new parents by type
                    [NonDiscPA, indNonDiscParents]  = intersect(NodeParents,NonDiscreteNodes,'stable');      % Non Discrete parents name and index in the CSparents cell
                    DiscPA                          = intersect(NodeParents,DiscreteNodes,'stable');         % Discrete parents name and index in the CSparents cell
                    [indGrandpa ,~]                 = find(CN.Mdag(:,indNodeParents(indNonDiscParents))==1); % Name of grandparents of the node to compute
                    GrandPas                        = intersect(NodesNames(indGrandpa),DiscreteNodes);       % Name of discrete grandparents of the node to compute
                    % New Parents name and Index in the net (topological order)
                    NewParents                      = intersect(NodesNames,[GrandPas,DiscPA],'stable');
                    
                end
            end
        end
    end

    LoldPaInd   = ismember(NewParents,DiscPA);        % Old discrete parents index in newParents cell

    VsizeNewPa  = CN.NodesSize(ismember(NodesNames,NewParents));                      % Vector of new parent sizes
    
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
        Xinput = CN.hybridInput('Combination',combind,'CombinationNames',NewParents,'Node',Xnode);
        
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
        
        Msamples=cell(1,length(Xinput.InputNames));
        NinitialSamples=ceil((10E3)^(1/(Xinput.NintervalVariables+Xinput.NrandomVariables)));
        for irv=1:size(CXrvs,1)
            upperRV=CXrvs{irv,2}.cdf2physical(1-10E-3);
            lowerRV=CXrvs{irv,2}.cdf2physical(10E-3);
            Msamples(1,strcmpi(CXrvs{irv,1},Xinput.Cnames))={linspace(lowerRV,upperRV,NinitialSamples+1)};
            
        end
        
        for iunc=1:size(CXrvs_unc,1)
            upperRV_unc=CXrvs{irv,2}.cdf2physical(1-10E-3);
            lowerRV_unc=CXrvs{irv,2}.cdf2physical(10E-3);
            UncParameters=Cmap(strcmpi(Cmap(:,2),CXrvs_unc(iunc,1)),:);
            MeanName=UncParameters(strcmpi(UncParameters(:,3),'mean'),1);
            if ~isempty(MeanName)
                Interval=CXbvs{strcmpi(CXInt_unc(:,1),MeanName),2};
                upperRV_unc=upperRV_unc+Interval.upperBound-CXrvs{irv,2}.mean;
                lowerRV_unc=lowerRV_unc+Interval.lowerBound-CXrvs{irv,2}.mean;
                
            end
            Msamples(1,strcmpi(CXrvs_unc{iunc,1},Xinput.Cnames))={linspace(lowerRV_unc,upperRV_unc,NinitialSamples+1)};
            if iunc==size(CXrvs_unc,1)
                Msamples(ismember(Xinput.Cnames,CXInt_unc(:,1)'))=[];
                Xinput=Xinput.remove(Xinput.Xbset.XBSet_Unc,'XBSet_Unc');
            end
        end
      
        for ibv=1:size(CXbvs,1)
            Msamples(1,strcmpi(CXbvs{ibv,1},Xinput.Cnames))={linspace(CXbvs{ibv,2}.lowerBound,CXbvs{ibv,2}.upperBound,NinitialSamples+1)};
        end
        for ipar=1:size(CXpars,1)
            Msamples(1,strcmpi(CXpars{ipar,1},Xinput.Cnames))={CXpars{ipar,2}.value};
        end
        TableInput = array2table(combvec(Msamples{:})','VariableNames',lower(Xinput.Cnames));
        TableOutput= Xm.evaluate(TableInput);
        values  = TableOutput.out; % Results of the model evaluation on the samples
        if ~isempty(Xnode.censoring)
            values(values<=Xnode.censoring)=[];
        end
        newCPD{combind{:}}  = intervals.Interval('upperBound',max(real(values)),'lowerBound',min(real(values))); % Build BV from the results
    end
    
    %% Overwrite newCPD values and newParents
    CN.Nodes(Index2compute(indCont)).CPD     = newCPD;
    CN.Nodes(Index2compute(indCont)).Parents = NewParents;
    
end