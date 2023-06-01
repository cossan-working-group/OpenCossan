classdef AnalysisTest < matlab.unittest.TestCase
    % ANALYSISTEST Unit tests for the class opencossan.common.Analysis
    % see http://cossan.co.uk/wiki/index.php/@Analysis
    %
    % See also: UNITTEST, ANALYSIS

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
    
    methods (TestMethodSetup)
        function resetAnalysis(~)
            opencossan.OpenCossan.setAnalysis();
        end
    end
    
    methods (TestClassTeardown)
        function finalAnalysisReset(~)
            opencossan.OpenCossan.setAnalysis();
        end
    end
    
    methods (Test)
        
        %% constructor
        function constructorEmpty(testCase)
            testCase.verifyClass(opencossan.OpenCossan.getAnalysis,...
                'opencossan.common.Analysis');
        end
        
        function callConstructorFailure(testCase)            
            testCase.verifyError(@()opencossan.common.Analysis,...
                     'MATLAB:class:MethodRestricted');
        end
        
        function callConstructorWithSeedAndAlgorithm(testCase)            
            opencossan.OpenCossan.setAnalysis('Seed',198756,...
                'RandomNumberGeneratorAlgorithm','mt19937ar');
            testCase.verifyEqual(RandStream.getGlobalStream().Type,'mt19937ar');
            testCase.verifyEqual(RandStream.getGlobalStream().Seed,uint32(198756));
        end
        
        function callConstructorWithStream(testCase)
            stream = RandStream('mt19937ar','Seed',198756);
            opencossan.OpenCossan.setAnalysis('RandomStream',stream);
            testCase.verifyEqual(RandStream.getGlobalStream().Type,'mt19937ar');
            testCase.verifyEqual(RandStream.getGlobalStream().Seed,uint32(198756));
        end
        
        function callConstructorWithTimer(testCase)
            timer = opencossan.common.Timer('Description','Analysis Test Timer');
            opencossan.OpenCossan.setAnalysis('Timer',timer);
            testCase.verifyEqual(timer,opencossan.OpenCossan.getAnalysis().Timer);
        end
        
        function getAnalysis(testCase)
            Xan = opencossan.OpenCossan.getAnalysis();
            testCase.verifyClass(Xan,'opencossan.common.Analysis');
            testCase.verifyEqual(Xan.ProjectName,"");
            testCase.verifyEqual(Xan.AnalysisName,"");
            testCase.verifyEqual(Xan.WorkingPath,userpath);
        end
        
        function setProject(testCase)
            Xan=opencossan.OpenCossan.getAnalysis();
            Xan.ProjectName="My First Project";
            testCase.verifyEqual(Xan.ProjectName,opencossan.OpenCossan.getProjectName);
        end
        
        function setAnalysisName(testCase)
            Xan=opencossan.OpenCossan.getAnalysis();
            Xan.AnalysisName="My First Analysis";
            testCase.verifyEqual(Xan.AnalysisName,opencossan.OpenCossan.getAnalysisName);
        end
        
        function checkSetAnalysis(testCase)
            opencossan.OpenCossan.setAnalysis('AnalysisName','TestAnalysisName')
            % Calling a setAnalysis should reset the Analysis object. 
            opencossan.OpenCossan.setAnalysis;
            testCase.verifyEqual(opencossan.OpenCossan.getAnalysisName,"");
            opencossan.OpenCossan.setAnalysis('AnalysisName',"TestAnalysisName");
            opencossan.OpenCossan.setAnalysis('ProjectName',"TestProjectName");
            testCase.verifyEqual(opencossan.OpenCossan.getAnalysisName,"");
            testCase.verifyEqual(opencossan.OpenCossan.getProjectName,"TestProjectName");
        end
        
        function checkEmptyWorkingPath(testCase)
            Soldpath=userpath;
            userpath('clear'); %empty userpath
            testCase.verifyError(@()opencossan.OpenCossan.setAnalysis(...
                'ProjectName','MyProject'),...
                'OpenCossan:Analysis:NoUserPath');
            userpath(Soldpath)
            opencossan.OpenCossan.setAnalysis();
        end
        
        %% setRandomStream
        function setRandomStreamShouldChangeGlobal(testCase)
            stream = RandStream('mt19937ar','Seed',198756);
            Xan = opencossan.OpenCossan.getAnalysis();
            Xan.RandomStream = stream;
            testCase.verifyEqual(RandStream.getGlobalStream().Type,'mt19937ar');
            testCase.verifyEqual(RandStream.getGlobalStream().Seed,uint32(198756));
        end
        
        %% resetRandomNumberGenerator
        function testReset(testCase)
            opencossan.OpenCossan.setAnalysis();
            samples1 = rand(10);
            opencossan.OpenCossan.getAnalysis().resetRandomNumberGenerator();
            samples2 = rand(10);
            testCase.verifyEqual(samples1,samples2);
            
            opencossan.OpenCossan.getAnalysis().resetRandomNumberGenerator(198756);
            testCase.verifyEqual(RandStream.getGlobalStream().Seed,uint32(198756));
        end
        
        %% getSeet
        function getSeedShouldReturnSeed(testCase)
            RandStream.getGlobalStream.reset(198756);
            testCase.verifyEqual(opencossan.OpenCossan.getAnalysis.Seed,...
                uint32(198756));
        end
        
        %% getAlgorithm
        function getRandomNumberGeneratorAlgorithmShouldReturnType(testCase)
            opencossan.OpenCossan.setAnalysis('RandomNumberGeneratorAlgorithm',...
                'mrg32k3a');
            testCase.verifyEqual(opencossan.OpenCossan.getAnalysis.RandomNumberGeneratorAlgorithm,...
                'mrg32k3a');
        end

    end
    
end

