classdef EvolutionStrategyTest < matlab.unittest.TestCase
    %EVOLUTIONSTRATEGYTEST Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        OptimizationProblem;
    end
    
    methods (TestMethodSetup)
        function setRngSeed(testCase)
            original = rng();
            testCase.addTeardown(@rng, original);
            rng(8756);
        end
        
        function setupOptimizationProblem(testCase)
            x1 = opencossan.optimization.ContinuousDesignVariable('upperbound', 5, ...
                'lowerBound', -5);
            x2 = opencossan.optimization.ContinuousDesignVariable('upperbound', 5, ...
                'lowerBound', -5);
            input = opencossan.common.inputs.Input('names',["x1" "x2"], 'members',{x1 x2});
            
            objfun = opencossan.optimization.ObjectiveFunction('Description','objective function', ...
                'FunctionHandle', @(x) (x(:,1).^2 + x(:,2) - 11).^2 + (x(:,1) + x(:,2).^2 -7).^2, ...
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
            es = opencossan.optimization.EvolutionStrategy();
            testCase.assertClass(es, 'opencossan.optimization.EvolutionStrategy');
        end
        
        function constructorFull(testCase)
            es = opencossan.optimization.EvolutionStrategy('Sigma',[0.5 1],'Nmu',10, ...
                'Nlambda',70,'Nrho',2);
            testCase.assertClass(es, 'opencossan.optimization.EvolutionStrategy');
            testCase.assertEqual(es.Sigma, [0.5 1]);
            testCase.assertEqual(es.Nmu, 10);
            testCase.assertEqual(es.Nlambda, 70);
            testCase.assertEqual(es.Nrho, 2);
        end
        
        % apply
        function shouldFindOptimum(testCase)
            es = opencossan.optimization.EvolutionStrategy('ObjectiveFunctionTolerance', 1e-3, ...
                'MaxIterations', 100, 'Sigma', [0.5 1], 'Nmu', 20, 'Nlambda', 70, 'Nrho', 2);
            
            optimum = testCase.OptimizationProblem.optimize('optimizer', es);
            
            testCase.assertEqual(optimum.OptimalSolution, [-2.8050, 3.1312], 'RelTol', 1e-3);
        end
    end
end

