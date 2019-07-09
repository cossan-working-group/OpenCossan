classdef PackageStats < de.unihannover.coverage.stats.CodeCoverageStats
    %PACKAGESTATS Represents the statistics for a package
    %
    %See also de.unihannover.coverage.stats.CodeCoverageStats
    
    properties
        name(1,:) char; % Name of the package
        classes(1,:) de.unihannover.coverage.stats.ClassStats; % Class stats for the package
    end
    
    methods
        function this = PackageStats(name)
            %PACKAGESTATS Constructs a new PackageStats object
            if nargin == 0
                return
            end
            this.name = name;
        end
        
        function addClass(this, class)
            %ADDCLASS Adds a ClassStats object
            persistent p
            if isempty(p)
                p = inputParser;
                p.FunctionName = 'de.unihannover.coverage.stats.ClassStats';
                addRequired(p,'class',@(x) validateattributes(x,...
                    {'de.unihannover.coverage.stats.ClassStats'},{}));
            end
            parse(p,class);
            
            if ~isempty(class)
                this.classes = [this.classes class];
                this.addStats(class);
            end
        end
    end
    
end

