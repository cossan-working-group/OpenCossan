function [super_args] = parseUnmatchedArguments(unmatched)
% PARSEUNMATCHEDARGUMENTS - Parse p.Unmatched for super constructor
% 
% This static function parses the p.Unmatched struct of the inputParser 
% into name-value pairs for the super constructor. 
%
%   super_args = OpenCossan.parseUnmatchedArguments(unmatched)

assert(isa(unmatched,'struct'),'openCOSSAN:OpenCossan:parseUnmatchedArguments',...
    'You must provide the p.Unmatched struct to this function');

fields = fieldnames(unmatched);
super_args = cell(1,2*length(fields));

for i = 1:2:length(super_args)
    super_args{i} = fields{floor(i/2)+1};
    super_args{i+1} = unmatched.(fields{floor(i/2)+1});
end

end

