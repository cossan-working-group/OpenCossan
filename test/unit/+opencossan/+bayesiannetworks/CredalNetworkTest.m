classdef CredalNetworkTest < matlab.unittest.TestCase
    %CREDALNETWORKTEST Tests for the class
    %opencossan.bayesiannetworks.CredalNetwork
    
    methods (Test)
        %% read_data
        function readDataShouldReturnCorrectVariable(testCase)
            [states, data] = opencossan.bayesiannetworks.CredalNetwork.read_data(...
                fullfile(opencossan.OpenCossan.getRoot(), "test", "unit", "data", "bayesiannetworks", "data.csv"), "Variable 1");
            
            testCase.verifyEqual(states, ["X"; "Y"]);
            testCase.verifyEqual(data, ["X"; "X"; "Y"]);
        end
        
        function readDataShouldErrorForMultipleVariables(testCase)
            testCase.verifyError(@() opencossan.bayesiannetworks.CredalNetwork.read_data(...
                fullfile(opencossan.OpenCossan.getRoot(), "test", "unit", "data", "bayesiannetworks", "data.csv"),...
                "Variable 2"), 'OpenCossan:CredalNetwork:DuplicateVariables');
        end
        
        function readDataShouldErrorForVariablesNotFound(testCase)
            testCase.verifyError(@() opencossan.bayesiannetworks.CredalNetwork.read_data(...
                fullfile(opencossan.OpenCossan.getRoot(), "test", "unit", "data", "bayesiannetworks", "data.csv"),...
                "Variable 3"), 'OpenCossan:CredalNetwork:VariableNotFound');
        end
    end
end

