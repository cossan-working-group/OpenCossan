classdef (Abstract) TutorialTest < matlab.unittest.TestCase
    %TUTORIALTEST This is the base test for all tutorial unit tests
    %Each unit test just has to override the abstract attributes and this
    %class will take care of the rest
    
    properties (Abstract)
        TutorialName; % Tutorial Name
        CoutputNames; % Expected Variable Names
        CvaluesExpected; % Enter the expected results into cell array
        Ctolerance; % Enter the given tolerances into cell array
        PreTest; % Any scripts that have to be run before the Tutorial
    end
    
    methods (Test)
        function runTest(testCase)
            % Run pre tests
            % Cannot be done inside TestClassSetup because of workspace
            % issues
            for i = 1:numel(testCase.PreTest)
                run(testCase.PreTest{i});
            end
            % Run the test
            run(testCase.TutorialName);
            % Do the assertions
            for i = 1:numel(testCase.CoutputNames)
                if (ischar(testCase.Ctolerance{i}))
                    testCase.Ctolerance{i} = eval(testCase.Ctolerance{i});
                end
                testCase.verifyEqual(eval(testCase.CoutputNames{i}),testCase.CvaluesExpected{i},'AbsTol',testCase.Ctolerance{i});
            end
        end
    end
    
end

