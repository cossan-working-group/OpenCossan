classdef TutorialBeam3PointBendingMatlabTest < examples.tutorials.TutorialTest
    
    properties
        TutorialName  = 'TutorialBeam3PointBendingPerformReliabilityAnalysis';
        CoutputNames  = {'Xpf.pfhat'};
        CvaluesExpected = {0.0575};
        Ctolerance   = {5E-4};
        PreTest     = {'TutorialBeam3PointBendingMatlab'};
    end
    
    
    
end   