classdef TutorialIntervalPredictorModelTest < tutorials.TutorialTest
    
    properties
        TutorialName  = 'TutorialIntervalPredictorModel';

        CoutputNames  = {'Xo_metamodel.Value' 'Xo_real.Value' 'Xo_metamodel2.Value' 'Xipm2.getReliability(0.37)'};    
        CvaluesExpected = {0.1770   0.121  0.1550 0.0014};      
        Ctolerance   = {0.1 0.1 0.1 0.001};        
        PreTest     = {};
    end
    
end      