classdef LineSamplingDataTest < matlab.unittest.TestCase
    %LINESAMPLINGDATATEST Summary of this class goes here
    %   Detailed explanation goes here
    properties
        NumberOfLines = 5;
        PointsOnLine = 0.5:0.5:1.5;
        LimitState = [0.3125; 0.3102; 0.2804; 0.1428; 0.0580];
        PerformanceFunctionVariable = "g";
        Alpha = [0.5774, 0.5774, 0.5774];
        ExitFlag = "Finished.";
        Input
        Samples
    end
    
    methods (TestMethodSetup)
        function setupInput(testCase)
            x = opencossan.common.inputs.random.UniformRandomVariable('bounds', [0, 1]);
            y = opencossan.common.inputs.random.UniformRandomVariable('bounds', [0, 1]);
            z = opencossan.common.inputs.random.UniformRandomVariable('bounds', [0, 1]);
            
            testCase.Input = opencossan.common.inputs.Input('members', {x, y, z}, ...
                'names', ["x" "y" "z"]);
        end
        
        function setupSamples(testCase)
            x = [0.38384; 0.49731; 0.611; 0.64786; 0.748; 0.83069; 0.68995; 0.7836; 0.85838; ...
                 0.49231; 0.60619; 0.71161; 0.54106; 0.65239; 0.75189];
            y = [0.6074; 0.71268; 0.80231; 0.40983; 0.5242; 0.63659; 0.47083; 0.58531; 0.69293; ...
                 0.21053; 0.30296; 0.41012; 0.16881; 0.25137; 0.35141];
            z = [0.50913; 0.62231; 0.72582; 0.43977; 0.55453; 0.66487; 0.33632; 0.44676; 0.56152; ...
                 0.79499; 0.86704; 0.91942; 0.80393; 0.87378; 0.92409];
            
            r = sqrt(x.^2 + y.^2 + z.^2);
            
            g = 1 - r;
            
            testCase.Samples = table(x, y, z, r, g, 'VariableNames', ["x" "y" "z" "r" "g"]);
        end
    end
    
    methods (Test)
        % Constructor
        function constructorEmpty(testCase)
            lsd = opencossan.simulations.LineSamplingData();
            testCase.assertClass(lsd, 'opencossan.simulations.LineSamplingData');
        end
        
        function constructorFull(testCase)
            lsd = opencossan.simulations.LineSamplingData('input', testCase.Input, ...
                'lines', testCase.NumberOfLines, 'points', testCase.PointsOnLine, ...
                'performance', testCase.PerformanceFunctionVariable, ...
                'limitstate', testCase.LimitState, 'alpha', testCase.Alpha, ...
                'samples', testCase.Samples, 'exitflag', testCase.ExitFlag);
            
            testCase.assertEqual(lsd.Input, testCase.Input);
            testCase.assertEqual(lsd.NumberOfLines, testCase.NumberOfLines);
            testCase.assertEqual(lsd.PointsOnLine, testCase.PointsOnLine);
            testCase.assertEqual(lsd.LimitState, testCase.LimitState);
            testCase.assertEqual(lsd.PerformanceFunctionVariable, testCase.PerformanceFunctionVariable);
            testCase.assertEqual(lsd.Alpha, testCase.Alpha);
            testCase.assertEqual(lsd.Samples, testCase.Samples);
            testCase.assertEqual(lsd.ExitFlag, testCase.ExitFlag);
        end
        
        % plotLines
        function shouldPlotLines(testCase)
            lsd = opencossan.simulations.LineSamplingData('input', testCase.Input, ...
                'lines', testCase.NumberOfLines, 'points', testCase.PointsOnLine, ...
                'performance', testCase.PerformanceFunctionVariable, ...
                'limitstate', testCase.LimitState, 'alpha', testCase.Alpha, ...
                'samples', testCase.Samples, 'exitflag', testCase.ExitFlag);
            
            f = lsd.plotLines();
            testCase.assertClass(f, 'matlab.ui.Figure');
            testCase.addTeardown(@close, f);
        end
        
        % plot2DLimitState
        function shouldPlot2DLimitState(testCase)
            lsd = opencossan.simulations.LineSamplingData('input', testCase.Input, ...
                'lines', testCase.NumberOfLines, 'points', testCase.PointsOnLine, ...
                'performance', testCase.PerformanceFunctionVariable, ...
                'limitstate', testCase.LimitState, 'alpha', testCase.Alpha, ...
                'samples', testCase.Samples, 'exitflag', testCase.ExitFlag);
            
            f = lsd.plot2DLimitState();
            testCase.assertClass(f, 'matlab.ui.Figure');
            testCase.addTeardown(@close, f);
        end
        
        function shouldPlot2DLimitStateWithNames(testCase)
            lsd = opencossan.simulations.LineSamplingData('input', testCase.Input, ...
                'lines', testCase.NumberOfLines, 'points', testCase.PointsOnLine, ...
                'performance', testCase.PerformanceFunctionVariable, ...
                'limitstate', testCase.LimitState, 'alpha', testCase.Alpha, ...
                'samples', testCase.Samples, 'exitflag', testCase.ExitFlag);
            
            f = lsd.plot2DLimitState(["x" "z"]);
            testCase.assertClass(f, 'matlab.ui.Figure');
            testCase.addTeardown(@close, f);
        end
        
        % plot3DLimitState
        function shouldPlot3DLimitState(testCase)
            lsd = opencossan.simulations.LineSamplingData('input', testCase.Input, ...
                'lines', testCase.NumberOfLines, 'points', testCase.PointsOnLine, ...
                'performance', testCase.PerformanceFunctionVariable, ...
                'limitstate', testCase.LimitState, 'alpha', testCase.Alpha, ...
                'samples', testCase.Samples, 'exitflag', testCase.ExitFlag);
            
            f = lsd.plot3DLimitState();
            testCase.assertClass(f, 'matlab.ui.Figure');
            testCase.addTeardown(@close, f);
        end
        
        function shouldPlot3DLimitStateWithNames(testCase)
            lsd = opencossan.simulations.LineSamplingData('input', testCase.Input, ...
                'lines', testCase.NumberOfLines, 'points', testCase.PointsOnLine, ...
                'performance', testCase.PerformanceFunctionVariable, ...
                'limitstate', testCase.LimitState, 'alpha', testCase.Alpha, ...
                'samples', testCase.Samples, 'exitflag', testCase.ExitFlag);
            
            f = lsd.plot3DLimitState(["x" "y" "z"]);
            testCase.assertClass(f, 'matlab.ui.Figure');
            testCase.addTeardown(@close, f);
        end
    end
end

