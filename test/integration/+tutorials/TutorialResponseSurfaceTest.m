classdef TutorialResponseSurfaceTest < tutorials.TutorialTest
    
    
    properties
        TutorialName  = 'TutorialResponseSurface';
        CoutputNames  = {'Xo_metamodel.Value' 'Xo_real.Value' 'Xrs.VvalidationError'};    
        CvaluesExpected = {0.142   0.121  0.87};      
        Ctolerance   = {0.1 0.1 0.05};        
        PreTest     = {};
    end
    
end      