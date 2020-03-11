classdef SobolSamplingTest < matlab.unittest.TestCase
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
            ss = opencossan.simulations.SobolSampling();
            testCase.assertClass(ss,'opencossan.simulations.SobolSampling');
            testCase.assertEqual(ss.NumberOfSamples, 1);
        end
        
        function constructorFull(testCase)
            ss = opencossan.simulations.SobolSampling('samples', 100, 'skip', 10, ...
                'leap', 5, 'scramble', true, 'pointorder', 'graycode');
            testCase.assertClass(ss,'opencossan.simulations.SobolSampling');
            
            testCase.assertEqual(ss.NumberOfSamples, 100);
            testCase.assertTrue(ss.Scramble);
            testCase.assertEqual(ss.Leap, 5);
            testCase.assertEqual(ss.Skip, 10);
            testCase.assertEqual(ss.PointOrder, 'graycode');
        end
        
        %% samples
        function scrambleShouldChangeSamples(testCase)
            ss = opencossan.simulations.SobolSampling('samples', 5, 'leap', 10, 'skip', 5);
            unscrambled = ss.sample('input', testCase.input);
            ss.Scramble = true;
            scrambled = ss.sample('input', testCase.input);
            
            testCase.assertNotEqual(unscrambled, scrambled);
        end
        
        %% computeFailureProbability
        function shouldComputPi(testCase)
            mc = opencossan.simulations.SobolSampling('samples', 10000, ...
                'seed', 8128, 'leap', 100, 'skip', 25);
            pf = mc.computeFailureProbability(testCase.probModel);
            
            testCase.assertEqual(4 * (1 - pf.Value), pi, 'RelTol', 0.01)
        end
        
    end
end
