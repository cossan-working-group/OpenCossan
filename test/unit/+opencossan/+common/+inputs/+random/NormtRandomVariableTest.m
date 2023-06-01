classdef NormtRandomVariableTest < matlab.unittest.TestCase
    %NORMTRANDOMVARIABLETEST Unit tests for the class
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
            random = opencossan.common.inputs.random.NormtRandomVariable();
            testCase.assertClass(random,'opencossan.common.inputs.random.NormtRandomVariable');
        end
        
        function constructorFull(testCase)
            random = opencossan.common.inputs.random.NormtRandomVariable(...
                'mu',1.5,'sigma',0.5,'bounds',[1;2],'Description', "Test Description");
            testCase.verifyEqual(random.Mu, 1.5);
            testCase.verifyEqual(random.Sigma, 0.5);
            testCase.verifyEqual(random.Bounds, [1 2]);
            testCase.verifyEqual(random.Description, "Test Description");
        end
        
        %% fromMeanAndStd
        function fromMeanAndStdShouldThrowException(testCase)
            import opencossan.common.inputs.random.NormtRandomVariable;
            testCase.verifyError(@() NormtRandomVariable.fromMeanAndStd(),...
                'NormtRandomVariable:UnsupportedOperation');
        end
        
        %% get.Std
        function getStdShouldCalculateStd(testCase)
            random = opencossan.common.inputs.random.NormtRandomVariable(...
                'mu',2.5,'sigma',2,'bounds',[0 10]);
            testCase.verifyEqual(1.6753, random.Std, 'RelTol',0.1);
        end
        
        function getStdShouldCalculateStdWithInf(testCase)
            random = opencossan.common.inputs.random.NormtRandomVariable(...
                'mu',2.5,'sigma',2,'bounds',[0 Inf]);
            testCase.verifyEqual(1.6769, random.Std, 'RelTol',0.1);
        end
        
        function getStdShouldCalculateStdWithMinusInf(testCase)
            random = opencossan.common.inputs.random.NormtRandomVariable(...
                'mu',2.5,'sigma',2,'bounds',[-Inf 10]);
            testCase.verifyEqual(1.9987, random.Std, 'RelTol',0.1);
        end
        
        %% get.Mean
        function getMeanShouldCalculateMean(testCase)
            random = opencossan.common.inputs.random.NormtRandomVariable(...
                'mu',2.5,'sigma',2,'bounds',[0 10]);
            testCase.verifyEqual(2.9077, random.Mean, 'RelTol',0.1);
        end
        
        %% modify bounds
        function modifyBounds(testCase)
            random = opencossan.common.inputs.random.NormtRandomVariable(...
                'mu',1.5,'sigma',0.5,'bounds',[0.5;1]);
            random.Bounds = [2;10];
            testCase.verifyEqual(random.Bounds(2), 10);
            testCase.verifyEqual(random.Bounds(1), 2);
        end
        
        %% sample
        function SampleEmpty(testCase)
            random = opencossan.common.inputs.random.NormtRandomVariable('mu',1.5,'sigma',0.5,'bounds',[1;2]);
            value = random.sample();
            testCase.verifySize(value, [1,1]);
        end
        
        function SampleOnlyM(testCase)
            random = opencossan.common.inputs.random.NormtRandomVariable('mu',1.5,'sigma',0.5,'bounds',[1;2]);
            value = random.sample(2);
            testCase.verifySize(value, [2,1]);
        end
        
        function SampleWithMAndN(testCase)
            random = opencossan.common.inputs.random.NormtRandomVariable('mu',1.5,'sigma',0.5,'bounds',[1;2]);
            value = random.sample([2 2]);
            testCase.verifySize(value, [2,2]);
        end
        
        %% map2physical
        function map2physical(testCase)
            random = opencossan.common.inputs.random.NormtRandomVariable('mu',1.5,'sigma',0.5,'bounds',[1;2]);
            VX = random.map2physical(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        
        %% cdf2physical
        function cdf2physical(testCase)
            random = opencossan.common.inputs.random.NormtRandomVariable('mu',1.5,'sigma',0.5,'bounds',[1;2]);
            VX = random.cdf2physical(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        
        %% map2stdnorm
        function map2stdnorm(testCase)
            random = opencossan.common.inputs.random.NormtRandomVariable('mu',1.5,'sigma',0.5,'bounds',[0;2]);
            VX = random.map2stdnorm(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        function map2stdnormMinusInf(testCase)
            random = opencossan.common.inputs.random.NormtRandomVariable('mu',1.5,'sigma',0.5,'bounds',[1;2]);
            VX = random.map2stdnorm(rand(10));
            testCase.verifyEqual(VX,-Inf);
        end
        function map2stdnormInf(testCase)
            random = opencossan.common.inputs.random.NormtRandomVariable('mu',1.5,'sigma',0.5,'bounds',[-1;0]);
            VX = random.map2stdnorm(rand(10));
            testCase.verifyEqual(VX,Inf);
        end
        
        %% physical2cdf
        function physical2cdf(testCase)
            random = opencossan.common.inputs.random.NormtRandomVariable('mu',1.5,'sigma',0.5,'bounds',[0;2]);
            VX = random.physical2cdf(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        function physical2cdfShouldBe0(testCase)
            random = opencossan.common.inputs.random.NormtRandomVariable('mu',1.5,'sigma',0.5,'bounds',[1;2]);
            VX = random.physical2cdf(rand(10));
            testCase.verifyEqual(VX,0);
        end
        function physical2cdfShouldBe1(testCase)
            random = opencossan.common.inputs.random.NormtRandomVariable('mu',1.5,'sigma',0.5,'bounds',[-1;0]);
            VX = random.physical2cdf(rand(10));
            testCase.verifyEqual(VX,1);
        end
        
        %% evalpdf
        function evalpdf(testCase)
            random = opencossan.common.inputs.random.NormtRandomVariable('mu',1.5,'sigma',0.5,'bounds',[0;2]);
            VX = random.evalpdf(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        
        %% fit
        function fitShouldThrowException(testCase)
            import opencossan.common.inputs.random.NormtRandomVariable;
            testCase.verifyError(@() NormtRandomVariable.fit(),...
                'NormtRandomVariable:UnsupportedOperation');
        end
    end
end


