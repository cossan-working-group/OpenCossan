classdef MonteCarloTest < matlab.unittest.TestCase
    % MONTECARLOTEST Unit tests for the class simulations.MonteCarlo
    % see http://cossan.co.uk/wiki/index.php/@MonteCarlo
    %
    % @author Jasper Behrensdorf <behrensdorf@irz.uni-hannover.de>
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
        Xin;
        Xmdl;
        Xpm;
    end
    
    methods (TestClassSetup)
        function setupModel(testCase)
            RV1 = opencossan.common.inputs.random.NormalRandomVariable('mean',0,'std',1);
            RV2 = opencossan.common.inputs.random.NormalRandomVariable('mean',0,'std',1);
            
            Xrvs1 = opencossan.common.inputs.random.RandomVariableSet(...
                'members',[RV1 RV2],'names',["RV1" "RV2"]);
            
            testCase.Xin = opencossan.common.inputs.Input('Description','Input satellite_inp');
            Xthreshold = opencossan.common.inputs.Parameter('value',1);
            Xadditionalparameter = opencossan.common.inputs.Parameter('value',rand(100,1));
            testCase.Xin = add(testCase.Xin,'Member',Xrvs1,'Name','Xrvs1');
            testCase.Xin = add(testCase.Xin,'Member',Xthreshold,'Name','Xthreshold');
            testCase.Xin = add(testCase.Xin,'Member',Xadditionalparameter,'Name','XadditionalParameter'); %#ok<*PROP>
            
            Xm = opencossan.workers.Mio('Script','for j=1:length(Tinput), Toutput(j).out1=sqrt(Tinput(j).RV1^2+Tinput(j).RV2^2); end', ...
                'Format','structure',...
                'Outputnames',{'out1'},...
                'Inputnames',{'RV1','RV2'});
            
            Xeval = opencossan.workers.Evaluator('Xmio',Xm,'Sdescription','Evaluator xmio');

            testCase.Xmdl = opencossan.common.Model('evaluator', Xeval, 'input', testCase.Xin);
            Xperffun = opencossan.reliability.PerformanceFunction('OutputName','Vg','Demand', 'out1', 'Capacity', 'Xthreshold');
            testCase.Xpm = opencossan.reliability.ProbabilisticModel('model', testCase.Xmdl, 'performancefunction', Xperffun);
        end
    end
    
    methods (Test)
        %% constructor
        function constructorEmpty(testCase)
            Xmc = opencossan.simulations.MonteCarlo();
            testCase.assertClass(Xmc,'opencossan.simulations.MonteCarlo');
            testCase.assertEqual(Xmc.Nsamples, 1);
        end
        
        function constructorFull(testCase)
            Xmc = opencossan.simulations.MonteCarlo('Sdescription','Unit Test MonteCarlo',...
                'Nsamples',100,...
                'Nbatches',5,...
                'cov',1,...
                'timeout',10,...
                'confLevel',0.95,...
                'Lintermediateresults',false,...
                'SbatchFolder',fullfile(opencossan.OpenCossan.getRoot(),'tmp','data'));
            
            testCase.assertEqual(Xmc.Sdescription,'Unit Test MonteCarlo');
            testCase.assertEqual(Xmc.Nsamples,100);
            testCase.assertEqual(Xmc.Nbatches,5);
            testCase.assertEqual(Xmc.CoV,1);
            testCase.assertEqual(Xmc.timeout,10);
            testCase.assertEqual(Xmc.confLevel,0.95);
            testCase.assertFalse(Xmc.Lintermediateresults);
            testCase.assertEqual(Xmc.SbatchFolder,fullfile(opencossan.OpenCossan.getRoot(),'tmp','data'));
        end
        
        function constructorShouldFailForInvalidInputs(testCase)
            testCase.assertError(@() opencossan.simulations.MonteCarlo('Nsamples',5,'Nbatches',10,'timeout',5000),...
                'openCOSSAN:simulations:MonteCarlo');
            testCase.verifyError(@() opencossan.simulations.MonteCarlo('Nsamples', 10,'Nbatches',1,'RandomNumberGenerator', 0),...
                'openCOSSAN:simulations:MonteCarlo');
        end
        %% apply
        function applyShouldOutputSimulationData(testCase)
            Nsamples = randi(50,1);
            Xmc = opencossan.simulations.MonteCarlo('Nsamples', Nsamples, 'Nbatches', 1);
            Xout = Xmc.apply(testCase.Xmdl);
            testCase.assertClass(Xout, 'opencossan.common.outputs.SimulationData');
            testCase.assertEqual(Xout.Nsamples, Nsamples);
        end
        
        function applyShouldNotTerminateWithTimeout(testCase)
            Xmc = opencossan.simulations.MonteCarlo('Sdescription', 'Unit Test', 'timeout', 999, 'Nsamples', 1, 'Nbatches', 1);
            tic;
            Xout = Xmc.apply(testCase.Xmdl);
            testCase.assertLessThanOrEqual(toc, Xmc.timeout);
            testCase.assertSubstring(Xout.SexitFlag, 'Maximum no. of samples reached');
        end
        
        function applyShouldTerminateWithTimeout(testCase)
            Xmc = opencossan.simulations.MonteCarlo('Sdescription', 'Unit Test', 'timeout', 0.1, 'Nsamples', 99999999, 'Nbatches', 99999999);
            tic;
            Xout = Xmc.apply(testCase.Xmdl);
            testCase.assertGreaterThanOrEqual(toc, Xmc.timeout);
            testCase.assertSubstring(Xout.SexitFlag, 'Maximum execution time reached');
        end
        
        function applyShouldReturnCorrectExitFlag(testCase)
            Xmc = opencossan.simulations.MonteCarlo('Sdescription', 'Unit Test', 'timeout', 2, 'Nsamples', 999999, 'Nbatches', 999999);
            Xout = Xmc.apply(testCase.Xmdl);
            testCase.assertSubstring(Xout.SexitFlag, 'Maximum execution time reached');
        end
        
        function applyShouldReturnCorrectAmountOfSamples(testCase)
            Xmc = opencossan.simulations.MonteCarlo('Nsamples', 10, 'Nbatches', 10, 'timeout', 5000);
            Xout = Xmc.apply(testCase.Xmdl);
            testCase.assertEqual(Xout.Nsamples, 1);
        end
        
        function applyShouldReturnSameRandomNumberForSameSeed(testCase)
            Xmc = opencossan.simulations.MonteCarlo('Nsamples', 10, 'Nbatches', 1, 'NseedRandomNumberGenerator', 0);
            Xout1 = Xmc.apply(testCase.Xmdl);
            Xmc = opencossan.simulations.MonteCarlo('Nsamples', 10, 'Nbatches', 1, 'NseedRandomNumberGenerator', 0);
            Xout2 = Xmc.apply(testCase.Xmdl);
            testCase.assertEqual(Xout1.getValues('Sname','out1'), Xout2.getValues('Sname','out1'));
        end
        
        %% sample
        function sampleShouldOutputSampleData(testCase)
            Xmc = opencossan.simulations.MonteCarlo('Nbatches', 1);
            Nsamples = randi(50,1);
            Xsample = Xmc.sample('Nsamples', Nsamples, 'Xinput', testCase.Xin);
            testCase.assertClass(Xsample, 'opencossan.common.Samples');
            testCase.assertEqual(Xsample.Nsamples,Nsamples);
        end
        
    end
end
