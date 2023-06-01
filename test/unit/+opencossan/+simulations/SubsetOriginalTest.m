classdef SubsetOriginalTest < matlab.unittest.TestCase
    % SubsetOriginalTest Unit tests for the class simulations.SubsetOriginal
    % see http://cossan.co.uk/wiki/index.php/@SubsetOriginal
    %
    % @author Marvin Kunze
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
            
            Xrvs1 = opencossan.common.inputs.random.RandomVariableSet('Names',["RV1", "RV2"],'Members',[RV1 RV2]);
            
            testCase.Xin = opencossan.common.inputs.Input('Description','Input satellite_inp');
            Xthreshold = opencossan.common.inputs.Parameter('value',1);
            Xadditionalparameter = opencossan.common.inputs.Parameter('value',rand(100,1));
            testCase.Xin = add(testCase.Xin,'Member',Xrvs1,'Name','Xrvs1');
            testCase.Xin = add(testCase.Xin,'Member',Xthreshold,'Name','Xthreshold');
            testCase.Xin = add(testCase.Xin,'Member',Xadditionalparameter,'Name','XadditionalParameter'); %#ok<*PROP>
            
            Xm = opencossan.workers.Mio('Script','for j=1:length(Tinput), Toutput(j).out1=0.35*sqrt(Tinput(j).RV1^2+Tinput(j).RV2^2); end', ...
                'Format','structure',...
                'Outputnames',{'out1'},...
                'Inputnames',{'RV1','RV2'});
            
            Xeval = opencossan.workers.Evaluator('Xmio',Xm,'Sdescription','Evaluator xmio');
            testCase.Xmdl = opencossan.common.Model('Evaluator', Xeval, 'Input', testCase.Xin);
            Xperffun = opencossan.reliability.PerformanceFunction('OutputName','Vg','Demand', 'out1', 'Capacity', 'Xthreshold');
            testCase.Xpm = opencossan.reliability.ProbabilisticModel('Model', testCase.Xmdl, 'PerformanceFunction', Xperffun);
        end
    end
    
    methods (Test)
        %% constructor
        function constructorShouldFailWithoutSamples(testCase)
            testCase.assertError(@() opencossan.simulations.SubsetOriginal(),...
                'openCOSSAN:SubsetOriginal:missingArgument');
            testCase.assertError(@() opencossan.simulations.SubsetOriginal('KeepSeeds', false),...
                'openCOSSAN:SubsetOriginal:missingArgument');
        end
        
        function constructorFull(testCase)
            SubS = opencossan.simulations.SubsetOriginal('Sdescription','Unit Test SubsetOriginal',...
                'initialSamples',100,...
                'target_pf', 0.2,...
                'maxlevels', 7,...
                'deltaxi', 0.6,...
                'KeepSeeds', false);
            
            testCase.assertEqual(SubS.Sdescription,'Unit Test SubsetOriginal');
            testCase.assertEqual(SubS.initialSamples,100);
            testCase.assertEqual(SubS.target_pf, 0.2);
            testCase.assertEqual(SubS.maxlevels, 7);
            testCase.assertEqual(SubS.deltaxi, 0.6);
            testCase.assertFalse(SubS.KeepSeeds);
        end
        
        function constructorShouldFailForInvalidInputs(testCase)
            testCase.assertError(@() opencossan.simulations.SubsetOriginal('initialSamples', 1000, 'CoV', 1),...
                'openCOSSAN:simulations:SubsetOriginal');
            testCase.assertError(@() opencossan.simulations.SubsetOriginal('initialSamples', 1000,...
                'SbatchFolder', fullfile(opencossan.OpenCossan.getRoot(),'tmp','data')),...
                'openCOSSAN:SubsetOriginal:wrongArgument');
        end
        %% apply
        function assertNotUsableWithSubsetSimulation(testCase)
            SubS = opencossan.simulations.SubsetOriginal('initialSamples', 1000);
            testCase.assertError(@() SubS.apply(testCase.Xmdl),...
                'openCOSSAN:simulations:subsetoriginal:apply');
        end
        %% sample
        function sampleShouldNotBeImplementedForSubset(testCase)
            SubS = opencossan.simulations.SubsetOriginal('initialSamples', 1000);
            Nsamples = randi(50,1);
            testCase.assertError(@() SubS.sample('Nsamples', Nsamples, 'Xinput', testCase.Xin),...
                'MATLAB:class:undefinedMethod');
        end
        %% computeFailureProbabiliy
        function computeFailureProbabilityShouldOutputSampleData(testCase)
            SubS = opencossan.simulations.SubsetOriginal('initialSamples', 100);
            [SubRes, SubOut] = SubS.computeFailureProbability(testCase.Xpm);
            testCase.assertClass(SubRes, 'opencossan.reliability.FailureProbability');
            testCase.assertClass(SubOut, 'opencossan.simulations.SubsetOutput');
            testCase.assertNotEmpty(SubRes.pfhat);
            testCase.assertNotEmpty(SubRes.stdPfhat);
            testCase.assertNotEmpty(SubRes.cov);
            testCase.assertNotEqual(SubRes.pfhat, NaN);
            testCase.assertNotEqual(SubRes.stdPfhat, NaN);
            testCase.assertNotEqual(SubRes.cov, NaN);
        end
        
        function computeFailureProbabilityDiscardSeedsShouldOutputSampleData(testCase)
            SubS = opencossan.simulations.SubsetOriginal('initialSamples', 100, 'KeepSeeds', false);
            [SubRes, SubOut] = SubS.computeFailureProbability(testCase.Xpm);
            testCase.assertClass(SubRes, 'opencossan.reliability.FailureProbability');
            testCase.assertClass(SubOut, 'opencossan.simulations.SubsetOutput');
            testCase.assertNotEmpty(SubRes.pfhat);
            testCase.assertNotEmpty(SubRes.stdPfhat);
            testCase.assertNotEmpty(SubRes.cov);
            testCase.assertNotEqual(SubRes.pfhat, NaN);
            testCase.assertNotEqual(SubRes.stdPfhat, NaN);
            testCase.assertNotEqual(SubRes.cov, NaN);
        end
    end
end