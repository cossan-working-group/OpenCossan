classdef BetaRandomVariableTest < matlab.unittest.TestCase
    %BETARANDOMVARIABLETEST Unit tests for the class
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
            random = opencossan.common.inputs.random.BetaRandomVariable();
            testCase.assertClass(random,'opencossan.common.inputs.random.BetaRandomVariable');
        end
        
        function constructorFull(testCase)
            random = opencossan.common.inputs.random.BetaRandomVariable(...
                'alpha',1.5,'beta',2.5,'Description', "Test Description");
            testCase.verifyEqual(random.Alpha, 1.5);
            testCase.verifyEqual(random.Beta, 2.5);
            testCase.verifyEqual(random.Description, "Test Description");
        end
        
        function constructorInvalidProperties(testCase)
            import opencossan.common.inputs.random.BetaRandomVariable
            testCase.verifyError(@() BetaRandomVariable('alpha',1.5,'beta',-0.5), ...
                'MATLAB:validators:mustBePositive');
            testCase.verifyError(@() BetaRandomVariable('alpha',-0.5,'beta',2.5), ...
                'MATLAB:validators:mustBePositive');
        end
        
        %% fromMeanAndStd
        function fromMeanAndStdShouldSetProperties(testCase)
            import opencossan.common.inputs.random.BetaRandomVariable
            rv1 = BetaRandomVariable('alpha',1.5,'beta',2.5,...
                'Description', "Test Description");
            rv2 = BetaRandomVariable.fromMeanAndStd('mean',rv1.Mean,'std',rv1.Std,...
                'Description', "Test Description");
            testCase.verifyEqual(rv2.Alpha, 1.5, 'RelTol', 0.01);
            testCase.verifyEqual(rv2.Beta, 2.5, 'RelTol', 0.01);
        end
                
        %% get.Std
        function getStdShouldCalculateStd(testCase)
            random = opencossan.common.inputs.random.BetaRandomVariable('alpha',1.5,'beta',2.5);
            [~, testVar_rv] =  betastat(1.5, 2.5);
            testStd  = sqrt(testVar_rv);
            testCase.verifyEqual(random.Std, testStd);
        end
        
        %% get.Mean
        function getMeanShouldCalculateMean(testCase)
            random = opencossan.common.inputs.random.BetaRandomVariable('alpha',1.5,'beta',2.5);
            [testMean, ~] =  betastat(1.5, 2.5);
            testCase.verifyEqual(random.Mean, testMean);
        end
        
        %% sample
        function SampleEmpty(testCase)
            random = opencossan.common.inputs.random.BetaRandomVariable('alpha',1.5,'beta',2.5);
            value = random.sample();
            testCase.verifySize(value, [1,1]);
        end
        
        function SampleOnlyM(testCase)
            random = opencossan.common.inputs.random.BetaRandomVariable('alpha',1.5,'beta',2.5);
            value = random.sample(2);
            testCase.verifySize(value, [2,1]);
        end
        
        function SampleWithMAndN(testCase)
            random = opencossan.common.inputs.random.BetaRandomVariable('alpha',1.5,'beta',2.5);
            value = random.sample([2 2]);
            testCase.verifySize(value, [2,2]);
        end
        
        %% map2physical
        function map2physical(testCase)
            random = opencossan.common.inputs.random.BetaRandomVariable('alpha',1.5,'beta',2.5);
            VX = random.map2physical(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        
        %% cdf2physical
        function cdf2physical(testCase)
            random = opencossan.common.inputs.random.BetaRandomVariable('alpha',1.5,'beta',2.5);
            VX = random.cdf2physical(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        
        %% map2stdnorm
        function map2stdnorm(testCase)
            random = opencossan.common.inputs.random.BetaRandomVariable('alpha',1.5,'beta',2.5);
            VX = random.map2stdnorm(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        
        %% physical2cdf
        function physical2cdf(testCase)
            random = opencossan.common.inputs.random.BetaRandomVariable('alpha',1.5,'beta',2.5);
            VX = random.physical2cdf(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        
        %% evalpdf
        function evalpdf(testCase)
            random = opencossan.common.inputs.random.BetaRandomVariable('alpha',1.5,'beta',2.5);
            VX = random.evalpdf(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        
        %% fit
        function fit(testCase)
            phat = opencossan.common.inputs.random.BetaRandomVariable.fit(...
                'data',betarnd(1.5,2.5,[10000 1]),'frequency',[],'censoring',[],'alpha',0.05);
            testCase.verifyEqual(phat.Alpha,1.5,'RelTol',0.2);
            testCase.verifyEqual(phat.Beta,2.5,'RelTol',0.2);
        end
        
        function fitWithBadData(testCase)
            data = binornd(1.0,0.9,[1000 1]);
            data(data < 0.0) = 0.01;
            data(data > 1.0) = 0.99;
            testCase.verifyWarning(@() opencossan.common.inputs.random.BetaRandomVariable.fit(...
                'data',data),'openCOSSAN:RandomVariable:beta:fit');
        end
        
        % qqplot
        function qqplotShouldReturnFigure(testCase)
            data = betarnd(1.5,2.5,[10000 1]);
            [~, f] = opencossan.common.inputs.random.BetaRandomVariable.fit(...
                'data',data,'frequency',[],'censoring',[],'alpha',0.05);
            testCase.assertClass(f,'matlab.ui.Figure');
            close(f);
        end
    end
end

