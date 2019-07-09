function [TsmallLower,TsmallUpper ]=marginalizeJointP(BN,TbucketLower, nodes2keep,Vevidence)

% check for evidence
TopologicalOrder=BN.TopologicalOrder;
VNetSizes=BN.NodesSize(TopologicalOrder);
VNetSizes((Vevidence(TopologicalOrder))~=0)=1;

% initialize output
TsmallLower=TbucketLower(1,:);

lowerPOT=cell2mat(TbucketLower.pot);
Vsize=VNetSizes(nodes2keep);
% identify dimentions to sum over
sumover  = setdiff([TbucketLower.domain{:}],nodes2keep);
sumIndex = find(ismember([TbucketLower.domain{:}],sumover));

for i=1:length(sumIndex)
    lowerPOT = sum(lowerPOT, sumIndex(i));
end
lowerPOT = squeeze(lowerPOT);
if isempty(Vsize)
    return;
elseif length(Vsize)==1
    lowerPOT = reshape(lowerPOT, [Vsize 1]);
else
    lowerPOT = reshape(lowerPOT, Vsize(:)');
end
TsmallUpper=[];


TsmallLower.pot={lowerPOT};
TsmallLower.domain={nodes2keep};
TsmallLower.size={Vsize};



