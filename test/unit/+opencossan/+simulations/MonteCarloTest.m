classdef MonteCarloTest < matlab.unittest.TestCase
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
            Xmc = opencossan.simulations.MonteCarlo();
            testCase.assertClass(Xmc,'opencossan.simulations.MonteCarlo');
            testCase.assertEqual(Xmc.NumberOfBatches, 1);
            testCase.assertEqual(Xmc.NumberOfSamples, 1);
            testCase.assertEqual(Xmc.CoV, 0);
            testCase.assertEqual(Xmc.RandomStream, []);
            testCase.assertEqual(Xmc.Timeout, 0);
        end
        
        function constructorFull(testCase)
            Xmc = opencossan.simulations.MonteCarlo('Description','Unit Test MonteCarlo',...
                'samples',100,...
                'batches',5,...
                'cov',1,...
                'timeout',10,...
                'seed', 8128);
            
            testCase.assertEqual(Xmc.Description,"Unit Test MonteCarlo");
            testCase.assertEqual(Xmc.NumberOfSamples, 100);
            testCase.assertEqual(Xmc.NumberOfBatches, 5);
            testCase.assertEqual(Xmc.CoV,1);
            testCase.assertEqual(Xmc.Timeout,10);
            testCase.assertEqual(double(Xmc.RandomStream.Seed), 8128);
        end
        
        %% sample
        function sampleShouldOutputTable(testCase)
            Xmc = opencossan.simulations.MonteCarlo('samples', 10);
            
            inputSamples = testCase.input.sample('Samples', 10);
            mcSamples = Xmc.sample('input', testCase.input, 'samples', 10);
            
            testCase.verifyEqual(height(mcSamples), 10);
            testCase.verifyEqual(inputSamples.Properties.VariableNames, ...
                mcSamples.Properties.VariableNames);
        end
        
        %% apply
        function applyShouldRunTheModel(testCase)
            Xmc = opencossan.simulations.MonteCarlo('samples', 10);
            simData = Xmc.apply(testCase.probModel);
            
            testCase.assertSize(simData.Samples.Vg, [10, 1]);
        end
        
        %% computeFailureProbability
        function shouldComputPi(testCase)
            mc = opencossan.simulations.MonteCarlo('samples', 10000, ...
                'seed', 8128);
            pf = mc.computeFailureProbability(testCase.probModel);
            
            testCase.assertEqual(4 * (1 - pf.Value), pi, 'RelTol', 0.01)
        end
        
        function shouldStopBecauseOfTimeout(testCase)
            mc = opencossan.simulations.MonteCarlo('samples', 10, 'batches', 10, 'timeout', eps);
            pf = mc.computeFailureProbability(testCase.probModel);
            
            testCase.assertEqual(pf.ExitFlag, "Maximum execution time reached.");
        end
        
        function shouldStopBecauseOfBatches(testCase)
            mc = opencossan.simulations.MonteCarlo('samples', 1, 'batches', 10);
            pf = mc.computeFailureProbability(testCase.probModel);
            
            testCase.assertEqual(pf.ExitFlag, "Maximum number of batches reached.");
        end
        
        function shouldStopBecauseOfCoV(testCase)
            mc = opencossan.simulations.MonteCarlo('samples', 1000, 'cov', 1, 'seed', 8128);
            pf = mc.computeFailureProbability(testCase.probModel);
            
            testCase.assertEqual(pf.ExitFlag, "Target CoV reached.");
        end
        
        %% exportBatch
        function shouldExportBatchAndResult(testCase)
            oldPath = opencossan.OpenCossan.getWorkingPath();
            newPath = tempname;
            opencossan.OpenCossan.setWorkingPath(newPath);
            
            mc = opencossan.simulations.MonteCarlo('samples', 1000, 'exportbatches', true, 'seed', 8128);
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
