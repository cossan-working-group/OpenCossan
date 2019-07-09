classdef CoberturaPlugin < de.unihannover.coverage.plugins.CodeCoveragePlugin
    %CCOBERTURAPLUGIN Writes the HTML coverage report
    
    properties
        fileName char = "";
    end
    
    methods
        %% Constructor
        function this = CoberturaPlugin(fileName)
            if nargin == 0
                return;
            end
            this.fileName = fileName;
        end
    end
    
    methods
        function execute(this, coverage)
            this.exportCoberturaXML(coverage);
        end
        exportCoberturaXML(this, coverage);
        node = buildPackageNode(this,doc,package,basePath);
        node = buildClassNode(this,doc,class,basePath);
        node = buildMethodNode(this,doc,method);
    end
    
end

