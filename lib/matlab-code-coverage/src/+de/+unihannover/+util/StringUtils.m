classdef StringUtils
    %STRINGUTILS Contains functions to handle strings

    methods(Static)
        function str = strjoin(sep, varargin)
            %STRJOIN Join strings in a cell array.
            
            p = inputParser;
            p.FunctionName = 'de.unihannover.util.StringUtils.strjoin';
            p.addRequired('sep',@ischar);
            p.addRequired('varargin',@iscellstr);
            p.parse(sep,varargin);
            
            if isempty(varargin)
                str = '';     
            elseif isempty(sep)
                % special case: empty separator so use simple string concatenation
                str = [ varargin{:} ];
            else
                % varargin is a row vector, so fill second column with separator (using scalar
                % expansion) and concatenate but strip last separator
                varargin(2,:) = { sep };
                str = [ varargin{1:end-1} ];
            end
        end
    end
    
end
    
