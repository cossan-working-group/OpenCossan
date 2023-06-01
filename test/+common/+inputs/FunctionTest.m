classdef FunctionTest < matlab.unittest.TestCase
    % FUNCTIONTEST Unit tests for the class
    % common.inputs.Function
    % see http://cossan.co.uk/wiki/index.php/@Function
    %
    % @author Jasper Behrensdorf<behrensdorf@irz.uni-hannover.de>
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
            Xfun = common.inputs.Function();
            testCase.assertClass(Xfun, 'common.inputs.Function');
        end
        
        function constructorFull(testCase)
            Xfun = common.inputs.Function('SDescription','Function',...
                'Sexpression','<&Xpar1&>+<&Xpar2&>');
            testCase.assertEqual(Xfun.Sdescription,'Function');
            testCase.assertEqual(Xfun.Sexpression,'<&Xpar1&>+<&Xpar2&>');
        end
        
        %% evaluate
        function evaluateAddition(testCase)
            Xin = common.inputs.Input();
            
            Xpar1 = common.inputs.Parameter('value', 1);
            Xpar2 = common.inputs.Parameter('value', 2);
            
            Xfun = common.inputs.Function('Sexpression', '<&Xpar1&>+<&Xpar2&>');
            
            Xin = add(Xin,'Xmember',Xpar1,'Sname','Xpar1');
            Xin = add(Xin,'Xmember',Xpar2,'Sname','Xpar2');
            
            actual = Xfun.evaluate(Xin);
            testCase.assertEqual(actual, 3);
        end
        
        function evaluateSubstraction(testCase)
            Xin = common.inputs.Input();
            
            Xpar1 = common.inputs.Parameter('value', 3);
            Xpar2 = common.inputs.Parameter('value', 2);
            
            Xfun = common.inputs.Function('Sexpression', '<&Xpar1&>-<&Xpar2&>');
            
            Xin = add(Xin,'Xmember',Xpar1,'Sname','Xpar1');
            Xin = add(Xin,'Xmember',Xpar2,'Sname','Xpar2');
            
            actual = Xfun.evaluate(Xin);
            testCase.assertEqual(actual, 1);
        end
        
        function evaluateMultiplication(testCase)
            Xin = common.inputs.Input();
            
            Xpar1 = common.inputs.Parameter('value', 1);
            Xpar2 = common.inputs.Parameter('value', 2);
            
            Xfun = common.inputs.Function('Sexpression', '<&Xpar1&>*<&Xpar2&>');
            
            Xin = add(Xin,'Xmember',Xpar1,'Sname','Xpar1');
            Xin = add(Xin,'Xmember',Xpar2,'Sname','Xpar2');
            
            actual = Xfun.evaluate(Xin);
            testCase.assertEqual(actual, 2);
        end
        
        function evaluateDivision(testCase)
            Xin = common.inputs.Input();
            
            Xpar1 = common.inputs.Parameter('value', 6);
            Xpar2 = common.inputs.Parameter('value', 2);
            
            Xfun = common.inputs.Function('Sexpression', '<&Xpar1&>/<&Xpar2&>');
            
            Xin = add(Xin,'Xmember',Xpar1,'Sname','Xpar1');
            Xin = add(Xin,'Xmember',Xpar2,'Sname','Xpar2');
            
            actual = Xfun.evaluate(Xin);
            testCase.assertEqual(actual, 3);
        end
        
        function evaluateImaginary(testCase)
            Xin = common.inputs.Input();
            
            Xpar1 = common.inputs.Parameter('value', 1i);
            Xpar2 = common.inputs.Parameter('value', 1i);
            
            Xfun = common.inputs.Function('Sexpression', '<&Xpar1&>+<&Xpar2&>');
            
            Xin = add(Xin,'Xmember',Xpar1,'Sname','Xpar1');
            Xin = add(Xin,'Xmember',Xpar2,'Sname','Xpar2');
            
            actual = Xfun.evaluate(Xin);
            testCase.assertEqual(actual, 0.0000 + 2.0000i)
        end
        
        function evaluateArrays(testCase)
            Xin = common.inputs.Input();
            
            Xpar1 = common.inputs.Parameter('value', [1 2 3 4]);
            Xpar2 = common.inputs.Parameter('value', [5 6 7 8]);
            
            Xfun = common.inputs.Function('Sexpression', '<&Xpar1&>+<&Xpar2&>');
            
            Xin = add(Xin,'Xmember',Xpar1,'Sname','Xpar1');
            Xin = add(Xin,'Xmember',Xpar2,'Sname','Xpar2');
            
            actual = Xfun.evaluate(Xin);
            testCase.assertEqual(actual, [6 8 10 12]);
        end
        
        function evaluateRandomVariable(testCase)
            Xin = common.inputs.Input();
            
            Xpar1 = common.inputs.Parameter('value', 1);
            Xrv1 = common.inputs.RandomVariable('Sdistribution', 'normal', 'mean', 2, 'std', 3);
            Xrvs = common.inputs.RandomVariableSet('Cmembers', {'Xrv1'},'CXrv',{Xrv1});
            Xfun = common.inputs.Function('Sexpression', '<&Xpar1&>+<&Xrv1&>');
            
            Xin = add(Xin,'Xmember',Xpar1,'Sname','Xpar1');
            Xin = add(Xin,'Xmember',Xrvs,'Sname','Xrvs');
            
            Xin = sample(Xin, 'Nsamples', 1);
            
            actual = Xfun.evaluate(Xin);
            exp = Xin.getValues('Sname', 'Xrv1');
            testCase.assertEqual(actual, exp+1);
        end
        
        function evaluateComplexNumbers(testCase)
            Xin = common.inputs.Input();
            
            Xpar1 = common.inputs.Parameter('value', [1 2 3 4]);
            Xpar2 = common.inputs.Parameter('value', [5 6 7 8]);
            
            Xfun = common.inputs.Function('Sexpression', 'complex(<&Xpar1&>,<&Xpar2&>)');
            
            Xin = add(Xin,'Xmember',Xpar1,'Sname','Xpar1');
            Xin = add(Xin,'Xmember',Xpar2,'Sname','Xpar2');
            
            actual = Xfun.evaluate(Xin);
            testCase.assertEqual(actual, [1 + 5i, 2 + 6i, 3 + 7i, 4 + 8i]);
        end
        
        function evaluateShouldFailWithInvalidSyntax(testCase)
            Xin = common.inputs.Input();
            
            Xpar1 = common.inputs.Parameter('value', [1 2 3 4]);
            Xpar2 = common.inputs.Parameter('value', [5 6 7 8]);
            
            Xfun = common.inputs.Function('Sexpression', 'pi.^<&Xpar1&>p<&Xpar2&>');
            
            Xin = add(Xin, 'Xmember',Xpar1,'Sname','Xpar1');
            Xin = add(Xin, 'Xmember',Xpar2,'Sname','Xpar2');
            
            testCase.assertError(@()Xfun.evaluate(Xin),...
                'openCOSSAN:Function:evaluatefunction');
        end
        
        function evaluateFunction(testCase)
            Xin = common.inputs.Input();
            
            Xpar1 = common.inputs.Parameter('value', [1 2 3 4]);
            Xpar2 = common.inputs.Parameter('value', [5 6 7 8]);
            
            Xfunc1 = common.inputs.Function('Sexpression', '2*<&Xpar1&>+<&Xpar2&>');
            Xfunc2 = common.inputs.Function('Sexpression', '2*<&Xfunc1&>(2)');
            
            Xin = add(Xin,'Xmember',Xpar1,'Sname','Xpar1');
            Xin = add(Xin,'Xmember',Xpar2,'Sname','Xpar2');
            
            Xin = add(Xin,'Xmember',Xfunc1,'Sname','Xfunc1');
            
            testCase.assertEqual(Xfunc1.evaluate(Xin),[7 10 13 16]);
            testCase.assertEqual(Xfunc2.evaluate(Xin), 20);
        end
        
        %% getMembers
        function getMembers(testCase)
            Xpar1 = common.inputs.Parameter('value', [1 2 3 4]); %#ok<NASGU>
            Xpar2 = common.inputs.Parameter('value', [5 6 7 8]); %#ok<NASGU>
            
            Xfun = common.inputs.Function('Sexpression', 'complex(<&Xpar1&>,<&Xpar2&>)');
            
            [m, t] = getMembers(Xfun);
            testCase.assertEqual(m, {'Xpar1';'Xpar2'});
            testCase.assertEqual(t, {'common.inputs.Parameter'; 'common.inputs.Parameter'})
        end
        
        function getMembersShouldWarAboutMissingObjects(testCase)
            Xfun = common.inputs.Function('Sexpression', 'complex(<&Xpar1&>,<&Xpar2&>)');
            testCase.assertWarning(@()Xfun.getMembers(),...
                'openCOSSAN:Function:getMembers');
        end
        
        %% set
        function setExpression(testCase)
            Xfun = common.inputs.Function('Sexpression', 'complex(<&Xpar1&>,<&Xpar2&>)');
            Xfun = Xfun.set('Sexpression','<&Xpar1&>+<&Xpar2&>');
            testCase.assertEqual(Xfun.Sexpression, '<&Xpar1&>+<&Xpar2&>');
        end
        
        function setShouldFailForInvalidFields(testCase)
            Xfun = common.inputs.Function('Sexpression', 'complex(<&Xpar1&>,<&Xpar2&>)');
            testCase.assertError(@()Xfun.set('SFoo','Bar'),...
                'openCOSSAN:Function:set');
        end
        
        %% disp
        function checkDisplayWorks(testCase)
            testCase.assertTrue(testOutput(common.inputs.Function(),'Function Object'));
        end
        
    end
end
