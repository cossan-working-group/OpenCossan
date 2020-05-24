classdef EvaluatorTest < matlab.unittest.TestCase
    % EVALUATORTEST Unit tests for the class common.MarkovChain
    % see http://cossan.co.uk/wiki/index.php/@Evaluator
    %
    % @author Jasper Behrensdorf<behrensdorf@irz.uni-hannover.de>
    % @date   05.09.2016
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
    
    properties
        MatWorker
        MatWorker2
        ConWorker
    end
    methods (TestClassSetup)
        function defineWorker(testCase)
            testCase.MatWorker  = opencossan.workers.MatlabWorker( ...
                'Description','covariance function', ...
                'Format','structure',...
                'InputNames',{'TestInput'},... % Define the inputs
                'Script', "%Do Nothing",'OutputNames',{'TestOutput'}); % Define the outputs
            
            testCase.MatWorker2  = opencossan.workers.MatlabWorker('Script',"Toutput.out2=Tinput.out1+5;", ...
                'Format',"structure", ...
                'OutputNames',{'out3'},...
                'InputNames',{'X1' 'X2' 'X4' 'out1'});
            
            testCase.ConWorker=opencossan.workers.Connector;
        end
    end
    
    methods (Test)
        %% Constructor
        function emptyConstructor(testCase)
            Xe = opencossan.workers.Evaluator;
            testCase.assertClass(Xe,'opencossan.workers.Evaluator');
        end
        
        function constructorShouldSetDescription(testCase)
            Xe = opencossan.workers.Evaluator('Description','Evaluator',...
                'Solver',testCase.MatWorker,'SolverName','test');
            testCase.assertEqual(Xe.Description,"Evaluator");
        end
        
        function constructorShouldSetMatlabWorker(testCase)
            Xe = opencossan.workers.Evaluator('Solver',testCase.MatWorker,...
                'SolverName',{'Xmio'});
            testCase.assertEqual(Xe.Solver(1),testCase.MatWorker);
        end
        
        function constructorTwoWorkers(testCase)
            
            Xe = opencossan.workers.Evaluator('Solver',[testCase.MatWorker testCase.MatWorker2],...
                'SolverName',["MatlabWorker" "ExtraName"]);
            testCase.assertEqual(Xe.Solver(2),testCase.MatWorker2);
        end
        
        function constructorShouldSetJobManagerInterface(testCase)
            Xjmi = opencossan.highperformancecomputing.JobManagerInterface();
            Xe = opencossan.workers.Evaluator('Solver',testCase.MatWorker,'JobManager',Xjmi,'SolverName','MatWorker');
            testCase.assertEqual(Xe.JobManager,Xjmi);
        end
        

        
        function constructorTestInputNames(testCase)
            
            Xe = opencossan.workers.Evaluator('Solver',[testCase.MatWorker testCase.MatWorker2],...
            'SolverName',["MatWorker" "MatWorker2"]);
            
            Cinput=[testCase.MatWorker.InputNames testCase.MatWorker2.InputNames];
            testCase.assertEqual(Xe.InputNames,Cinput);
        end
        
        function constructorTestOutputNames(testCase)
            Xe = opencossan.workers.Evaluator('Solver',[testCase.MatWorker testCase.MatWorker2],...
                'SolverName',["MatWorker" "MatWorker2"]);          
            Coutput=[testCase.MatWorker.OutputNames testCase.MatWorker2.OutputNames];
            testCase.assertEqual(Xe.OutputNames,Coutput);
        end
        
        %% Deterministic Analysis
        function deterministicAnalyis(testCase)
            Xmio = opencossan.workers.MatlabWorker('Script',"Toutput.out1=Tinput.Xpar",...
                'OutputNames',{'out1'},'InputNames',{'Xpar'},'Format',"structure");
            Xpar = opencossan.common.inputs.Parameter('value',10.2);
            Xinput = opencossan.common.inputs.Input('Parameter',Xpar);
            Xe  = opencossan.workers.Evaluator('Solver',Xmio,'SolverName',"mio Name");
            Xout=Xe.deterministicAnalysis(Xinput);
            testCase.assertClass(Xout,'opencossan.common.outputs.SimulationData');
            testCase.assertEqual(Xout.getValues('Sname','out1'),10.2);
        end
        
    end
    
end

