classdef GutenbergRichterRandomVariableTest < matlab.unittest.TestCase
    %GUTENBERGRICHTERRANDOMVARIABLETEST  Unit tests for the class
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
            random = opencossan.common.inputs.random.GutenbergRichterRandomVariable();
            testCase.assertClass(random,'opencossan.common.inputs.random.GutenbergRichterRandomVariable');
        end
        
        function constructorFull(testCase)
            random = opencossan.common.inputs.random.GutenbergRichterRandomVariable('b',0.7,'bounds',[0.5;1],...
                'Description', "Test Description");
            testCase.verifyEqual(random.Bounds, [0.5 1]);
            testCase.verifyEqual(random.B, 0.7);
            testCase.verifyEqual(random.Description, "Test Description");
        end
        
        %% fromMeanAndStd
        function fromMeanAndStdShouldThrowException(testCase)
            import opencossan.common.inputs.random.GutenbergRichterRandomVariable;
            testCase.verifyError(@() GutenbergRichterRandomVariable.fromMeanAndStd(),...
                'GutenbergRichterRandomVariable:UnsupportedOperation');
        end
        
        %% get.Std
        function getStdShouldCalculateStd(testCase)
            random = opencossan.common.inputs.random.GutenbergRichterRandomVariable('b',0.7,'bounds',[0.5;1]);
            testStd =  sqrt(exp(1)*(1)); % TODO Is this correct?
            testCase.verifyEqual(random.Std, testStd);
        end
        
        %% get.Mean
        function getMeanShouldCalculateMean(testCase)
            random = opencossan.common.inputs.random.GutenbergRichterRandomVariable('b',0.7,'bounds',[0.5;1]);
            b = 0.7*log(10);
            Den = (exp(-b*(0.5)) - exp(-b*(1)));
            testMean = 1/Den*(-(1*exp(-b*(1))-1*exp(-b*(0.5))) - 1/b*(exp(-b*(1))-exp(-b*(0.5))));
            testCase.verifyEqual(random.Mean, testMean);
        end
        
        %% sample
        function SampleEmpty(testCase)
            random = opencossan.common.inputs.random.GutenbergRichterRandomVariable('b',0.7,'bounds',[0.5;1]);
            value = random.sample();
            testCase.verifySize(value, [1,1]);
        end
        
        function SampleOnlyM(testCase)
            random = opencossan.common.inputs.random.GutenbergRichterRandomVariable('b',0.7,'bounds',[0.5;1]);
            value = random.sample(2);
            testCase.verifySize(value, [2,1]);
        end
        
        function SampleWithMAndN(testCase)
            random = opencossan.common.inputs.random.GutenbergRichterRandomVariable('b',0.7,'bounds',[0.5;1]);
            value = random.sample([2 2]);
            testCase.verifySize(value, [2,2]);
        end
        
        %% map2physical
        function map2physical(testCase)
            random = opencossan.common.inputs.random.GutenbergRichterRandomVariable('b',0.7,'bounds',[0.5;1]);
            VX = random.map2physical(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        
        %% cdf2physical
        function cdf2physical(testCase)
            random = opencossan.common.inputs.random.GutenbergRichterRandomVariable('b',0.7,'bounds',[0.5;1]);
            VX = random.cdf2physical(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        
        %% map2stdnorm
        function map2stdnorm(testCase)
            random = opencossan.common.inputs.random.GutenbergRichterRandomVariable('b',0.7,'bounds',[0.5;1]);
            VX = random.map2stdnorm(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        
        %% physical2cdf
        function physical2cdf(testCase)
            random = opencossan.common.inputs.random.GutenbergRichterRandomVariable('b',0.7,'bounds',[0.5;1]);
            VX = random.physical2cdf(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        
        %% evalpdf
        function evalpdf(testCase)
            random = opencossan.common.inputs.random.GutenbergRichterRandomVariable('b',0.7,'bounds',[0.5;1]);
            % evalpdf not implemented - error expected
            testCase.verifyError(@() random.evalpdf(rand(10)),...
                'GutenbergRichterRandomVariable:UnsupportedOperation');
        end
        
        %% fit
        function fit(testCase)
            import opencossan.common.inputs.random.GutenbergRichterRandomVariable
            testCase.verifyError(@() GutenbergRichterRandomVariable.fit(),...
                'GutenbergRichterRandomVariable:UnsupportedOperation');
        end
    end
end


