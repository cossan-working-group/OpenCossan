classdef InputTest < matlab.unittest.TestCase
    %INPUTTEST Unit tests for the class Input
    % See also opencossan.common.inputs.Input
    
    %{
    This file is part of OpenCossan <https://cossan.co.uk>.
    Copyright (C) 2006-2018 COSSAN WORKING GROUP

    OpenCossan is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License or,
    (at your option) any later version.

    OpenCossan is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with OpenCossan. If not, see <http://www.gnu.org/licenses/>.
    %}
    
    properties
        x = opencossan.common.inputs.Parameter('Value', 10);
        y = opencossan.common.inputs.Parameter('Value', -10);
        
        f1 = opencossan.common.inputs.Function('Expression', '<&x&>.^2');
        f2 = opencossan.common.inputs.Function('Expression', '<&x&> - <&y&>');
        
        r = opencossan.common.inputs.random.ExponentialRandomVariable('lambda', 1);
        a = opencossan.common.inputs.random.ExponentialRandomVariable('lambda', 2);
        b = opencossan.common.inputs.random.NormalRandomVariable('mean', 1, 'std', 0);
        
        c = opencossan.optimization.ContinuousDesignVariable('Value', 5, 'LowerBound', 0);
        d = opencossan.optimization.ContinuousDesignVariable('Value', 3, 'UpperBound', 10);
        
        sp = opencossan.common.inputs.StochasticProcess();
        
        set;
    end
    
    methods (TestMethodSetup)
        function setupRandomVariableSet(testCase)
            testCase.set = opencossan.common.inputs.random.RandomVariableSet(...
                'Members', [testCase.a, testCase.b], 'Names', ["a", "b"]);
        end
    end
    
    methods (Test)
        
        %% Constructor
        function constructorEmpty(testCase)
            input = opencossan.common.inputs.Input();
            testCase.verifyClass(input, 'opencossan.common.inputs.Input');
            testCase.verifyEqual(input.NumberOfInputs, 0);
        end
        
        %% Parameters
        function testParameters(testCase)
            input = opencossan.common.inputs.Input('Members', ...
                {testCase.x, testCase.y}, 'Names', ["x", "y"]);
            testCase.verifyEqual(input.Parameters, [testCase.x, testCase.y]);
            testCase.verifyEqual(input.ParameterNames, ["x", "y"]);
            testCase.verifyEqual(input.NumberOfParameters, 2);
        end
        
        %% Functions
        function testFunctions(testCase)
            input = opencossan.common.inputs.Input('Members', ...
                {testCase.x, testCase.y, testCase.f1, testCase.f2}, 'Names', ["x", "y", "f1", "f2"]);
            testCase.verifyEqual(input.Functions, [testCase.f1, testCase.f2]);
            testCase.verifyEqual(input.FunctionNames, ["f1", "f2"]);
            testCase.verifyEqual(input.NumberOfFunctions, 2);
        end
        
        %% RandomVariables
        function testRandomVariables(testCase)
            input = opencossan.common.inputs.Input('Members', ...
                {testCase.a, testCase.b}, 'Names', ["a", "b"]);
            testCase.verifyEqual(input.RandomVariables, [testCase.a, testCase.b]);
            testCase.verifyEqual(input.RandomVariableNames, ["a", "b"]);
            testCase.verifyEqual(input.NumberOfRandomVariables, 2);
        end
        
        %% DesignVariables
        function testDesignVariables(testCase)
            input = opencossan.common.inputs.Input('Members', ...
                {testCase.c, testCase.d}, 'Names', ["c", "d"]);
            testCase.verifyEqual(input.DesignVariables, [testCase.c, testCase.d]);
            testCase.verifyEqual(input.DesignVariableNames, ["c", "d"]);
            testCase.verifyEqual(input.NumberOfDesignVariables, 2);
        end
        
        %% RandomVariableSets
        function testRandomVariableSets(testCase)
            input = opencossan.common.inputs.Input('Members', ...
                {testCase.set}, 'Names', "set");
            testCase.verifyEqual(input.RandomVariableSets, testCase.set);
            testCase.verifyEqual(input.RandomVariableSetNames, "set");
            testCase.verifyEqual(input.NumberOfRandomVariableSets, 1);
        end
        
        %% StochasticProcesses
        function testStochasticProcesses(testCase)
            input = opencossan.common.inputs.Input('Members', ...
                {testCase.sp}, 'Names', "sp");
            testCase.verifyEqual(input.StochasticProcesses, testCase.sp);
            testCase.verifyEqual(input.StochasticProcessNames, "sp");
            testCase.verifyEqual(input.NumberOfStochasticProcesses, 1);
        end
        
        %% getMoments
        function shouldReturnMeanAndStd(testCase)
            input = opencossan.common.inputs.Input('Members', ...
                {testCase.r, testCase.set}, 'Names', ["r", "set"]);
            
            [mean, std] = input.getMoments();
            testCase.assertEqual(mean{:,:}, [1 .5 1]);
            testCase.assertEqual(std{:,:}, [1 .5 0]);
        end
        
        %% getStatistics
        function shouldReturnMedian(testCase)
            input = opencossan.common.inputs.Input('Members', ...
                {testCase.r, testCase.set}, 'Names', ["r", "set"]);
            
            median = input.getStatistics();
            testCase.assertEqual(median{:,:}, [0.69315, 0.34657, 1], 'RelTol', 1e-4);
        end
        
        function shouldThrowErrorForSkewnessAndCurtosis(testCase)
            input = opencossan.common.inputs.Input('Members', ...
                {testCase.r, testCase.set}, 'Names', ["r", "set"]);
            
            function skewnessAndCurtosis()
                [~, ~, ~] = input.getStatistics();
            end
            
            testCase.assertError(@() skewnessAndCurtosis(), 'OpenCossan:Input:getStatistics');
        end
        
        %% add
        function shouldAddMemberToInput(testCase)
            input = opencossan.common.inputs.Input('Members', ...
                {testCase.set}, 'Names', "set");
            input = input.add('member', testCase.r, 'name', 'r');
            
            testCase.assertEqual(input.Members, {testCase.set, testCase.r});
            testCase.assertEqual(input.Names, ["set", "r"]);
        end
        
        function shouldThrowErrorForDuplicateInput(testCase)
            input = opencossan.common.inputs.Input('Members', ...
                {testCase.r, testCase.set}, 'Names', ["r", "set"]);
            testCase.assertError(@() input.add('member', testCase.r, 'name', 'r'), ...
                'OpenCossan:Input:add');
        end
        
         %% remove
        function shouldRemoveMemberFromInput(testCase)
            input = opencossan.common.inputs.Input('Members', ...
                {testCase.r, testCase.set}, 'Names', ["r", "set"]);
            input = input.remove('name', 'r');
            
            testCase.assertEqual(input.Members, {testCase.set});
            testCase.assertEqual(input.Names, "set");
        end
        
        function shouldThrowErrorForMissingInput(testCase)
            input = opencossan.common.inputs.Input('Members', ...
                {testCase.set}, 'Names', "set");
            testCase.assertError(@() input.remove('name', 'r'), ...
                'OpenCossan:Input:remove');
        end
    end
end
