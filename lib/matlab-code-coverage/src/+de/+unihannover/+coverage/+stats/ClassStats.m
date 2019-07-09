classdef ClassStats < de.unihannover.coverage.stats.CodeCoverageStats
    %CLASSSTATS Represents code coverage statistics for a class
    %
    %See also de.unihannover.coverage.stats.CodeCoverageStats
    
    properties
        name(1,:) char;     % Name of the class
        fileName(1,:) char; % File name of the class
        functions(:,1) de.unihannover.coverage.stats.MethodStats; % Function statistics for the class
        lines(:,1) de.unihannover.coverage.stats.LineStats; % Linestats for the functions
    end
    
    methods
        function this = ClassStats(name, fileName)
            %CLASSSTATS Constructs a new ClassStats object
            if nargin == 0
                return
            end
            this.name = name;
            this.fileName = fileName;
        end
        
        function addFunction(this, fun)
            %ADDFUNCTION Adds a FunctionStats object
            persistent p
            if isempty(p)
                p = inputParser;
                p.FunctionName = 'de.unihannover.coverage.stats.ClassStats.addFunction';
                addRequired(p,'fun',@(x) validateattributes(x,...
                    {'de.unihannover.coverage.stats.MethodStats'},{}));
            end
            p.parse(fun);
            
            if ~isempty(fun)
                this.functions = [this.functions; fun];
                this.lines = [this.lines; fun.lines];
                this.addStats(fun);
            end
        end
    end
    
end

