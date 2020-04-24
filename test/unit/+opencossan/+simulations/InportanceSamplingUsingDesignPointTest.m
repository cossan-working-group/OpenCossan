classdef InportanceSamplingUsingDesignPointTest < matlab.unittest.TestCase
    %INPORTANCESAMPLINGUSINGDESIGNPOINTTEST Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ProbabilisticModel;
        DesignPoint;
    end
    
    methods (TestMethodSetup)
        function setupProbabilisticModelAndDesignPoint(testCase)
            load = opencossan.common.inputs.random.LargeIRandomVariable.fromMeanAndStd('mean', 50, 'std', 5);
            yield = opencossan.common.inputs.random.LognormalRandomVariable.fromMeanAndStd('mean', 28.8e4 - 19.9e4,'std', 2.64e4);

            input = opencossan.common.inputs.Input('members', {load,yield}, ...
                'names',["load" "yield"]);

            stress = opencossan.workers.Mio(...
                'FunctionHandle', @(x) 3 * 2 / (3 + 2) * (1 / 3.66e-4) .* x(:, 1) - 19.9e4, ...
                'Format', 'matrix', 'IsFunction', true, 'InputNames', {'load'}, ...
                'OutputNames', {'stress'});

            evaluator = opencossan.workers.Evaluator('Xmio',stress);
            model = opencossan.common.Model('evaluator', evaluator, 'input', input);

            g = opencossan.reliability.PerformanceFunction(...
                'FunctionHandle', @(x) x(:, 1) - x(:, 2), 'IsFunction', true, ...
                'Format', 'matrix', 'InputNames', {'yield', 'stress'}, 'OutputName','g');

            testCase.DesignPoint = opencossan.reliability.DesignPoint('designpoint', ...
                table(78.873331, 59616.520303, 'VariableNames', {'load', 'yield'}), ...
                'model', model, 'performanceatorigin', 1.23084048);
            testCase.ProbabilisticModel = opencossan.reliability.ProbabilisticModel('model', model, 'performancefunction', g);
        end
    end
    
    methods (Test)
        % constructor
        function constructorEmpty(testCase)
            ispud = opencossan.simulations.ImportanceSamplingUsingDesignPoint();
            testCase.assertClass(ispud, 'opencossan.simulations.ImportanceSamplingUsingDesignPoint');
        end
        
        function constructorFull(testCase)
            ispud = opencossan.simulations.ImportanceSamplingUsingDesignPoint('designpoint', ...
                testCase.DesignPoint);
            testCase.assertClass(ispud, 'opencossan.simulations.ImportanceSamplingUsingDesignPoint');
            testCase.assertEqual(ispud.DesignPoint, testCase.DesignPoint);
        end
        
        % computeFailureProbability
        function shouldComputePfAndDesignPoint(testCase)
            ispud = opencossan.simulations.ImportanceSamplingUsingDesignPoint(...
                'samples', 2000, 'seed', 8128);
            
            pf = ispud.computeFailureProbability(testCase.ProbabilisticModel);
            dp = pf.Simulation.DesignPoint.DesignPointPhysical;
            
            testCase.assertEqual(pf.Value, 1.3108e-4, 'AbsTol', 1e-4);
            testCase.assertEqual(dp.load, 78.873331, 'AbsTol', 1e-6);
            testCase.assertEqual(dp.yield, 59616.520303, 'AbsTol', 1e-6);
        end
        
        function shouldComputePfGivenDesignPoint(testCase)
            ispud = opencossan.simulations.ImportanceSamplingUsingDesignPoint(...
                'designpoint', testCase.DesignPoint, ...
                'samples', 2000, 'seed', 8128);
            
            pf = ispud.computeFailureProbability(testCase.ProbabilisticModel);
            testCase.assertEqual(pf.Value, 1.3108e-4, 'AbsTol', 1e-4);
        end
        
        % apply
        function shouldReturnSimulationDataWithoutDesignpoint(testCase)
            ispud = opencossan.simulations.ImportanceSamplingUsingDesignPoint('samples', 1e3);
            
            simData = ispud.apply(testCase.ProbabilisticModel);
            testCase.assertClass(simData, 'opencossan.common.outputs.SimulationData');
        end
        
        function shouldReturnSimulationDataWithDesignpoint(testCase)
            ispud = opencossan.simulations.ImportanceSamplingUsingDesignPoint(...
                'designpoint', testCase.DesignPoint, 'samples', 1e3);
            
            simData = ispud.apply(testCase.ProbabilisticModel);
            testCase.assertClass(simData, 'opencossan.common.outputs.SimulationData');
        end
    end
end

