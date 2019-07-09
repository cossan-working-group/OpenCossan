classdef HtmlReportPlugin < de.unihannover.coverage.plugins.CodeCoveragePlugin
    %CODECOVERAGEREPORTWRITER Writes the HTML coverage report
    
    properties
        Path char = "";
    end
    
    properties (Access=private)
        CodeInfoProvider(1,1) de.unihannover.coverage.CodeInfoProvider = ...
            de.unihannover.coverage.CodeInfoProvider;
    end
    
    methods
        %% Constructor
        function this = HtmlReportPlugin(path)
            if nargin == 0
                return;
            end
            
            this.Path = path;
        end
        
        function execute(this, coverage)
            if isfolder(this.Path)
                rmdir(this.Path,'s');
            end
            mkdir(this.Path)
            this.writeReport(coverage);
        end
        
        %% Write report
        function writeReport(this, coverage)
            copyfile(which(fullfile('assets', 'css', 'base.css')),...
                fullfile(this.Path,'base.css'));
            fileID = fopen(fullfile(this.Path, 'index.html'), 'w');
            this.writeMainIndex(fileID, coverage);
            fclose(fileID);
            for i = 1:numel(coverage.packages)
                package = coverage.packages(i);
                dir = fullfile(this.Path, package.name);
                mkdir(dir);
                fileID = fopen(fullfile(dir, 'index.html'), 'w');
                this.writePackageReport(fileID, package);
                fclose(fileID);
                for j = 1:numel(package.classes)
                    class = package.classes(j);
                    dir = fullfile(this.Path, package.name, class.name);
                    mkdir(dir);
                    fileID = fopen(fullfile(dir, 'index.html'), 'w');
                    this.writeClassReport(fileID, package.name, class);
                    fclose(fileID);
                    for k = 1:numel(class.functions)
                        method = class.functions(k);
                        dir = fullfile(this.Path, package.name, ...
                            class.name, method.name);
                        dir = replace(dir,'>','.');
                        mkdir(dir);
                        fileID = fopen(fullfile(dir, 'index.html'), 'w');
                        this.writeMethodReport(fileID, package.name,...
                            class.name, method);
                        fclose(fileID);
                    end
                end
            end
        end
    end
    
    methods
        writeClassReport(this,fileID,package,class);
        writeMainIndex(~,fileID, coverage);
        writeMethodReport(this, fileId, package, class, method);
        writePackageReports(this, fileId, package);
    end
    
    methods (Static)
        html = injectSummary(stats, html);
        level = getCoverageLevel(coverage);
    end
    
end
