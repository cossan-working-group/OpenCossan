classdef HybridModelTest < matlab.unittest.TestCase
    % HYBRIDMODELTEST Unit tests for the class
    % reliability.HybridModel
    % see http://cossan.co.uk/wiki/index.php/@HybridModel
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
            import intervals.*;
            import common.inputs.*;
            
            Xbv1 = Interval('lowerbound',0,'upperbound',2);
            Xbv2 = Interval('lowerbound',0.5,'upperbound',1.5);
            Xcs1 = BoundedSet('Cmembers',{'Xbv1', 'Xbv2'},'CXint',{Xbv1 Xbv2 }, 'Mcorrelation',[1,0;0 1],'Lconvex',true);
            Xin = Input('CSmembers',{'Xcs1'},'CXmembers',{Xcs1});
            Xpar = Parameter('value',1);
            Xin = Xin.add('Xmember',Xpar,'Sname','Xpar');
            %            Xin = sample(Xin,'Nsamples',1000);
            
            Xm = workers.Mio('Sscript','for j=1:length(Tinput), Toutput(j).out1=Tinput(j).Xbv2-Tinput(j).Xbv1; end', ...
                'Sformat','structure',...
                'Coutputnames',{'out1'},'Cinputnames',{'Xbv1','Xbv2'},...
                'Lfunction',false);
            
            Xeval = workers.Evaluator('Xmio',Xm,'Sdescription','first CM evaluator');
            
            testCase.Model = common.Model('Xinput',Xin,'Xevaluator',Xeval);
        end
        
        function setupPerformanceFunction(testCase)
            testCase.PerformanceFunction = reliability.PerformanceFunction('OutputName','Vg','Capacity','Xpar','Demand','out1');
        end
    end
    
    methods (Test)
        %% constructor
        function constructorEmpty(testCase)
            Xhm = reliability.HybridModel();
            testCase.assertClass(Xhm,'reliability.HybridModel');
        end
        
        function constructor(testCase)
            Xhm = reliability.HybridModel(testCase.PerformanceFunction,'Model',testCase.Model);
            testCase.assertEqual(Xhm.PerformanceFunctionVariable,'Vg');
        end
        
        function constructorCell(testCase)
            Xhm = reliability.HybridModel({testCase.PerformanceFunction},'Model',{testCase.Model});
            testCase.assertEqual(Xhm.PerformanceFunctionVariable,'Vg');
        end
        
        function constructorShouldFailForInvalidInputs(testCase)
            testCase.assertError(@() reliability.HybridModel({}),...
                'MATLAB:expectedNonempty');
            testCase.assertError(@() reliability.HybridModel(common.inputs.Input()),...
                'MATLAB:invalidType');
            testCase.assertError(@() reliability.HybridModel(testCase.PerformanceFunction,...
                'Model',common.inputs.Input()),...
                'MATLAB:invalidType');
        end
    end
    
end



