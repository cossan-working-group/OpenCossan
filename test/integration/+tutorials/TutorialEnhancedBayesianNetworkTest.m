classdef TutorialEnhancedBayesianNetworkTest < tutorials.TutorialTest
    properties
        Name = "TutorialEnhancedBayesianNetwork";
        Variables = ["Marginalization.MarginalProbability.Overtopping", ...
            "Marginalization.MarginalProbability.StationDamage"];
        ExpectedValues = {[0.99827; 0.0017322], ...
            [0.99982; 0.00018159]};
        Tolerance = [1e-5, 1e-5];
        PreTest = "";
    end
end