function [Stds] = getStd(obj,Names)
%GET  Get method for the RVSET class
%   V = getStd(RVS,A) returns the value of the Std
%       from the RandomVariables which are included by an RandomVariableSet.
%       A is a cellarray, filled with Names of the RandomVariables which 
%       are going to be shown.
%
%   getStd(RandomVariableSet) displays all names and their current values of their Std.
%
%
%   Example:    Stds = getStd(RVS)
%               Stds = getStd(RVS,["RV_1","RV_2"]);
%
% =====================================================



if (nargin < 2)
    % default case Stds all Members from the RandomVariableSet
    Names = obj.Names;
else
    validateattributes(Names,{'string','char'},{});
end

%% Building Output Cellarray [Stds]
[~,idx] = ismember(Names,obj.Names);
Stds = zeros(length(idx),1);
for i=1:length(idx)
    assert(idx(i) ~= 0,...
        'OpenCossan:RandomVariableSet:getStd',...
        'There are demanded names which are not inlcuded in the used RandomVariableSet')
    Stds(i) = obj.Members(idx(i)).Std;
end

end
