classdef TutorialPolyharmonicSplinesTest < tutorials.TutorialTest
    properties
        Name = "TutorialPolyharmonicSplines";
        Variables  = ["mean(Xoutps1.out)", "Xps1.VcalibrationError", "Xps1.VvalidationError"];    
        ExpectedValues = {24708, 1, 0.997};      
        Tolerance = [0.1 0.0001 0.01];        
        PreTest = "";
    end
end      