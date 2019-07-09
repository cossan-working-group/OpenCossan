function Xobj = addNodes(Xobj,varargin)
% ADDNODES Thisfunction add new nodes to the FaultTree
%
% The function return a FaultTree object


%% Remove cut-sets
Xobj.McutSets=[];
Xobj.MminimalCutSets=[];
Xobj.CminimalCutSets=[];

%% Process inputs
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'cnodetypes'}
            Xobj.CnodeTypes=[Xobj.CnodeTypes varargin{k+1}];
        case {'cnodenames'}
            Xobj.CnodeNames=[Xobj.CnodeNames varargin{k+1}];
        case {'vnodeconnections'}
            Xobj.VnodeConnections=[Xobj.VnodeConnections varargin{k+1}];
        otherwise
            error('openCOSSAN:reliability:FaultTree:addNodes',...
                'Field name not allowed');
    end
end

%% Check consistency of the passed variables
if length(Xobj.CnodeTypes)~=length(Xobj.CnodeNames) && length(Xobj.CnodeTypes)~=length(Xobj.VnodeConnections)
    error('openCOSSAN:reliability:FaultTree',...
        ['Length of Cnodetype Cnodenames and Vnodeout must be the same \n Cnodetype: ' ...
        num2str(length(Xobj.CnodeTypes)) ' \n Cnodenames: ' num2str(length(Xobj.CnodeNames)) ...
        ' \n Vnodeout: ' num2str(length(Xobj.VnodeConnections))])
end

