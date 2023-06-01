classdef TutorialCantileverBeamMatlabTest < tutorials.TutorialTest
    properties
        Name = "TutorialCantileverBeamMatlab";
        Variables = "NominalDisplacement";
        ExpectedValues = {0.0071922};
        Tolerance = 1e-6;
        PreTest = "";
    end
end
