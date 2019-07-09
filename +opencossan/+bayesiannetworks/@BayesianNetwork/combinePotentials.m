function Tbucket=combinePotentials(BN,varargin)

p = inputParser;
p.FunctionName = 'opencossan.bayesiannetworks.BayesianNetwork.combinePotentials';

% Initialize input
p.addParameter('Tbig',''); % or tbig
p.addParameter('Tsmall','');
p.addParameter('Node','');
p.addParameter('Vevidence',@(s)isnumeric(s));
p.parse(varargin{:});
% Assign input
TbucketBig      = p.Results.Tbig;
TbucketSmall    = p.Results.Tsmall;
Node            = p.Results.Node;
Vevidence       = p.Results.Vevidence;

TopologicalOrder    = BN.TopologicalOrder;
TopologicalSize     = BN.NodesSize(TopologicalOrder);
TopologicalEvidence = Vevidence(TopologicalOrder);
TopologivalNames    = BN.NodesNames(TopologicalOrder);

% Initialize output as a table
Tbucket=TbucketBig(1,:);
% check if the node receives evidence
IndObservedNodes=find(TopologicalEvidence>0);
TopologicalSize(IndObservedNodes)=1;
% Extract small bucket properties
if ~isempty(Node)
    Domain(2) = {find(ismember(TopologivalNames,[Node.Name,Node.Parents]))};
    [~,~,VTopologicalOrder]=intersect(TopologivalNames,[Node.Parents,Node.Name],'stable');
    [~,EvInObsNodes,EvInCPT]=intersect(IndObservedNodes,Domain{2});
    
    if ~issorted(VTopologicalOrder)
        Pot{2}    =    permute(cell2mat(Node.CPD),VTopologicalOrder);
    else
        Pot{2}    =    cell2mat(Node.CPD);
    end
    
    
    
    
    if ~isempty(EvInObsNodes)
        preEvPot=Pot{2};
        Index=cell(1,length(size(Pot{2})));
        if length(Domain{2})>1
            Index(:)={':'};
            Index{EvInCPT}=TopologicalEvidence(IndObservedNodes(EvInObsNodes));
        else
            Index(:)={1,TopologicalEvidence(IndObservedNodes(EvInObsNodes))};
        end
        Pot{2}=preEvPot(Index{:});
    end
    Size(2)   = {TopologicalSize(ismember(TopologivalNames,[Node.Name,Node.Parents]))};
    
    
elseif ~isempty(TbucketSmall)
    Domain(2) = {[TbucketSmall.domain{:}]};
    Pot(2)    = {TbucketSmall.pot{:}};
    Size(2)   = {[TbucketSmall.size{:}]};
else
    error('openCOSSAN:bayesiannetworks:BayesianNetwork:combinePotentials',...
        'Input an object node or a bucket table');
end
if ~issorted(Domain{1})
    [Domain{2}, indSort]=sort(Domain{2});
    Pot{2}=permute(Pot{2},indSort);
end

% Extract big bucket properties
Domain(1) = {TbucketBig.domain{:}};
Pot(1)    = {TbucketBig.pot{:}};
Size(1)   = {[TbucketBig.size{:}]};


Tbucket.domain  =  {union(Domain{2},Domain{1})};
Tbucket.size    =  {TopologicalSize([Tbucket.domain{:}])};

if isempty(Tbucket.size)
    Tbucket.pot = {1};
elseif length([Tbucket.size{:}])==1
    Tbucket.pot = {ones([Tbucket.size{:}], 1)};
else
    Tbucket.pot= {ones([Tbucket.size{:}])};
end

for ibuck=1:2
    % first merge Tbucket with TbucketBig
    [~,mapInSize,mapInBuck] = intersect([Tbucket.domain{:}],Domain{ibuck},'stable');
    Vsize                   = ones(1, length([Tbucket.domain{:}]));
    Vsize(mapInSize)        = Size{ibuck}(mapInBuck);
    
    if ~isequal(size(Pot{ibuck}), [1 1])
        if isempty(Vsize)
        elseif length(Vsize)==1
            Pot{ibuck} = reshape(Pot{ibuck}, [Vsize 1]);
        else
            Pot{ibuck} = reshape(Pot{ibuck}, [Vsize(:)']);
        end
        Vsize       = [Tbucket.size{:}];
        Vsize(mapInSize)  = 1; % don't replicate along TbucketSmall's dimensions
        
        if isempty(Vsize)
        elseif length(Vsize)==1
            Pot{ibuck} = repmat(Pot{ibuck}, [Vsize, 1]);
        else
            Pot{ibuck} = repmat(Pot{ibuck}, Vsize(:)');
        end
    end
    Tbucket.pot= {cell2mat(Tbucket.pot).*Pot{ibuck}};
end

