try
    % Imports
    import matlab.unittest.TestRunner;
    import matlab.unittest.TestSuite;
    import matlab.unittest.plugins.XMLPlugin;
    import matlab.unittest.plugins.ToFile;
    
    %% Initialize OpenCossan
    workingDirectory = fullfile(fileparts(which(mfilename())),'tmp');
    if ~exist(workingDirectory,'dir')
        mkdir(workingDirectory);
    end
    userpath(workingDirectory);
    import opencossan.OpenCossan;
    OpenCossan.setVerbosityLevel(0);
    
    %% Add tests folders
    addpath(genpath(fullfile(OpenCossan.getRoot(),'test','integration')));
    addpath(genpath(fullfile(OpenCossan.getRoot(),'lib','matlab-code-coverage')));
    
    %% Create TestRunner
    runner = TestRunner.withTextOutput;
    % Add XMLPlugin
    % The XMLPlugin provides a jUnit style file  to interface with Jenkins
    xmlFile = 'integration_test_results.xml';
    if exist(xmlFile,'file')
        delete(xmlFile);
    end
    runner.addPlugin(XMLPlugin.producingJUnitFormat(xmlFile));
    
    %% Create TestSuites
    suite = TestSuite.fromPackage('tutorials');
    
    %% Run and display results
    result = runner.run(suite);
    disp(result);
    
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