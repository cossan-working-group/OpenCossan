function [Info_table] = getRVInfo(obj,Names)
%GET  Get method for the RVSET class
%   V = getRVInfo(RVS,A) returns all values 
%       from the RandomVariables which are included by an RandomVariableSet.
%       A is a cellarray, filled with Names of the RandomVariables which
%       are going to be shown.
%
%   getMean(RandomVariableSet) displays all names and their current values of their mean.
%
%
%   Example:    Means = getRVInfo(RVS)
%               Means = getRVInfo(RVS,["RV_1","RV_2"]);
%
% =====================================================


if (nargin < 2)
    % default case means all Members from the RandomVariableSet
    Names = obj.Names;
else
    validateattributes(Names,{'string','char'},{});
end

%% Building Output table
[~,idx] = ismember(Names,obj.Names);
assert(isempty(idx(idx == 0)),...
    'OpenCossan:RandomVariableSet:getMean',...
    'There are demanded names which are not inlcuded in the used RandomVariableSet')

NamesChar = cell(1,length(Names));
for i = 1:length(Names)
    NamesChar{i} = char(Names(i));
end

dists = strings(length(Names),1);
for i=1:length(idx)
    dists(i) = extractBetween(class(obj.Members(idx(i))),'random.','RandomVariable');
end

Info_table = table(dists,...
                   obj.getMean(Names(idx)),...
                   obj.getStd(Names(idx)),...
                   obj.getCoV(Names(idx)),...
                   obj.getBounds(Names(idx)),...
                   'VariableNames',{'Distribution';'Mean';'Std';'CoV';'Bounds'},...
                   'RowNames',NamesChar);
end
