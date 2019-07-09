function [Bounds] = getBounds(obj,Names)
%GET  Get method for the RVSET class
%   V = getBounds(RVS,A) returns the value of the Bounds
%       from the RandomVariables which are included by an RandomVariableSet.
%       A is a cellarray, filled with Names of the RandomVariables which
%       are going to be shown.
%
%   getBounds(RandomVariableSet) displays all names and their current values of their Bounds.
%
%
%   Example:    Bounds = getBounds(RVS)
%               Bounds = getBounds(RVS,["RV_1","RV_2"]);
%
% =====================================================



if (nargin < 2)
    % default case Bounds all Members from the RandomVariableSet
    Names = obj.Names;
else
    validateattributes(Names,{'string','char'},{});
end

%% Building Output Cellarray [Bounds]
[~,idx] = ismember(Names,obj.Names);
Bounds = zeros(length(idx),2);

for i=1:length(idx)
    assert(idx(i) ~= 0,...
        'OpenCossan:RandomVariableSet:getBounds',...
        'There are demanded names which are not inlcuded in the used RandomVariableSet')
    Bounds(i,1) = obj.Members(idx(i)).Bounds(1);
    Bounds(i,2) = obj.Members(idx(i)).Bounds(2);
end

end
