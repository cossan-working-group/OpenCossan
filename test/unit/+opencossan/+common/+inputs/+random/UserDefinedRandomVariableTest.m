classdef UserDefinedRandomVariableTest < matlab.unittest.TestCase
    %NORMALRANDOMVARIABLETEST Unit tests for the class
    % opencossan.common.inputs.random.RandomVariable
    % See also: opencossan.common.inputs.random.RandomVariable
    
    %{
    This file is part of OpenCossan <https://cossan.co.uk>.
    Copyright (C) 2006-2019 COSSAN WORKING GROUP

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
    
    properties
        support;
        pdf;
        cdf;
        data;
    end
    
    methods (TestMethodSetup)
        function setup(testCase)
            testCase.support = -5:0.01:5;
            testCase.pdf = normpdf(testCase.support);
            testCase.cdf = normcdf(testCase.support);
            testCase.data = randn(1,1000);
            opencossan.OpenCossan.resetRandomNumberGenerator(51124);
        end
    end
    
    methods (Test)
        %% Constructor
        function constructorEmpty(testCase)
            import opencossan.common.inputs.random.UserDefinedRandomVariable;
            testCase.verifyClass(UserDefinedRandomVariable(),...
                'opencossan.common.inputs.random.UserDefinedRandomVariable');
        end
        
        function constructorDataAndCdf(testCase)
            import opencossan.common.inputs.random.UserDefinedRandomVariable;
            testCase.verifyError(@() UserDefinedRandomVariable('data',testCase.data,'cdf',testCase.cdf),...
                'UserDefinedRandomVariable:UnambiguousArguments');
        end
        
        function constructorDataAndPdf(testCase)
            import opencossan.common.inputs.random.UserDefinedRandomVariable;
            testCase.verifyError(@() UserDefinedRandomVariable('data',testCase.data,'pdf',testCase.pdf),...
                'UserDefinedRandomVariable:UnambiguousArguments');
        end
        
        function constructorPdfAndCdf(testCase)
            import opencossan.common.inputs.random.UserDefinedRandomVariable;
            testCase.verifyError(@() UserDefinedRandomVariable('pdf',testCase.pdf,'cdf',testCase.cdf),...
                'UserDefinedRandomVariable:UnambiguousArguments');
        end
        
        %% Contructor using data
        
        function constructorFullSamples(testCase)
            random = opencossan.common.inputs.random.UserDefinedRandomVariable('data',testCase.data,...
                'Description', "Samples Test Description");
            testCase.assertClass(random,'opencossan.common.inputs.random.UserDefinedRandomVariable');
            testCase.verifyEqual(random.data,testCase.data);
            testCase.verifyEqual(random.Description, "Samples Test Description");
        end
        
        function chiTestData(testCase)
             random = opencossan.common.inputs.random.UserDefinedRandomVariable('data',testCase.data,...
                'Description', "Samples Test Description");
            
            samples = random.sample(500);
            testCase.verifyEqual(chi2gof(samples),0);
        end
        
        %% Constructor using pdf
        
        function constructorFullPdf(testCase)
            random = opencossan.common.inputs.random.UserDefinedRandomVariable('pdf',testCase.pdf,...
                'support',testCase.support,'Description', "pdf Test Description");
            testCase.assertClass(random,'opencossan.common.inputs.random.UserDefinedRandomVariable');
            testCase.verifyEqual(random.pdf, testCase.pdf);
            testCase.verifyEqual(random.support, testCase.support);
            testCase.verifyEqual(random.Description, "pdf Test Description");
        end
        
        function constructorPdfAndNoSupport(testCase)
            import opencossan.common.inputs.random.UserDefinedRandomVariable;
            testCase.verifyError(@() UserDefinedRandomVariable('pdf',testCase.pdf),...
                'UserDefinedRandomVariable:NoSupport');
        end
        
        function constructorPdfandSupportUnequal(testCase)
            import opencossan.common.inputs.random.UserDefinedRandomVariable;
            testCase.verifyError(@() UserDefinedRandomVariable('pdf',testCase.pdf,'support',-5:0.1:5),...
                'UserDefinedRandomVariable:Pdf:supportLengthsUnequal');
        end
        
        function constructorInvalidPdf(testCase)
            import opencossan.common.inputs.random.UserDefinedRandomVariable;
            testCase.verifyError(@() UserDefinedRandomVariable('pdf',5 .* testCase.pdf,'support',testCase.support),...
                'UserDefinedRandomVariable:PdfError');
        end
        
        function constructorSupportMonotonicWithPdf(testCase)
            import opencossan.common.inputs.random.UserDefinedRandomVariable;
            testCase.verifyError(@() UserDefinedRandomVariable('pdf',normpdf([0,1,2]),'support',[1,0,2]),...
                'UserDefinedRandomVariable:SupportError');
        end
        
        function chiTestPdf(testCase)
             random = opencossan.common.inputs.random.UserDefinedRandomVariable('pdf',testCase.pdf,...
                'support',testCase.support);
            
            samples = random.sample(500);
            testCase.verifyEqual(chi2gof(samples),0);
        end
        
        %% Constructor using cdf
        
        function constructorFullCdf(testCase)
            random = opencossan.common.inputs.random.UserDefinedRandomVariable('cdf',testCase.cdf,...
                'support',testCase.support,'Description', "cdf Test Description");
            testCase.assertClass(random,'opencossan.common.inputs.random.UserDefinedRandomVariable');
            testCase.verifyEqual(random.cdf, testCase.cdf);
            testCase.verifyEqual(random.support, testCase.support);
            testCase.verifyEqual(random.Description, "cdf Test Description");
        end
        
        function constructorCdfAndNoSupport(testCase)
            import opencossan.common.inputs.random.UserDefinedRandomVariable;
            testCase.verifyError(@() UserDefinedRandomVariable('cdf',testCase.cdf),...
                'UserDefinedRandomVariable:NoSupport');
        end
        
        function constructorCdfandSupportUnequal(testCase)
            import opencossan.common.inputs.random.UserDefinedRandomVariable;
            testCase.verifyError(@() UserDefinedRandomVariable('cdf',testCase.cdf,'support',-5:0.1:5),...
                'UserDefinedRandomVariable:Cdf:supportLengthsUnequal');
        end
        
        function constructorCdfMonotonic(testCase)
            import opencossan.common.inputs.random.UserDefinedRandomVariable;
            testCase.verifyError(@() UserDefinedRandomVariable('cdf',[0.5,0,1],'support',[0,1,2]),...
                'UserDefinedRandomVariable:CdfError');
        end
        
        function constructorSupportMonotonicWithCdf(testCase)
            import opencossan.common.inputs.random.UserDefinedRandomVariable;
            testCase.verifyError(@() UserDefinedRandomVariable('cdf',[0,0.5,1],'support',[1,0,2]),...
                'UserDefinedRandomVariable:SupportError');
        end
        
        function chiTestCdf(testCase)
             random = opencossan.common.inputs.random.UserDefinedRandomVariable('cdf',testCase.cdf,...
                'support',testCase.support);
            
            samples = random.sample(500);
            testCase.verifyEqual(chi2gof(samples),0);
        end
        
        %% fromMeanAndStd
        function fromMeanAndStdShouldThrowException(testCase)
            import opencossan.common.inputs.random.UserDefinedRandomVariable
            testCase.verifyError(@() UserDefinedRandomVariable.fromMeanAndStd(),...
                'UserDefinedRandomVariable:UnsupportedOperation');
        end
        
        %% get.Std
        function getStdShouldCalculateStd(testCase)
            random = opencossan.common.inputs.random.UserDefinedRandomVariable('data',testCase.data);
            testCase.verifyEqual(random.Std, std(testCase.data));
        end
        
        %% get.Mean
        function getMeanShouldCalculateMean(testCase)
            random = opencossan.common.inputs.random.UserDefinedRandomVariable('data',testCase.data);
            testCase.verifyEqual(random.Mean, mean(testCase.data));
        end
        
        %% sample
        function SampleEmpty(testCase)
            random = opencossan.common.inputs.random.UserDefinedRandomVariable('data',testCase.data);
            value = random.sample();
            testCase.verifySize(value, [1,1]);
        end
        
        function SampleOnlyM(testCase)
            random = opencossan.common.inputs.random.UserDefinedRandomVariable('data',testCase.data);
            value = random.sample(2);
            testCase.verifySize(value, [2,1]);
        end
        
        function SampleWithMAndN(testCase)
            random = opencossan.common.inputs.random.UserDefinedRandomVariable('data',testCase.data);
            value = random.sample([2 2]);
            testCase.verifySize(value, [2,2]);
        end
        
        %% map2physical
        function map2physical(testCase)
            random = opencossan.common.inputs.random.UserDefinedRandomVariable('data',testCase.data);
            VX = random.map2physical(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        
        %% cdf2physical
        function cdf2physical(testCase)
            random = opencossan.common.inputs.random.UserDefinedRandomVariable('data',testCase.data);
            VX = random.cdf2physical(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        
        %% map2stdnorm
        function map2stdnorm(testCase)
            random = opencossan.common.inputs.random.UserDefinedRandomVariable('data',testCase.data);
            VX = random.map2stdnorm(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        
        %% physical2cdf
        function physical2cdf(testCase)
            random = opencossan.common.inputs.random.UserDefinedRandomVariable('data',testCase.data);
            VX = random.physical2cdf(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        
        %% evalpdf
        function evalpdf(testCase)
            random = opencossan.common.inputs.random.UserDefinedRandomVariable('data',testCase.data);
            VX = random.evalpdf(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        
        %% fit
        function fit(testCase)
            random = opencossan.common.inputs.random.UserDefinedRandomVariable('data',testCase.data);
            testCase.verifyError(@() random.fit(),...
                'UserDefinedRandomVariable:UnsupportedOperation');
        end
    end
end


