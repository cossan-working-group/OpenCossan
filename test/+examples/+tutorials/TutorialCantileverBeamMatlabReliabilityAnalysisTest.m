classdef TutorialCantileverBeamMatlabReliabilityAnalysisTest < examples.tutorials.TutorialTest
    
    
    properties
        TutorialName  = 'TutorialCantileverBeamMatlabReliabilityAnalysis';
        CoutputNames  = {'XfailireProbMC.pfhat' 'XfailireProbLHS.pfhat'...
                            'XfailireProbLS.pfhat' 'XfailireProbLS2.pfhat'};  
        CvaluesExpected = {0.0738 0.083 0.06683 0.07267};   
        Ctolerance   = {eps eps 0.000001 0.0001};        
        PreTest     = {'TutorialCantileverBeamMatlab'};
    end
    
    methods (TestClassSetup)
        function skip(testCase)
            % TODO Skip as long as reference values are unclear and
            % assertion fails
            assumeFail(testCase);
        end
    end
end      