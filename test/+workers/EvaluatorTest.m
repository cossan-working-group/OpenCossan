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
    end
    
    methods (Test)
        %% Constructor
        function emptyConstructor(testCase)
            Xe = workers.Evaluator;
            testCase.assertClass(Xe,'workers.Evaluator');
        end
        
        function constructorShouldSetDescription(testCase)
            Xe = workers.Evaluator('Sdescription','Evaluator');
            testCase.assertEqual(Xe.Sdescription,'Evaluator');
        end
        
        function constructorShouldSetMio(testCase)
            Xmio = workers.Mio('Coutputnames',{'output'},...
                'Cinputnames',{'input'},'Sscript','%do nothing');
            Xe = workers.Evaluator('Xmio',Xmio);
            testCase.assertEqual(Xe.CXsolvers{1},Xmio);
        end
        
        function constructorShouldSetConnector(testCase)
            Xcon = workers.Connector;
            Xe = workers.Evaluator('Xconnector',Xcon);
            testCase.assertEqual(Xe.CXsolvers{1},Xcon);
        end
        
        function constructorShouldSetJobManagerInterface(testCase)
            Xjmi = highperformancecomputing.JobManagerInterface();
            Xe = workers.Evaluator('XjobManagerInterface',Xjmi);
            testCase.assertEqual(Xe.XjobInterface,Xjmi);
            Xe = workers.Evaluator('CXjobManagerInterface',{Xjmi});
            testCase.assertEqual(Xe.XjobInterface,Xjmi);
        end
        
        function constructorShouldSetLremoteInjectExtract(testCase)
            Xe = workers.Evaluator('LremoteInjectExtract',true);
            testCase.assertTrue(Xe.LremoteInjectExtract);
        end
        
        function constructorShouldSetHostNames(testCase)
            Xcon = workers.Connector;
            Xmio = workers.Mio('Coutputnames',{'output'},...
                'Cinputnames',{'input'},'Sscript','%do nothing');
            CSqueues = {'Queue1' 'Queue2'};
            CShostnames = {'Host1','Host2'};
            Xe = workers.Evaluator('CXmembers',{Xcon Xmio},'CShostnames',CShostnames,...
                'CSqueues',CSqueues);
            testCase.assertEqual(Xe.CShostnames,CShostnames);
            
        end
        
        function constructorShouldSetQueues(testCase)
            Xcon = workers.Connector;
            Xmio = workers.Mio('Coutputnames',{'output'},...
                'Cinputnames',{'input'},'Sscript','%do nothing');
            CSqueues = {'Queue1' 'Queue2'};
            Xe = workers.Evaluator('Xconnector',Xcon,'Xmio',...
                Xmio,'CSqueues',CSqueues);
            testCase.assertEqual(Xe.CSqueues,CSqueues);
        end
        
        function constructorShouldSetVconcurrent(testCase)
            Xcon = workers.Connector;
            Xmio = workers.Mio('Coutputnames',{'output'},...
                'Cinputnames',{'input'},'Sscript','%do nothing');
            Xe = workers.Evaluator('Xconnector',Xcon,'Xmio',...
                Xmio,'Vconcurrent',[Inf 4]);
            testCase.assertEqual(Xe.Vconcurrent,[Inf 4]);
        end
        
        function constructorShouldSetMembers(testCase)
            Xcon = workers.Connector;
            Xmio = workers.Mio('Coutputnames',{'output'},...
                'Cinputnames',{'input'},'Sscript','%do nothing');
            Xe = workers.Evaluator('CXmembers',{Xcon Xmio});
            testCase.assertEqual(Xe.CXsolvers,{Xcon Xmio});
        end
        
        function constructorShouldSetNames(testCase)
            Xcon = workers.Connector;
            Xmio = workers.Mio('Coutputnames',{'output'},...
                'Cinputnames',{'input'},'Sscript','%do nothing');
            CSnames = {'Connector Name', 'Mio name'};
            Xe = workers.Evaluator('Xconnector',Xcon,'Xmio',...
                Xmio,'CSnames',CSnames);
            testCase.assertEqual(Xe.CXsolvers,{Xcon Xmio});
            testCase.assertEqual(Xe.CSnames,CSnames);
        end
        
        function constructorShouldSetSolutionSequence(testCase)
            Xss = workers.SolutionSequence();
            Xe = workers.Evaluator('XsolutionSequence',Xss);
            testCase.assertEqual(Xe.CXsolvers{1},Xss);
        end
        
        function constructorShouldSetMetaModel(testCase)
            Xrs = metamodels.ResponseSurface();
            Xe = workers.Evaluator('XmetaModel',Xrs);
            testCase.assertEqual(Xe.CXsolvers{1},Xrs);
        end
        
        function constructorShouldSetParallelEnvironment(testCase)
            Xcon = workers.Connector;
            Xe = workers.Evaluator('Xconnector',Xcon,'CSparallelEnvironments',{'parallel'});
            testCase.assertEqual(Xe.CSparallelEnvironments,{'parallel'});
        end
        
        function constructorShouldSetVSlots(testCase)
            Xcon = workers.Connector;
            Xmio = workers.Mio('Coutputnames',{'output'},...
                'Cinputnames',{'input'},'Sscript','%do nothing');
            Xe = workers.Evaluator('Xconnector',Xcon,'Xmio',...
                Xmio,'Vslots',[1 1]);
            testCase.assertEqual(Xe.Vslots,[1 1]);
        end
        
        function constructorTestInputNames(testCase)
            Xmio1 = workers.Mio('Sscript','Toutput.out1=1;', ...
                'Sformat','structure', ...
                'Coutputnames',{'out1' 'out2'},...
                'Cinputnames',{'X1' 'X2' 'X3'});
            
            Xmio2 = workers.Mio('Sscript','Toutput.out2=Tinput.out1+5;', ...
                'Sformat','structure', ...
                'Coutputnames',{'out3'},...
                'Cinputnames',{'X1' 'X2' 'X4' 'out1'});
            
            Xe = workers.Evaluator('CXmembers',{Xmio1 Xmio2});
            
            Cinput={'X1' 'X2' 'X3' 'X4'};
            testCase.assertEqual(Xe.Cinputnames,Cinput);
        end
        
        function constructorTestOutputNames(testCase)
            Xmio1 = workers.Mio('Sscript','Toutput.out1=1;', ...
                'Sformat','structure', ...
                'Coutputnames',{'out1' 'out2'},...
                'Cinputnames',{'X1' 'X2' 'X3'});
            
            Xmio2 = workers.Mio('Sscript','Toutput.out2=Tinput.out1+5;', ...
                'Sformat','structure', ...
                'Coutputnames',{'out3'},...
                'Cinputnames',{'X1' 'X2' 'X4' 'out1'});
            
            Xe = workers.Evaluator('CXmembers',{Xmio1 Xmio2});
            
            Coutput={'out1' 'out2' 'out3'};
            testCase.assertEqual(Xe.Coutputnames,Coutput);
        end
        
        %% Deterministic Analysis
        function deterministicAnalyis(testCase)
            Xmio = workers.Mio('Sscript','Toutput.out1=Tinput.Xpar','CoutputNames',{'out1'},'CinputNames',{'Xpar'},'Sformat','structure');
            Xpar = common.inputs.Parameter('value',10.2);
            Xinput = common.inputs.Input('Xparameter',Xpar);
            Xe  = workers.Evaluator('CXmembers',{Xmio},'CSnames',{'mio Name'});
            Xout=Xe.deterministicAnalysis(Xinput);
            testCase.assertClass(Xout,'common.outputs.SimulationData');
            testCase.assertEqual(Xout.getValues('Sname','out1'),10.2);
        end
        
    end
    
end

