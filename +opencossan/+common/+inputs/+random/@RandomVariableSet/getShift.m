function [Shifts] = getShift(obj,Names)
%GET  Get method for the RVSET class
%   V = getShift(RVS,A) returns the value of the Shift
%       from the RandomVariables which are included by an RandomVariableSet.
%       A is a cellarray, filled with Names of the RandomVariables which 
%       are going to be shown.
%
%   getShift(RandomVariableSet) displays all names and their current values of their Shift.
%
%
%   Example:    Shifts = getShift(RVS)
%               Shifts = getShift(RVS,["RV_1","RV_2"]);
%
% =====================================================



if (nargin < 2)
    % default case Shifts all Members from the RandomVariableSet
    Names = obj.Names;
else
    validateattributes(Names,{'string','char'},{});
end

%% Building Output Cellarray [Shifts]
[~,idx] = ismember(Names,obj.Names);
Shifts = zeros(length(idx),1);
for i=1:length(idx)
    assert(idx(i) ~= 0,...
        'OpenCossan:RandomVariableSet:getShift',...
        'There are demanded names which are not inlcuded in the used RandomVariableSet')
    Shifts(i) = obj.Members(idx(i)).Shift;
end

end
