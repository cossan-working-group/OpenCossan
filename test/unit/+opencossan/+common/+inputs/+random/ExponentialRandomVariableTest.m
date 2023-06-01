classdef ExponentialRandomVariableTest < matlab.unittest.TestCase
    %EXPONANTIALRANDOMVARIABLETEST Unit tests for the class
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
            random = opencossan.common.inputs.random.ExponentialRandomVariable();
            testCase.assertClass(random,'opencossan.common.inputs.random.ExponentialRandomVariable');
        end
        
        function constructorFull(testCase)
            random = opencossan.common.inputs.random.ExponentialRandomVariable('lambda',1.5,...
                'Description',"Test Description");
            testCase.verifyEqual(random.Lambda,1.5);
            testCase.verifyEqual(random.Description,"Test Description");
        end
        
        %% fromMeanAndStd
        function fromMeanAndStdShouldThrowException(testCase)
            import opencossan.common.inputs.random.ExponentialRandomVariable;
            testCase.verifyError(@() ExponentialRandomVariable.fromMeanAndStd(),...
                'ExponentialRandomVariable:UnsupportedOperation');
        end
        
        %% get.Std
        function getStdShouldCalculateStd(testCase)
            random = opencossan.common.inputs.random.ExponentialRandomVariable('lambda', 1.5);
            testCase.verifyEqual(random.Std,1/1.5);
        end
        
        %% get.Mean
        function getMeanShouldCalculateMean(testCase)
            random = opencossan.common.inputs.random.ExponentialRandomVariable('lambda', 1.5);
            testCase.verifyEqual(random.Mean,1/1.5);
        end
        
        %% sample
        function SampleEmpty(testCase)
            random = opencossan.common.inputs.random.ExponentialRandomVariable('lambda', 1.5);
            value = random.sample();
            testCase.verifySize(value, [1,1]);
        end
        
        function SampleOnlyM(testCase)
            random = opencossan.common.inputs.random.ExponentialRandomVariable('lambda', 1.5);
            value = random.sample(2);
            testCase.verifySize(value, [2,1]);
        end
        
        function SampleWithMAndN(testCase)
            random = opencossan.common.inputs.random.ExponentialRandomVariable('lambda', 1.5);
            value = random.sample([2,2]);
            testCase.verifySize(value, [2,2]);
        end
        
        %% map2physical
        function map2physical(testCase)
            random = opencossan.common.inputs.random.ExponentialRandomVariable('lambda', 1.5);
            VX = random.map2physical(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        
        %% cdf2physical
        function cdf2physical(testCase)
            random = opencossan.common.inputs.random.ExponentialRandomVariable('lambda', 1.5);
            VX = random.cdf2physical(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        
        %% map2stdnorm
        function map2stdnorm(testCase)
            random = opencossan.common.inputs.random.ExponentialRandomVariable('lambda', 1.5);
            VX = random.map2stdnorm(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        
        %% physical2cdf
        function physical2cdf(testCase)
            random = opencossan.common.inputs.random.ExponentialRandomVariable('lambda', 1.5);
            VX = random.physical2cdf(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        %% evalpdf
        function evalpdf(testCase)
            random = opencossan.common.inputs.random.ExponentialRandomVariable('lambda', 1.5);
            VX = random.evalpdf(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        
        %% fit
        function fit(testCase)
            phat = opencossan.common.inputs.random.ExponentialRandomVariable.fit(...
                'data',exprnd(1.5,[10000 1]),'frequency',[],'censoring',[],'alpha',0.05);
            testCase.verifyEqual(phat.Mean,1.5,'RelTol',0.2);
        end
        
        function fitWithBadData(testCase)
            data = normrnd(0.5,0.1,[10000 1]);
            testCase.verifyWarning(@() opencossan.common.inputs.random.ExponentialRandomVariable.fit(...
                'data',data),'openCOSSAN:RandomVariable:Exponential:fit');
        end
        
        % qqplot
        function qqplotShouldReturnFigure(testCase)
            data = exprnd(1.5,[10000 1]);
            [~, f] = opencossan.common.inputs.random.ExponentialRandomVariable.fit(...
                'data',data,'frequency',[],'censoring',[],'alpha',0.05,'qqplot',true);
            testCase.assertClass(f,'matlab.ui.Figure');
            close(f);
        end
    end
end

