try
    % Imports
    import matlab.unittest.TestRunner;
    import matlab.unittest.TestSuite;
    import matlab.unittest.plugins.XMLPlugin;
    import matlab.unittest.plugins.ToFile;
    import matlab.unittest.plugins.CodeCoveragePlugin;
    import matlab.unittest.plugins.codecoverage.*;
    
    %% Initialize OpenCossan
    workingDirectory = fullfile(fileparts(which(mfilename())),'tmp');
    if ~exist(workingDirectory,'dir')
        mkdir(workingDirectory);
    end
    userpath(workingDirectory);
    import opencossan.OpenCossan;
    clc
    OpenCossan.setVerbosityLevel(0);
    
    %% Add tests folders
    addpath(genpath(fullfile(OpenCossan.getRoot(),'test','unit')));
    
    %% Create TestRunner
    runner = TestRunner.withTextOutput;
    % Add XMLPlugin
    % The XMLPlugin provides a jUnit style file  to interface with Jenkins
    xmlFile = 'unit_test_results.xml';
    if exist(xmlFile,'file')
        delete(xmlFile);
    end
    runner.addPlugin(XMLPlugin.producingJUnitFormat(xmlFile));
    runner.addPlugin(CodeCoveragePlugin.forPackage(...
        'opencossan', ...
        'IncludingSubpackages', true, ...
        'Producing', CoverageReport('coverage')));
    runner.addPlugin(CodeCoveragePlugin.forPackage(...
        'opencossan', ...
        'IncludingSubpackages', true, ...
        'Producing', CoberturaFormat('cobertura.xml')));
    
    % Create TestSuites
    suite = TestSuite.fromPackage('opencossan','IncludingSubpackages',true);
    % Run test suites with coverage
    runner.run(suite);
    
    OpenCossan.setVerbosityLevel(3);
catch e
    disp(getReport(e,'extended'));
    OpenCossan.setVerbosityLevel(3);
    if ~usejava('desktop') % Exit if running in headless mode
        exit(1);
    end
end
if ~usejava('desktop') % Exit if running in headless mode
    exit(0);
end
