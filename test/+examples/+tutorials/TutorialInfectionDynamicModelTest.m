classdef TutorialInfectionDynamicModelTest < examples.tutorials.TutorialTest
    
    properties
        TutorialName  = 'TutorialInfectionDynamicModel';
        CoutputNames  = {'min(VY)'};
        CvaluesExpected = {-1.6894};
        Ctolerance   = {1e-4};
        PreTest     = {};
    end
    
end
