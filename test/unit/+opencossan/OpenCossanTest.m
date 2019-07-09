classdef OpenCossanTest < matlab.unittest.TestCase
    %OPENCOSSANTEST Unit tests for the class opencossan.OpenCossan
    
    % =====================================================================
    % This file is part of *OpenCossan*: you can redistribute it and/or modify
    % it under the terms of the GNU General Public License as published by
    % the Free Software Foundation, either version 3 of the License.
    %
    % *OpenCossan* is distributed in the hope that it will be useful,
    % but WITHOUT ANY WARRANTY; without even the implied warranty of
    % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    % GNU General Public License for more details.
    %
    % You should have received a copy of the GNU General Public License
    % along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
    % =====================================================================
    
    methods (Test)
        
        %% getInstance
        function getInstanceShouldReturnTheSingletonInstance(testCase)
            % Get current OpenCossan object and clear it
            cossan = opencossan.OpenCossan.getInstance();
            testCase.assertClass(cossan,'opencossan.OpenCossan');
            delete(cossan);
            testCase.verifyFalse(isvalid(cossan));
            
            % Create new object
            cossan1 = opencossan.OpenCossan.getInstance();
            testCase.assertClass(cossan1,'opencossan.OpenCossan');
            % Check that the same object gets returned by a consecutive
            % call
            cossan2 = opencossan.OpenCossan.getInstance();
            testCase.assertEqual(cossan1,cossan2);
        end
        
        %% getAnalysis
        function getAnalysisShouldReturnAnalysis(testCase)
            analysis = opencossan.OpenCossan.getAnalysis();
            testCase.verifyClass(analysis,'opencossan.common.Analysis');
            testCase.verifyEqual(analysis,...
                opencossan.OpenCossan.getInstance().Analysis);
        end
        
        %% getAnalysisId
        function getAnalysisIdShouldReturnAnalysisId(testCase)
            id = opencossan.OpenCossan.getAnalysisId();
            testCase.verifyEqual(id,...
                opencossan.OpenCossan.getInstance().Analysis.AnalysisID);
        end
        
        %% getAnalysisName
        function getAnalysisNameShouldReturnAnalysisName(testCase)
            name = opencossan.OpenCossan.getAnalysisName();
            testCase.verifyEqual(name,...
                opencossan.OpenCossan.getInstance().Analysis.AnalysisName);
        end
        
        %% getProjectName
        function getProjectNameShouldReturnProject(testCase)
            name = opencossan.OpenCossan.getProjectName();
            testCase.verifyEqual(name,...
                opencossan.OpenCossan.getInstance().Analysis.ProjectName);
        end
        
        %% getDescriptionName
        function getDescriptionShouldReturnDescription(testCase)
            desc = opencossan.OpenCossan.getDescription();
            testCase.verifyEqual(desc,...
                opencossan.OpenCossan.getInstance().Analysis.Description);
        end
        
        %% getSSHConnection
        function getSSHConnectionShouldReturnConnection(testCase)
            ssh = opencossan.OpenCossan.getSSHConnection();
            testCase.assertClass(ssh,...
                'opencossan.highperformancecomputing.SSHConnection');
            testCase.verifyEqual(ssh,...
                opencossan.OpenCossan.getInstance().SSHConnection());
        end
        
        %% getWorkingPath
        function getWorkingPathShouldReturnPath(testCase)
            path = opencossan.OpenCossan.getWorkingPath();
            testCase.verifyEqual(path,...
                opencossan.OpenCossan.getInstance().Analysis.WorkingPath);
        end
        
        %% setAnalysis
        function setAnalysisShouldSetAnalysis(testCase)
            opencossan.OpenCossan.setAnalysis('AnalysisName',...
                "AnalysisTest");
            testCase.verifyEqual("AnalysisTest",...
                opencossan.OpenCossan.getInstance().Analysis.AnalysisName);
        end
        
        %% setAnalysisId
        function setAnalysisIdShouldSetAnalysisId(testCase)
            opencossan.OpenCossan.setAnalysisId(8128);
            testCase.verifyEqual(8128,...
                opencossan.OpenCossan.getInstance().Analysis.AnalysisID);
        end
        
        %% setAnalysisName
        function setAnalysisNameShouldSetAnalysisName(testCase)
            opencossan.OpenCossan.setAnalysisName("TestAnalysis");
            testCase.verifyEqual("TestAnalysis",...
                opencossan.OpenCossan.getInstance().Analysis.AnalysisName);
        end
        
        %% setProjectName
        function setProjectNameShouldSetProjectName(testCase)
            opencossan.OpenCossan.setProjectName("TestProject");
            testCase.verifyEqual("TestProject",...
                opencossan.OpenCossan.getInstance().Analysis.ProjectName);
        end
        
        %% setProjectName
        function setDescriptionNameShouldSetDescription(testCase)
            opencossan.OpenCossan.setDescription('TestDescription');
            testCase.verifyEqual("TestDescription",...
                opencossan.OpenCossan.getInstance().Analysis.Description);
        end
        
        %% setSSHConnection
        function setSSHConnectionShouldSetConnection(testCase)
            ssh = opencossan.highperformancecomputing.SSHConnection();
            opencossan.OpenCossan.setSSHConnection(ssh);
            testCase.verifyEqual(ssh,...
                opencossan.OpenCossan.getInstance().SSHConnection);
        end
        
        %% setWorkingPath
        function setWorkingPathNameShouldSetPath(testCase)
            cossan = opencossan.OpenCossan.getInstance();
            backup = cossan.Analysis.WorkingPath;
            path = fullfile(cossan.Root,'test');
            opencossan.OpenCossan.setWorkingPath(path);
            testCase.assertEqual(path,...
                cossan.Analysis.WorkingPath);
            opencossan.OpenCossan.setWorkingPath(backup);
        end
        
        %% getUserName
        function getUserNameShouldReturnUser(testCase)
            user = opencossan.OpenCossan.getUserName();
            testCase.verifyClass(user,'char');
        end
        
        %% getTimer
        function getTimerShouldReturnTimer(testCase)
            timer = opencossan.OpenCossan.getTimer();
            testCase.assertClass(timer,'opencossan.common.Timer');
            testCase.verifyEqual(timer,...
                opencossan.OpenCossan.getInstance().Analysis.Timer);
        end
        
        %% getRandomStream
        function getRandomStreamShouldReturnStream(testCase)
            stream = opencossan.OpenCossan.getRandomStream();
            testCase.assertClass(stream,'RandStream');
            testCase.verifyEqual(stream,...
                opencossan.OpenCossan.getInstance().Analysis.RandomStream);
        end
        
        %% getVerbostityLevel
        function getVerbosityLevelShouldReturnLevel(testCase)
            level = opencossan.OpenCossan.getVerbosityLevel();
            testCase.verifyTrue(isinteger(level));
        end
        
        %% setVerbosityLevel
        function setVerbosityLevelShouldSetLevel(testCase)
            level = opencossan.OpenCossan.getInstance().VerboseLevel;
            opencossan.OpenCossan.setVerbosityLevel(0);
            testCase.verifyEqual(uint8(0),...
                opencossan.OpenCossan.getInstance().VerboseLevel);
            opencossan.OpenCossan.setVerbosityLevel(1);
            testCase.verifyEqual(uint8(1),...
                opencossan.OpenCossan.getInstance().VerboseLevel);
            opencossan.OpenCossan.setVerbosityLevel(2);
            testCase.verifyEqual(uint8(2),...
                opencossan.OpenCossan.getInstance().VerboseLevel);
            opencossan.OpenCossan.setVerbosityLevel(3);
            testCase.verifyEqual(uint8(3),...
                opencossan.OpenCossan.getInstance().VerboseLevel);
            opencossan.OpenCossan.setVerbosityLevel(4);
            testCase.verifyEqual(uint8(4),...
                opencossan.OpenCossan.getInstance().VerboseLevel);
            
            opencossan.OpenCossan.setVerbosityLevel(level);
        end
        
        %% getDatabaseDriver
        function getDatabaseDriverShouldReturnDriver(testCase)
            driver = opencossan.OpenCossan.getDatabaseDriver();
            testCase.assertClass(driver,'opencossan.common.database.DatabaseDriver');
            testCase.verifyEqual(driver,...
                opencossan.OpenCossan.getInstance().DatabaseDriver);
        end
        
        %% setDatabaseDriver
        function setDatabaseDriverShouldSetDriver(testCase)
            driver = opencossan.common.database.DatabaseDriver();
            opencossan.OpenCossan.setDatabaseDriver(driver);
            testCase.verifyEqual(driver,...
                opencossan.OpenCossan.getInstance().DatabaseDriver);
        end
        
        %% createStartupFile
        function createStartupFileShouldCreateFile(testCase)
            cossan = opencossan.OpenCossan.getInstance();
            backup = userpath();
            folder = fullfile(userpath,'OpenCossanTest');
            mkdir(folder);
            userpath(folder);
            cossan.createStartupFile();
            testCase.assertTrue(isfile(fullfile(folder,'startup.m')));
            delete(fullfile(folder,'startup.m'));
            rmdir(folder);
            userpath(backup);
        end
        
        function createStartupFileShouldCreateBackup(testCase)
            cossan = opencossan.OpenCossan.getInstance();
            backup = userpath();
            folder = fullfile(userpath,'OpenCossantest');
            mkdir(folder);
            userpath(folder);
            cossan.createStartupFile();
            cossan.createStartupFile();
            testCase.assertTrue(isfile(fullfile(folder,'startup.m')));
            delete(fullfile(folder,'startup.m'));
            testCase.assertTrue(isfile(fullfile(folder,'startup.m.backup1')));
            delete(fullfile(folder,'startup.m.backup1'));
            rmdir(folder);
            userpath(backup);
        end
        
        %% resetRandomNumberGenerator
        function resetRandomNumberGeneratorShouldChangeSeet(testCase)
            seed = uint32(8128);
            opencossan.OpenCossan.resetRandomNumberGenerator(seed);
            testCase.verifyEqual(seed,...
                opencossan.OpenCossan.getAnalysis().RandomStream.Seed);
        end
        
        function resetRandomNumberGeneratorShouldReset(testCase)
            samples1 = opencossan.OpenCossan.getAnalysis.RandomStream.rand(3,3);
            opencossan.OpenCossan.resetRandomNumberGenerator();
            samples2 = opencossan.OpenCossan.getAnalysis.RandomStream.rand(3,3);
            testCase.verifyEqual(samples1,samples2);
        end
        
        %% isKilled
        function isKilledShouldReturnFalse(testCase)
            testCase.verifyFalse(opencossan.OpenCossan.isKilled);
        end
        
        function isKilledShouldReturnTrue(testCase)
            killfile = fullfile(opencossan.OpenCossan.getWorkingPath(),...
                opencossan.OpenCossan.getInstance().KillFileName);
            fid = fopen(killfile,'w+');
            fclose(fid);
            testCase.verifyTrue(opencossan.OpenCossan.isKilled);
            delete(killfile);
        end
        
        %% reset
        function resetShouldResetTheTimer(testCase)
            opencossan.OpenCossan.getTimer().stop();
            opencossan.OpenCossan.reset();
            timer = opencossan.OpenCossan.getTimer();
            testCase.verifyEqual(0,timer.Time);
            testCase.verifyEqual({'Timer_started_from_OpenCossan'},timer.Descriptions);
            testCase.verifyTrue(timer.IsRunning);
        end
        
    end
    
end

