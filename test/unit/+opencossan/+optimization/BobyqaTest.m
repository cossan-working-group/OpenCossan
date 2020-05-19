classdef BobyqaTest < matlab.unittest.TestCase
    %BOBYQATEST Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        OptimizationProblem;
    end
    
    methods (TestMethodSetup)
        function setupOptimizationProblem(testCase)
            x1 = opencossan.optimization.ContinuousDesignVariable('value', -5, ...
                'lowerBound', -5, 'upperBound', 5);
            x2 = opencossan.optimization.ContinuousDesignVariable('value', 5, ...
                'lowerBound', -5, 'upperBound', 5);
            input = opencossan.common.inputs.Input('names',["x1" "x2"], 'members',{x1 x2});
            
            objfun = opencossan.optimization.ObjectiveFunction('Description','objective function', ...
                'FunctionHandle', @(x) (1 -x(:,1)).^2 + 100 * (x(:, 2) - x(:,1).^2).^2, ...
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
            bobyqa = opencossan.optimization.Bobyqa();
            testCase.assertClass(bobyqa, 'opencossan.optimization.Bobyqa');
        end
        
        function constructorFull(testCase)
            bobyqa = opencossan.optimization.Bobyqa('npt', 0,...
                'stepSize', 0.1,...
                'rhoEnd',  1e-3,...
                'xtolRel', 1e-3,...
                'minfMax', 1e-3,...
                'ftolRel', 1e-3,...
                'ftolAbs', 1e-3,...
                'verbose', 2);
            testCase.assertClass(bobyqa, 'opencossan.optimization.Bobyqa');
            testCase.assertEqual(bobyqa.npt, 0);
            testCase.assertEqual(bobyqa.stepSize, 0.1);
            testCase.assertEqual(bobyqa.rhoEnd, 1e-3);
            testCase.assertEqual(bobyqa.xtolRel, 1e-3);
            testCase.assertEqual(bobyqa.minfMax, 1e-3);
            testCase.assertEqual(bobyqa.ftolRel, 1e-3);
            testCase.assertEqual(bobyqa.ftolAbs, 1e-3);
            testCase.assertEqual(bobyqa.verbose, 2);
        end
        
        % apply
        function shouldFindOptimum(testCase)
            bobyqa = opencossan.optimization.Bobyqa();
            optimum = testCase.OptimizationProblem.optimize('optimizer', bobyqa);
            
            testCase.assertEqual(optimum.OptimalSolution, [1, 1], 'RelTol', 1e-4);
        end
    end
end

