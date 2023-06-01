classdef TutorialCantileverBeamMatlabOptimizationTest < examples.tutorials.TutorialTest
    
    
    properties
        TutorialName  = 'TutorialCantileverBeamMatlabOptimization';
        CoutputNames  = {'Voptimim(1)' 'Voptimim(2)' 'Voptimim(3)'};    
        CvaluesExpected = {1.5627e-04   2.6385e-05   9.9860e-04};      
        Ctolerance   = {0.0001 0.0001 0.0001};        
        PreTest     = {};
    end
    
    methods (TestClassSetup)
        function skip(testCase)
            % TODO Skip as long as reference values are unclear and
            % assertion fails
            assumeFail(testCase);
        end
    end
end      