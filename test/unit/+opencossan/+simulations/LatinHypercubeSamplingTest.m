classdef LatinHypercubeSamplingTest < matlab.unittest.TestCase
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
            Xmc = opencossan.simulations.LatinHypercubeSampling();
            testCase.assertClass(Xmc,'opencossan.simulations.LatinHypercubeSampling');
            testCase.assertEqual(Xmc.Nsamples, 1);
        end
        
        function constructorFull(testCase)
            Xmc = opencossan.simulations.LatinHypercubeSampling('Sdescription','Unit Test LatinHypercubeSampling',...
                'Nsamples',100,...
                'Nbatches',5,...
                'cov',1,...
                'timeout',10,...
                'confLevel',0.95,...
                'Lintermediateresults',false,...
                'SbatchFolder',fullfile(opencossan.OpenCossan.getRoot(),'tmp','data'));
            
            testCase.assertEqual(Xmc.Sdescription,'Unit Test LatinHypercubeSampling');
            testCase.assertEqual(Xmc.Nsamples,100);
            testCase.assertEqual(Xmc.Nbatches,5);
            testCase.assertEqual(Xmc.CoV,1);
            testCase.assertEqual(Xmc.timeout,10);
            testCase.assertEqual(Xmc.confLevel,0.95);
            testCase.assertFalse(Xmc.Lintermediateresults);
            testCase.assertEqual(Xmc.SbatchFolder,fullfile(opencossan.OpenCossan.getRoot(),'tmp','data'));
        end
        
        %% sample
        function sampleShouldOutputTable(testCase)
            Xmc = opencossan.simulations.LatinHypercubeSampling('Nsamples', 10);
            
            inputSamples = testCase.input.sample('Samples', 10);
            mcSamples = Xmc.sample('Xinput', testCase.input, 'Nsamples', 10);
            
            testCase.verifyEqual(height(mcSamples), 10);
            testCase.verifyEqual(inputSamples.Properties.VariableNames, ...
                mcSamples.Properties.VariableNames);
        end
        
        %% computeFailureProbability
        function shouldComputPi(testCase)
            mc = opencossan.simulations.LatinHypercubeSampling('Nsamples', 10000, ...
                'nseedrandomnumbergenerator', 8128);
            pf = mc.computeFailureProbability(testCase.probModel);
            
            testCase.assertEqual(4 * (1 - pf.Value), pi, 'RelTol', 0.01)
        end
        
    end
end
