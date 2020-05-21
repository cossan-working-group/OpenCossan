classdef ImportanceSamplingTest < matlab.unittest.TestCase
    %IMPORTANCESAMPLINGTEST Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Correlation = [1 0 .5 0; 0 1 -.5 0; .5 -.5 1 .7; 0 0 .7 1];
        Model;
        OriginalDistribution;
        ProposalDistribution;
    end
    
    methods (TestMethodSetup)
        function setupModel(testCase)
            rv1 = opencossan.common.inputs.random.NormalRandomVariable('mean',2,'std',1);
            rv2 = opencossan.common.inputs.random.NormalRandomVariable('mean',2,'std',1);
            rv3 = opencossan.common.inputs.random.NormalRandomVariable('mean',0,'std',2);
            rv4 = opencossan.common.inputs.random.NormalRandomVariable('mean',0,'std',2);
            
            rvset = opencossan.common.inputs.random.RandomVariableSet(...
                'members', [rv1, rv2, rv3, rv4], ...
                'names', ["rv1" "rv2" "rv3" "rv4"], ...
                'correlation', testCase.Correlation);
            
            input = opencossan.common.inputs.Input('members', {rvset}, 'names', "rvset");
            
            mio = opencossan.workers.Mio('FunctionHandle',@(x) -x(:, 1) + x(:, 2), ...
                'format','matrix',...
                'outputnames',{'out'},...
                'inputnames',{'rv1','rv3'},...
                'IsFunction',true);
            
            evaluator = opencossan.workers.Evaluator('Xmio', mio);
            
            testCase.OriginalDistribution = rvset;
            testCase.Model = opencossan.common.Model('evaluator', evaluator, 'input', input);
        end
        
        function setupProposalDistribution(testCase)
            rv5 = opencossan.common.inputs.random.NormalRandomVariable('mean',0, 'std',1);
            rv6 = opencossan.common.inputs.random.NormalRandomVariable('mean',0, 'std',1);
            testCase.ProposalDistribution = opencossan.common.inputs.random.RandomVariableSet(...
                'members', [rv5 rv6], 'names', ["rv1" "rv2"]);
        end
    end
    
    methods (Test)
        % constructor
        function constructorEmpty(testCase)
            is = opencossan.simulations.ImportanceSampling();
            testCase.assertClass(is, 'opencossan.simulations.ImportanceSampling');
        end
        
        function constructorFull(testCase)
            is = opencossan.simulations.ImportanceSampling('proposaldistribution', ...
                testCase.ProposalDistribution);
            testCase.assertClass(is, 'opencossan.simulations.ImportanceSampling');
            testCase.assertEqual(is.ProposalDistribution, testCase.ProposalDistribution);
        end
        
        % sample
        function sampleShouldPreserveCorrelation(testCase)
            is = opencossan.simulations.ImportanceSampling('proposaldistribution', ...
                testCase.ProposalDistribution, 'samples', 1e5);
            s = rng(); rng(8128);
            testCase.addTeardown(@rng, s);
            
            samples = is.sample('input', testCase.Model.Input);
            
            absTol = 0.01;
            
            % rv1 and rv2 should be distributed according to the proposal distribution
            testCase.assertEqual(mean(samples.rv1), 0, 'AbsTol', absTol);
            testCase.assertEqual(mean(samples.rv2), 0, 'AbsTol', absTol);
            testCase.assertEqual(std(samples.rv1), 1, 'AbsTol', absTol);
            testCase.assertEqual(std(samples.rv2), 1, 'AbsTol', absTol);
            
            % rv3 and rv4 should be distributed according to their original distribution
            testCase.assertEqual(mean(samples.rv3), 0, 'AbsTol', absTol);
            testCase.assertEqual(mean(samples.rv4), 0, 'AbsTol', absTol);
            testCase.assertEqual(std(samples.rv3), 2, 'AbsTol', absTol);
            testCase.assertEqual(std(samples.rv4), 2, 'AbsTol', absTol);
            
            corr = corrcoef(samples{:,:});
            testCase.assertEqual(corr(1,2), 0, 'AbsTol', absTol);
            
            testCase.assertEqual(corr(1,3), testCase.Correlation(1,3), 'AbsTol', absTol);
            testCase.assertEqual(corr(2,3), testCase.Correlation(2,3), 'AbsTol', absTol);
            testCase.assertEqual(corr(1,4), testCase.Correlation(1,4), 'AbsTol', absTol);
            testCase.assertEqual(corr(2,4), testCase.Correlation(2,4), 'AbsTol', absTol);
            testCase.assertEqual(corr(3,4), testCase.Correlation(3,4), 'AbsTol', absTol);
        end
        
        function weightsShouldBeOnesForIdenticalProposal(testCase)
            is = opencossan.simulations.ImportanceSampling('proposaldistribution', ...
                testCase.OriginalDistribution, 'samples', 1e3);
            
            [~, weights] = is.sample('input', testCase.Model.Input);
            
            testCase.assertTrue(all(weights == 1));
        end
        
        function weightsShouldNotBeOne(testCase)
            is = opencossan.simulations.ImportanceSampling('proposaldistribution', ...
                testCase.ProposalDistribution, 'samples', 1e3);
            
            [~, weights] = is.sample('input', testCase.Model.Input);
            
            testCase.assertTrue(all(weights ~= 1));
        end
        
        %apply
        function shouldReturnSimulationData(testCase)
            is = opencossan.simulations.ImportanceSampling('proposaldistribution', ...
                testCase.ProposalDistribution, 'samples', 1e3);
            
            simData = is.apply(testCase.Model);
            
            testCase.assertClass(simData, 'opencossan.common.outputs.SimulationData');
        end
        
        % computeFailureProbability
        function shouldReturnPfWithAllRvsMapped(testCase)
            rv1 = opencossan.common.inputs.random.NormalRandomVariable('mean',0,'std',1);
            rv2 = opencossan.common.inputs.random.NormalRandomVariable('mean',0,'std',1);
            
            input = opencossan.common.inputs.Input('Members', {rv1, rv2},...
                'Names', ["rv1","rv2"]);
            
            mio = opencossan.workers.Mio('FunctionHandle', @(x) sum(x, 2), ...
                'Inputnames',{'rv1','rv2'}, 'Outputnames',{'prod'},...
                'format','matrix','isfunction', true);
            
            evaluator = opencossan.workers.Evaluator('CXmembers', {mio}, 'CSmembers', {'Xmio'});
            
            model = opencossan.common.Model('Input', input, 'Evaluator', evaluator);
            
            perfun = opencossan.reliability.PerformanceFunction('FunctionHandle', @(x) 4 - x(:, 1), ...
                'OutputName', 'Vg', 'Inputnames', {'prod'}, 'isfunction', true, 'format', 'matrix');
            
            probModel = opencossan.reliability.ProbabilisticModel(...
                'Model', model, 'PerformanceFunction', perfun);
            
            map1 = opencossan.common.inputs.random.NormalRandomVariable('mean',2,'std',sqrt(2)/2);
            map2 = opencossan.common.inputs.random.NormalRandomVariable('mean',2,'std',sqrt(2)/2);
            proposal = opencossan.common.inputs.random.RandomVariableSet('Members',[map1, map2], ...
                'Names', ["rv1","rv2"], 'correlation', [1, -0.8; -0.8 1]);
            
            is = opencossan.simulations.ImportanceSampling('samples',200, ...
                'proposaldistribution',proposal, 'seed', 8128);
            pf = is.computeFailureProbability(probModel);
            
            testCase.assertEqual(pf.Value, 0.0020, 'AbsTol', 1e-4);
        end
        
        function shouldReturnPfWithMixedMapping(testCase)
            rv1 = opencossan.common.inputs.random.NormalRandomVariable('mean',0,'std',1);
            rv2 = opencossan.common.inputs.random.NormalRandomVariable('mean',0,'std',1);
            rv3 = opencossan.common.inputs.random.NormalRandomVariable('mean',0,'std',1);
            rvset = opencossan.common.inputs.random.RandomVariableSet('Members',[rv1, rv2, rv3], ...
                'Names',["rv1","rv2","rv3"], 'correlation',[1, 0.8, 0; 0.8 1 0.3333; 0 0.3333 1]);
            
            input = opencossan.common.inputs.Input('Members', {rvset},...
                'Names', "rvset");
            
            mio = opencossan.workers.Mio('FunctionHandle', @(x) sum(x, 2), ...
                'Inputnames',{'rv1','rv2'}, 'Outputnames',{'prod'},...
                'format','matrix','isfunction', true);
            
            evaluator = opencossan.workers.Evaluator('xmio', mio);
            
            model = opencossan.common.Model('Input', input, 'Evaluator', evaluator);
            
            perfun = opencossan.reliability.PerformanceFunction('FunctionHandle', @(x) 5 - x(:, 1), ...
                'OutputName', 'Vg', 'Inputnames', {'prod'}, 'isfunction', true, 'format', 'matrix');
            
            probModel = opencossan.reliability.ProbabilisticModel(...
                'Model', model, 'PerformanceFunction', perfun);
            
            map1 = opencossan.common.inputs.random.NormalRandomVariable('mean',2.5,'std',0.5);
            map2 = opencossan.common.inputs.random.NormalRandomVariable('mean',2.5,'std',0.5);
            proposal = opencossan.common.inputs.random.RandomVariableSet('Members', [map1, map2], ...
                'Names', ["rv1","rv2"]);
            
            is = opencossan.simulations.ImportanceSampling('samples',200, ...
                'proposaldistribution',proposal, 'seed', 8128);
            pf = is.computeFailureProbability(probModel);
            
            testCase.assertEqual(pf.Value, 0.0041, 'AbsTol', 1e-4);
        end
    end
end

