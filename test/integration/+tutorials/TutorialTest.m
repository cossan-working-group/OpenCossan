classdef (Abstract) TutorialTest < matlab.unittest.TestCase
    %TUTORIALTEST This is the base test for all tutorial unit tests
    %Each unit test just has to override the abstract attributes and this
    %class will take care of the rest
    
    properties (Abstract)
        Name(1,1) string; % Tutorial Name
        Variables(1,:) string; % Expected Variable Names
        ExpectedValues(1,:) cell; % Enter the expected results into cell array
        Tolerance(1,:) double; % Enter the given tolerances into cell array
        PreTest(1,:) string; % Any scripts that have to be run before the Tutorial
    end
    
    methods (Test)
        function runTest(testCase)
            % Add teardown to close all figures
            testCase.addTeardown(@closeFigures);
            
            % Run pre tests
            % Cannot be done inside TestClassSetup because of workspace issues.
            for i = 1:numel(testCase.PreTest)
                run(testCase.PreTest(i));
            end
            
            % Run the test
            run(testCase.Name);
            
            % Do the assertions
            for i = 1:numel(testCase.Variables)
                actual = eval(testCase.Variables(i));
                expected = testCase.ExpectedValues{i};
                tolerance = testCase.Tolerance(i);
                testCase.verifyEqual(actual, expected, 'AbsTol', tolerance);
            end
        end
    end
end

function closeFigures()
    close all hidden;
end

