classdef JobTest < matlab.unittest.TestCase
    % JOB Unit tests for the class common.highperformancecompiting.Job
    % See also: Job, JobManager
    %
    % @author Edoardo Patelli <edoardo.patelli@strath.ac.uk>
    % @date   23.02.2020
    
    properties
        JobManagerSlurm
    end
    
    methods (TestClassSetup)
          function defineWorker(testCase)
           
            stringSimulated='Simulating submission Job *Submitted batch job 2020.';
              
            testCase.JobManagerSLurm = opencossan.highperformancecomputing.JobManagerSlurm(...
                'isRemoteCluster','false','AdditionalSubmitArgs',stringSimulated);
          end
    end
    
    methods (Test)
        %% Constructor
        function emptyConstructor(testCase)
            obj = opencossan.highperformancecomputing.Job;
            testCase.assertClass(obj,'opencossan.workers.highperformancecomputing.Job');
        end
        
        function constructorWithMandatoryArguments(testCase)
            obj = opencossan.highperformancecomputing.Job(...
                'ID','2020','state','unknown');
            testCase.assertEqual(obj.ID,"2020");
        end
        
        function constructorWithOptionalArguments(testCase)
            obj = opencossan.highperformancecomputing.Job(...
                'ID','2020','State','unknown','Sescription','TestJob',...
                'ScriptName','myScript','Dependences',[]);
            testCase.assertEqual(obj.description,'TestJob');
        end
        
        function constructorShouldFail(testCase)  
            % Missing mandatory inputs
            testCase.verifyError(@() opencossan.highperformancecomputing.Job(...
                'State','unknown','Sescription','TestJob'),...
                'OpenCossan:MissingRequiredInput')
        end
        
        % TODO: Add additional tests
        function testJobContructionFromJobManagerSlurm(testCase)

            obj=testCase.JobManagerSlurm.submitJob('Hostname','localhost',...
                'Queue','none');
            testCase.assertEqual(obj.ID,'2020');
            
        end

    end
    
end

