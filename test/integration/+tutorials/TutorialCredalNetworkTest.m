classdef TutorialCredalNetworkTest < tutorials.TutorialTest

    properties
        TutorialName  = 'TutorialCredalNetwork';
        CoutputNames  = {'Marginal_BuiltIn.Report.LowerBound',...
                         'Marginal_BuiltIn.Report.UpperBound'};
        CvaluesExpected = {[0.325423611686751; 0.641233722778278],...
            [0.35877; 0.67458]};
        Ctolerance   = {1e-5, 1e-5};
        PreTest     = {};
    end

end