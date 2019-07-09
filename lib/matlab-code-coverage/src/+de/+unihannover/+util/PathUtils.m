classdef PathUtils
    %PATHUTILS Summary of this class goes here
    %   Detailed explanation goes here
    
    methods (Static)
        function  absolute = absolutePath(relative, base)
            %ABSOLUTEPATH  returns the absolute path relative to a given base path.
            % If the base path is omitted the pwd is used instead
            
            p = inputParser;
            p.FunctionName = 'de.unihannover.util.PathUtils.absolutePath';
            p.addRequired('relative',@ischar);
            p.addOptional('base',[pwd filesep],@ischar);
            
            if nargin > 1
                p.parse(relative, base);
            else
                p.parse(relative);
            end
            
            base = p.Results.base; % Set default if necessary
            
            if ~endsWith(base, filesep)
                base = [base filesep];
            end
            
            %build absolute path
            file = java.io.File([base relative]);
            absolute = char(file.getCanonicalPath());
            
            %check that file exists
            if ~exist(absolute, 'file')
                error('MatlabCodeCoverage:PathUtils:FileNotFound', 'The file located at %s does not exist', absolute);
            end
        end
        
        function [relative] = relativeToBasePath(base, absolute)
            %RELATIVETOBASEPATH Returns the absolute path relative to the
            %base path
            assert(startsWith(absolute, base), ...
                'MatlabCodeCoverage:PathUtils:InvalidPath', ...
                'Relative path must be contained within absolute base path');
            relative = absolute(numel(base)+1:end);
        end
    end
end

