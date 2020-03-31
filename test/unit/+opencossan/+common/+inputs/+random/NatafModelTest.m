classdef NatafModelTest < matlab.unittest.TestCase
    %NATAFMODELTEST Tests all combinations of random variables with a fixed correlation of 0.9
    %against the corrected values from the nataf model by sampling 1e6 values and estimating the
    %resulting correlation. Without the nataf correction these would usually be significantly lower
    %due to the gaussian copula used during sampling.
    
    properties
        rvs = containers.Map('keytype', 'char', ...
            'valuetype', 'any');
    end
    
    properties (TestParameter)
        rho = {0.7, -0.6};
        rv1 = {'normal', 'exponential', 'uniform', 'lognormal', ...
               'rayleigh', 'weibull', 'smallI', 'largeI'};
        rv2 = {'normal', 'exponential', 'uniform', 'lognormal', ...
               'rayleigh', 'weibull', 'smallI', 'largeI'};
    end
    
    methods (TestMethodSetup)
        function setRngSeed(testCase)
            original = rng();
            testCase.addTeardown(@rng, original);
            rng(8128);
        end
    end
    
    methods (TestMethodSetup)
        function setupRvMap(testCase)
            testCase.rvs('normal') = opencossan.common.inputs.random.NormalRandomVariable();
            testCase.rvs('exponential') = opencossan.common.inputs.random.ExponentialRandomVariable();
            testCase.rvs('uniform') = opencossan.common.inputs.random.UniformRandomVariable();
            testCase.rvs('lognormal') = ...
                opencossan.common.inputs.random.LognormalRandomVariable('mu', 0, 'sigma', 0.25);
            testCase.rvs('rayleigh') = opencossan.common.inputs.random.RayleighRandomVariable();
            testCase.rvs('weibull') = ...
                opencossan.common.inputs.random.WeibullRandomVariable('a', 1, 'b', 3);
            testCase.rvs('smallI') = opencossan.common.inputs.random.SmallIRandomVariable();
            testCase.rvs('largeI') = opencossan.common.inputs.random.LargeIRandomVariable();
        end
    end
    
    methods (Test, ParameterCombination='exhaustive')
        function shouldReturnCorrectCorrelationCoefficient(testCase, rv1, rv2, rho)
            rvset = opencossan.common.inputs.random.RandomVariableSet(...
                'Members', [testCase.rvs(rv1), testCase.rvs(rv2)], 'Names', ["a", "b"], ...
                'Correlation', [1, rho; rho, 1]);
            
            samples = rvset.sample(1e6);
            
            testCase.assertEqual(corr(samples.a, samples.b), rho, 'RelTol', 1e-2);
        end
    end
    
    methods (Test)
        function shouldReturnCorrectCorrelationCoefficientWithMonteCarlo(testCase)
            chi = opencossan.common.inputs.random.ChiRandomVariable();
            beta = opencossan.common.inputs.random.BetaRandomVariable();
            
            rvset = opencossan.common.inputs.random.RandomVariableSet(...
                'Members', [chi, beta], 'Names', ["chi", "beta"], ...
                'Correlation', [1, 0.7; 0.7, 1]);
            
            samples = rvset.sample(1e6);
            
            testCase.assertEqual(corr(samples.chi, samples.beta), 0.7, 'RelTol', 1e-2);
        end
    end
end

