classdef GammaRandomVariableTest < matlab.unittest.TestCase
    %GAMMARANDOMVARIABLETEST Unit tests for the class
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
            random = opencossan.common.inputs.random.GammaRandomVariable();
            testCase.assertClass(random,'opencossan.common.inputs.random.GammaRandomVariable');
        end
        
        function constructorFull(testCase)
            random = opencossan.common.inputs.random.GammaRandomVariable('k',0.1,'theta',0.1,...
                'Description', "Test Description");
            testCase.verifyEqual(random.K, 0.1);
            testCase.verifyEqual(random.Theta, 0.1);
            testCase.verifyEqual(random.Description, "Test Description");
        end
        
        %% fromMeanAndStd
        function constructorFullWithMeanAndStd(testCase)
            import opencossan.common.inputs.random.GammaRandomVariable
            rv1 = GammaRandomVariable('k',0.1,'theta',0.1,...
                'Description', "Test Description");
            rv2 = GammaRandomVariable.fromMeanAndStd('mean',rv1.Mean,'std',rv1.Std,...
                'Description', "Test Description");
            testCase.verifyEqual(rv2.K, 0.1);
            testCase.verifyEqual(rv2.Theta, 0.1);
        end
        
        %% get.Std
        function getStdShouldCalculateStd(testCase)
            random = opencossan.common.inputs.random.GammaRandomVariable('k',0.1,'theta',0.1);
            [~, testVar_rv] =  gamstat(0.1, 0.1);
            testStd  = sqrt(testVar_rv);
            testCase.verifyEqual(random.Std, testStd);
        end
        
        %% get.Mean
        function getMeanShouldCalculateMean(testCase)
            random = opencossan.common.inputs.random.GammaRandomVariable('k',0.1,'theta',0.1);
            [testMean, ~] =  gamstat(0.1, 0.1);
            testCase.verifyEqual(random.Mean, testMean);   
        end
        
         %% sample
        function SampleEmpty(testCase)
            random = opencossan.common.inputs.random.GammaRandomVariable('k',0.1,'theta',0.1);
            value = random.sample();
            testCase.verifySize(value, [1,1]);
        end
        
        function SampleOnlyM(testCase)
            random = opencossan.common.inputs.random.GammaRandomVariable('k',0.1,'theta',0.1);
            value = random.sample(2);
            testCase.verifySize(value, [2,1]);
        end
        
        function SampleWithMAndN(testCase)
            random = opencossan.common.inputs.random.GammaRandomVariable('k',0.1,'theta',0.1);
            value = random.sample([2 2]);
            testCase.verifySize(value, [2,2]);
        end
        
        %% map2physical
        function map2physical(testCase)
            random = opencossan.common.inputs.random.GammaRandomVariable('k',0.1,'theta',0.1);
            VX = random.map2physical(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        
        %% cdf2physical
        function cdf2physical(testCase)
            random = opencossan.common.inputs.random.GammaRandomVariable('k',0.1,'theta',0.1);
            VX = random.cdf2physical(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        
        %% map2stdnorm
        function map2stdnorm(testCase)
            random = opencossan.common.inputs.random.GammaRandomVariable('k',0.1,'theta',0.1);
            VX = random.map2stdnorm(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        
        %% physical2cdf
        function physical2cdf(testCase)
            random = opencossan.common.inputs.random.GammaRandomVariable('k',0.1,'theta',0.1);
            VX = random.physical2cdf(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        %% evalpdf
        function evalpfg(testCase)
            random = opencossan.common.inputs.random.GammaRandomVariable('k',0.1,'theta',0.1);
            VX = random.evalpdf(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        
        %% fit
        function fit(testCase)
            phat = opencossan.common.inputs.random.GammaRandomVariable.fit(...
                'data',gamrnd(2.5,1.5,[10000 1]),'frequency',[],'censoring',[],'alpha',0.05);
            testCase.verifyEqual(phat.K,2.5,'RelTol',0.2);
            testCase.verifyEqual(phat.Theta,1.5,'RelTol',0.2);
        end
        
        function fitWithBadData(testCase)
            data = normrnd(0.5,0.1,[10000 1]);
            testCase.verifyWarning(@() opencossan.common.inputs.random.GammaRandomVariable.fit(...
                'data',data),'openCOSSAN:RandomVariable:Gamma:fit');
        end
        
        %qqplot
        function qqplotShouldReturnFigure(testCase)
            data = gamrnd(2.5,1.5,[10000 1]);
            [~, f] = opencossan.common.inputs.random.GammaRandomVariable.fit(...
                'data',data,'frequency',[],'censoring',[],'alpha',0.05,'qqplot',true);
            testCase.assertClass(f,'matlab.ui.Figure');
            close(f);
        end
    end
end


