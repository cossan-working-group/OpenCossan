classdef GeneticAlgorithmsTest < matlab.unittest.TestCase
    %GENETICALGORITHMSTEST Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        OptimizationProblem;
    end
    
    methods (TestMethodSetup)
        function setupOptimizationProblem(testCase)
            x1 = opencossan.optimization.ContinuousDesignVariable('value', 0);
            x2 = opencossan.optimization.ContinuousDesignVariable('value', 0);
            input = opencossan.common.inputs.Input('names',["x1" "x2"], 'members',{x1 x2});
            
            objfun = opencossan.optimization.ObjectiveFunction('Description','objective function', ...
                'FunctionHandle', @(x) 20 + sum(x.^2 - 10 * cos(2 * pi .* x), 2), ...
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
            ga = opencossan.optimization.GeneticAlgorithms();
            testCase.assertClass(ga, 'opencossan.optimization.GeneticAlgorithms');
        end
        
        function constructorFull(testCase)
            ga = opencossan.optimization.GeneticAlgorithms('FitnessScalingFcn','fitscalingtop',...
                'SelectionFcn','selectionremainder',...
                'PopulationSize',100, 'StallGenLimit',5);
            testCase.assertClass(ga, 'opencossan.optimization.GeneticAlgorithms');
            testCase.assertEqual(ga.PopulationSize, 100);
            testCase.assertEqual(ga.FitnessScalingFcn, 'fitscalingtop');
            testCase.assertEqual(ga.SelectionFcn, 'selectionremainder');
            testCase.assertEqual(ga.StallGenLimit, 5);
        end
        
        % apply
        function shouldFindOptimum(testCase)
            ga = opencossan.optimization.GeneticAlgorithms('PopulationSize', 100);
            
            s = rng(); rng(2727);
            testCase.addTeardown(@rng, s);
            
            x0 = unifrnd(5, 10, 100, 2);
            optimum = ga.apply('optimizationproblem', testCase.OptimizationProblem, ...
                'initialsolutions', x0);
            
            testCase.assertEqual(optimum.OptimalSolution, [0, 0], 'AbsTol', 1e-9);
        end
    end
end

