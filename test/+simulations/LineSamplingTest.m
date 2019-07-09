%% UNIT TEST FOR @FUNCTION
% The class tested here can be found at: http://cossan.co.uk/wiki/index.php/@LineSampling
%%
% Author: Umar Razzaq
% Revised by Edoardo Patelli
%%
% Individual tests have been split into their own sections to make it easy
% to find out what each test does.

%% xUnit sub-class defintion
% This sub-class inherits from matlab.unittest.TestCase
classdef LineSamplingTest < matlab.unittest.TestCase
    %% xUnit sub-class defintion
    % This sub-class inherits from matlab.unittest.TestCase
    properties
        RV1;
        RV2;
        Xrvs1;
        Xthreshold;
        Xin;
        Xm;
        Xeval;
        Xmdl;
        XlsFD;
        Xgrad;
        X1;
        X2;
        Xrvs2;
        Xinput2;
        Xpm;
        Xperffun;
    end
    
    %% Class Fixture
    % This sets up the problem from the tutorial using example 1 and 2
    methods (TestClassSetup)
        
        function defineFirstModel(testCase)
            % define Random Variables:
            testCase.RV1=common.inputs.RandomVariable('Sdistribution','normal', 'mean',0,'std',1);
            testCase.RV2=common.inputs.RandomVariable('Sdistribution','normal', 'mean',0,'std',1);
            
            % define Random Variable Set:
            testCase.Xrvs1=common.inputs.RandomVariableSet('CSmembers',{'RV1', 'RV2'},'CXrandomVariables',{testCase.RV1, testCase.RV2});
            
            % add parameter for performance function:
            testCase.Xthreshold=common.inputs.Parameter('value',2);
            
            % construct input object:
            testCase.Xin = common.inputs.Input('Sdescription','Input Object of our model', ...
                'CXmembers',{testCase.Xrvs1 testCase.Xthreshold},'CSmembers',{'Xrvs1' 'Xthreshold'});
            
            % construct Mio object:
            testCase.Xm = workers.Mio('Sdescription', 'Model Definition',...
                'Sscript','for j=1:length(Tinput), Toutput(j).out=-Tinput(j).RV1+Tinput(j).RV2+Tinput(j).RV2.^2; end', ...
                'Sformat','structure',...
                'Coutputnames',{'out'},...
                'Cinputnames',{'RV1' 'RV2'});
            
            % construct evaluator:
            testCase.Xeval = workers.Evaluator('Xmio',testCase.Xm,'Sdescription','evaluator for tutorial');
            
            % define a physical model:
            testCase.Xmdl = common.Model('Xevaluator', testCase.Xeval, 'Xinput', testCase.Xin);
            
            % generate 10 samples:
            testCase.Xin = sample(testCase.Xin,'Nsamples',10);
            
            % define important direction:
            testCase.XlsFD=sensitivity.LocalSensitivityFiniteDifference('Xmodel',testCase.Xmdl,'Coutputnames',{'out'});
            
            % Compute the Gradient
            testCase.Xgrad = testCase.XlsFD.computeGradient;
            
            % construct performance function:
            testCase.Xperffun=reliability.PerformanceFunction('OutputName','Vg','Demand','RV1','Capacity','Xthreshold');
            
            % construct a probablistic model:
            testCase.Xpm=reliability.ProbabilisticModel('XModel',testCase.Xmdl,'XPerformanceFunction',testCase.Xperffun);
            
        end % end define first model
        
        % using example 2:
        function defineSecondModel(testCase)
            
            % Random Variables:
            testCase.X1=common.inputs.RandomVariable('Sdistribution','normal', 'mean',7,'std',2);
            testCase.X2=common.inputs.RandomVariable('Sdistribution','normal', 'mean',7,'std',2);
            
            % Define Random Variable Set:
            testCase.Xrvs2 = common.inputs.RandomVariableSet('CSmembers',{'X1', 'X2'},...
                'CXrandomVariables',{testCase.X1, testCase.X2});
            
            % Define Input Object:
            testCase.Xinput2 = common.inputs.Input('Sdescription','Input Object', ...
                'CXmembers',{testCase.Xrvs2},...
                'CSmembers',{'Xrvs2'});
            
            % Define Evaluator:
        end
    end
    
    %%
    
    % Methods Block: Place individual tests in this block
    methods (Test)
        
        %% test 1: test object properties
        % This test checks that the constructor returns an object back with
        % correct properties and values
        function testCreateEmptyLineSampling(testCase)
            Xls = simulations.LineSampling;
            testCase.assertClass(Xls,'simulations.LineSampling');
            
            % Test constructor
            Xls = simulations.LineSampling('Sdescription', 'First Empty Object',...
                'Nsamples', 6,...
                'Nbatches', 1,...
                'Xgradient',testCase.Xgrad);
            
            testCase.assertEqual(Xls.Nsamples, 6);
            testCase.assertEqual(Xls.Nbatches, 1);
            testCase.assertEqual(Xls.Sdescription, 'First Empty Object')
        end
        %%
        %
        %
        % Status: Should Pass
        %% test 2: test no Xgrad
        % When no important direction is passed it should show an error
        function testNoGradientLineSampling(testCase)
            Xls = simulations.LineSampling('Sdescription', 'First Empty Object',...
                'Nsamples', 6,...
                'Nbatches', 1);
            testCase.assertError(@()Xls.sample('Xinput',testCase.Xin) ,'openCOSSAN:LineSampling:sample')
        end
        %%
        %
        %
        % Status: Should Pass
        
        %% test 3: pass LexportSamples
        % This should fail when LexportSamples passed as input
        function testLexportSamplesLineSampling(testCase)
            try
                simulations.LineSampling('Sdescription', 'LineSampling unit test #1',...
                    'Nsamples',6,...
                    'Nbatches',1,...
                    'LexportSamples',true,...
                    'Xgradient',testCase.Xgrad);
            catch err
                testCase.assertEqual(err.identifier, 'openCOSSAN:LineSampling:wrongArgument');
            end
        end
        %%
        %
        %
        % Status: Should Pass
        
        %% test 4: not enough samples
        % this should fail when not enough samples are passed. The number
        % of batches cannot be greater than the number of lines. The number
        % of samples should be greater than 60 (Nsamples)
        function testVsetLineSampling(testCase)
            testCase.assertError(@()simulations.LineSampling('Sdescription', 'First Empty Object',...
                'Nsamples', 60,...
                'Nbatches', 1,...
                'Vset', 1:0.1:7,...
                'Xgradient',testCase.Xgrad),'openCOSSAN:simulations:LineSampling');
        end
        %%
        %
        %
        % Status: Should Pass
        %% test 5: test Vset
        % This is the same as the previous test however this time there are
        % enough samples. This test checks the Nlastbatch property.
        function testVsetx2LineSampling(testCase)
            Xls=simulations.LineSampling('Sdescription', 'LineSample Object',...
                'Nsamples',70,...
                'Nbatches',1,...
                'Vset',1:0.5:4,...
                'Xgradient',testCase.Xgrad);
            testCase.assumeEqual(Xls.Nlastbatch, 70)
        end
        %%
        %
        %
        % Status: Should Pass
        
        %% test 6: test 2 batches
        % This works by having 70 samples and 2 batches. Each batch should have 35 samples
        function testVsetx3LineSampling(testCase)
            Xls=simulations.LineSampling('Sdescription', 'LineSample Object',...
                'Nsamples',70,...
                'Nbatches',2,...
                'Vset',1:0.5:4,...
                'Xgradient',testCase.Xgrad);
            testCase.assumeEqual(Xls.Nlastbatch, 35)
        end
        
        %%
        % TODO XRandomNumberGenerator expects a CossanObject which
        % RandStream is not
        function shouldAcceptRandStream(testCase)
            assumeFail(testCase);
            randStream = RandStream('mlfg6331_64','Seed','shuffle');
            
            Xls=simulations.LineSampling('Sdescription', 'LineSample Object',...
                'Nsamples',35,...
                'Nbatches',1,...
                'Vset',1:0.5:4,...
                'Xgradient',testCase.Xgrad,...
                'XRandomNumberGenerator', randStream);
            
            testCase.assertEqual( Xls.XrandomStream.Type,randStream.Type)
        end
        
        function shouldAcceptSeed(testCase)
            Xls=simulations.LineSampling('Sdescription', 'LineSample Object',...
                'Nsamples',35,...
                'Nbatches',1,...
                'Vset',1:0.5:4,...
                'Xgradient',testCase.Xgrad,...
                'NseedRandomNumberGenerator', 835476);
            
            testCase.assertEqual(double(Xls.XrandomStream.Seed),835476)
        end
        %%
        %
        %
        % Status: Should Pass, however this test should be changed once the RandStream error is sorted out. This is because the exception will not be thrown if there is no error.
        
        %       Error using RandStream.getDefaultStream (line 457)
        %       The RandStream.getDefaultStream static method has been removed.  Use
        %       RandStream.getGlobalStream instead.
        %
        %       Error in Simulations/initializeUserDefinedRandomNumberGenerator (line
        %       32)
        %       XRandomNumberGenerator   = RandStream.getDefaultStream;
        %
        %       Error in LineSampling/apply (line 48)
        %       XRandomNumberGenerator = ...
        
        
        %% test 7: test XrandomNumberGenerator
        % Change random stream from
        % Mersenne twister standard to Multiplication lagged fib generator,
        % mlfg6331_64, there should be no error here
        % This test should not pass
        %         function testXrandomNumberGenerator(testCase)
        %                 try
        %                 s = RandStream('mlfg6331_64','Seed','shuffle')
        %                 RandStream.setGlobalStream(s);
        %                 Xls=LineSampling('Sdescription', 'LineSample Object',...
        %                     'Nsamples',35,...
        %                     'Nbatches',1,...
        %                     'Vset',1:0.5:4,...
        %                     'Xgradient',testCase.Xgrad,...
        %                     'XRandomNumberGenerator', s);
        %                 Xsample=Xls.sample('Xinput',testCase.Xin);
        %                 Xo =Xls.apply(testCase.Xmdl);
        %                 catch err
        %                     testCase.assertEqual(err.identifier, 'MATLAB:RandStream:GetDefaultStream')
        %                 end
        %         end
        %%
        %
        %
        % Status: Should Pass, however this test should be changed once the RandStream error is sorted out. This is because the exception will not be thrown if there is no error.
        
        
        
        %% test 9: test sample method
        % This should give gradient error because a different input is
        % passed into sample. This gradient cannot be used with this input
        function testSampleMethodLineSampling(testCase)
            Xls = simulations.LineSampling('Sdescription', 'First Empty Object',...
                'Nsamples', 6,...
                'Nbatches', 1,...
                'Xgradient',testCase.Xgrad);
            
            testCase.assertError(@()Xls.sample('Nlines', 10, 'Xinput', testCase.Xinput2),'openCOSSAN:LineSampling:sample');
        end
        %%
        %
        %
        % Status: Should Pass
        
        %% test 10: test without a model
        % TODO: Simulation.checkInputs needs to check for valid input
        function testWithoutModelLineSampling(testCase)
            assumeFail(testCase); %Skip test
            Xls = simulations.LineSampling('Sdescription', 'First Empty Object',...
                'Nsamples', 6,...
                'Nbatches', 1,...
                'Xgradient',testCase.Xgrad);
            
            testCase.assertError(@()Xls.apply(testCase.Xin),'openCOSSAN:Simulations:checkInputs');
        end
        %%
        %
        %
        % Status: Should Pass
        
        %% test 14: test timeout
        % This test passes a very short timeout value to the constructor
        % which should then cause the SexitFlag to contain a maximum time
        % reached string
        function testTimeoutCriteriaLineSampling(testCase)
            Xls = simulations.LineSampling('Sdescription', 'First Empty Object',...
                'timeout', 0.01,...
                'Nsamples', 6,...
                'Nbatches', 1,...
                'Xgradient',testCase.Xgrad);
            tic;
            Xopf  = Xls.computeFailureProbability(testCase.Xpm);
            time = toc;
            if time > 0.01
                actFlag = logical(strfind(Xopf.SexitFlag, 'Maximum execution time reached.'));
                testCase.assertTrue(actFlag)
            end
        end
        %%
        %
        %
        % Status: Should Pass
        
        %% test 15: test CoV criteria
        % This test passes a very short CoV that should be reached, like
        % the previous test it checks if the correct string is contained in
        % the flag.
        function testCoVreachedLineSampling(testCase)
            Xg=sensitivity.LocalSensitivityFiniteDifference('Xtarget',testCase.Xpm,'Coutputname',{testCase.Xpm.SperformanceFunctionVariable}).computeGradient();
            Xls = simulations.LineSampling('Sdescription', 'First Empty Object',...
                'Nsamples', 600,...
                'cov', 0.1,...
                'Nbatches', 10,...
                'Xgradient',testCase.Xgrad);
            
            Xopfl  = Xls.computeFailureProbability(testCase.Xpm);
            ExpexitFlag = 'Target CoV level reached.';
            testCase.assumeTrue(logical(strfind(Xopfl.SexitFlag,ExpexitFlag)));
        end
        %%
        %
        %
        % Status: Should Pass
        
        %% test 17: test empty class
        % This test should return an empty LineSampling Object
        function testGenerateSamplesLineSampling(testCase)
            Xls =simulations.LineSampling('Nlines',20,'Xgradient',testCase.Xgrad);
            Xsample=Xls.sample('Xinput',testCase.Xin);
            
            testCase.assertClass(Xsample, 'common.Samples');
        end
        %%
        %
        %
        % Status: Should Pass
        
        % test 18: test sample method
        % This tests that the sample method produces the same number of
        % samples as those in the LineSampling object (6 * 20 = 120)
        function testNumberOfSamplesLineSampling(testCase)
            Xls =simulations.LineSampling('Nlines',20,'Xgradient',testCase.Xgrad);
            Xsample=Xls.sample('Xinput',testCase.Xin);
            testCase.assertEqual(Xsample.Nsamples, Xls.Nsamples);
            
        end
        %%
        %
        %
        % Status: Should Pass
        
        %% test 19: Nsamples
        % This tests that the number of points is equal to the number of
        % samples (6 * 20 = 120)
        function testLineSamplingPointsLineSimulation(testCase)
            Xls =simulations.LineSampling('Nlines',20,'Xgradient',testCase.Xgrad);
            Xsample=Xls.sample('Xinput',testCase.Xin);
            Xo =Xls.apply(testCase.Xmdl);
            
            testCase.assertEqual(Xo.Npoints, Xls.Nsamples);
        end
        %%
        %
        %
        % Status: Should Pass
        
        %% test 20: check SexitFlag
        % This checks the SexitFlag is correct when all samples are
        % computed.
        function testSexitFlagLineSimulation(testCase)
            Xls =simulations.LineSampling('Nlines',20,'Xgradient',testCase.Xgrad);
            Xsample=Xls.sample('Xinput',testCase.Xin);
            Xo =Xls.apply(testCase.Xmdl);
            SexitFlag = 'Maximum no. of samples reached. Samples computed 120; Maximum allowed samples: 120';
            
            testCase.assertEqual(Xo.SexitFlag, SexitFlag);
        end
        %%
        %
        %
        % Status: Should Pass
        
        %% test 21: check display works
        % Save command window output to a file, which is then read and
        % checked to see if it contains a line from LineSampling output.
        function checkDisplayWorksLineSampling(testCase)
            Xls = simulations.LineSampling();
            diary('outputWorks');
            Xls.display()
            diary off
            content = fileread('outputWorks');
            testCase.assertTrue(all(strfind(content, '* Number of elements: 0')) );
        end
        %%
        %
        %
        % Status: Should Pass
    end
end