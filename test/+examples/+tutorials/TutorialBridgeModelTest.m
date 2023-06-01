classdef TutorialBridgeModelTest < examples.tutorials.TutorialTest
    
    properties
        TutorialName  = 'TutorialBridgeModel';
        CoutputNames  = {'NominalDisplacement'};
        CvaluesExpected = {0.0040523};
        Ctolerance   = {0.000001};
        PreTest     = {};
    end
    
end
