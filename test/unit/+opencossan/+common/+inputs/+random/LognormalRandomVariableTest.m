classdef LognormalRandomVariableTest < matlab.unittest.TestCase
    %LOGNORMALRANDOMVARIABLETEST Unit tests for the class
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
            random = opencossan.common.inputs.random.LognormalRandomVariable();
            testCase.assertClass(random,'opencossan.common.inputs.random.LognormalRandomVariable');
        end
        
        function constructorFull(testCase)
            random = opencossan.common.inputs.random.LognormalRandomVariable('mu',1,'sigma',0.5,...
                'Description', "Test Description");
            testCase.verifyEqual(random.Mu, 1);
            testCase.verifyEqual(random.Sigma, 0.5);
            testCase.verifyEqual(random.Description, "Test Description");
        end
        
        %% fromMeanAndStd
        function fromMeanAndStdShouldSetParameters(testCase)
            import opencossan.common.inputs.random.LognormalRandomVariable
            random = LognormalRandomVariable.fromMeanAndStd('mean',80,'std',15);
            testCase.verifyEqual(random.Mu,4.36475,'RelTol',0.1);
            testCase.verifyEqual(random.Sigma,0.18588,'RelTol',0.1);
        end
        
        %% get.Std
        function getStdShouldCalculateStd(testCase)
            random = opencossan.common.inputs.random.LognormalRandomVariable('mu',1,'sigma',0.5);
            [~, testVar_rv] =  lognstat(1, 0.5);
            testStd  = sqrt(testVar_rv);
            testCase.verifyEqual(random.Std, testStd);
        end
        
        %% get.Mean
        function getMeanShouldCalculateMean(testCase)
            random = opencossan.common.inputs.random.LognormalRandomVariable('mu',1,'sigma',0.5);
            [testMean, ~] =lognstat(1, 0.5);
            testCase.verifyEqual(random.Mean, testMean);   
        end
        
         %% sample
        function SampleEmpty(testCase)
            random = opencossan.common.inputs.random.LognormalRandomVariable('mu',1,'sigma',0.5);
            value = random.sample();
            testCase.verifySize(value, [1,1]);
        end
        
        function SampleOnlyM(testCase)
            random = opencossan.common.inputs.random.LognormalRandomVariable('mu',1,'sigma',0.5);
            value = random.sample(2);
            testCase.verifySize(value, [2,1]);
        end
        
        function SampleWithMAndN(testCase)
            random = opencossan.common.inputs.random.LognormalRandomVariable('mu',1,'sigma',0.5);
            value = random.sample([2 2]);
            testCase.verifySize(value, [2,2]);
        end
        
        %% map2physical
        function map2physical(testCase)
            random = opencossan.common.inputs.random.LognormalRandomVariable('mu',1,'sigma',0.5);
            VX = random.map2physical(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        
        %% cdf2physical
        function cdf2physical(testCase)
            random = opencossan.common.inputs.random.LognormalRandomVariable('mu',1,'sigma',0.5);
            VX = random.cdf2physical(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        
        %% map2stdnorm
        function map2stdnorm(testCase)
            random = opencossan.common.inputs.random.LognormalRandomVariable('mu',1,'sigma',0.5);
            VX = random.map2stdnorm(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        
        %% physical2cdf
        function physical2cdf(testCase)
            random = opencossan.common.inputs.random.LognormalRandomVariable('mu',1,'sigma',0.5);
            VX = random.physical2cdf(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        
        %% evalpdf
        function evalpdf(testCase)
            random = opencossan.common.inputs.random.LognormalRandomVariable('mu',1,'sigma',0.5);
            VX = random.evalpdf(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        
        %% fit
        function fit(testCase)
            random = opencossan.common.inputs.random.LognormalRandomVariable('mu',1,'sigma',0.5);
            samples = random.sample(10000);
            phat = opencossan.common.inputs.random.LognormalRandomVariable.fit(...
                'data',samples,'frequency',[],'censoring',[],'alpha',0.05);
            testCase.verifyEqual(phat.Mu,1.0,'RelTol',0.2);
            testCase.verifyEqual(phat.Sigma,0.5,'RelTol',0.2);
        end
        
        function fitWithBadData(testCase)
            data = exprnd(0.1,[1000 1]);
            testCase.verifyWarning(@() opencossan.common.inputs.random.LognormalRandomVariable.fit(...
                'data',data),'openCOSSAN:RandomVariable:Lognormal:fit');
        end
        
        %qqplot
        function qqplotShouldReturnFigure(testCase)
            random = opencossan.common.inputs.random.LognormalRandomVariable('mu',1,'sigma',0.5);
            data = random.sample(10000);
            [~, f] = opencossan.common.inputs.random.LognormalRandomVariable.fit(...
                'data',data,'frequency',[],'censoring',[],'alpha',0.05,'qqplot',true);
            testCase.assertClass(f,'matlab.ui.Figure');
            close(f);
        end
    end
end


