function [CoVs] = getCoV(obj,Names)
%GET  Get method for the RVSET class
%   V = getCoV(RVS,A) returns the value of the CoV
%       from the RandomVariables which are included by an RandomVariableSet.
%       A is a cellarray, filled with Names of the RandomVariables which
%       are going to be shown.
%
%   getCoV(RandomVariableSet) displays all names and their current values of their CoV.
%
%
%   Example:    CoVs = getCoV(RVS)
%               CoVs = getCoV(RVS,["RV_1","RV_2"]);
%
% =====================================================



if (nargin < 2)
    % default case CoVs all Members from the RandomVariableSet
    Names = obj.Names;
else
    validateattributes(Names,{'string','char'},{});
end

%% Building Output Cellarray [CoVs]
[~,idx] = ismember(Names,obj.Names);
CoVs = zeros(length(idx),1);

for i=1:length(idx)
    assert(idx(i) ~= 0,...
        'OpenCossan:RandomVariableSet:getCoV',...
        'There are demanded names which are not inlcuded in the used RandomVariableSet')
    CoVs(i) = obj.Members(idx(i)).CoV;
end

end
