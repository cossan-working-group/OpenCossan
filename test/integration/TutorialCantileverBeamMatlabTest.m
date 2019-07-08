classdef TutorialCantileverBeamMatlabTest < TutorialTest
    
    properties
        TutorialName  = 'TutorialCantileverBeamMatlab';
        CoutputNames  = {'NominalDisplacement'};
        CvaluesExpected = {0.0072};
        Ctolerance   = {0.0001};
        PreTest     = {};
    end
    
end
