classdef SubsetInfiniteTest < matlab.unittest.TestCase
    % SubsetInfiniteTest Unit tests for the class simulations.SubsetInfinite
    % see http://cossan.co.uk/wiki/index.php/@SubsetInfinite
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
            Xthreshold = opencossan.common.inputs.Parameter('value',1);
            
            testCase.Xin = opencossan.common.inputs.Input('Names', ["Xrvs1", "Xthreshold"], ...
                'Members', {Xrvs1, Xthreshold});
            
            Xm = opencossan.workers.Mio('Script','for j=1:length(Tinput), Toutput(j).out1=0.35*sqrt(Tinput(j).RV1^2+Tinput(j).RV2^2); end', ...
                'Format','structure', ...
                'Outputnames',{'out1'}, ...
                'Inputnames',{'RV1','RV2'});
            
            Xeval = opencossan.workers.Evaluator('Xmio',Xm,'Sdescription','Evaluator xmio');
            testCase.Xmdl = opencossan.common.Model('Evaluator', Xeval, 'Input', testCase.Xin);
            Xperffun = opencossan.reliability.PerformanceFunction('OutputName','Vg','Demand', 'out1', 'Capacity', 'Xthreshold');
            testCase.Xpm = opencossan.reliability.ProbabilisticModel('Model', testCase.Xmdl, 'PerformanceFunction', Xperffun);
        end
    end
    
    methods (Test)
        %% constructor
        
        function constructorFull(testCase)
            SubS = opencossan.simulations.SubsetInfinite('Description','Unit Test SubsetInfinite',...
                'initialSamples',100,...
                'targetprobabilityoffailure', 0.2,...
                'maxlevels', 7,...
                'deltaxi', 0.6,...
                'proposalStd', 0.4,...
                'updateStd', true);
            
            testCase.assertEqual(SubS.InitialSamples,100);
            testCase.assertEqual(SubS.TargetProbabilityOfFailure, 0.2);
            testCase.assertEqual(SubS.MaxLevels, 7);
            testCase.assertEqual(SubS.DeltaXi, 0.6);
            testCase.assertEqual(SubS.ProposalStd, 0.4);
            testCase.assertTrue(SubS.UpdateStd);
        end
        
        %% computeFailureProbabiliy
        function computeFailureProbabilityShouldOutputSampleData(testCase)
            SubS = opencossan.simulations.SubsetInfinite('initialSamples', 100, 'proposalStd', 0.5, 'seed', 8128);
            pf = SubS.computeFailureProbability(testCase.Xpm);
            
            testCase.assertClass(pf, 'opencossan.reliability.FailureProbability');
        end
    end
end