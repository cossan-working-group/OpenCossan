classdef DesignOfExperimentsTest < matlab.unittest.TestCase
    %DESIGNOFEXPERIMENTSTEST Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        input
    end
    
    methods (TestMethodSetup)
        function setupInput(testCase)
        rv1   = opencossan.common.inputs.random.NormalRandomVariable('mean',5, 'std',1);
        rv2   = opencossan.common.inputs.random.NormalRandomVariable('mean',15,'std',2); 

        dv1 = opencossan.optimization.ContinuousDesignVariable('value',2,'lowerbound',1,'upperbound',6);
        dv2 = opencossan.optimization.DiscreteDesignVariable('value',3,'support',1:2:9);

        testCase.input = opencossan.common.inputs.Input(...
            'members', {rv1 rv2 dv1 dv2}, 'names', ["rv1" "rv2" "dv1" "dv2"]);
        end
    end
    
    methods (Test)
        %% constructor
        function constructorEmpty(testCase)
            doe = opencossan.simulations.DesignOfExperiments();
            testCase.assertClass(doe, 'opencossan.simulations.DesignOfExperiments');
        end
        
        function constructorFull(testCase)
            doe = opencossan.simulations.DesignOfExperiments(...
                'DesignType', 'UserDefined', 'CentralCompositeType', 'inscribed', ...
                'factors', [1 2 3 4], 'usecurrentvalues', false, 'levelvalues', [3 4]);
            
            testCase.assertEqual(doe.DesignType, "UserDefined");
            testCase.assertEqual(doe.CentralCompositeType, "inscribed");
            testCase.assertEqual(doe.Factors, [1 2 3 4]);
            testCase.assertEqual(doe.UseCurrentValues, false);
            testCase.assertEqual(doe.LevelValues, [3 4]);
        end
        
        function shouldFailWithoutFactors(testCase)
            testCase.assertError(@() opencossan.simulations.DesignOfExperiments(...
                'DesignType', 'UserDefined'), 'OpenCossan:DesignOfExperiments');
        end
        
        %% sample
        function shouldRunBoxBehnken(testCase)
            doe = opencossan.simulations.DesignOfExperiments('DesignType','BoxBehnken');

            samples = doe.sample('input', testCase.input);

            testCase.assertEqual(samples{1, :}, [4 13 2 3]);
            testCase.assertEqual(samples{end, :}, [5 15 2 3]);
        end
        
        function shouldRun2LevelFactorial(testCase)
            doe = opencossan.simulations.DesignOfExperiments('DesignType','2LevelFactorial');

            samples = doe.sample('input', testCase.input);

            testCase.assertEqual(samples{1, :}, [5 15 2 3]);
            testCase.assertEqual(samples{end, :}, [6 17 6 9]);
        end
        
        function shouldRunFullFactorial(testCase)
            doe = opencossan.simulations.DesignOfExperiments('DesignType','FullFactorial',...
                'levelvalues', 2);

            samples = doe.sample('input', testCase.input);

            testCase.assertEqual(samples{1, :}, [5 15 1 1]);
            testCase.assertEqual(samples{end, :}, [6 17 6 9]);
        end
        
        function shouldRunCentralCompositeFaced(testCase)
            doe = opencossan.simulations.DesignOfExperiments('DesignType','CentralComposite', ...
                'CentralCompositeType', 'faced');

            samples = doe.sample('input', testCase.input);

            testCase.assertEqual(samples{1, :}, [4 13 1 1]);
            testCase.assertEqual(samples{end, :}, [5 15 2 3]);
        end
        
        function shouldRunCentralCompositeInscribed(testCase)
            doe = opencossan.simulations.DesignOfExperiments('DesignType','CentralComposite', ...
                'CentralCompositeType', 'inscribed');

            samples = doe.sample('input', testCase.input);

            testCase.assertEqual(samples{1, :}, [4.5 14 2.25 3]);
            testCase.assertEqual(samples{end, :}, [5 15 2 3]);
        end
        
        function shouldRunUserDefined(testCase)
            doe = opencossan.simulations.DesignOfExperiments('DesignType','UserDefined', ...
                'Factors', [-1 -0.5 0.5 1; 1 0.5 -0.5 -1]);

            samples = doe.sample('input', testCase.input);

            testCase.assertEqual(samples{1, :}, [4 14 4.75 9]);
            testCase.assertEqual(samples{end, :}, [6 16 2.25 1]);
        end
    end
end

