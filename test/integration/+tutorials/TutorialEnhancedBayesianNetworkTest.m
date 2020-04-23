classdef TutorialEnhancedBayesianNetworkTest < tutorials.TutorialTest

    properties
        TutorialName  = 'TutorialEnhancedBayesianNetwork';
        CoutputNames  = {'Marginalization.MarginalProbability.Overtopping',...
                         'Marginalization.MarginalProbability.StationDamage'};
        CvaluesExpected = {[0.99827; 0.0017322],...
            [0.99982; 0.00018159]};
        Ctolerance   = {1e-5, 1e-5};
        PreTest     = {};
    end

end