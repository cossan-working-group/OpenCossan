classdef TutorialCredalNetworkTest < tutorials.TutorialTest
    properties
        Name = "TutorialCredalNetwork";
        Variables = ["Marginal_BuiltIn.Report.LowerBound", ...
            "Marginal_BuiltIn.Report.UpperBound"];
        ExpectedValues = {[0.325423611686751; 0.641233722778278], ...
            [0.35877; 0.67458]};
        Tolerance = [1e-5, 1e-5];
        PreTest = "";
    end
end