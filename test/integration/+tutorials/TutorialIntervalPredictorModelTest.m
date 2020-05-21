classdef TutorialIntervalPredictorModelTest < tutorials.TutorialTest
    properties
        Name = "TutorialIntervalPredictorModel";
        Variables = ["Xo_metamodel.pfhat", "Xo_real.pfhat", "Xo_metamodel2.pfhat", ...
            "Xipm2.getReliability(0.37)"];    
        ExpectedValues = {0.1770, 0.121, 0.1550, 0.0014};      
        Tolerance = [0.1 0.1 0.1 0.001];        
        PreTest = "";
    end
end