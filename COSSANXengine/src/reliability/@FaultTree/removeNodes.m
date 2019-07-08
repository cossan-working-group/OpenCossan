function Xobj = removeNodes(Xobj,varargin)
% REMOVENODES This function remove nodes to the FaultTree
%
% The function return a FaultTree object


%% Remove cut-sets
Xobj.McutSets=[];
Xobj.MminimalCutSets=[];
Xobj.CminimalCutSets=[];

%% Process inputs
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'vnodeindex','vnodeindecies'}
            Vindex=varargin{k+1};
        otherwise
            error('openCOSSAN:reliability:FaultTree:removeNodes',...
                'Field name not allowed');
    end
end

if max(Vindex)>length(Xobj.VnodeConnections)
   error('openCOSSAN:reliability:FaultTree:removeNodes',...
         ['It is not possible to remove the node ' num2str(max(Vindex)) ...
         '. The FaultTree contains ' num2str(length(Xobj.VnodeConnections)) ' nodes'] );
end

if min(Vindex)<=1
   error('openCOSSAN:reliability:FaultTree:removeNodes',...
         'It is not possible to remove the node 0 (TopEvent)' );
end

% define vector of logical values
Lkeepnodes=true(length(Xobj.CnodeTypes),1);
Lkeepnodes(Vindex)=false;

Xobj.CnodeTypes=Xobj.CnodeTypes(Lkeepnodes);
Xobj.CnodeNames=Xobj.CnodeNames(Lkeepnodes);
Xobj.VnodeConnections=Xobj.VnodeConnections(Lkeepnodes);

