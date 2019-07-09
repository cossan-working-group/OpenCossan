classdef CodeCoverage < de.unihannover.coverage.stats.CodeCoverageStats
    %CODECOVERAGE Generates a coverage support in HTML
    
    properties
        sources
        basePath(1,:) char;
        timeStamp;
        packages = [];
        plugins = de.unihannover.coverage.plugins.CodeCoveragePlugin.empty;
    end
    
    properties (GetAccess=private,SetAccess=?de.unihannover.coverage.CodeCoverageTest)
        % Only allow the test class to change the provider for mocking
        CodeInfoProvider(1,1) de.unihannover.coverage.CodeInfoProvider = ...
            de.unihannover.coverage.CodeInfoProvider;
    end
    
    properties (Dependent)
        coverageSummary;
    end
    
    methods
        function this = CodeCoverage(sources, basePath)
            if nargin == 0
                return;
            end
            
            p = inputParser;
            p.FunctionName = 'de.unihannover.coverage.CodeCoverage.CodeCoverage';
            p.addRequired('sources',@(x) validateattributes(x,{'char', 'cell'},...
                {'nonempty'}));
            p.addRequired('basePath',@(x) validateattributes(x,{'char'},...
                {'nonempty'}));
            p.parse(sources, basePath);
            
            if ~iscell(p.Results.sources)
                sources = {sources};
            end
            
            for i = 1:size(sources, 1)
                sources{i, 1} = de.unihannover.util.PathUtils.absolutePath(sources{i,1});
            end
            
            this.sources = sources;
            this.basePath = de.unihannover.util.PathUtils.absolutePath(p.Results.basePath);
        end
        
        function [results, this] = cover(this, runner, suite)
            p = inputParser;
            addRequired(p,'this', @(x) isa(x,'de.unihannover.coverage.CodeCoverage'));
            addRequired(p,'runner',@(x) isa(x,'matlab.unittest.TestRunner'));
            addRequired(p,'suite',@(x) isa(x,'matlab.unittest.TestSuite'));
            parse(p,this,runner,suite);
            
            % Run tests
            [results, info] = this.runTests(runner, suite);
            
            % Create report
            this.timeStamp = datestr(now, 31);
            this.buildReportFromDir(info);
            
            for i = 1:numel(this.plugins)
                this.plugins(i).execute(this);
            end
            
            % Display results
            display(results);
            disp(this.coverageSummary);
        end
        
        function [results, info] = runTests(~, runner, suite)
            status = profile('status');
            if isequal(status.ProfilerStatus,'on')
                warning('CodeCoverage:ProfilerAlreadyRunning',...
                    'Profiler was already running and has been restarted!');
                profile('off');
            end
            profile('on','-nohistory');
            
            results = run(runner, suite);
            profile('off');
            info = profile('info');
        end
        
        
        function coverageSummary = get.coverageSummary(this)
            template = ['=============================== Coverage summary ===============================\n' ...
                'Branches     : %2.2f%% (%d/%d)\n' ...
                'Lines        : %2.2f%% (%d/%d)\n' ...
                '================================================================================'];
            
            coverageSummary = sprintf(template,this.branchRate*100,this.branchesCovered,this.branchesValid,...
                this.lineRate*100,this.linesCovered,this.linesValid);
        end
        
        function addPlugin(this,plugin)
            this.plugins = [this.plugins plugin];
        end
        
        %% Methods from files
        addPackage(this, package);
        class = buildClassReport(this, metaClass, profData);
        func = buildFunctionReport(this, packageName, metaFunction, profData)
        
        method = buildMethodReport(this, name, signature, shortClassName,...
            fileName, methodsCallInfo, runnableLineIndex, code, profData);
        package = buildPackageReport(this, metaPackage, profData);
        buildReportFromDir(this, propData);
        method = buildSubFunctionReport(this, fileName, code, runnableLineIndex, callInfo, signature, profData);
        in = inSources(this, fileName);
    end
    
    methods (Static)
        stats = buildLinesReport(code, runLineIndex, firstLine, lastLine, profData);
    end
end
