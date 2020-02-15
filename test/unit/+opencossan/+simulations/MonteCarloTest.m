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
            
            Xthreshold = opencossan.common.inputs.Parameter('value',1);
            Xadditionalparameter = opencossan.common.inputs.Parameter('value',[1, 2, 3]);
            
            testCase.Xin = opencossan.common.inputs.Input(...
                'Members', {Xrvs1, Xthreshold, Xadditionalparameter}, ...
                'Names', ["Xrvs1", "Xthreshold" "Xadditionalparameter"]);
            
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
        
        %% sample
        function sampleShouldOutputTable(testCase)
            Xmc = opencossan.simulations.MonteCarlo('Nsamples', 10);
            
            inputSamples = testCase.Xin.sample('Samples', 10);
            mcSamples = Xmc.sample('XInput', testCase.Xin, 'Nsamples', 10);
            
            testCase.verifyEqual(height(mcSamples), 10);
            testCase.verifyEqual(inputSamples.Properties.VariableNames, ...
                mcSamples.Properties.VariableNames);
        end
        
    end
end
