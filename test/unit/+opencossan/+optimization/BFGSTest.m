classdef BFGSTest < matlab.unittest.TestCase
    %BFGSTEST Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        OptimizationProblem;
    end
    
    methods (TestMethodSetup)
        function setupOptimizationProblem(testCase)
            x1 = opencossan.optimization.ContinuousDesignVariable('value', -5, ...
                'lowerBound', -5.12, 'upperBound', 5.12);
            x2 = opencossan.optimization.ContinuousDesignVariable('value', 5, ...
                'lowerBound', -5.12, 'upperBound', 5.12);
            input = opencossan.common.inputs.Input('names',["x1" "x2"], 'members',{x1 x2});

            objfun = opencossan.optimization.ObjectiveFunction('Description','objective function', ...
                'FunctionHandle', @(x) 20 + sum(x.^2 - 10 * cos(2 * pi .* x)), ...
                'OutputNames',{'y'},...
                'IsFunction', true, ...
                'format', 'matrix', ...
                'InputNames',{'x1' 'x2'});

            testCase.OptimizationProblem = opencossan.optimization.OptimizationProblem(...
                'Input',input,'ObjectiveFunction',objfun);
        end
    end
    
    methods (Test)
        % constructor
        function constructorEmpty(testCase)
            bfgs = opencossan.optimization.BFGS();
            testCase.assertClass(bfgs, 'opencossan.optimization.BFGS');
        end
        
        function constructorFull(testCase)
            bfgs = opencossan.optimization.BFGS('FiniteDifferenceStepSize', 1e-4, ...
                'FiniteDifferenceType', 'central');
            testCase.assertClass(bfgs, 'opencossan.optimization.BFGS');
            testCase.assertEqual(bfgs.FiniteDifferenceType, 'central');
            testCase.assertEqual(bfgs.FiniteDifferenceStepSize, 1e-4);
        end
        
        % apply
        function shouldFindOptimum(testCase)
            bfgs = opencossan.optimization.BFGS();
            optimum = testCase.OptimizationProblem.optimize('optimizer', bfgs);
            
            testCase.assertEqual(optimum.OptimalSolution, [0, 0], 'AbsTol', 1e-9);
        end
    end
end

