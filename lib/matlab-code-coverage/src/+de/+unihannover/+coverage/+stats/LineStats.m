classdef LineStats < de.unihannover.coverage.stats.CodeCoverageStats
    %LINESTATS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        lines;
    end
    
    methods
        function this = LineStats(numLines)
            if nargin == 0
                return
            end
            this.lines = repmat(struct('number', [], 'hits', [], 'branch', ...
                [], 'time', [], 'complex', [], 'valid', false), numLines, 1);
        end
        
        function addLine(this, index, line, valid, hits, branch, time, complex)
            this.lines(index, 1).number = line;
            this.lines(index, 1).hits = hits;
            this.lines(index, 1).branch = branch;
            this.lines(index, 1).time = time;
            this.lines(index, 1).complex = complex;
            
            if valid
                this.lines(index, 1).valid = true;
                this.linesValid = this.linesValid + 1;
                if branch
                    this.branchesValid = this.branchesValid + 1;
                end
                if hits > 0
                    this.linesCovered = this.linesCovered + 1;
                    if branch
                        this.branchesCovered = this.branchesCovered + 1;
                    end
                end
                if complex
                    this.complexity = this.complexity + 1;
                end
            end
        end
    end
    
end

