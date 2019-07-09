classdef UniformDiscreteRandomVariableTest < matlab.unittest.TestCase
    %UNIFORMDISCRETERANDOMVARIABLETEST Unit tests for the class
    % opencossan.common.inputs.random.RandomVariable
    % See also: opencossan.common.inputs.random.RandomVariable
    
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
    
    methods (Test)
        %% Constructor
        function constructorEmpty(testCase)
            random = opencossan.common.inputs.random.UniformDiscreteRandomVariable();
            testCase.assertClass(random,'opencossan.common.inputs.random.UniformDiscreteRandomVariable');
        end
        
        function constructorFull(testCase)
            random = opencossan.common.inputs.random.UniformDiscreteRandomVariable('bounds',[0;10],...
                'Description', "Test Description");
            testCase.verifyEqual(random.Bounds(2), 10);
            testCase.verifyEqual(random.Bounds(1), 0);
            testCase.verifyEqual(random.Description, "Test Description");
        end
        
        %% fromMeanAndStd
        function constructorFullWithMeanAndStd(testCase)
            import opencossan.common.inputs.random.UniformDiscreteRandomVariable
            random = UniformDiscreteRandomVariable.fromMeanAndStd('mean',7.5,'std',1.707825127659933);
            testCase.verifyEqual(random.Bounds(1), 5, 'AbsTol', 0.01);
            testCase.verifyEqual(random.Bounds(2), 10, 'RelTol', 0.01);
        end
        
        %% get.Std
        function getStdShouldCalculateStd(testCase)
            random = opencossan.common.inputs.random.UniformDiscreteRandomVariable('bounds',[0;10]);
            [~,Nvar] = unidstat(10 - 0 + 1);
            testStd  = sqrt(Nvar);
            testCase.verifyEqual(random.Std, testStd);
        end
        
        %% get.Mean
        function getMeanShouldCalculateMean(testCase)
            random = opencossan.common.inputs.random.UniformDiscreteRandomVariable('bounds',[0;10]);
            [Nmean,~] = unidstat(10 - 0 + 1);
            testMean = Nmean + 0 - 1;
            testCase.verifyEqual(random.Mean, testMean);   
        end
        
        %% modify bounds
        function modifyBounds(testCase)
            random = opencossan.common.inputs.random.UniformDiscreteRandomVariable('bounds',[0;10]);
            random.Bounds = [2;11];
            testCase.verifyEqual(random.Bounds(2), 11);
            testCase.verifyEqual(random.Bounds(1), 2);
        end
        
         %% sample
        function SampleEmpty(testCase)
            random = opencossan.common.inputs.random.UniformDiscreteRandomVariable('bounds',[0;10]);
            value = random.sample();
            testCase.verifySize(value, [1,1]);
        end
        
        function SampleOnlyM(testCase)
            random = opencossan.common.inputs.random.UniformDiscreteRandomVariable('bounds',[0;10]);
            value = random.sample(2);
            testCase.verifySize(value, [2,1]);
        end
        
        function SampleWithMAndN(testCase)
            random = opencossan.common.inputs.random.UniformDiscreteRandomVariable('bounds',[0;10]);
            value = random.sample([2 2]);
            testCase.verifySize(value, [2,2]);
        end
        
        %% map2physical
        function map2physical(testCase)
            random = opencossan.common.inputs.random.UniformDiscreteRandomVariable('bounds',[0;10]);
            VX = random.map2physical(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        
        %% cdf2physical
        function cdf2physical(testCase)
            random = opencossan.common.inputs.random.UniformDiscreteRandomVariable('bounds',[0;10]);
            VX = random.cdf2physical(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        
        %% map2stdnorm
        function map2stdnorm(testCase)
            random = opencossan.common.inputs.random.UniformDiscreteRandomVariable('bounds',[0;10]);
            VX = random.map2stdnorm(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        
        %% physical2cdf
        function physical2cdf(testCase)
            random = opencossan.common.inputs.random.UniformDiscreteRandomVariable('bounds',[0;10]);
            VX = random.physical2cdf(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        
        %% evalpdf
        function evalpdf(testCase)
            random = opencossan.common.inputs.random.UniformDiscreteRandomVariable('bounds',[0;10]);
            VX = random.evalpdf(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        
        %% fit
        function fitShouldThrowException(testCase)
            import opencossan.common.inputs.random.UniformDiscreteRandomVariable
            testCase.verifyError(@() UniformDiscreteRandomVariable.fit(),...
                'UniformDiscreteRandomVariable:UnsupportedOperation');
        end
    end
end


