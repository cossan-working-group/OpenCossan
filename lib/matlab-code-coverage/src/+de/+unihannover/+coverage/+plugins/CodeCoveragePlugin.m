classdef (Abstract) CodeCoveragePlugin < matlab.mixin.Heterogeneous
    %CODECOVERAGEPLUGIN Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function this = CodeCoveragePlugin()
        end
    end
    
    methods (Abstract)
        execute(coverage);
    end
end

