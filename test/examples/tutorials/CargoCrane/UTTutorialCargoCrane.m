classdef UTTutorialCargoCrane < matlab.unittest.TestCase                          %Enter Script name after UT
    
    properties
        TestNum     = 11;                                         %Enter Test Number
        PreTest     = {[]};                                     %Enter the names of any scripts that need to be run
                                                                %prior to performing the test into a cell array.
        Name        = 'TutorialCargoCrane';                                       %Enter the name of the script to be tested.
        VName       = {'Xout1.Tvalues.U1_Node104.Mdata'};                                     %Enter Variable Names into cell array
        Expected    = {[0  1.1296e-04  6.0031e-04  1.2209e-03  1.7666e-03  2.4168e-03 ...
     3.0162e-03  3.4425e-03  3.6957e-03  3.6469e-03  3.2817e-03  2.8180e-03 ...
     2.3059e-03  1.6838e-03  1.1684e-03  9.5108e-04  9.9018e-04  1.2522e-03 ...
     1.6610e-03  2.1058e-03  2.5696e-03  2.9903e-03  3.2392e-03  3.2808e-03 ...
     3.1527e-03  2.8682e-03  2.4562e-03  2.0065e-03  1.6190e-03  1.3821e-03 ...
     1.3346e-03  1.4347e-03  1.6447e-03  1.9530e-03  2.3116e-03  2.6440e-03 ...
     2.8846e-03  2.9929e-03  2.9590e-03  2.7963e-03  2.5300e-03  2.0989e-03 ...
     1.3185e-03  4.8885e-04 -1.6090e-04 -8.0587e-04 -1.2962e-03 -1.5277e-03 ...
    -1.5319e-03 -1.2291e-03 -6.5720e-04 -6.9253e-05  4.6698e-04  1.0100e-03 ...
     1.3619e-03  1.3700e-03  1.1194e-03  6.8090e-04  1.5667e-04 -3.2833e-04 ...
    -7.5148e-04]};                                     %Enter the expected results into cell array
        Tolerance   = {0.0001};                                     %Enter the given tolerances into cell array
        NumOfTests  = 1;                                         %Enter the number of tests being performed (no. of variables)
        
        Actual      = [];
        ErrorPC     = [];
        ErrorPCT    = [];
        SLocation   = pwd;
    end
    
    methods(TestMethodSetup)
        function Initiate(TestCase)
            
            for i = 1:length(TestCase.PreTest)
                if isempty(TestCase.PreTest{i}) == 0;
                    eval(TestCase.PreTest{i});
                end
            end
            
            eval(TestCase.Name);
            
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
