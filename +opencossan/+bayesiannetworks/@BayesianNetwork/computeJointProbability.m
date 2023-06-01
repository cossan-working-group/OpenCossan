function [JointProbabilityValues,JointNodes]=computeJointProbability(BN,varargin)
%  Internal method for the class BayesianNetwork and
%  EnhancedBayesianNetwork for the computation of joint probability of
%  network nodes

%% Process Input
p = inputParser;
p.FunctionName = 'opencossan.bayesiannetworks.BayesianNetwork.computeJointProbability';
p.addParameter('NodesNames',@(s)isstring(s)); 
p.addParameter('Vevidence',@(s)isnumeric(s));
p.parse(varargin{:});
% Assign input 
NodesNames      = p.Results.NodesNames;
Vevidence       = p.Results.Vevidence;
TopologicalOrder= BN.TopologicalOrder;
Nnodes          = BN.Nnodes;
[NodesNames, query] =intersect(BN.NodesNames(TopologicalOrder),NodesNames,'stable');

% Extract domain for each node (node and node's parents index)
Domain  = cell(1,Nnodes);
for idom=1:Nnodes
    if ~BN.Nodes(TopologicalOrder(idom)).Lroot
        Domain{idom}  = sort([idom,find(ismember(BN.NodesNames(TopologicalOrder),BN.ParentNodes{TopologicalOrder(idom)}))]);
    else
        Domain{idom}  = idom;
    end
end

sum_over = setdiff(1:Nnodes, query);
Vorder = [query(:); sum_over(:)]';

% Initialize the buckets UpperBound and LowerBound
Tbucket = cell(Nnodes,3);
Tbucket = cell2table(Tbucket,'VariableNames',{'domain','pot','size'});
Tbucket.pot(:)={1};

for inode=1:Nnodes
    buckID =  find(ismember(Vorder,Domain{inode}),1,'last');
    TempUP    = BN.combinePotentials('Tbig',Tbucket(buckID,:),...
        'Node',BN.Nodes(TopologicalOrder(inode)),'Vevidence',Vevidence);
    % exctract info upper bound bucket
    Tbucket.domain(buckID)  = TempUP.domain;
    Tbucket.size(buckID)    = TempUP.size;
    Tbucket.pot(buckID)     = TempUP.pot;
end
sum_over = fliplr(sum_over);
for jnode=sum_over
    % sum over variable inode which occurs in bucket ibuck
    jbuck = find(ismember(Vorder,Domain{jnode}),1,'last');
    nodes2keep = setdiff(Tbucket.domain{jbuck}, jnode);
    if ~isempty(nodes2keep)
        TsmallBuckUP= BN.marginalizeJointP(Tbucket(jbuck,:), nodes2keep,Vevidence);
        buckID = find(ismember(Vorder,[TsmallBuckUP.domain{:}]),1,'last');
        % exctract info upper bound bucket
        Tbucket(buckID,:)  = BN.combinePotentials('Tbig',Tbucket(buckID,:),...
            'Tsmall',TsmallBuckUP,'Vevidence',Vevidence);
    end
end
% Combine all the remaining buckets into one
TBucket = Tbucket(1,:);
for i=2:length(query)
    if ~isempty(Tbucket.domain(i))
        TBucket = BN.combinePotentials('Tbig',Tbucket(i,:), 'Tsmall',TBucket,...
            'Vevidence',Vevidence);
    end
end
Joint=TBucket.pot{:};

JointProbabilityValues = Joint./sum(Joint(:));
JointNodes = NodesNames;


end

