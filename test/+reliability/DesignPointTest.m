classdef DesignPointTest < matlab.unittest.TestCase
    % DESIGNPOINTTEST Unit tests for the class
    % reliability.DesignPoint
    % see http://cossan.co.uk/wiki/index.php/@DesignPoint
    %
    % @author Jasper Behrensdorf<behrensdorf@irz.uni-hannover.de>
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
        ProbabilisticModel;
    end
    
    methods (TestMethodSetup)
        function setupProbabilisticModel(testCase)
            Xrv1 = common.inputs.RandomVariable('Sdistribution','normal', 'mean',1,'std',0.5);
            Xrv2 = common.inputs.RandomVariable('Sdistribution','normal', 'mean',-1,'std',2);
            Xrvs1 = common.inputs.RandomVariableSet('Cmembers',{'Xrv1','Xrv2'},'CXrv',{Xrv1 Xrv2});
            Xin = common.inputs.Input('CXmembers',{Xrvs1},'CSmembers',{'Xrvs1'});
            
            Xm = workers.Mio('Sdescription','normalized demand', ...
                'Spath','./',...
                'Sscript','Toutput.D=Tinput.RV1;',...
                'Sformat','structure',...
                'Lfunction',false,...
                'Cinputnames',{'Xrv1','Xrv2'},...
                'Coutputnames',{'D','C'});
          
            Xeval = workers.Evaluator('Xmio',Xm,'Sdescription','Evaluator xmio');
            
            Xmdl = common.Model('Xevaluator',Xeval,'Xinput',Xin);
            
            Xperf = reliability.PerformanceFunction('OutputName','Vg','Capacity','C','Demand','D');
            
            testCase.ProbabilisticModel = reliability.ProbabilisticModel('Xmodel',Xmdl,'XperformanceFunction',Xperf);
        end
    end
    
    methods (Test)
        %% constructor
        function constructorEmpty(testCase)
            Xdp = reliability.DesignPoint();
            testCase.assertClass(Xdp,'reliability.DesignPoint');
        end
        
        function constructorPhysical(testCase)
            Xdp = reliability.DesignPoint('Sdescription','Unit Test DesignPoint',...
                'XProbabilisticModel',testCase.ProbabilisticModel,...
                'VDesignPointPhysical',[0 0]);
            
            testCase.assertEqual(Xdp.Sdescription,'Unit Test DesignPoint');
            testCase.assertEqual(Xdp.XProbabilisticModel,testCase.ProbabilisticModel);
            testCase.assertEqual(Xdp.VDesignPointPhysical,[0 0]);
            
            testCase.assertEqual(Xdp.VDesignPointStdNormal,[-2 0.5]);
            % TODO VDirectionDesignPointPhysical? Returns [NaN NaN]
            testCase.assertEqual(Xdp.VDirectionDesignPointStdNormal,[-0.9701425 0.2425356],'AbsTol',1e6);
            testCase.assertEqual(Xdp.ReliabilityIndex,2.0615528,'AbsTol',1e6);
        end
        
        function constructorStdNorm(testCase)
            Xdp = reliability.DesignPoint('Sdescription','Unit Test DesignPoint',...
                'XProbabilisticModel',testCase.ProbabilisticModel,...
                'VDesignPointStdNormal',[-2 0.5]);
            
            testCase.assertEqual(Xdp.Sdescription,'Unit Test DesignPoint');
            testCase.assertEqual(Xdp.XProbabilisticModel,testCase.ProbabilisticModel);
            testCase.assertEqual(Xdp.VDesignPointStdNormal,[-2 0.5]);
            
            testCase.assertEqual(Xdp.VDesignPointPhysical,[0 0]);
            % TODO VDirectionDesignPointPhysical? Returns [NaN NaN]
            testCase.assertEqual(Xdp.VDirectionDesignPointStdNormal,[-0.9701425 0.2425356],'AbsTol',1e6);
            testCase.assertEqual(Xdp.ReliabilityIndex,2.0615528,'AbsTol',1e6);
        end
        
        function constructorShouldFailForInvalidInputs(testCase)
            testCase.assertError(@() reliability.DesignPoint('XProbabilisticModel',common.inputs.Input()),...
                'openCOSSAN:DesignPoint:DesignPoint');
            testCase.assertError(@() reliability.DesignPoint('XInput',testCase.ProbabilisticModel),...
                'openCOSSAN:DesignPoint:DesignPoint');
            testCase.assertError(@() reliability.DesignPoint('XHybridModel',common.inputs.Input()),...
                'openCOSSAN:DesignPoint:DesignPoint');
            testCase.assertError(@() reliability.DesignPoint('XOptimizer',common.inputs.Input()),...
                'openCOSSAN:DesignPoint:DesignPoint');
        end
        
        %% set
        function setDesignPointPhysical(testCase)
            Xdp = reliability.DesignPoint('Sdescription','Unit Test DesignPoint',...
                'XProbabilisticModel',testCase.ProbabilisticModel,...
                'VDesignPointStdNormal',[-2 0.5]);
            
            Xdp = Xdp.set('VDesignPointPhysical',[1 2]);
            testCase.assertEqual(Xdp.VDesignPointPhysical,[1 2]);
        end
        
        function setDesignPointStdNormal(testCase)
            Xdp = reliability.DesignPoint('Sdescription','Unit Test DesignPoint',...
                'XProbabilisticModel',testCase.ProbabilisticModel,...
                'VDesignPointPhysical',[1 2]);
            
            Xdp = Xdp.set('VDesignPointStdNormal',[-3 1]);
            testCase.assertEqual(Xdp.VDesignPointStdNormal,[-3 1]);
        end
        
        function setShouldWarnAboutIgnoredFields(testCase)
            Xdp = reliability.DesignPoint('Sdescription','Unit Test DesignPoint',...
                'XProbabilisticModel',testCase.ProbabilisticModel,...
                'VDesignPointPhysical',[1 2]);
            
            testCase.assertWarning(@() Xdp.set('Xinput',common.inputs.Input),...
                'openCOSSAN:DesignPoint:set');
        end
        
    end
    
end

