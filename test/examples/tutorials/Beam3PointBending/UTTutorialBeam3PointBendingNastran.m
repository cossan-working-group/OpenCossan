classdef UTTutorialBeam3PointBendingNastran < matlab.unittest.TestCase                          %Enter Script name after UT
    
    properties
        TestNum     = 5;                                         %Enter Test Number
        PreTest     = {[]};                                     %Enter the names of any scripts that need to be run
                                                                %prior to performing the test into a cell array.
        Name        = 'TutorialBeam3PointBendingNastran';                                       %Enter the name of the script to be tested.
        VName       = {'Xpf'};                                     %Enter Variable Names into cell array
        Expected    = {[0.07]};                                     %Enter the expected results into cell array
        Tolerance   = {[5E-3]};                                     %Enter the given tolerances into cell array
        NumOfTests  = 1;                                         %Enter the number of tests being performed (no. of variables)
        
        Actual      = [];
        ErrorPC     = [];
        ErrorPCT    = [];
        SLocation   = pwd;
    end
    
    methods(TestMethodSetup)
        function Initiate(TestCase)
            
            for i = 1:length(TestCase.PreTest)
                TestCase.PreTest{i};
            end
            
            eval(TestCase.Name);
            TutorialBeam3PointBendingPerformReliabilityAnalysis;
            
            for i = 1:TestCase.NumOfTests
                TestCase.Actual{i} = eval(TestCase.VName{i});
            end
        end
    end

    methods (TestMethodTeardown)
        function SaveData(TestCase)
            if exist(fullfile(TestCase.SLocation,'TestData.mat'))
                load(fullfile(TestCase.SLocation,'TestData.mat'),'TestData');
            else
                TestData = struct('Script',[],'NumberOfTests',[],'VariableNames',[],'Expected',[],...
                                    'Tolerance',[],'Actual',[],'ErrorPC',[],'ErrorPCofTol',[],...
                                        'Test',[]);
            end
            
            TestData(TestCase.TestNum).Script           = TestCase.Name;
            TestData(TestCase.TestNum).NumberOfTests    = TestCase.NumOfTests;
            TestData(TestCase.TestNum).VariableNames    = TestCase.VName;
            
            TestData(TestCase.TestNum).Expected         = TestCase.Expected;
            TestData(TestCase.TestNum).Tolerance        = TestCase.Tolerance;
            TestData(TestCase.TestNum).Actual           = TestCase.Actual;
            TestData(TestCase.TestNum).ErrorPC{length(TestData(TestCase.TestNum).ErrorPC)+1}...
                                                        = TestCase.ErrorPC;
            TestData(TestCase.TestNum).ErrorPCofTol{length(TestData(TestCase.TestNum).ErrorPCofTol)+1}...
                                                        = TestCase.ErrorPCT;
            
            save(fullfile(TestCase.SLocation,'TestData.mat'),'TestData');
        end
    end
    
    methods (Test)                                              %Remove Tests below as appropriate for the number of variables
        function UnitTest1(TestCase)
            [r,c] = size(TestCase.Actual{1});
            for j = 1:r
                for i = 1:c
                    TestCase.verifyEqual(TestCase.Actual{1}(j,i),TestCase.Expected{1}(j,i),'AbsTol',TestCase.Tolerance{1});
                
                    TestCase.ErrorPC(j,i)  = (abs(TestCase.Actual{1}(j,i)-TestCase.Expected{1}(j,i))/TestCase.Expected{1}(j,i))*100;
                    TestCase.ErrorPCT(j,i) = (abs(TestCase.Actual{1}(j,i)-TestCase.Expected{1}(j,i))/TestCase.Tolerance{1})*100;
                end
            end
        end
    end
    
end
