classdef JobManagerSlurmTest < matlab.unittest.TestCase
    % JOBMANAGERSLURMTEST Unit tests for the class
    % common.highperformancecompiting.JobMagagerSlurm
    %
    % See also: Job, JobManager
    %
    % @author Edoardo Patelli <edoardo.patelli@strath.ac.uk>
    % @date   23.02.2020
    
    properties
        Evaluator
    end
    methods (TestClassSetup)
        
        
        function defineWorker(testCase)
            MatWorker  = opencossan.workers.MatlabWorker('Script',"Toutput.out2=Tinput.out1+5;", ...
                'Format',"structure", ...
                'OutputNames',{'out3'},...
                'InputNames',{'X1' 'X2' 'X4' 'out1'});
            
            testCase.Evaluator = opencossan.workers.Evaluator('Solver',MatWorker,...
                'SolverName',{'Xmio'});
        end
        
    end
    
    methods (Test)
        %% Constructor
        function emptyConstructor(testCase)
            Xjm = opencossan.highperformancecomputing.JobManagerSlurm;
            testCase.assertClass(Xjm,'opencossan.workers.highperformancecomputing');
        end
        
        function constructorShouldSetDescription(testCase)
            Xjm = opencossan.highperformancecomputing.JobManagerSlurm(...
                'description','TestJobManager','moduleList',["matlabR2019a" "secondModule"], ...
                'ClusterMatlabRoot','/Apps/Matlab/R2019b');
            testCase.assertEqual(Xe.Description,"Evaluator");
        end
        
        function constructorShouldSetMatlabWorker(testCase)
            Xe = opencossan.workers.Evaluator('Solver',testCase.MatWorker,...
                'SolverName',{'Xmio'});
            testCase.assertEqual(Xe.Solver(1),testCase.MatWorker);
        end
        
        function constructorShouldFail(testCase)
            
            Xe = opencossan.workers.Evaluator('Solver',[testCase.MatWorker testCase.MatWorker2],...
                'SolverName',["MatlabWorker" "ExtraName"]);
            testCase.assertEqual(Xe.Solver(2),testCase.MatWorker2);
        end
        
        
        
        function constructorShouldSetJobManagerInterface(testCase)
            Xjmi = opencossan.highperformancecomputing.JobManagerInterface();
            Xe = opencossan.workers.Evaluator('Solver',testCase.MatWorker,'JobManager',Xjmi);
            testCase.assertEqual(Xe.JobManager,Xjmi);
        end
        
        function constructorShouldSetLremoteInjectExtract(testCase)
            Xe = opencossan.workers.Evaluator('Solver',testCase.MatWorker,...
                'RemoteInjectExtract',true);
            testCase.assertTrue(Xe.RemoteInjectExtract);
        end
        
        function constructorShouldSetHostNames(testCase)
            
            Squeues = ["Queue1" "Queue2"];
            Shostnames = ["Host1","Host2"];
            Xe = opencossan.workers.Evaluator('Solver',[testCase.ConWorker testCase.MatWorker],...
                'Hostnames',Shostnames,...
                'Queues',Squeues);
            testCase.assertEqual(Xe.Hostnames,Shostnames);
        end
        
        function constructorShouldSetQueues(testCase)
            Squeues = ["Queue1" "Queue2"];
            Xe = opencossan.workers.Evaluator('Solver',...
                [testCase.ConWorker testCase.MatWorker],'Queues',Squeues);
            testCase.assertEqual(Xe.Queues,Squeues);
        end
        
        function constructorShouldSetVconcurrent(testCase)
            Xe = opencossan.workers.Evaluator('Solver',[testCase.ConWorker testCase.MatWorker],...
                'MaxCuncurrentJobs',[Inf 4]);
            testCase.assertEqual(Xe.MaxCuncurrentJobs,[Inf 4]);
        end
        
        function constructorShouldSetMembers(testCase)
            Xe = opencossan.workers.Evaluator('Solver',[testCase.ConWorker testCase.MatWorker]);
            testCase.assertEqual(Xe.Solver,[testCase.ConWorker testCase.MatWorker]);
        end
        
        function constructorShouldSetNames(testCase)
            CSnames = ["Connector Name", "Mio name"];
            Xe = opencossan.workers.Evaluator('Solver',[testCase.ConWorker testCase.MatWorker],'SolverName',CSnames);
            testCase.assertEqual(Xe.Solver,[testCase.ConWorker  testCase.MatWorker]);
            testCase.assertEqual(Xe.SolverName,CSnames);
        end
        
        function constructorShouldSetSolutionSequence(testCase)
            Xss = opencossan.workers.SolutionSequence();
            Xe = opencossan.workers.Evaluator('Solver',Xss);
            testCase.assertEqual(Xe.Solver(1),Xss);
        end
        
        function constructorShouldSetMetaModel(testCase)
            Xrs = opencossan.metamodels.ResponseSurface();
            Xe = opencossan.workers.Evaluator('Solver',Xrs);
            testCase.assertEqual(Xe.Solver(1),Xrs);
        end
        
        function constructorShouldSetParallelEnvironment(testCase)
            Xe = opencossan.workers.Evaluator('Solver',[testCase.ConWorker testCase.MatWorker],...
                'ParallelEnvironments',["parallel" "parallel"]);
            testCase.assertEqual(Xe.ParallelEnvironments,["parallel";"parallel"]);
        end
        
        function constructorShouldSetVSlots(testCase)
            Xe = opencossan.workers.Evaluator('Solver',[testCase.ConWorker testCase.MatWorker],...
                'Slots',[1 1]);
            testCase.assertEqual(Xe.Slots,[1 1]);
        end
        
        function constructorTestInputNames(testCase)
            
            Xe = opencossan.workers.Evaluator('Solver',[testCase.MatWorker testCase.MatWorker2]);
            
            Cinput=[testCase.MatWorker.InputNames testCase.MatWorker2.InputNames];
            testCase.assertEqual(Xe.InputNames,Cinput);
        end
        
        function constructorTestOutputNames(testCase)
            
            
            Xe = opencossan.workers.Evaluator('Solver',[testCase.MatWorker testCase.MatWorker2]);
            
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

