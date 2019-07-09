classdef CodeCoverageStats < handle
    %CODECOVERAGESTATS Represents the overall statistics of the covered
    %code
    
    properties (SetAccess = protected)
        linesValid(1,1) {mustBeInteger};        % Number of valid lines
        linesCovered(1,1) {mustBeInteger};      % Number of covered lines
        branchesValid(1,1) {mustBeInteger};     % Number of valid branches
        branchesCovered(1,1) {mustBeInteger};   % Number of covered branches
        complexity(1,1) {mustBeInteger};        % Cyclomatic complexety
    end
    
    properties(Dependent)
        lineRate;   % Percentage of valid lines covered
        branchRate; % Percentage of branches covered
    end
    
    methods (Access = protected)
        function addStats(this, stats)
            %ADDSTATS Adds another CodeCoverageStats object by summing the
            %stats
            persistent p
            if isempty(p)
                p = inputParser;
                p.FunctionName = 'de.unihannover.coverage.stats.CodeCoverageStats.addStats';
                addRequired(p,'stats',@(x) validateattributes(x,...
                    {'de.unihannover.coverage.stats.CodeCoverageStats'},{}));
            end
            parse(p,stats);
            
            this.linesCovered = this.linesCovered + stats.linesCovered;
            this.linesValid = this.linesValid + stats.linesValid;
            this.branchesCovered = this.branchesCovered + stats.branchesCovered;
            this.branchesValid = this.branchesValid + stats.branchesValid;
            this.complexity = this.complexity + stats.complexity;
        end
    end
    
    methods
        function lineRate = get.lineRate(this)
            %GET.LINERATE Returns the line rate
            if this.linesValid == 0
                lineRate = 1; % The line rate is 1 for 0 valid lines
            else
                lineRate = this.linesCovered / this.linesValid;
            end
        end
        
        function branchRate = get.branchRate(this)
            %GET.BRANCHRATE Returns the branch rate
            if this.branchesValid == 0
                branchRate = 1; % The branch rate is 1 for 0 valid branches
            else
                branchRate = this.branchesCovered / this.branchesValid;
            end
        end
    end
    
end

