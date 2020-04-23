classdef TutorialBayesianNetworkTest < tutorials.TutorialTest

    properties
        TutorialName  = 'TutorialBayesianNetwork';
        CoutputNames  = {'Marginal_BuiltIn.MarginalProbability.Report',...
                         'Marginal_BNT.MarginalProbability.Report'};
        CvaluesExpected = {[0.31443; 0.68557],...
            [0.31443; 0.68557]};
        Ctolerance   = {1e-5, 1e-5};
        PreTest     = {};
    end

end