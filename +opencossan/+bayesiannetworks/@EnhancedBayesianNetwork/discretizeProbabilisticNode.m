function  EBN  = discretizeNode(EBN,varargin)
%	DISCRETIZE method of the class EnhancedBayesianNetwork
%   Allows to replace a continuous random variable (Xi) with two random
%   variables: a discrete variable (Yi) and a continuous one(X'i), wich is a child of
%   the discrete one (Yi). The discrete random variable inherit all parent
%   variables of the inizial RV Xi, while X'i becomes parent to all the
%   children of Xi. The outcome space of Yi consists of mi states which
%   correspond to mutually exclusive,collectively exhaustive intervals in
%   the outcome space of the original variable Xi. The outcome space of X'i
%   is identical to the outcome space of Xi.
%
%
%   Bibliographic source: Straub&Kiureghiam(2010a)
%
%
%
%   Author: Silvia Tolo
%   Institute for Risk and Uncertainty, University of Liverpool, UK
%   email address: openengine@cossan.co.uk
%   Website: http://www.cossan.co.uk

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

%% Process Input
p = inputParser;
p.FunctionName = 'opencossan.bayesiannetworks.EnhancedBayesianNetwork.discretizeProbabilisticNode';
p.addParameter('Nstates',3); 
p.addParameter('NodeName',@(s)isstring(s));
p.addParameter('DiscretizationBounds',[]);
p.addParameter('NprobilisticNodes',1);
p.parse(varargin{:});
% Assign input 
Nstates             = p.Results.Nstates;                % number of states of the new discrete node
NodeName            = p.Results.NodeName;
DiscretizationBounds= p.Results.DiscretizationBounds;   % vector of values which identify the bounds of each state
Nchildren           = p.Results.NprobilisticNodes;      % number of probabilistic/bounded children


%% Compute node to discretize if children of non-discrete
indnode = find(ismember(EBN.NodesNames,NodeName)); 
Node    = EBN.Nodes(indnode);
if iscellstr(Node.CPD)
    EBN=EBN.computeNode('CSnames',NodeName);
end

NodeCorrelation = EBN.Mcorrelation(:,indnode);
%% DISCRETIZE NODE!
% N.B. NewNodes contains first the discrete node, secondly the continuous nodes
% which together substitute the node to discretize
if  ~isempty(DiscretizationBounds)% Discretization bounds specified
    
    NewNodes=Node.discretize('DiscretizationBounds',DiscretizationBounds,...
        'Nchildren',Nchildren);

else
    
    NewNodes=Node.discretize('Nchildren',Nchildren,'Nstates',Nstates);
    
end

%% Update Children's list of parents
indChildren =ismember(EBN.NodesNames, EBN.ChildNodes{indnode});
oldChildren = EBN.Nodes(indChildren);
% Define continuous node/s (which inherit the children of the discretized node)
if Nchildren==length(indChildren)    
    
    % In this case each children will have a different continuous nodes (CnewNode{1+ichild}) as parent
    for ichild=1:length(indChildrenNet)
        
        % Replace name of the parent with the new one
        oldChildren(ichild).Parents(ismember(oldChildren.Parents,NodeName))=NewNodes(1+ichild).Name;
        
        % Regular expression to update children's scripts
        if iscellstr(oldChildren(ichild).CPD)            
            oldChildren(ichild).CPD=regexprep(oldChildren(ichild).CPD,...
                ['\.',lower(NodeName),'(\D)'],['\.',lower(NewNodes{1+ichild}.Sname),'$1']);
        end
        
    end
    
else
    
    % In this case all the children will have the same continuous node (CnewNode{2}) as common parent
    for ichild=1:length(indChildren)
        
        % Replace name of the parent with the new one
        oldChildren(ichild).Parents(ismember(oldChildren.Parents,NodeName))=NewNodes(2).Name;
        
        % Regular expression to update children's scripts
        if iscellstr(oldChildren(ichild).CPD)  
            
            oldChildren(ichild).CPD=regexprep(oldChildren(ichild).CPD,...
                ['\.',lower(NodeName),'(\D)'],['\.',lower(NewNodes{2}.Sname),'$1']);
        end
    end
    
end


%% Update Net  
EBN.Nodes(indnode)=[];
EBN.Nodes=[EBN.Nodes,NewNodes];

%% Update Mcorrelation
% N.B. THERE IS NO NEED TO UPLOAD THE CORRELATION VALUES OF THE DISCRETE NODE
% SINCE NO CORRELATION IS CONSIDERED FOR DISCRETE VARIABLES
% On the contrary all the continuous new nodes are considered perfectly
% correlated (they are the same node!)
Nnodes=EBN.Nnodes;
NodeCorrelation(indnode)=[];
NewMCorrelation=eye(EBN.Nnodes);   % Inizialize new matrix
NNewNodes=length(NewNodes);         % Build new values on the former ones

%   Build new Correlation Matrix
NewMCorrelation(1:Nnodes-NNewNodes,1:Nnodes-NNewNodes)=EBN.Correlation;
NewCorr=[0, ones(1,NNewNodes-1)];             % New Correlation vetors to add
NodeCorrelation(end+1:end+NNewNodes)=NewCorr; % Upload old correlation values
NewMCorrelation(:,Nnodes-NNewNodes+1:Nnodes)= repmat(NodeCorrelation,[1,NNewNodes]);
NewMCorrelation(Nnodes-NNewNodes+1:Nnodes,:)= (repmat(NodeCorrelation,[1,NNewNodes]))';
EBN.Correlation=NewMCorrelation;

end

