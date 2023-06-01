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
            Xtimer = common.Timer();
            testCase.assertClass(Xtimer,'common.Timer');
        end
        
        function constructorShouldSetDescription(testCase)
            Xtimer = common.Timer('Description','Test Timer');
            testCase.assertClass(Xtimer,'common.Timer');
            testCase.assertEqual(Xtimer.Description,{'Test Timer'});
        end
        
        %% Test starttime
        function starttimeShouldStartNewTiming(testCase)
            Xtimer = common.Timer();
            Xtimer.start();
            Xtimer.start('Description','Third Timing');
            testCase.assertEqual(Xtimer.Description,{'Timing 1' 'Timing 2' 'Third Timing'});
            testCase.assertEqual(Xtimer.Timing,3);
            testCase.assertEqual(Xtimer.Time,[0 0 0]);
        end
        
        %% Test stoptime
        function stoptimeShouldStopTiming(testCase)
            Xtimer = common.Timer();
            pause(1);
            Xtimer.stop;
            testCase.assertFalse(Xtimer.IsRunning);
            testCase.assertEqual(Xtimer.Time,1,'AbsTol',0.1);
        end
        
        %% Test laptime
        function laptimeShouldStopStart(testCase)
            Xtimer = common.Timer();
            num = Xtimer.lap;
            testCase.assertEqual(num,2);
            testCase.assertTrue(Xtimer.IsRunning);
            testCase.assertEqual(Xtimer.Description,{'Timing 1' 'Timing 2'});
            testCase.assertGreaterThan(Xtimer.Time(1),0);
            testCase.assertEqual(Xtimer.Time(2),0);
        end
        
        %% Test deltatime
        function deltatimeShouldWithoutLaps(testCase)
            Xtimer = common.Timer();
            testCase.assertError(@()Xtimer.delta(1,2),...
                'OpenCossan:Timer:delta');
        end
        
        function deltatimeShouldFailWithWrongOrder(testCase)
            Xtimer = common.Timer();
            Xtimer.lap;
            Xtimer.lap;
            testCase.assertError(@()Xtimer.delta(2,1),...
                'openCOSSAN:Timer:deltatime');
        end
        
        function deltatimeShouldReturnSum(testCase)
            Xtimer = common.Timer();
            Xtimer.lap;
            Xtimer.lap;
            Xtimer.stop;
            
            deltatime = Xtimer.delta(1,3);
            testCase.assertEqual(delta,sum(Xtimer.Time));
        end
        
        %% Test totaltime
        function totaltimeShouldReturnSum(testCase)
            Xtimer = common.Timer();
            Xtimer.lap;
            Xtimer.lap;
            Xtimer.stop;
            
            totaltime = Xtimer.TotalTime();
            testCase.assertEqual(totaltime,sum(Xtimer.Time));
        end
        
        %% Test reset
        function resetShouldClearAll(testCase)
            Xtimer = common.Timer('Sdescription','1st Timing');
            Xtimer.lap('Sdescription','2nd Timing');
            Xtimer.stop;
            Xtimer.reset;
            
            testCase.assertEqual(Xtimer.Description,{});
            testCase.assertEqual(Xtimer.Time,[]);
            testCase.assertFalse(Xtimer.IsRunning);
        end
        
    end
    
end

