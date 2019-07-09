classdef ProbabilisticModelTest < matlab.unittest.TestCase
    % PROBABILISTICMODELTEST Unit tests for the class
    % reliability.ProbabilisticModel
    % see http://cossan.co.uk/wiki/index.php/@ProbabilisticModel
    %
    % @author Jasper Behrensdorf <behrensdorf@irz.uni-hannover.de>
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
        Model;
        PerformanceFunction;
    end
    
    methods (TestMethodSetup)
        function setupModel(testCase)
            Xvar1 = common.inputs.RandomVariable('Sdistribution','normal','mean',0,'std',1);
            Xrvset = common.inputs.RandomVariableSet('CXrandomvariables',{Xvar1},'Cmembers',{'Xvar1'});
            Xpar = common.inputs.Parameter('value',3);
            Xinp = common.inputs.Input('Xrvset',Xrvset,'Xparameter',Xpar);
            
            Xinp = Xinp.sample('Nsamples',100);
            Xmio = workers.Mio('Sscript','for i=1:length(Tinput); Toutput(i).out1= Tinput(i).Xvar1;end;',...
                'Cinputnames',{'Xvar1'},'Coutputnames',{'out1'},'Sformat','structure');
            testCase.Model = common.Model('Xevaluator', workers.Evaluator('Xmio',Xmio),'Xinput',Xinp);
        end
        
        function setupPerformanceFunction(testCase)
            testCase.PerformanceFunction = reliability.PerformanceFunction('OutputName','vg','Capacity','Xpar','Demand','out1'); 
        end
    end
    
    methods (Test)
        %% constructor
        function constructorEmpty(testCase)
            Xpm = reliability.ProbabilisticModel();
            testCase.assertClass(Xpm,'reliability.ProbabilisticModel');
        end
        
        function constructorFull(testCase)
            Xpm = reliability.ProbabilisticModel('Xmodel',testCase.Model,...
                'XperformanceFunction',testCase.PerformanceFunction);
            
            testCase.assertEqual(Xpm.Cinputnames,{'Xvar1' 'Xpar'});
            testCase.assertEqual(Xpm.Coutputnames,{'out1' 'vg'});
            testCase.assertEqual(Xpm.Xevaluator.CXsolvers{1}, testCase.Model.Xevaluator.CXsolvers{1});
            testCase.assertEqual(Xpm.Xevaluator.CXsolvers{2}, testCase.PerformanceFunction);
        end
        
        function constructorShouldFailForInvalidInputs(testCase)
            testCase.assertError(@() reliability.ProbabilisticModel('Xmodel',common.inputs.Input(),...
                'XperformanceFunction',testCase.PerformanceFunction),...
                'openCOSSAN:reliability:ProbabilisticModel');
            testCase.assertError(@() reliability.ProbabilisticModel('Xmodel',testCase.Model,...
                'XperformanceFunction',common.inputs.Input()),...
                'openCOSSAN:reliability:ProbabilisticModel');
        end
        
        %% computeFailureProbability
        function computeFailureProbability(testCase)
            Xpm = reliability.ProbabilisticModel('Xmodel',testCase.Model,...
                'XperformanceFunction',testCase.PerformanceFunction);
            
            Xmc = simulations.MonteCarlo('Nsamples',100);
            Xpf = Xpm.computeFailureProbability(Xmc);
            
            testCase.assertClass(Xpf,'reliability.FailureProbability');
        end
        
        function computeFailureProbabilityShouldFailWithoutSimulation(testCase)
            Xpm = reliability.ProbabilisticModel('Xmodel',testCase.Model,...
                'XperformanceFunction',testCase.PerformanceFunction);
            
            testCase.assertError(@() Xpm.computeFailureProbability(common.inputs.Input()),...
                'openCOSSAN:ProbabilisticModel:computeFailureProbability');
        end
        
        %% designPointIdentification
        function designPointIdentification(testCase)
            Xpm = reliability.ProbabilisticModel('Xmodel',testCase.Model,...
                'XperformanceFunction',testCase.PerformanceFunction);
            
            Xdp = Xpm.designPointIdentification();
            testCase.assertClass(Xdp,'reliability.DesignPoint');
            testCase.assertEqual(Xdp.VDesignPointPhysical, 3);
        end
        
        %% deterministicAnalysis
        function deterministicAnalysis(testCase)
            Xpm = reliability.ProbabilisticModel('Xmodel',testCase.Model,...
                'XperformanceFunction',testCase.PerformanceFunction);
            
            Xout = Xpm.deterministicAnalysis();
            testCase.assertClass(Xout,'common.outputs.SimulationData');
            testCase.assertSize(Xout.getValues('Sname','out1'),[100 1]);
            testCase.assertSize(Xout.getValues('Sname','vg'),[100 1]);
        end       
        
    end
    
end

