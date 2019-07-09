function [results, unmatched] = parseOptionalNameValuePairs(names, defaults, varargin)
    p = inputParser();
    p.KeepUnmatched = true;
    for i = 1:numel(names)
        p.addParameter(lower(names(i)),defaults{i});
    end
    p.parse(varargin{:});
    
    results = p.Results;
    unmatched = opencossan.common.utilities.parseUnmatchedArguments(p.Unmatched);
end

