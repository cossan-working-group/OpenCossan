classdef TutorialResponseSurfaceTest < tutorials.TutorialTest
    
    
    properties
        TutorialName  = 'TutorialResponseSurface';
        CoutputNames  = {'Xo_metamodel.pfhat' 'Xo_real.pfhat' 'Xrs.VvalidationError'};    
        CvaluesExpected = {0.142   0.121  0.87};      
        Ctolerance   = {0.1 0.1 0.05};        
        PreTest     = {};
    end
    
end      