classdef ObjectiveFunctionTest < matlab.unittest.TestCase
    %OBJECTIVEFUNCTIONTEST Unit tests for the class 
    % optimization.ObjectiveFunction
    
    properties
        Description = "Objective Function";
        Script = 'for n=1:length(Tinput), Toutput(n).Out = Tinput(n).In1 + Tinput(n).In2; end';
        OutputNames = {'Out'};
        InputNames = {'In1' 'In2'};
    end
    
    
    methods (Test)
        %% constructor
        function constructorEmpty(testCase)
            obj = opencossan.optimization.ObjectiveFunction();
            testCase.verifyClass(obj, 'opencossan.optimization.ObjectiveFunction');
        end
        
        function constructorFull(testCase)
            obj = opencossan.optimization.ObjectiveFunction(...
                'Description', testCase.Description, ...
                'Script', testCase.Script, ...
                'OutputNames', testCase.OutputNames, ...
                'InputNames', testCase.InputNames);
            testCase.verifyEqual(obj.Description, testCase.Description);
            testCase.verifyEqual(obj.Script, testCase.Script);
            testCase.verifyEqual(obj.OutputNames, testCase.OutputNames);
            testCase.verifyEqual(obj.InputNames, testCase.InputNames);
        end
        
        function shouldErrorForMultipleOutputs(testCase)
            testCase.verifyError(@() opencossan.optimization.ObjectiveFunction(...
                'Description', testCase.Description, ...
                'Script', testCase.Script, ...
                'OutputNames', {' Out1' 'Out2'}, ...
                'InputNames', testCase.InputNames), ...
                'openCOSSAN:optimization:ObjectiveFunction');
        end
    end
end

