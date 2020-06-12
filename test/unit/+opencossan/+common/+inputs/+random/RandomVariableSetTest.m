classdef RandomVariableSetTest < matlab.unittest.TestCase
    %RANDOMVARIABLESETTEST Summary of this class goes here
    
    % See also: opencossan.common.inputs.random.RandomVariableSet
    
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
    
    properties
        X1;
        X2;
    end
    
    methods (TestMethodSetup)
        function constructRandomVariables(testCase)
            testCase.X1 = opencossan.common.inputs.random.BinomialRandomVariable();
            testCase.X2 = opencossan.common.inputs.random.ExponentialRandomVariable('lambda', 0.5);
        end
    end
    methods (Test)
        
        %% Constructor
        function constructorEmpty(testCase)
            rvs = opencossan.common.inputs.random.RandomVariableSet();
            testCase.assertClass(rvs,'opencossan.common.inputs.random.RandomVariableSet');
        end
        
        function constructorFull(testCase)
            rvset = opencossan.common.inputs.random.RandomVariableSet(...
                'members',[testCase.X1, testCase.X2],'names',["X1" "X2"],...
                'Description','Test Description');
            testCase.verifyEqual(rvset.Names,["X1", "X2"]);
            testCase.verifyEqual(rvset.Members,...
                [testCase.X1, testCase.X2]);
            testCase.verifyEqual(rvset.Description, "Test Description");
            testCase.verifyEqual(rvset.Nrv, 2);
        end
        
        function constructorWithCorrelation(testCase)
            corr = [1 -0.5; -0.5 1];
            rvset = opencossan.common.inputs.random.RandomVariableSet(...
                'members', [testCase.X1, testCase.X2], 'names',...
                ["X1" "X2"], 'correlation', corr);
            testCase.verifyEqual(corr, rvset.Correlation);
            testCase.verifyEqual([0.25 -0.5; -0.5 4.0], rvset.Covariance);
        end
        
        function constructorWithCovariance(testCase)
            cov = [0.25 -0.5; -0.5 4.0];
            rvset = opencossan.common.inputs.random.RandomVariableSet(...
                'members', [testCase.X1, testCase.X2], 'names',...
                ["X1" "X2"], 'covariance', cov);
            testCase.verifyEqual([1 -0.5; -0.5 1], rvset.Correlation);
            testCase.verifyEqual(cov, rvset.Covariance);
        end
        
        function constructorWithNoncompleteCorrelationMatrix(testCase)
            corr = [1 0; 0.5 1];
            rvset = opencossan.common.inputs.random.RandomVariableSet(...
                'members', [testCase.X1,testCase.X2], 'names', ...
                ["X1","X2"], 'Correlation', corr);
            testCase.verifyEqual([1 0.5; 0.5 1], rvset.Correlation);
        end
        
        function constructorWithNoncompleteCovarianceMatrix(testCase)
            cov = [0.04 0.02; 0 0.04];
            rvset = opencossan.common.inputs.random.RandomVariableSet(...
                'members', [testCase.X1, testCase.X2], 'names', ...
                ["X1","X2"], 'Covariance', cov);
            testCase.verifyEqual([0.04 0.02; 0.02 0.04], rvset.Covariance);
        end
        
        %% fromIidRandomVariables
        function fromIidRandomVariablesShouldConstructIndependentRvSet(testCase)
            import opencossan.common.inputs.random.RandomVariableSet
            rvset = RandomVariableSet.fromIidRandomVariables(testCase.X2,3);
            testCase.verifyEqual(3, rvset.Nrv);
            testCase.verifyEqual(eye(3),rvset.Correlation);
            testCase.verifyEqual(["RV_1" "RV_2" "RV_3"], rvset.Names);
        end
        
        %% get-Methods
        function getMean(testCase)
            random = opencossan.common.inputs.random.RandomVariableSet(...
                'members', [testCase.X1, testCase.X2], 'names', ...
                ["X1","X2"]);
            testCase.verifyEqual([0.5; 2],random.getMean(),'RelTol',0.01);
        end
        
        function getStd(testCase)
            random = opencossan.common.inputs.random.RandomVariableSet(...
                'members', [testCase.X1, testCase.X2], 'names', ...
                ["X1","X2"]);
            testCase.verifyEqual([0.5;2],random.getStd(),'RelTol',0.01);
        end
        
        function getCoV(testCase)
            random = opencossan.common.inputs.random.RandomVariableSet(...
                'members', [testCase.X1, testCase.X2], 'names', ["X1","X2"]);
            testCase.verifyEqual([1;1],random.getCoV(),'RelTol',0.01);
        end
        
        function getBounds(testCase)
            random = opencossan.common.inputs.random.RandomVariableSet(...
                'members', [testCase.X1, testCase.X2], 'names', ["X1","X2"]);
            testCase.verifyEqual([0 Inf;0 Inf],random.getBounds(),'RelTol',0.01);
        end
        
        function getRVInfo(testCase)
            random = opencossan.common.inputs.random.RandomVariableSet(...
                'members', [testCase.X1, testCase.X2], 'names', ["X1","X2"]);
            testCase.verifySize(random.getRVInfo(), [2,5]);
        end
        
        %% sample
        function sampleShouldReturnSampleObject(testCase)
            rvs = opencossan.common.inputs.random.RandomVariableSet(...
                'members', [testCase.X1, testCase.X2], 'names', ...
                ["X1","X2"]);
            samples = rvs.sample(2);
            testCase.verifyEqual(2,height(samples));
        end
        
        function sampleWithCorrelationShouldReturnSampleObject(testCase)
            corr = [1 0.5; 0.5 1];
            rvs = opencossan.common.inputs.random.RandomVariableSet(...
                'members', [testCase.X2, testCase.X2], 'names', ...
                ["X1","X2"], 'Correlation', corr);
            samples = rvs.sample(10000);
            testCase.verifyEqual(10000,height(samples));
            testCase.verifyEqual(corr, ...
                corrcoef(samples{:,:}),'RelTol',0.1);
        end
        
        function cdf2physical(testCase)
            rvs = opencossan.common.inputs.random.RandomVariableSet(...
                'members', [testCase.X1, testCase.X2], 'names', ...
                ["X1" "X2"]);
            mu = rvs.cdf2physical(rand(10,2));
            testCase.verifySize(mu,[10 2]);
        end
        
        function cdf2stdnorm(testCase)
            rvs = opencossan.common.inputs.random.RandomVariableSet(...
                'members', [testCase.X1, testCase.X2], 'names', ...
                ["X1" "X2"]);
            mu = rvs.cdf2stdnorm(rand(10,2));
            testCase.verifySize(mu,[10 2]);
        end
        
        function map2physical(testCase)
            rvs = opencossan.common.inputs.random.RandomVariableSet(...
                'members', [testCase.X1, testCase.X2], 'names', ...
                ["X1" "X2"]);
            mu = rvs.map2physical(rand(10,2));
            testCase.verifySize(mu,[10 2]);
        end
        
        function map2stdnorm(testCase)
            rvs = opencossan.common.inputs.random.RandomVariableSet(...
                'members', [testCase.X1, testCase.X2], 'names', ["X1" "X2"]);
            mu = rvs.map2stdnorm(rand(10,2));
            testCase.verifySize(mu,[10 2]);
        end
        
        function physical2cdf(testCase)
            rvs = opencossan.common.inputs.random.RandomVariableSet(...
                'members', [testCase.X1, testCase.X2], 'names', ["X1" "X2"]);
            mu  = rvs.physical2cdf(rand(10,2));
            testCase.verifySize(mu,[10 2]);
        end
        
        function stdnorm2cdf(testCase)
            rvs = opencossan.common.inputs.random.RandomVariableSet(...
                'members', [testCase.X1, testCase.X2], 'names', ["X1" "X2"]);
            mu  = rvs.stdnorm2cdf(rand(10,2));
            testCase.verifySize(mu,[10 2]);
        end
        
        function pdfRatio(testCase)
            rvs = opencossan.common.inputs.random.RandomVariableSet(...
                'members', [testCase.X1, testCase.X2], 'names', ["X1" "X2"]);
            mu = rvs.pdfRatio('Denominator',eye(2),'Numerator',eye(2));
            testCase.verifySize(mu,[2 1]);
        end
        
        function evalpdf(testCase)
            rvs = opencossan.common.inputs.random.RandomVariableSet(...
                'members', [testCase.X1, testCase.X2], 'names', ["X1" "X2"]);
            pdf = rvs.pdf(rvs.sample(10));
            testCase.verifySize(pdf,[10 1]);
        end
    end
end



