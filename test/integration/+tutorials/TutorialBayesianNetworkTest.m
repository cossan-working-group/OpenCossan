classdef TutorialBayesianNetworkTest < tutorials.TutorialTest
    properties
        Name  = "TutorialBayesianNetwork";
        Variables  = ["Marginal_BuiltIn.MarginalProbability.Report", ...
            "Marginal_BNT.MarginalProbability.Report"];
        ExpectedValues = {[0.31443; 0.68557],...
            [0.31443; 0.68557]};
        Tolerance = [1e-5, 1e-5];
        PreTest = "";
    end
end