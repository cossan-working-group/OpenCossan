function [results, unmatched] = parseRequiredNameValuePairs(names, varargin)
    %PARSEREQUIREDNAMEVALUEPAIRS Parses required name-value pairs from
    %varargin.
    %
    % [results, unmatched] = parseRequiredNameValuePairs(names, varargin)
    % returns the inputParser.Results and a cell array of unmatched
    % arguments (to be passed to the next parsing function or super
    % constructor). The names are converted to lowercase and must be
    % accessed as such from the results structure.
    %
    % An exception is thrown if any of the strings in the names array have
    % no value present in varargin.
    
    % setup the inputParser
    p = inputParser();
    p.KeepUnmatched = true;
    for i = 1:numel(names)
        p.addParameter(lower(names(i)),[]);
    end
    p.parse(varargin{:});
    
    % check if all required inputs are not empty
    idx_found = false(1,numel(names));
    for i = 1:numel(names)
        idx_found(i) = ~isempty(p.Results.(lower(names(i))));
    end
    
    % assert and throw exception
    assert(all(idx_found),...
        'OpenCossan:MissingRequiredInput',...
        'Missing required inputs ''%s''.', strjoin(names(~idx_found), ''', '''));
    
    results = p.Results;
    unmatched = opencossan.common.utilities.parseUnmatchedArguments(p.Unmatched);
end

