try
    % Imports
    import matlab.unittest.TestRunner;
    import matlab.unittest.TestSuite;
    import matlab.unittest.plugins.XMLPlugin;
    import matlab.unittest.plugins.ToFile;
    
    root = fileparts(mfilename('fullpath'));
    
    %% Initialize OpenCossan
    workingDirectory = fullfile(root,'tmp');
    if ~exist(workingDirectory,'dir')
        mkdir(workingDirectory);
    end
    userpath(workingDirectory);
    
    %% Setup
    addpath(genpath(fullfile(root,'test','integration')));
    addpath(genpath(fullfile(root,'COSSANXengine','src')));
    OpenCossan('NverboseLevel',0);
    
    %% Create TestRunner
    runner = TestRunner.withTextOutput;
    % Add XMLPlugin
    % The XMLPlugin provides a jUnit style file  to interface with Jenkins
    xmlFile = 'integrationResults.xml';
    if exist(xmlFile,'file')
        delete(xmlFile);
    end
    runner.addPlugin(XMLPlugin.producingJUnitFormat(xmlFile));
    
    %% Create TestSuites
    suite = TestSuite.fromFolder(fullfile(root,'test','integration'));
    
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