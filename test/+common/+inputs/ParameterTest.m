classdef ParameterTest < matlab.unittest.TestCase
    % PARAMETERTEST Unit tests for the class common.inputs.Parameter
    %   For more detailed information, see <a
    %   href="https://cossan.co.uk/wiki/index.php/@Parameter">OpenCossan-Wiki</a>.
    %
    %   See also: COMMON.INPUTS.PARAMETER
    
    % =====================================================================
    % This file is part of openCOSSAN.  The open general purpose matlab
    % toolbox for numerical analysis, risk and uncertainty quantification.
    
    % =====================================================================
    % This file is part of openCOSSAN.  The open general purpose matlab
    % toolbox for numerical analysis, risk and uncertainty quantification.
    %
    % openCOSSAN is free software: you can redistribute it and/or modify
    % it under the terms of the GNU General Public License as published by
    % the Free Software Foundation, either version 3 of the License.
    %
    % openCOSSAN is distributed in the hope that it will be useful,
    % but WITHOUT ANY WARRANTY; without even the implied warranty of
    % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    % GNU General Public License for more details.
    %
    % You should have received a copy of the GNU General Public License
    % along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
    % =====================================================================
       
    methods (Test)
        %% constructor
        function constructorEmpty(testCase)
            Xpar = common.inputs.Parameter();
            testCase.verifyClass(Xpar, 'common.inputs.Parameter');
            testCase.verifyNumElements(Xpar, 1);
            testCase.verifyLength(Xpar.Value, 0);
            testCase.verifyEqual(Xpar.Nelements, 0);
        end
        
        function constructorShouldSetDescription(testCase)
            Xpar = common.inputs.Parameter('description','Description');
            testCase.verifyEqual(Xpar.Description,"Description");
        end
        
        function constructorShouldSetValue(testCase)
            Xpar = common.inputs.Parameter('value', 5);
            testCase.verifyEqual(Xpar.Value, 5);
        end
        
        function constructorShouldValidateInput(testCase)
            % String validation for Description
            testCase.verifyError(@()common.inputs.Parameter('description', cell(1)),...
                'MATLAB:UnableToConvert');
            testCase.verifyError(@()common.inputs.Parameter('description', rand(2)),...
                'MATLAB:type:InvalidInputSize');
            % Numeric validation for Value
            testCase.verifyError(@()common.inputs.Parameter('value', 'c'),...
                'MATLAB:validators:mustBeNumeric');
        end
                               
        function constructorClassShouldNotInheritFromHandle(testCase)
            Xpar = common.inputs.Parameter();
            testCase.verifyFalse(ishandle(Xpar));
        end
        
                
        %% display
        function checkDisplayWorks(testCase)
            % Check for single Object
            Xpar = common.inputs.Parameter('description', 'Test Object',...
                'value', magic(4));
            testPhrase = [Xpar.Description;...
                          num2str(Xpar.Nelements)];
            worksSingle = testOutput(Xpar,testPhrase);
            % Check for array of objects
            Xpar = [common.inputs.Parameter(); common.inputs.Parameter()];
            testPhrase = ["Parameter array with properties:";...
                          "Description";...
                           "Nelements";...
                           "Value"];
            worksMulti = testOutput(Xpar,testPhrase);
            
            works = worksSingle && worksMulti;
            testCase.assertTrue(works);
        end
    end
end