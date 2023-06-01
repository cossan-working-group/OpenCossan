function  NewNodes  = discretize(Node,varargin)
%	DISCRETIZE method of the class Node
%   Allows to replace a probabilistic random variable (Xi) with two random
%   variables: a discrete variable (Yi) and a probabilistic one(X'i), wich is a child of
%   the discrete one (Yi). The discrete random variable inherits all parent
%   variables of the inizial RV Xi, while X'i becomes parent to all the
%   children of Xi. The outcome space of Yi consists of mi states which
%   correspond to mutually exclusive,collectively exhaustive intervals in
%   the outcome space of the original variable Xi. The outcome space of X'i
%   is identical to the outcome space of Xi.
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
p.FunctionName = 'opencossan.bayesiannetworks.ProbabilisticNode.discretize';
p.addParameter('Nstates',[]);
p.addParameter('DiscretizationBounds',[]);
p.addParameter('NprobilisticNodes',1);
p.parse(varargin{:});
% Assign input
Nstates             = p.Results.Nstates;                % number of states of the new discrete node
DiscretizationBounds= p.Results.DiscretizationBounds;   % vector of values which identify the bounds of each state
Nchildren           = p.Results.NprobilisticNodes;      % number of probabilistic/bounded children


DiscreteParents = Node.Parents(arrayfun(@(s)isa(s,'opencossan.bayesiannetwork.DiscreteNode'),Node.Parents));

% Reorganize info about discretization options
if ~isempty(DiscretizationBounds) && ~isempty(Nstates) %check bounds values and number of outcomes introduced are coherent
    
    assert((length(DiscretizationBounds)==Nstates+1),...
        'openCOSSAN:Node:discretize',...
        'The values provided as bounds of the outcome values are not compatible with the number of states specified')
    
elseif isempty(DiscretizationBounds) && isempty(Nstates)
    Nstates = 3;
    DiscretizationBounds = Node.computeBounds('Nstates',Nstates);
end

VinitialCPDsize=size(Node.CPD);
% CPD of new discrete node: it contains the new discretized states (Nstates)
discretizedCPD         = cell([VinitialCPDsize,Nstates]);
% Index of discrete parents in the CPT
indDiscretePA   = find(ismember(Node.Parents,DiscreteParents));
% CPT of new probabilistic node/s
probabilisticCPD       = cell([VinitialCPDsize(indDiscretePA),Nstates,1]);


for ivs=1:Nrvs
    
    comb=num2cell(common.utilities.myind2sub(size(Node.CPD),ivs)); % index in CPT to extract RVs/BVs
    XVs=Node.CPD{comb{:}}; % exctract RV to discretize
    
    % Define new CPT entried for each state (for both new discrete and probabilistic nodes)
    for istate=1:Nstates
        
        index=[comb,istate];
        
        
        %% DISCRETIZATION CONINUOUS NODES
        % Compute conditional probabilities for the discrete node
        discretizedCPD(index{:})={XVs.physical2cdf(DiscretizationBounds(istate+1))-XVs.physical2cdf(DiscretizationBounds(istate))}; % new entry discrete CPT
        %% FIX cdf USERDEF!
        if isnan(discretizedCPD{index{:}}) && (DiscretizationBounds(istate)>XVs.cdf2physical(1) ||DiscretizationBounds(istate+1)<XVs.cdf2physical(0))
            discretizedCPD(index{:})={0};
        elseif isnan(discretizedCPD{index{:}}) && DiscretizationBounds(istate+1)>XVs.cdf2physical(1) && DiscretizationBounds(istate)<=XVs.cdf2physical(1)
            discretizedCPD(index{:})={1-XVs.physical2cdf(DiscretizationBounds(istate))};
        elseif isnan(discretizedCPD{index{:}}) && DiscretizationBounds(istate)<XVs.cdf2physical(0) && DiscretizationBounds(istate+1)>=XVs.cdf2physical(0)
            discretizedCPD(index{:})={XVs.physical2cdf(Vbounds(istate+1))};
        end
        %%
        if discretizedCPD{index{:}}==0 %the state istate has conditional prob 0
            
            % no info on probability distribution available--> use uniform distribution
            probabilisticCPD{index{[indDiscretePA,end]},1}=UserDefRandomVariable('Vdata',unifrnd(DiscretizationBounds(istate),DiscretizationBounds(istate+1),50,1),...
                'Vtails',[0 1-1E-20]);
            
        else
            
            % Create new RV
            CdfLowerB=XVs.physical2cdf(DiscretizationBounds(istate));
            CdfUpperB=XVs.physical2cdf(DiscretizationBounds(istate+1));
            CDFValues=linspace(CdfLowerB,CdfUpperB);
            Vsupport=XVs.cdf2physical(CDFValues);
            NewCDFValues=(CDFValues-min(CDFValues))./(max(CDFValues)-min(CDFValues));
            % build new random variable (slice of the initial one)
            probabilisticCPD{index{[indDiscretePA,end]},1}=UserDefRandomVariable('Mdata',[Vsupport',NewCDFValues']);
        end
        
        
        
    end
end

%% Build new DIscrete Node Object
NewNodes=Node.empty([0,Nchildren+1]);
NewNodes(1)=DiscreteNode('Name',strcat(Node.Name,'discrete'),'Parents',Node.Parents,...
    'CPD',squeeze(discretizedCPD),'StateBounds',DiscretizationBounds);

%% Build new probabilistic Node Objects
DiscreteParents=[DiscreteParents, strcat(Node.Sname,'discrete')]; %update names of parents (adding new discrete)

names = strings(1,Nchildren);
names(:) = strcat(Node.Sname,'probabilistic');    % suffix 'probabilistic' suggests the node is probabilistic
NewNames= matlab.lang.makeUniqueStrings(names,names);     % generate different names for each probabilistic/bounded children

for i=1:Nchildren
    NewNodes(1+i)=ProbabilisticNode('Name',NewNames{i},'Parents',DiscreteParents,...
        'CPD',probabilisticCPD);
end

end

