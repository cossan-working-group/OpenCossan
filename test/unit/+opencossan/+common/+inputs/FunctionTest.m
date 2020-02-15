classdef FunctionTest < matlab.unittest.TestCase
    % FUNCTIONTEST Unit tests for the class opencossan.common.inputs.Function
    % see http://cossan.co.uk/wiki/index.php/@Function
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
        input = table(2, 3, 'VariableNames', {'x', 'y'});
        imaginaryInput = table(1i, 1i, 'VariableNames', {'x', 'y'});
        arrayInput = table([1, 2, 3, 4], [5, 6, 7, 8], 'VariableNames', {'x', 'y'});
    end
    
    methods (Test)
        %% constructor
        function constructorEmpty(testCase)
            fun = opencossan.common.inputs.Function();
            testCase.assertClass(fun, 'opencossan.common.inputs.Function');
        end
        
        function constructorFull(testCase)
            fun = opencossan.common.inputs.Function('Description',"Function",...
                'Expression',"<&x&>+<&y&>");
            testCase.assertEqual(fun.Description,"Function");
            testCase.assertEqual(fun.Expression,"<&x&>+<&y&>");
        end
        
        %% evaluate
        function shouldAddValues(testCase)
            fun = opencossan.common.inputs.Function('Expression', '<&x&>+<&y&>');
            
            result = fun.evaluate(testCase.input);
            testCase.assertEqual(result, 5);
        end
        
        function shouldSubtractValues(testCase)
            fun = opencossan.common.inputs.Function('Expression', '<&x&>-<&y&>');
            
            result = fun.evaluate(testCase.input);
            testCase.assertEqual(result, -1);
        end
        
        function shouldMultiply(testCase)
            fun = opencossan.common.inputs.Function('Expression', '<&x&>*<&y&>');
            
            result = fun.evaluate(testCase.input);
            testCase.assertEqual(result, 6);
        end
        
        function shouldDivide(testCase)
            fun = opencossan.common.inputs.Function('Expression', '<&x&>/<&y&>');
            
            result = fun.evaluate(testCase.input);
            testCase.assertEqual(result, 2/3);
        end
        
        function shouldAcceptImaginary(testCase)
            testCase.imaginaryInput = table(1i, 1i, 'VariableNames', {'x', 'y'});
            fun = opencossan.common.inputs.Function('Expression', '<&x&>+<&y&>');
            
            result = fun.evaluate(testCase.imaginaryInput);
            testCase.assertEqual(result, 0.0000 + 2.0000i);
        end
        
        function evaluateArrays(testCase)
            fun = opencossan.common.inputs.Function('Expression', '<&x&>+<&y&>');
            
            result = fun.evaluate(testCase.arrayInput);
            testCase.assertEqual(result, [6 8 10 12]);
        end
        
        function shouldThrowErrorForInvalidSyntax(testCase)
            fun = opencossan.common.inputs.Function('Expression', '<&x&>sdbj<&y&>');
            
            testCase.assertError(@()fun.evaluate(testCase.input),...
                'openCOSSAN:Function:evaluate');
        end
        
        function shouldReturnTokens(testCase)
            fun = opencossan.common.inputs.Function('Expression', '<&x&>+<&y&>');

            testCase.assertEqual(fun.Tokens, {'x', 'y'});
        end
    end
end
