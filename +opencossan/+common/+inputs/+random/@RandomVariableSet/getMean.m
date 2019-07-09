function [Means] = getMean(obj,Names)
%GET  Get method for the RVSET class
%   V = getMean(RVS,A) returns the value of the mean
%       from the RandomVariables which are included by an RandomVariableSet.
%       A is a cellarray, filled with Names of the RandomVariables which 
%       are going to be shown.
%
%   getMean(RandomVariableSet) displays all names and their current values of their mean.
%
%
%   Example:    Means = getMean(RVS)
%               Means = getMean(RVS,["RV_1","RV_2"]);
%
% =====================================================



if (nargin < 2)
    % default case means all Members from the RandomVariableSet
    Names = obj.Names;
else
    validateattributes(Names,{'string','char'},{});
end

%% Building Output Cellarray [Means]
[~,idx] = ismember(Names,obj.Names);
Means = zeros(length(idx),1);

for i=1:length(idx)
    assert(idx(i) ~= 0,...
        'OpenCossan:RandomVariableSet:getMean',...
        'There are demanded names which are not inlcuded in the used RandomVariableSet')
    Means(i) = obj.Members(idx(i)).Mean;
end

end
