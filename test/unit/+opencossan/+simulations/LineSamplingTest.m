classdef LineSamplingTest < matlab.unittest.TestCase
    % MONTECARLOTEST Unit tests for the class simulations.MonteCarlo
    % see http://cossan.co.uk/wiki/index.php/@MonteCarlo
    %
    % @author Jasper Behrensdorf <behrensdorf@irz.uni-hannover.de>
    %
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
        input;
        model;
        probModel;
    end
    
    methods (TestClassSetup)
        function setupModel(testCase)
            x = opencossan.common.inputs.random.UniformRandomVariable('bounds', [0, 1]);
            y = opencossan.common.inputs.random.UniformRandomVariable('bounds', [0, 1]);
            
            limit = opencossan.common.inputs.Parameter('value', 1);
            
            testCase.input = opencossan.common.inputs.Input(...
                'Members', {x, y, limit}, ...
                'Names', ["x", "y" "limit"]);
            
            mio = opencossan.workers.Mio('FunctionHandle', @(x) sqrt(x(:,1).^2 + x(:, 2).^2), ...
                'Format', 'matrix','IsFunction', true, ...
                'Outputnames',{'radius'},...
                'Inputnames',{'x','y'});
            
            Xeval = opencossan.workers.Evaluator('Xmio',mio);

            testCase.model = opencossan.common.Model('evaluator', Xeval, 'input', testCase.input);
            Xperffun = opencossan.reliability.PerformanceFunction('OutputName','Vg','Demand', 'radius', 'Capacity', 'limit');
            testCase.probModel = opencossan.reliability.ProbabilisticModel('model', testCase.model, 'performancefunction', Xperffun);
        end
    end
    
    methods (Test)
        %% constructor
        function constructorEmpty(testCase)
            Xmc = opencossan.simulations.LineSampling();
            testCase.assertClass(Xmc,'opencossan.simulations.LineSampling');
            testCase.assertEqual(Xmc.NumberOfBatches, 1);
            testCase.assertEqual(Xmc.NumberOfLines, 1);
            testCase.assertEqual(Xmc.PointsOnLine, 1:6);
        end
        
        function constructorFull(testCase)
            Xmc = opencossan.simulations.LineSampling('Description','Unit Test MonteCarlo',...
                'lines',100, ...
                'batches',5, ...
                'points', [1 2 3 4], ...
                'alpha', [0.7071, 0.7071]);
            
            testCase.assertEqual(Xmc.Description,"Unit Test MonteCarlo");
            testCase.assertEqual(Xmc.NumberOfLines, 100);
            testCase.assertEqual(Xmc.NumberOfBatches, 5);
            testCase.assertEqual(Xmc.PointsOnLine, [1 2 3 4]);
            testCase.assertEqual(Xmc.Alpha, [0.7071; 0.7071]);
        end
        
        function constructorShouldFailWithAlphaAndGradient(testCase)
            testCase.assertError(@() opencossan.simulations.LineSampling(...
                'lines', 10, ...
                'alpha', [0.7071; 0.7071], ...
                'gradient', opencossan.sensitivity.Gradient), ...
                'OpenCossan:LineSampling');
        end
        
        function constructorShouldWarnAboutSamples(testCase)
            testCase.assertWarning(@() opencossan.simulations.LineSampling(...
                'lines', 10, ...
                'samples', 100),  'OpenCossan:LineSampling');
        end
        
        %% sample
        function sampleShouldOutputTable(testCase)
            ls = opencossan.simulations.LineSampling('lines', 10, 'points', 1:3, 'alpha', [0.7071; 0.7071]);
            
            samples = ls.sample('input', testCase.input);
            
            testCase.verifyEqual(height(samples), 30);
            testCase.verifyEqual(string(samples.Properties.VariableNames), ...
                testCase.input.InputNames);
        end
        
        %% computeFailureProbability
        function shouldComputPi(testCase)
            ls = opencossan.simulations.LineSampling('lines', 50, 'points', 0.5:0.5:3, ...
                'seed', 8128);
            pf = ls.computeFailureProbability(testCase.probModel);
            
            testCase.assertEqual(4 * (1 - pf.Value), pi, 'RelTol', 0.01)
        end
        
        function shouldStopBecauseOfBatches(testCase)
            ls = opencossan.simulations.LineSampling('lines', 50, ...
                'points', 0.5:0.5:3, 'seed', 8128);
            pf = ls.computeFailureProbability(testCase.probModel);
            
            testCase.assertEqual(pf.ExitFlag, "Maximum number of batches reached.");
        end
        
        %% exportBatch
        function shouldExportBatchAndResult(testCase)
            oldPath = opencossan.OpenCossan.getWorkingPath();
            newPath = tempname;
            opencossan.OpenCossan.setWorkingPath(newPath);
            
            mc = opencossan.simulations.LineSampling('lines', 50, 'points', .5:.5:3, ...
                'exportbatches', true, 'seed', 8128);
            mc.computeFailureProbability(testCase.probModel);
            
            
            listing = dir(newPath);
            testCase.verifySize(listing, [3, 1]);
            
            listing = dir(fullfile(newPath, listing(3).name));
            testCase.verifyEqual(listing(3).name, 'batch_001.mat');
            testCase.verifyEqual(listing(4).name, 'pf.mat');
            
            opencossan.OpenCossan.setWorkingPath(oldPath);
        end
        
    end
end
