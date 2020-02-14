classdef InputTest < matlab.unittest.TestCase
    % INPUTTEST Unit tests for the class opencossan.common.inputs.Input
    % see http://cossan.co.uk/wiki/index.php/@Input
    %
    % @author Jasper Behrensdorf<behrensdorf@irz.uni-hannover.de>
    % @date   01.08.2016
    %
    % =====================================================================
    % This file is part of openCOSSAN.  The open general purpose matlab
    % toolbox for numerical analysis, risk and uncertainty quantification.
    %
    % openCOSSAN is free software: you can redistribute it and/or modify
    % it under the terms of the GNU General Public License as published by
    % the Free Software Foundation, either version 3 of the License.
    %
    % openCOSSAN is distributed in the hope that it will be useful,
    % but WITHOUT ANY WARRANTY; without even the implied warranty of
    % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    % GNU General Public License for more details.
    %
    % You should have received a copy of the GNU General Public License
    % along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
    % =====================================================================
    
    properties
        x = opencossan.common.inputs.Parameter('Value', 10);
        y = opencossan.common.inputs.Parameter('Value', -10);
        
        f1 = opencossan.common.inputs.Function('Expression', '<&x&>.^2');
        f2 = opencossan.common.inputs.Function('Expression', '<&x&> - <&y&>');
        
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
    end
end
