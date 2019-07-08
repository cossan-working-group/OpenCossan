classdef TutorialCantileverBeamMatlabOptimizationTest < TutorialTest
    
    properties
        TutorialName  = 'TutorialCantileverBeamMatlabOptimization';
        CoutputNames  = {'SQP(5)' 'COBYLA(5)' 'GA(5)'};    
        CvaluesExpected = {-8.16e-06   -2.1771e-05   9.9860e-04};      
        Ctolerance   = {1e-4 1e-4 1e-4};        
        PreTest     = {};
    end
    
end      