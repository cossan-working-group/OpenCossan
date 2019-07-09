classdef ModelTest < matlab.unittest.TestCase
    % TIMERTEST Unit tests for the class common.Model
    % see http://cossan.co.uk/wiki/index.php/@Model
    %
    % @author Jasper Behrensdorf<behrensdorf@irz.uni-hannover.de>
    % @date   15.08.2016
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
    
    % Contains model properties used in test below
    properties
        Xevaluator
        Xinput
    end
    
    methods (TestClassSetup)
        function setup(testCase)
            X1 = common.inputs.RandomVariable('Sdistribution','normal', 'mean',3,'std',1);
            X2 = common.inputs.RandomVariable('Sdistribution','normal', 'mean',7,'std',1);
            
            Xrvs = common.inputs.RandomVariableSet('CSmembers',{'X1', 'X2'},...
                'CXrandomVariables',{X1,X2});
            
            maxDistance = common.inputs.Parameter('value', 10);
            
            testCase.Xinput = common.inputs.Input('Sdescription','Input Object', ...
                'CXmembers',{Xrvs maxDistance},...
                'CSmembers',{'Xrvs' 'maxDistance'});
            
            Xmio = workers.Mio('Sdescription', 'Matlab I-O for the demand of the system',...
                'Sscript',['for j=1:length(Tinput),',...
                'Toutput(j).demand=sqrt(Tinput(j).X1^2+Tinput(j).X2); end'],...
                'Sformat','structure',...
                'Coutputnames',{'demand'},...
                'Cinputnames',{'X1' 'X2'});
            
            testCase.Xevaluator = workers.Evaluator('Xmio',Xmio,'Sdescription','Evaluate demand of the system');
        end
        
    end
    
    methods (Test)
        
        %% Test constructor
        function constructorEmpty(testCase)
            Xmodel = common.Model();
            testCase.assertClass(Xmodel,'common.Model');
        end
        
        function constructorShouldFailWithWrongInput(testCase)
            testCase.assertError(@()common.Model('Xinput',common.inputs.RandomVariable()),...
                'openCOSSAN:Model:wrongInput');
        end
        
        function constructorShouldFailWithWrongEvaluator(testCase)
            testCase.assertError(@()common.Model('XEvaluator',common.inputs.RandomVariable()),...
                'openCOSSAN:Model:wrongEvaluator');
        end
        
        function constructorShouldFailWithoutInput(testCase)
            testCase.assertError(@()common.Model('Xevaluator',testCase.Xevaluator),...
                'openCOSSAN:Model:noInput');
            testCase.assertError(@()common.Model('CXmembers',{testCase.Xevaluator}),...
                'openCOSSAN:Model:noInput');
        end
        
        function constructorShouldFailWithoutEvaluator(testCase)
            testCase.assertError(@()common.Model('Xinput',testCase.Xinput),...
                'openCOSSAN:Model:noEvaluator');
            testCase.assertError(@()common.Model('CXmembers',{testCase.Xinput}),...
                'openCOSSAN:Model:noEvaluator');
        end
        
        function constructorShouldSetProperties(testCase)
            Xmodel = common.Model('Xinput',testCase.Xinput,...
                'Xevaluator',testCase.Xevaluator','Sdescription','Test Model');
            testCase.assertEqual(Xmodel.Xinput,testCase.Xinput);
            testCase.assertEqual(Xmodel.Xevaluator,testCase.Xevaluator);
            testCase.assertEqual(Xmodel.Sdescription,'Test Model');
            
            Xmodel = common.Model('CXmembers',{testCase.Xinput testCase.Xevaluator},...
                'Sdescription','Test Model');
            testCase.assertEqual(Xmodel.Xinput,testCase.Xinput);
            testCase.assertEqual(Xmodel.Xevaluator,testCase.Xevaluator);
            testCase.assertEqual(Xmodel.Sdescription,'Test Model');
        end
        
        function constructorShouldAcceptCells(testCase)
            Xmodel = common.Model('CXinput',{testCase.Xinput testCase.Xinput},...
                'CXevaluator',{testCase.Xevaluator}','Sdescription','Test Model');
            testCase.assertEqual(Xmodel.Xinput,testCase.Xinput);
            testCase.assertEqual(Xmodel.Xevaluator,testCase.Xevaluator);
        end
        
        %% Test deterministicAnalysis
        function deterministicAnalysis(testCase)
            Xmodel = common.Model('Xinput',testCase.Xinput,'Xevaluator',testCase.Xevaluator);
            Xout=Xmodel.deterministicAnalysis;
            testCase.assertEqual(Xout.getValues('Sname','demand'),4)
        end
        
        %% Test apply
        function applyShouldRunEvaluator(testCase)
            Xmodel = common.Model('CXmembers',{testCase.Xinput testCase.Xevaluator});
            Xsamples=testCase.Xinput.sample('Nsamples',10);
            Xout=Xmodel.apply(Xsamples);
            testCase.assertClass(Xout,'common.outputs.SimulationData');
            testCase.assertEqual(Xout.Nsamples,10)
        end
        
        % TODO Test setGridProperties
        
    end
    
end



