classdef TutorialCantileverBeamMatlabReliabilityAnalysisTest < TutorialTest
    
    
    properties
        TutorialName  = 'TutorialCantileverBeamMatlabReliabilityAnalysis';
        CoutputNames  = {'XfailureProbMC.pfhat' 'XfailureProbLHS.pfhat'...
                            'XfailureProbLS.pfhat' 'XfailureProbLS2.pfhat'};  
        CvaluesExpected = {0.0696 0.0696 0.0696 0.0696};   
        Ctolerance   = {'2.81*XfailureProbMC.stdPfhat' 
                        '2.81*XfailureProbLHS.stdPfhat'
                        '2.81*XfailureProbLS.stdPfhat'
                        '2.81*XfailureProbLS2.stdPfhat'};        
        PreTest     = {'TutorialCantileverBeamMatlab'};
    end
    
end      