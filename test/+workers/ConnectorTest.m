%% UNIT TEST FOR @CONNECTOR
%
% Written by Matteo Broggi
%
% TODO: All tests are skipped until the tests work without user input

%% xUnit sub-class defintion
% This sub-class inherits from matlab.unittest.TestCase
classdef ConnectorTest < matlab.unittest.TestCase
    %%
    
    % This block contains all the properties that are used in the Test.
    properties
        Xinput;        % Store Input
        Xconnector_local;    % Store Connector
        Xconnector_remote;   % Store Connector
        Xjob = [];
        LtestHasSSH = false;
        LtestHasGrid = false;
        Mexpected = [];
    end
       
    
    %% Class Fixture
    % This sets up the problem from the tutorial
    methods (TestClassSetup)
        function defineModel(testCase)
            %% set up SSH connection
            assumeFail(testCase);
            Susername=input('Define username: ','s');
            % Assume that the user can connect without a password
            %Spassword = input('Define password: ','s');
            SsshPrivateKey = input('Path to the private key: ','s');
            
            try
                SSHConnection('SSSHhost','cossan.cfd','SSSHuser',Susername,...% we need an unprivileged user dedicated to tests
                    'SremoteWorkFolder',fullfileunix('/home',Susername,'tmp'),...
                    'SsshPassword','',... 
                    'SsshPrivateKey',SsshPrivateKey,...
                    'SremoteMCRPath','/usr/software/matlab/MATLAB_Compiler_Runtime/v81/',...
                    'SremoteExternalPath',fullfileunix('/home',Susername,'workspace','OpenSourceSoftware')); % we need a distributed OpenSourceSoftware on the server
                % try a command via ssh
                out = OpenCossan.issueSSHcommand('ls -la');
                if out==0
                    testCase.LtestHasSSH = true;
                end                
            catch
                testCase.LtestHasSSH = false;
            end
            %% Input Definition
            Xrv1=RandomVariable('Sdistribution','uniform','lowerbound',-pi,'upperbound',pi);
            Xrv2=RandomVariable('Sdistribution','uniform','lowerbound',-pi,'upperbound',pi);
            Xrv3=RandomVariable('Sdistribution','uniform','lowerbound',-pi,'upperbound',pi);
            Xrvset = RandomVariableSet('Cmembers',{'Xrv1','Xrv2','Xrv3'},'CXrv',{Xrv1,Xrv2,Xrv3});
            parameterA = Parameter('value',7);
            parameterB = Parameter('value',0.1);
            
            testCase.Xinput = Input('CXmembers',{Xrvset,parameterA,parameterB},...
                'CSmembers',{'Xrvset','parameterA','parameterB'});
            
            testCase.Xinput = testCase.Xinput.sample('Nsamples',10);
            
            % compute expected values
            Msamples=testCase.Xinput.getSampleMatrix;
            testCase.Mexpected = sin(Msamples(:,1)) + 7*(sin(Msamples(:,2)).^2) + ...
                                 0.1*Msamples(:,3).^4.*sin(Msamples(:,1));
            
            %% Connector set-up
            Spath = fullfile(OpenCossan.getCossanExternalPath,'src','ishigamiFunction');
            % Injector
            Xinjector = Injector('Sscanfilename','input.dat.cossan',... 
                'Sscanfilepath',Spath,...
                'Sfile','input.dat'); 
            % Extractor
            Xresponse = Response('Sname','out',... 
                'ClookOutFor',{'Result'}, ...
                'Ncol',1,'Nrow',1,'Sformat','%9e');
            Xextractor = Extractor('Sfile','result.out','CXresponse',{Xresponse});
            % Connector using local solver
            if ispc
                % Windows solver
                testCase.Xconnector_local = Connector('Sdescription','Connector to test executable',...
                    'Sexecmd','%SsolverBinary %SmainInputFile', ...
                    'SmainInputPath',Spath,...
                    'SmainInputFile','input.dat',...
                    'SsolverBinary',fullfile(OpenCossan.getCossanDistributionPath,'bin','ishigamiFunction.exe'),...
                    'CXmembers',{Xinjector,Xextractor});
            elseif isunix
                % Mac os & linux
                testCase.Xconnector_local = Connector('Sdescription','Connector to test executable',...
                    'Sexecmd','%SsolverBinary %SmainInputFile', ...
                    'SmainInputPath',Spath,...
                    'SmainInputFile','input.dat',...
                    'SsolverBinary',fullfile(OpenCossan.getCossanDistributionPath,'bin','ishigamiFunction'),...
                    'CXmembers',{Xinjector,Xextractor});
            end
            
            try
                testCase.Xjob=JobManager('XjobManagerInterface',JobManagerInterface('Stype','GridEngine'), ...
                    'Squeue','all.q','Shostname','cossan.cfd.liv.ac.uk', ...
                    'Nconcurrent',2,...
                    'Sdescription','JobManager to run the Connector UnitTest');
                    
                testCase.LtestHasGrid = true;
            catch
                testCase.LtestHasGrid = false;
            end
            
            testCase.Xconnector_remote = Connector('Sdescription','Connector to test executable',...
                'Sexecmd','%SsolverBinary %SmainInputFile', ...
                'SmainInputPath',Spath,...
                'SmainInputFile','input.dat',...
                'SsolverBinary',fullfileunix('/home',Susername,'workspace','OpenSourceSoftware','dist','CentOS','6.5','glnxa64','bin','ishigamiFunction'),... % to be pointing to the OpenSourceSoftware on the server
                'CXmembers',{Xinjector,Xextractor});
            
        end % end defineModel
        
        
    end % end TestClassSetup
    
    %%
    
    % Methods Block: Place individual tests in this block
    methods (Test)
        
        %% test 1: check empty Monte Carlo object:
        % Should return expected properties of empty MonteCarlo object
        function testEmptyConnector(testCase)
            % output = 'This checks the expected properties of an empty MonteCarlo object'
            expProp = {'Stype',...
                'Sdescription',...
                'Smaininputfile',...
                'Smaininputpath',...
                'Soutputfile',...
                'SpreExecutionCommand',...
                'SpostExecutionCommand',...
                'Ssolverbinary',...
                'Sexeflags',...
                'SerrorString',...
                'SerrorFileExtension',...
                'Caddfiles',...
                'LkeepSimulationFiles',...
                'CXmembers',...
                'CSmembersNames',...
                'Lremoteprepost',...
                'sleepTime',...
                'matlabInputName',... % should this be private?
                'matlabOutputName',... % should this be private?
                'Sexecmd',...
                'NverboseLevel',...
                'Lremote',...
                'SfolderTimeStamp',...
                'SremoteWorkingDirectory',... % should this be private?
                'Cinputnames',...
                'Coutputnames',...
                'Linjectors',...
                'Lextractors',...
                'SexecutionCommand'}';
            
            Xc = Connector();
            msg = 'Checking actual and expected properties of an empty Monte Carlo Object, not as expected';
            testCase.assertEqual(properties(Xc), expProp, msg);
        end
        % Status: Should Pass
        
        %% test 2: check the input names of the connector are as expected
        function checkInputOutputNames(testCase)
            testCase.assertEqual({'Xrv1','Xrv2','Xrv3','parameterA','parameterB'}, ...
                testCase.Xconnector_local.Cinputnames, ...
                'Connector input names from scanning the .cossan file are not as expected.');
            testCase.assertEqual({'out'}, ...
                testCase.Xconnector_local.Coutputnames, ...
                'Connector output names are not as expected.');
        end
        % Status: Should Pass
        
        %% test 3: deterministic analysis
        function testDeterministicAnalysis(testCase)
            % be that sure the test solver is available 
            testCase.assumeTrue(logical(exist(testCase.Xconnector_local.Ssolverbinary,'file')),...
                ['The test solver is not available in ' testCase.Xconnector_local.Ssolverbinary])
            
            Xout = testCase.Xconnector_local.deterministicAnalysis;
            testCase.assertEqual(Xout.getValues('Sname','out'),0,...
                'Deterministic analysis didn''t return expected value')
        end
        %% test 4: run connector, passing Input object
        function testRunInput(testCase)
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.AbsoluteTolerance
            
            % be sure that the test solver is available 
            testCase.assumeTrue(logical(exist(testCase.Xconnector_local.Ssolverbinary,'file')),...
                ['The test solver is not available in ' testCase.Xconnector_local.Ssolverbinary])
            
            Xout = testCase.Xconnector_local.run(testCase.Xinput);
            testCase.verifyThat(Xout.getValues('Sname','out'),...
                IsEqualTo(testCase.Mexpected,'Within',AbsoluteTolerance(1e-3)),...
                'Run method didn''t return expected values')
        end
        % should pass
        %% test 5: run connector, passing structure
        function testRunStructure(testCase)
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.AbsoluteTolerance
            
            % be sure that the test solver is available 
            testCase.assumeTrue(logical(exist(testCase.Xconnector_local.Ssolverbinary,'file')),...
                ['The test solver is not available in ' testCase.Xconnector_local.Ssolverbinary])
            
            Xout = testCase.Xconnector_local.run(testCase.Xinput.getStructure);
            testCase.verifyThat(Xout.getValues('Sname','out'),...
                IsEqualTo(testCase.Mexpected,'Within',AbsoluteTolerance(1e-3)),...
                'Run method didn''t return expected values')
        end
        % should pass
       
        %% test 6: runjob connector, local inject extract without SSH
        function testRunJobLocalInjExtGrid(testCase)
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.AbsoluteTolerance
            
            % be sure that the test solver is available 
            testCase.assumeTrue(logical(exist(testCase.Xconnector_remote.Ssolverbinary,'file')),...
                ['The test solver is not available in ' testCase.Xconnector_remote.Ssolverbinary])
            
            % this test need to be run a grid machine
            testCase.assumeTrue(testCase.LtestHasGrid,...
                'The test machine is not part of a Grid')
            % this test need to be run without SSH connection
            testCase.assumeFalse(testCase.LtestHasSSH,...
                'This test work with no SSH connection')
            Xout = testCase.Xconnector_remote.runJob('Xinput',testCase.Xinput,...
                'LremoteInjectExtract',false,...
                'XjobManager',testCase.Xjob);
            testCase.verifyThat(Xout.getValues('Sname','out'),...
                IsEqualTo(testCase.Mexpected,'Within',AbsoluteTolerance(1e-3)),...
                'Run method didn''t return expected values')
        end
        % should pass
        %% test 7: runjob connector, remote inject extract without SSH
        function testRunJobRemoteInjExtGrid(testCase)
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.AbsoluteTolerance
            
            % be sure that the test solver is available 
            testCase.assumeTrue(logical(exist(testCase.Xconnector_remote.Ssolverbinary,'file')),...
                ['The test solver is not available in ' testCase.Xconnector_remote.Ssolverbinary])
            
            % this test need to be run a grid machine
            testCase.assumeTrue(testCase.LtestHasGrid,...
                'The test machine is not part of a Grid')
            % this test need to be run without SSH connection
            testCase.assumeFalse(testCase.LtestHasSSH,...
                'This test work with no SSH connection')
            Xout = testCase.Xconnector_remote.runJob('Xinput',testCase.Xinput,...
                'LremoteInjectExtract',true,...
                'XjobManager',testCase.Xjob);
            testCase.verifyThat(Xout.getValues('Sname','out'),...
                IsEqualTo(testCase.Mexpected,'Within',AbsoluteTolerance(1e-3)),...
                'Run method didn''t return expected values')
        end
        % should pass
        %% test 8: runjob connector, local inject extract with SSH
        function testRunJobLocalInjExtSSH(testCase)
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.AbsoluteTolerance
            
            % this test need to be run on a remote grid machine
            testCase.assumeTrue(testCase.LtestHasGrid,...
                'The remote test machine is not part of a Grid')
            % this test need to be run with SSH connection
            testCase.assumeTrue(testCase.LtestHasSSH,...
                'The SSH connection is not available')
            
            % be sure that the test solver is available on the remote
            % machine
            status=OpenCossan.issueSSHcommand(['[ -f ' testCase.Xconnector_remote.Ssolverbinary ' ]']);
            testCase.assumeTrue(status==0,...
                ['The test solver is not available in '...
                testCase.Xconnector_remote.Ssolverbinary ...
                ' on the remote machine.'])
            
            Xout = testCase.Xconnector_remote.runJob('Xinput',testCase.Xinput,...
                'LremoteInjectExtract',false,...
                'XjobManager',testCase.Xjob);
            testCase.verifyThat(Xout.getValues('Sname','out'),...
                IsEqualTo(testCase.Mexpected,'Within',AbsoluteTolerance(1e-3)),...
                'Run method didn''t return expected values')
        end
        % should pass
        %% test 9: runjob connector, remote inject extract with SSH
        function testRunJobRemoteInjExtSSH(testCase)
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.AbsoluteTolerance

            % this test need to be run on a remote grid machine
            testCase.assumeTrue(testCase.LtestHasGrid,...
                'The remote test machine is not part of a Grid')
            % this test need to be run with SSH connection
            testCase.assumeTrue(testCase.LtestHasSSH,...
                'The SSH connection is not available')   
            
            % be sure that the test solver is available on the remote
            % machine
            status=OpenCossan.issueSSHcommand(['[ -f ' testCase.Xconnector_remote.Ssolverbinary ' ]']);
            testCase.assumeTrue(status==0,...
                ['The test solver is not available in '...
                testCase.Xconnector_remote.Ssolverbinary ...
                ' on the remote machine.'])            

            Xout = testCase.Xconnector_remote.runJob('Xinput',testCase.Xinput,...
                'LremoteInjectExtract',true,...
                'XjobManager',testCase.Xjob);
            testCase.verifyThat(Xout.getValues('Sname','out'),...
                IsEqualTo(testCase.Mexpected,'Within',AbsoluteTolerance(1e-3)),...
                'Run method didn''t return expected values')
        end
        % should pass
    end
end