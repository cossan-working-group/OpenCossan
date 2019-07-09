classdef RandomVariableTest < matlab.unittest.TestCase
    %RANDOMVARIABLETEST Unit tests for the class
    % opencossan.common.inputs.random.RandomVariable
    % See also: opencossan.common.inputs.random.RandomVariable
    
    % =====================================================================
    % This file is part of *OpenCossan*: you can redistribute it and/or modify
    % it under the terms of the GNU General Public License as published by
    % the Free Software Foundation, either version 3 of the License.
    %
    % *OpenCossan* is distributed in the hope that it will be useful,
    % but WITHOUT ANY WARRANTY; without even the implied warranty of
    % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    % GNU General Public License for more details.
    %
    % You should have received a copy of the GNU General Public License
    % along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
    % =====================================================================
    
    methods (Test)
        %% cdf2stdnorm
        function  cdf2stdnormRow(testCase)
            VX = opencossan.common.inputs.random.RandomVariable.cdf2stdnorm(rand(10,1));
            testCase.verifySize(VX,[10 1]);
        end
        
        function cdf2stdnormShouldErrorForInvalidValue(testCase)
            testCase.verifyError(@() opencossan.common.inputs.random.RandomVariable.cdf2stdnorm(1.1),...
                'openCOSSAN:RandomVariable:cdf2physical');
            testCase.verifyError(@() opencossan.common.inputs.random.RandomVariable.cdf2stdnorm(-0.1),...
                'openCOSSAN:RandomVariable:cdf2physical');
        end
        
        function cdf2stdnormColumn(testCase)
            VX = opencossan.common.inputs.random.RandomVariable.cdf2stdnorm(rand(1,10));
            testCase.verifySize(VX,[1 10]);
        end
        
        %% stdnorm2cdf
        function stdnorm2cdfRow(testCase)
            VU = opencossan.common.inputs.random.RandomVariable.stdnorm2cdf(rand(10,1));
            testCase.verifySize(VU,[10 1]);
        end
        
        function stdnorm2cdfColumn(testCase)
            VU = opencossan.common.inputs.random.RandomVariable.stdnorm2cdf(rand(1,10));
            testCase.verifySize(VU,[1 10]);
        end 
        
        %% getPdf
        function getPdfWithExponantial(testCase)
            random = opencossan.common.inputs.random.ExponentialRandomVariable('lambda', 2.2913);
            testCase.verifySize(random.getPdf, [1 101]);
        end
        
        function getPdfWithBinomial(testCase)
            random = opencossan.common.inputs.random.BinomialRandomVariable();
            testCase.verifySize(random.getPdf('samples', 150), [1 2]);
        end
        
        %% transform2designVariable
        function transform2designVariable(testCase)
            random = opencossan.common.inputs.random.ExponentialRandomVariable('lambda', 2.2913); 
            designVariable = random.transform2designVariable;
            testCase.verifyEqual(designVariable.value, random.Mean);
        end
    end
end
