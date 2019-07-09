classdef TutorialCantileverBeamMatlabTest < tutorials.TutorialTest

    properties
        TutorialName  = 'TutorialCantileverBeamMatlab';
        CoutputNames  = {'NominalDisplacement'};
        CvaluesExpected = {0.0071922};
        Ctolerance   = {0.000001};
        PreTest     = {};
    end

end
