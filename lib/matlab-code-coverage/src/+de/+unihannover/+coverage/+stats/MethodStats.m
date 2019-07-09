classdef MethodStats < de.unihannover.coverage.stats.CodeCoverageStats
    %METHODSTATS Represents statistics for a method/function
    %
    %See also de.unihannover.coverage.stats.CodeCoverageStats
    
    properties
        name(1,:) char;                 % Name of the method
        fileName(1,:) char;             % File name of the method
        signature(1,:) char;            % Signature of the method
        firstLine(1,1) {mustBeInteger}; % First line number
        lastLine(1,1) {mustBeInteger};  % Last line number
        lines(1,1) de.unihannover.coverage.stats.LineStats; % Line statistics
        calls(1,1) {mustBeInteger};     % Number of calls
        time(1,1) double;               % Time spent running this method
    end
    
    methods
        function this = MethodStats(name, fileName, signature, firstLine,...
                lastLine)
            %METHODSTATS Constructs a new MethodStats object
            this.complexity = 1;
            if nargin == 0
                return
            end
            this.name = name;
            this.fileName = fileName;
            this.signature = signature;
            this.firstLine = firstLine;
            this.lastLine = lastLine;
        end
        
        function addLineStats(this, lines)
            %ADDLINESTATS Adds line stats
            persistent p
            if isempty(p)
                p = inputParser;
                p.FunctionName = 'de.unihannover.coverage.stats.MethodStats.addLineStats';
                addRequired(p,'lines',@(x) validateattributes(x,...
                    {'de.unihannover.coverage.stats.LineStats'},{}));
            end
            parse(p,lines);
            
            this.addStats(lines);
            this.lines = lines;
        end
    end
    
end

