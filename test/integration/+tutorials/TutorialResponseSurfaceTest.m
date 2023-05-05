classdef TutorialResponseSurfaceTest < tutorials.TutorialTest
    properties
        Name = "TutorialResponseSurface";
        Variables = ["Xo_metamodel.pfhat", "Xo_real.pfhat", "Xrs.VvalidationError"];    
        ExpectedValues = {0.142, 0.121, 0.87};      
        Tolerance = [0.1, 0.1, 0.05];        
        PreTest = "";
    end
end