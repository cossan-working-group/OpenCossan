classdef ModelTest < matlab.mock.TestCase
    % MODELTEST Unit tests for the class common.Model
    % see http://cossan.co.uk/wiki/index.php/@Model
    
    %{
    This file is part of OpenCossan <https://cossan.co.uk>.
    Copyright (C) 2006-2018 COSSAN WORKING GROUP

    OpenCossan is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License or,
    (at your option) any later version.

    OpenCossan is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with OpenCossan. If not, see <http://www.gnu.org/licenses/>.
    %}
    
    % Contains model properties used in test below
    properties
        EvaluatorStub;
        EvaluatorBehavior;
        InputStub;
        InputBehavior;
    end
    
    methods (TestMethodSetup)
        function setupEvaluatorMock(testCase)
            [evaluatorStub, evaluatorBehavior] = ...
                testCase.createMock(?opencossan.workers.Evaluator);
            
            simulationDataStub = testCase.createMock(...
                ?opencossan.common.outputs.SimulationData);
            testCase.assignOutputsWhen(...
                withAnyInputs(evaluatorBehavior.deterministicAnalysis),...
                simulationDataStub);
            testCase.assignOutputsWhen(...
                withAnyInputs(evaluatorBehavior.apply),...
                simulationDataStub);
            
            testCase.EvaluatorStub = evaluatorStub;
            testCase.EvaluatorBehavior = evaluatorBehavior;
        end
        
        function setupInputMock(testCase)
            [inputStub, inputBehavior] = ...
                testCase.createMock(?opencossan.common.inputs.Input);
            
            testCase.assignOutputsWhen(...
                withAnyInputs(inputBehavior.set), inputStub);
            testCase.InputStub = inputStub;
            testCase.InputBehavior = inputBehavior;
        end
    end
    
    methods (Test)
        function shouldConstructEmptyObject(testCase)
            model = opencossan.common.Model();
            testCase.verifyClass(model,'opencossan.common.Model');
        end
        
        function shouldConstructCompleteObject(testCase)
            model = opencossan.common.Model('Input',testCase.InputStub,...
                'Evaluator', testCase.EvaluatorStub, ...
                'Description', "Model Test");
            testCase.verifyEqual(model.Input, testCase.InputStub);
            testCase.verifyEqual(model.Evaluator, testCase.EvaluatorStub);
            testCase.verifyEqual(model.Description, "Model Test");
            
            % I tried to mock the dependent properties on the Input and
            % Evaluator but MATLAB wouldn't let me.
            testCase.verifyEqual(model.InputNames, cell(1,0));
            testCase.verifyEqual(model.OutputNames, {});
        end
        
        function shouldFailToConstructObject(testCase)
            import opencossan.common.Model;
            % Missing inputs
            testCase.verifyError(@() Model('Input',testCase.InputStub),...
                'OpenCossan:MissingRequiredInput');
            testCase.verifyError(@() Model('Evaluator',testCase.EvaluatorStub),...
                'OpenCossan:MissingRequiredInput');
            % Wrong input types
            testCase.verifyError(@() Model('Input',1,'Evaluator',1),...
                'MATLAB:UnableToConvert');
            testCase.verifyError(@() Model('Input',testCase.InputStub,...
                'Evaluator',1),...
                'MATLAB:UnableToConvert');
            testCase.verifyError(@() Model('Input',1,...
                'Evaluator',testCase.EvaluatorStub), ...
                'MATLAB:UnableToConvert');
        end
        
        function shouldRunDeterministicAnalysis(testCase)
            model = opencossan.common.Model('Input', testCase.InputStub, ...
                'Evaluator', testCase.EvaluatorStub);
            out = model.deterministicAnalysis();
            testCase.verifyClass(out,'matlab.mock.classes.SimulationDataMock');
        end
        
        function shouldRunApplyWithInput(testCase)
            model = opencossan.common.Model('Input', testCase.InputStub, ...
                'Evaluator', testCase.EvaluatorStub);
            out = model.apply(testCase.InputStub);
            testCase.verifyClass(out,'matlab.mock.classes.SimulationDataMock');
        end
        
        function shouldRunApplyWithSamples(testCase)
            model = opencossan.common.Model('Input', testCase.InputStub, ...
                'Evaluator', testCase.EvaluatorStub);
            samplesStub = testCase.createMock(...
                ?opencossan.common.Samples);
            out = model.apply(samplesStub);
            testCase.verifyClass(out,'matlab.mock.classes.SimulationDataMock');
        end
        
    end
    
end



