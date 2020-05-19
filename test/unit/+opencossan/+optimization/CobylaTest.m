classdef CobylaTest < matlab.unittest.TestCase
    %COBYLATEST Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        OptimizationProblem;
    end
    
    methods (TestMethodSetup)
        function setupOptimizationProblem(testCase)
            x1 = opencossan.optimization.ContinuousDesignVariable('value', 7, ...
                'lowerBound', 0);
            x2 = opencossan.optimization.ContinuousDesignVariable('value', 2, ...
                'lowerBound', 0);
            input = opencossan.common.inputs.Input('names',["x1" "x2"], 'members',{x1 x2});
            
            objfun = opencossan.optimization.ObjectiveFunction('Description','objective function', ...
                'FunctionHandle', @(x) x(:,1).^2 + x(:, 2).^2, ...
                'OutputNames',{'y'},...
                'IsFunction', true, ...
                'format', 'matrix', ...
                'InputNames',{'x1' 'x2'});
            
            constraint = opencossan.optimization.Constraint('Description','non linear inequality constraint', ...
                'FunctionHandle',@(x) 2 - x(:,1) - x(:, 2), ...
                'IsFunction', true, ...
                'Format', 'matrix', ...
                'OutputNames',{'con'},...
                'InputNames',{'x1','x2'},...
                'Inequality',true);
            
            testCase.OptimizationProblem = opencossan.optimization.OptimizationProblem(...
                'Input',input,'ObjectiveFunction',objfun, 'constraints', constraint);
        end
    end
    
    methods (Test)
        % constructor
        function constructorEmpty(testCase)
            cobyla = opencossan.optimization.Cobyla();
            testCase.assertClass(cobyla, 'opencossan.optimization.Cobyla');
        end
        
        function constructorFull(testCase)
            cobyla = opencossan.optimization.Cobyla('InitialTrustRegion', 1.5,...
                'FinalTrustRegion', 1e-4);
            testCase.assertClass(cobyla, 'opencossan.optimization.Cobyla');
            testCase.assertEqual(cobyla.InitialTrustRegion, 1.5);
            testCase.assertEqual(cobyla.FinalTrustRegion, 1e-4);
        end
        
        % apply
        function shouldFindOptimum(testCase)
            cobyla = opencossan.optimization.Cobyla('FinalTrustRegion', 1e-6);
            optimum = testCase.OptimizationProblem.optimize('optimizer', cobyla);
            
            testCase.assertEqual(optimum.OptimalSolution, [1, 1], 'RelTol', 1e-3);
        end
    end
end

