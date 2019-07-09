classdef UniformCircularAreaRandomVariableTest < matlab.unittest.TestCase
    %UNIFORMCIRCULARAREARANDOMVARIABLETEST Unit tests for the class
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
        %% Constructor
        function constructorEmpty(testCase)
            random = opencossan.common.inputs.random.UniformCircularAreaRandomVariable();
            testCase.assertClass(random,'opencossan.common.inputs.random.UniformCircularAreaRandomVariable');
        end
        
        function constructorFull(testCase)
            random = opencossan.common.inputs.random.UniformCircularAreaRandomVariable('bounds',[0.5;1],...
                'Description', "Test Description");
            testCase.verifyEqual(random.Bounds(2), 1);
            testCase.verifyEqual(random.Bounds(1), 0.5);
            testCase.verifyEqual(random.Description, "Test Description");
        end
        
        %% fromMeanAndStd
        function fromMeanAndStdShouldThrowException(testCase)
            import opencossan.common.inputs.random.UniformCircularAreaRandomVariable;
            testCase.verifyError(@() UniformCircularAreaRandomVariable.fromMeanAndStd(),...
                'UniformCircularAreaRandomVariable:UnsupportedOperation');
        end
        
        %% get.Std
        function getStdShouldCalculateStd(testCase)
            random = opencossan.common.inputs.random.UniformCircularAreaRandomVariable('bounds',[0.5;1]);
            testStd  = (1 - 0.5) / (2 * sqrt(3));
            testCase.verifyEqual(random.Std, testStd);
        end
        
        %% get.Mean
        function getMeanShouldCalculateMean(testCase)
            random = opencossan.common.inputs.random.UniformCircularAreaRandomVariable('bounds',[0.5;1]);
            testMean = (0.5 + 1) / 2;
            testCase.verifyEqual(random.Mean, testMean);
        end
        
        %% modify bounds
        function modifyBounds(testCase)
            random = opencossan.common.inputs.random.UniformCircularAreaRandomVariable('bounds',[0.5;1]);
            random.Bounds = [2;10];
            testCase.verifyEqual(random.Bounds(2), 10);
            testCase.verifyEqual(random.Bounds(1), 2);
        end
        
        %% sample
        function SampleEmpty(testCase)
            random = opencossan.common.inputs.random.UniformCircularAreaRandomVariable('bounds',[0.5;1]);
            value = random.sample();
            testCase.verifySize(value, [1,1]);
        end
        
        function SampleOnlyM(testCase)
            random = opencossan.common.inputs.random.UniformCircularAreaRandomVariable('bounds',[0.5;1]);
            value = random.sample(2);
            testCase.verifySize(value, [2,1]);
        end
        
        function SampleWithMAndN(testCase)
            random = opencossan.common.inputs.random.UniformCircularAreaRandomVariable('bounds',[0.5;1]);
            value = random.sample([2 2]);
            testCase.verifySize(value, [2,2]);
        end
        
        %% map2physical
        function map2physical(testCase)
            random = opencossan.common.inputs.random.UniformCircularAreaRandomVariable('bounds',[0.5;1]);
            VX = random.map2physical(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        
        %% cdf2physical
        function cdf2physical(testCase)
            random = opencossan.common.inputs.random.UniformCircularAreaRandomVariable('bounds',[0.5;1]);
            VX = random.cdf2physical(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        
        %% map2stdnorm
        function map2stdnorm(testCase)
            random = opencossan.common.inputs.random.UniformCircularAreaRandomVariable('bounds',[0.5;1]);
            VX = random.map2stdnorm(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        
        %% physical2cdf
        function physical2cdf(testCase)
            random = opencossan.common.inputs.random.UniformCircularAreaRandomVariable('bounds',[0.5;1]);
            VX = random.physical2cdf(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        
        %% evalpdf
        function evalpdf(testCase)
            random = opencossan.common.inputs.random.UniformCircularAreaRandomVariable('bounds',[0.5;1]);
            testCase.verifyError(@() random.evalpdf(rand(10)),'UniformCircularAreaRandomVariable:UnsupportedOperation');
        end
        
        %% fit
        function fitShouldThrowException(testCase)
            import opencossan.common.inputs.random.UniformCircularAreaRandomVariable
            testCase.verifyError(@() UniformCircularAreaRandomVariable.fit(),...
                'UniformCircularAreaRandomVariable:UnsupportedOperation');
        end
    end
end


