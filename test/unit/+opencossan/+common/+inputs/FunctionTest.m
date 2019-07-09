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
    
    methods (Test)
        %% constructor
        function constructorEmpty(testCase)
            Xfun = opencossan.common.inputs.Function();
            testCase.assertClass(Xfun, 'opencossan.common.inputs.Function');
        end
        
        function constructorFull(testCase)
            Xfun = opencossan.common.inputs.Function('Description',"Function",...
                'Expression',"<&Xpar1&>+<&Xpar2&>");
            testCase.assertEqual(Xfun.Description,"Function");
            testCase.assertEqual(Xfun.Expression,"<&Xpar1&>+<&Xpar2&>");
        end
        
        %% evaluate
        function evaluateAddition(testCase)
            Xpar1 = opencossan.common.inputs.Parameter('value', 1);
            Xpar2 = opencossan.common.inputs.Parameter('value', 2);
            
            Xfun = opencossan.common.inputs.Function('Expression', '<&Xpar1&>+<&Xpar2&>');
            
            Xin = opencossan.common.inputs.Input('Members',{Xpar1,Xpar2},'MembersNames',{'Xpar1','Xpar2'});
            
            actual = Xfun.evaluate(Xin);
            testCase.assertEqual(actual, 3);
        end
        
        function evaluateSubstraction(testCase)
            Xin = opencossan.common.inputs.Input();
            
            Xpar1 = opencossan.common.inputs.Parameter('value', 3);
            Xpar2 = opencossan.common.inputs.Parameter('value', 2);
            
            Xfun = opencossan.common.inputs.Function('Expression', '<&Xpar1&>-<&Xpar2&>');
            
            Xin = add(Xin,'Member',Xpar1,'Name','Xpar1');
            Xin = add(Xin,'Member',Xpar2,'Name','Xpar2');
            
            actual = Xfun.evaluate(Xin);
            testCase.assertEqual(actual, 1);
        end
        
        function evaluateMultiplication(testCase)
            Xin = opencossan.common.inputs.Input();
            
            Xpar1 = opencossan.common.inputs.Parameter('value', 1);
            Xpar2 = opencossan.common.inputs.Parameter('value', 2);
            
            Xfun = opencossan.common.inputs.Function('Expression', '<&Xpar1&>*<&Xpar2&>');
            
            Xin = add(Xin,'Member',Xpar1,'Name','Xpar1');
            Xin = add(Xin,'Member',Xpar2,'Name','Xpar2');
            
            actual = Xfun.evaluate(Xin);
            testCase.assertEqual(actual, 2);
        end
        
        function evaluateDivision(testCase)
            Xin = opencossan.common.inputs.Input();
            
            Xpar1 = opencossan.common.inputs.Parameter('value', 6);
            Xpar2 = opencossan.common.inputs.Parameter('value', 2);
            
            Xfun = opencossan.common.inputs.Function('Expression', '<&Xpar1&>/<&Xpar2&>');
            
            Xin = add(Xin,'Member',Xpar1,'Name','Xpar1');
            Xin = add(Xin,'Member',Xpar2,'Name','Xpar2');
            
            actual = Xfun.evaluate(Xin);
            testCase.assertEqual(actual, 3);
        end
        
        function evaluateImaginary(testCase)
            Xin = opencossan.common.inputs.Input();
            
            Xpar1 = opencossan.common.inputs.Parameter('value', 1i);
            Xpar2 = opencossan.common.inputs.Parameter('value', 1i);
            
            Xfun = opencossan.common.inputs.Function('Expression', '<&Xpar1&>+<&Xpar2&>');
            
            Xin = add(Xin,'Member',Xpar1,'Name','Xpar1');
            Xin = add(Xin,'Member',Xpar2,'Name','Xpar2');
            
            actual = Xfun.evaluate(Xin);
            testCase.assertEqual(actual, 0.0000 + 2.0000i)
        end
        
        function evaluateArrays(testCase)
            Xin = opencossan.common.inputs.Input();
            
            Xpar1 = opencossan.common.inputs.Parameter('value', [1 2 3 4]);
            Xpar2 = opencossan.common.inputs.Parameter('value', [5 6 7 8]);
            
            Xfun = opencossan.common.inputs.Function('Expression', '<&Xpar1&>+<&Xpar2&>');
            
            Xin = add(Xin,'Member',Xpar1,'Name','Xpar1');
            Xin = add(Xin,'Member',Xpar2,'Name','Xpar2');
            
            actual = Xfun.evaluate(Xin);
            testCase.assertEqual(actual, [6 8 10 12]);
        end
        
        function evaluateRandomVariable(testCase)
            Xin = opencossan.common.inputs.Input();
            
            Xpar1 = opencossan.common.inputs.Parameter('value', 1);
            Xrv1 = opencossan.common.inputs.random.NormalRandomVariable('mean',2,'std',3);
            Xrvs = opencossan.common.inputs.random.RandomVariableSet('Names', "Xrv1",'Members',Xrv1);
            Xfun = opencossan.common.inputs.Function('Expression', '<&Xpar1&>+<&Xrv1&>');
            
            Xin = add(Xin,'Member',Xpar1,'Name','Xpar1');
            Xin = add(Xin,'Member',Xrvs,'Name','Xrvs');
            
            Xin = sample(Xin, 'Nsamples', 1);
            
            actual = Xfun.evaluate(Xin);
            exp = Xin.getValues('VariableName', 'Xrv1');
            testCase.assertEqual(actual, exp+1);
        end
        
        function evaluateComplexNumbers(testCase)
            Xin = opencossan.common.inputs.Input();
            
            Xpar1 = opencossan.common.inputs.Parameter('value', [1 2 3 4]);
            Xpar2 = opencossan.common.inputs.Parameter('value', [5 6 7 8]);
            
            Xfun = opencossan.common.inputs.Function('Expression', 'complex(<&Xpar1&>,<&Xpar2&>)');
            
            Xin = add(Xin,'Member',Xpar1,'Name','Xpar1');
            Xin = add(Xin,'Member',Xpar2,'Name','Xpar2');
            
            actual = Xfun.evaluate(Xin);
            testCase.assertEqual(actual, [1 + 5i, 2 + 6i, 3 + 7i, 4 + 8i]);
        end
        
        function evaluateShouldFailWithInvalidSyntax(testCase)
            Xin = opencossan.common.inputs.Input();
            
            Xpar1 = opencossan.common.inputs.Parameter('value', [1 2 3 4]);
            Xpar2 = opencossan.common.inputs.Parameter('value', [5 6 7 8]);
            
            Xfun = opencossan.common.inputs.Function('Expression', 'pi.^<&Xpar1&>p<&Xpar2&>');
            
            Xin = add(Xin,'Member',Xpar1,'Name','Xpar1');
            Xin = add(Xin,'Member',Xpar2,'Name','Xpar2');
            
            testCase.assertError(@()Xfun.evaluate(Xin),...
                'openCOSSAN:Function:evaluatefunction');
        end
        
        function evaluateFunction(testCase)
            Xin = opencossan.common.inputs.Input();
            
            Xpar1 = opencossan.common.inputs.Parameter('value', [1 2 3 4]);
            Xpar2 = opencossan.common.inputs.Parameter('value', [5 6 7 8]);
            
            Xfunc1 = opencossan.common.inputs.Function('Expression', '2*<&Xpar1&>+<&Xpar2&>');
            Xfunc2 = opencossan.common.inputs.Function('Expression', '2*<&Xfunc1&>(2)');
            
            Xin = add(Xin,'Member',Xpar1,'Name','Xpar1');
            Xin = add(Xin,'Member',Xpar2,'Name','Xpar2');
            
            Xin = add(Xin,'Member',Xfunc1,'Name','Xfunc1');
            
            testCase.assertEqual(Xfunc1.evaluate(Xin),[7 10 13 16]);
            testCase.assertEqual(Xfunc2.evaluate(Xin), 20);
        end
        
        function evaluateShouldThrowMissingObjectError(testCase)
            Xin = opencossan.common.inputs.Input();
            Xpar1 = opencossan.common.inputs.Parameter('value', 1);
            Xfun = opencossan.common.inputs.Function('Expression', '<&Xpar1&>+<&Xpar3&>');
            Xin = add(Xin,'Member',Xpar1,'Name','Xpar1');
            
            testCase.assertError(@()Xfun.evaluate(Xin),...
                'openCOSSAN:Function:evaluatefunction');
        end
        
        function evaluateDesignVariable(testCase)
            Xin = opencossan.common.inputs.Input();
            Xpar = opencossan.optimization.DesignVariable('value', 0);
            Xin = Xin.add('Member', Xpar, 'Name', 'Xpar');
            Xfun = opencossan.common.inputs.Function('Expression', '<&Xpar&>*2');
            
            testCase.assumeEqual(Xfun.evaluate(Xin), 0);
        end
        %% get.Inputnames
        function getInputnames(testCase)
            Xfun = opencossan.common.inputs.Function('Expression', '<&Var1&>');
            vars = cell(1,1);
            vars{1} = 'Var1';
            testCase.assertEqual(Xfun.InputNames, vars);
        end
        
        function getInputnamesForEmptyObject(testCase)
            Xfun = opencossan.common.inputs.Function();
            vars = {};
            testCase.assertEqual(Xfun.InputNames, vars);
        end
        
        
        %% getMembers
        function getMembers(testCase)
            Xpar1 = opencossan.common.inputs.Parameter('value', [1 2 3 4]); %#ok<NASGU>
            Xpar2 = opencossan.common.inputs.Parameter('value', [5 6 7 8]); %#ok<NASGU>
            Xfun = opencossan.common.inputs.Function('Expression', 'complex(<&Xpar1&>,<&Xpar2&>)');
            [m, t] = Xfun.getMembers;
            testCase.assertEqual(m, {'Xpar1';'Xpar2'});
            testCase.assertEqual(t, {'opencossan.common.inputs.Parameter'; 'opencossan.common.inputs.Parameter'})
        end
        
        function getMembersShouldWorkOnNestedFunction(testCase)
            Xpar1 = opencossan.common.inputs.Parameter('value', [1 2 3 4]); %#ok<NASGU>
            Xfun1 = opencossan.common.inputs.Function('Expression', '2*<&Xpar1&>'); %#ok<NASGU>
            Xfun2 = opencossan.common.inputs.Function('Expression', '<&Xpar1&>+<&Xfun1&>');
            [m, t] = Xfun2.getMembers;
            testCase.assertEqual(m, {'Xpar1';'Xfun1'});
            testCase.assertEqual(t, {'opencossan.common.inputs.Parameter';'opencossan.common.inputs.Function'})
        end
        
        function getMembersShouldWarnAboutMissingObjects(testCase)
            Xfun = opencossan.common.inputs.Function('Expression', 'complex(<&Xpar3&>,<&Xpar4&>)');
            testCase.assertWarning(@()Xfun.getMembers(),...
                'openCOSSAN:Function:getMembers');
        end
        
        %% display
        function checkDisplayWorks(testCase)
            % Check for single Object
            Xpar = opencossan.common.inputs.Parameter('value', 2);%#ok<NASGU>
            Xfun1 = opencossan.common.inputs.Function('Description', 'Testobject',...
                'Expression', '2*<&Xpar1&>');
            testPhrase = [Xfun1.Description;...
                Xfun1.Expression;...
                Xfun1.Tokens;...
                Xfun1.InputNames];
            worksSingle = testOutput(Xfun1,testPhrase);
            % Check for array of objects
            Xfun2 = [opencossan.common.inputs.Function(); opencossan.common.inputs.Function()];
            testPhrase = ["Function array with properties:";...
                "Inputnames";...
                "Expression";...
                "Description";];
            worksMulti = testOutput(Xfun2,testPhrase);
            
            works = worksSingle && worksMulti;
            testCase.assertTrue(works);
        end
    end
end
