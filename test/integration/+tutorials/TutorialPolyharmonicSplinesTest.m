classdef TutorialPolyharmonicSplinesTest < tutorials.TutorialTest
    
    
    properties
        TutorialName  = 'TutorialPolyharmonicSplines';
        CoutputNames  = {'mean(Xoutps1.out)' 'Xps1.VcalibrationError' 'Xps1.VvalidationError'};    
        CvaluesExpected = {24708   1  0.997};      
        Ctolerance   = {0.1 0.0001 0.01};        
        PreTest     = {};
    end
    
end      