classdef SystemReliabilityTest < matlab.unittest.TestCase
    % SYSTEMRELIABILITYTEST Unit tests for the class
    % reliability.SystemReliability
    % see http://cossan.co.uk/wiki/index.php/@SystemReliability
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
        Pf1 = reliability.PerformanceFunction('OutputName','vg1','Capacity','Xpar','Demand','out1');
        Pf2 = reliability.PerformanceFunction('OutputName','vg2','Capacity','Xpar','Demand','out2');;
        Pf3 = reliability.PerformanceFunction('OutputName','vg3','Capacity','Xpar','Demand','out3');;
        Model;
        FaultTree;
    end
    
    methods (TestMethodSetup)
        function setupModel(testCase)
            Xrv = common.inputs.RandomVariable('Sdistribution','normal','mean',0,'std',1);
            Xrvset = common.inputs.RandomVariableSet('Cmembers',{'Xrv'},'Cxrv',{Xrv},'Nrviid',3);
            Xpar = common.inputs.Parameter('value',3*sqrt(2));
            Xinput = common.inputs.Input('XRandomvariableset',Xrvset,'XParameter',Xpar);
            Xinput = Xinput.sample('Nsamples',100);
            Xmio = workers.Mio('Cinputnames',{'Xrv_1' 'Xrv_2' 'Xrv_3'},...
                'Coutputnames',{'out1' 'out2' 'out3'},...
                'Sformat','structure',...
                'Sscript',['for i=1:length(Tinput);' ...
                'Toutput(i).out1 = Tinput(i).Xrv_1 + Tinput(i).Xrv_2;' ...
                'Toutput(i).out2 = Tinput(i).Xrv_2 + Tinput(i).Xrv_3;' ...
                'Toutput(i).out3 = Tinput(i).Xrv_1 + Tinput(i).Xrv_3;' ...
                'end']);
            testCase.Model = common.Model('Xevaluator',workers.Evaluator('Xmio',Xmio),'Xinput',Xinput);
        end
        
        function setupFaultTree(testCase)
            CnodeTypes={'Output','AND','Input','AND','Input','Input'};
            VnodeConnections = [0 1 2 2 4 4];
            CnodeNames={'Out','AND gate 1','Xpf1','AND gate 2','Xpf2','Xpf3'};
            testCase.FaultTree = reliability.FaultTree('CnodeTypes',CnodeTypes,...
                'CnodeNames',CnodeNames,...
                'VnodeConnections',VnodeConnections);
        end
    end
    
    methods (Test)
        function constructorEmpty(testCase)
            Xsr = reliability.SystemReliability();
            testCase.assertClass(Xsr,'reliability.SystemReliability');
        end
        
        function constructorMinimal(testCase)
            Xsr = reliability.SystemReliability('Cmembers',{'Xpf1';'Xpf2';'Xpf3'},...
                'XperformanceFunctions',[testCase.Pf1 testCase.Pf2 testCase.Pf3],...
                'Xmodel',testCase.Model,...
                'XFaultTree',testCase.FaultTree);
            
            testCase.assertEqual(Xsr.Cnames,{'Xpf1';'Xpf2';'Xpf3'});
            testCase.assertEqual(Xsr.XperformanceFunctions,[testCase.Pf1 testCase.Pf2 testCase.Pf3]);
            testCase.assertEqual(Xsr.Xmodel,testCase.Model);
            testCase.assertEqual(Xsr.XFaultTree,testCase.FaultTree);
        end
        
        function constructorShouldFailForMissingInputs(testCase)
            testCase.assertError(@() reliability.SystemReliability('XperformanceFunctions',[testCase.Pf1 testCase.Pf2 testCase.Pf3],...
                'Xmodel',testCase.Model,...
                'XFaultTree',testCase.FaultTree),...
                'openCOSSAN:reliability:SystemReliability');
            testCase.assertError(@() reliability.SystemReliability('Cmembers',{'Xpf1';'Xpf2';'Xpf3'},...
                'Xmodel',testCase.Model,...
                'XFaultTree',testCase.FaultTree),...
                'openCOSSAN:reliability:SystemReliability');
            testCase.assertError(@() reliability.SystemReliability('Cmembers',{'Xpf1';'Xpf2';'Xpf3'},...
                'XperformanceFunctions',[testCase.Pf1 testCase.Pf2 testCase.Pf3],...
                'XFaultTree',testCase.FaultTree),...
                'openCOSSAN:reliability:SystemReliability');
            testCase.assertError(@() reliability.SystemReliability('Cmembers',{'Xpf1';'Xpf2';'Xpf3'},...
                'XperformanceFunctions',[testCase.Pf1 testCase.Pf2 testCase.Pf3],...
                'Xmodel',testCase.Model),...
                'openCOSSAN:reliability:SystemReliability');
        end
        
        function constructorShouldFailForInvalidInputs(testCase)
            testCase.assertError(@() reliability.SystemReliability('Cmembers',{'Xpf1';'Xpf2';'Xpf3'},...
                'XperformanceFunctions',[common.inputs.Input() common.inputs.Input() common.inputs.Input()],...
                'Xmodel',testCase.Model,...
                'XFaultTree',testCase.FaultTree),...
                'openCOSSAN:SystemReliability');
            
            testCase.assertError(@() reliability.SystemReliability('Cmembers',{'Xpf1';'Xpf2';'Xpf3'},...
                'XperformanceFunctions',[testCase.Pf1 testCase.Pf2 testCase.Pf3],...
                'Xmodel',common.inputs.Input(),...
                'XFaultTree',testCase.FaultTree),...
                'openCOSSAN:SystemReliability');
            
            testCase.assertError(@() reliability.SystemReliability('Cmembers',{'Xpf1';'Xpf2';'Xpf3'},...
                'XperformanceFunctions',[testCase.Pf1 testCase.Pf2 testCase.Pf3],...
                'Xmodel',testCase.Model,...
                'XFaultTree',common.inputs.Input()),...
                'openCOSSAN:SystemReliability');
        end
        
    end
    
end

