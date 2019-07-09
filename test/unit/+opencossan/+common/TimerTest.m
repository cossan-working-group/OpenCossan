classdef TimerTest < matlab.unittest.TestCase
    % TIMERTEST Unit tests for the class common.Timer
    % see http://cossan.co.uk/wiki/index.php/@Timer
    %
    % @author Jasper Behrensdorf<behrensdorf@irz.uni-hannover.de>
    % @date   15.08.2016
    %
    % =====================================================================
    % This file is part of openCOSSAN.  The open general purpose matlab
    % toolbox for numerical analysis, risk and uncertainty quantification.
    %
    % openCOSSAN is free software: you can redistribute it and/or modify
    % it under the terms of the GNU General Public License as published by
    % the Free Software Foundation, either version 3 of the License.
    %
    % openCOSSAN is distributed in the hope that it will be useful,
    % but WITHOUT ANY WARRANTY; without even the implied warranty of
    % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    % GNU General Public License for more details.
    %
    % You should have received a copy of the GNU General Public License
    % along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
    % =====================================================================
    
    methods (Test)
        
        %% Test constructor
        function constructorEmpty(testCase)
            timer = opencossan.common.Timer();
            testCase.assertClass(timer,'opencossan.common.Timer');
            testCase.assertTrue(timer.IsRunning);
            testCase.assertEqual(timer.Descriptions,{'Timing_1'});
        end
        
        function constructorShouldSetDescription(testCase)
            timer = opencossan.common.Timer('Description','Test');
            testCase.assertClass(timer,'opencossan.common.Timer');
            testCase.assertEqual(timer.Descriptions,{'Test'});
        end
        
        %% start
        function startShouldStartNewTiming(testCase)
            timer = opencossan.common.Timer();
            timer.stop();
            timer.start('Description','Timing 2');
            testCase.assertTrue(timer.IsRunning);
            testCase.assertEqual(timer.Descriptions,{'Timing_1';'Timing_2'});
            testCase.assertEqual(timer.Ntiming,2);
            testCase.assertGreaterThan(timer.CurrentTime,0);
            testCase.assertSize(timer.Time,[2 1]);
        end
        
        function startShouldWarnIfAlreadyRunning(testCase)
            timer = opencossan.common.Timer();
            testCase.assertWarning(@() timer.start(),...
                'OpenCossan:Timer:AlreadyRunning');
        end
        
        %% stop
        function stopShouldStopTiming(testCase)
            timer = opencossan.common.Timer();
            pause(1);
            timer.stop();
            testCase.assertFalse(timer.IsRunning);
            testCase.assertEqual(timer.Ntiming,1);
            testCase.assertGreaterThan(timer.TotalTime,1);
        end
        
        %% lap
        function lapShouldStopStart(testCase)
            Xtimer = opencossan.common.Timer();
            num = Xtimer.lap();
            testCase.assertEqual(num,2);
            testCase.assertTrue(Xtimer.IsRunning);
            testCase.assertEqual(Xtimer.Descriptions,{'Timing_1';'Timing_2'});
            testCase.assertGreaterThan(Xtimer.CurrentTime,0);
            testCase.assertEqual(Xtimer.Time(2),0);
        end
        
        %% delta
        function deltaShouldWithoutLaps(testCase)
            timer = opencossan.common.Timer();
            testCase.assertError(@()timer.delta(1,2),...
                'OpenCossan:Timer:delta');
        end
        
        function deltaShouldFailWithWrongOrder(testCase)
            timer = opencossan.common.Timer();
            timer.lap();
            timer.lap();
            testCase.assertError(@()timer.delta(2,1),...
                'OpenCossan:Timer:delta');
        end
        
        function deltaShouldReturnSum(testCase)
            timer = opencossan.common.Timer();
            timer.lap();
            timer.lap();
            timer.stop();
            
            delta = timer.delta(1,3);
            testCase.assertEqual(delta,sum(timer.Time));
            
            delta = timer.delta(1);
            testCase.assertEqual(delta,sum(timer.Time));
            
            delta = timer.delta(1,2);
            testCase.assertEqual(delta,sum(timer.Time(1:2)));
        end
        
        %% reset
        function resetShouldClearAll(testCase)
            timer = opencossan.common.Timer();
            timer.lap();
            timer.stop();
            timer.reset();
            
            testCase.assertEqual(timer.Descriptions,cell(0,1));
            testCase.assertEqual(timer.Time,double.empty(0,1));
            testCase.assertFalse(timer.IsRunning);
            testCase.assertEqual(timer.TotalTime,0);
            testCase.assertEqual(timer.CurrentTime,0);
        end
        
        %% display
        function checkDisplayWorksForScalars(testCase)
            timer = opencossan.common.Timer();
            timer.lap();
            testPhrases = ["Running";timer.TimeStamp;timer.Descriptions];
            testCase.assertTrue(testOutput(timer,testPhrases));
            timer.stop();
            testPhrases = ["Stopped";timer.TimeStamp;timer.Descriptions];
            testCase.assertTrue(testOutput(timer,testPhrases));
        end
        
        function checkDisplayWorksForArrays(testCase)
            timer = [opencossan.common.Timer(); opencossan.common.Timer()];
            testPhrases = ["Timer array with properties:";"Descriptions";...
                "Time";"TimeStamp";"CurrentTime";"TotalTime";"Ntiming"];
            testCase.assertTrue(testOutput(timer,testPhrases));
        end
        
        %% plot
        function plotShouldReturnFigure(testCase)
            timer = opencossan.common.Timer();
            timer.lap();
            f = plot(timer);
            testCase.assertClass(f,'matlab.ui.Figure');
            close(f);
        end
        
        function plotShouldExportFigure(testCase)
            timer = opencossan.common.Timer();
            timer.lap();
            f = plot(timer,'FigureName','Timer');
            file = fullfile(opencossan.OpenCossan.getWorkingPath,'Timer.eps');
            testCase.assertClass(f,'matlab.ui.Figure');
            testCase.assertEqual(exist(file,'file'),2);
            close(f);
            delete(file);
        end
        
        function plotShouldExportFigureAsPdf(testCase)
            timer = opencossan.common.Timer();
            timer.lap();
            f = plot(timer,'FigureName','Timer','ExportFormat','pdf');
            file = fullfile(opencossan.OpenCossan.getWorkingPath,'Timer.pdf');
            testCase.assertClass(f,'matlab.ui.Figure');
            testCase.assertEqual(exist(file,'file'),2);
            close(f);
            delete(file);
        end
        
    end
    
end

