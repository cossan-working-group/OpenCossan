classdef SimulationDataTest < matlab.unittest.TestCase
    % SIMULATIONDATATEST Unit tests for the class
    % common.outputs.SimulationData
    % see http://cossan.co.uk/wiki/index.php/@SimulationData
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
    
    methods (Test)
        %% constructor
        function constructor(testCase)
            Mvalues = rand(10,3);
            Cnames = {'Huey' 'Louie' 'Dewey'};
            Xsd = common.outputs.SimulationData('Sdescription','Unit Test SimulationData',...
                'Table',array2table(Mvalues,'VariableNames',Cnames),'Sexitflag','Unit Test Exit');
            testCase.assertClass(Xsd,'common.outputs.SimulationData');
            testCase.assertEqual(Xsd.Sdescription,'Unit Test SimulationData');
            testCase.assertEqual(Xsd.SexitFlag,'Unit Test Exit');
            testCase.assertEqual(Xsd.TableValues{:,:},Mvalues);
            testCase.assertEqual(Xsd.Cnames,Cnames);
        end
        
        function constructorShouldWithInvalidInputs(testCase)
            testCase.assertError(@() common.outputs.SimulationData('Cnames',{'Huey' 'Louie' 'Dewey'}),...
                'openCOSSAN:SimulationData:NoValues');
            testCase.assertError(@() common.outputs.SimulationData('Cnames',{'Huey' 'Louie' 'Dewey'},...
                'Mvalues',rand(2,2)),'openCOSSAN:SimulationData:WrongSizeMvalue');
            testCase.assertError(@() common.outputs.SimulationData('Cnames',{'Huey' 'Louie' 'Dewey'},...
                'Mvalues',rand(4,4)),'openCOSSAN:SimulationData:WrongSizeMvalue');
        end
        
        %% plus
        function plus(testCase)
            Mvalues1 = [0.8007  1.4056  2.4109  1.1032  -0.3025  1.5000  2.5000
                1.4631  2.1828  3.6341  1.8230  -0.3599  1.5000  2.5000
                0.5203  3.2296  6.1990  1.8749  -1.3547  1.5000  2.5000
                -0.5559 3.9562  8.1904  1.7001  -2.2561  1.5000  2.5000
                1.9063  2.0082  3.0632  1.9573  -0.0509  1.5000  2.5000];
            
            Mvalues2 = [2.6066  1.1044  0.9056  1.8555  0.7511   1.5000  2.5000
                1.5002  1.1882  1.6263  1.3442  0.1560   1.5000  2.5000
                0.1972  2.1291  4.1596  1.1632  -0.9659  1.5000  2.5000
                1.2604  1.7863  2.9425  1.5234  -0.2629  1.5000  2.5000
                2.0261  1.7854  2.5577  1.9058  0.1204   1.5000  2.5000];
            
            Xsd1 = common.outputs.SimulationData('Cnames',{'add1' 'sub1' 'linfunc1','Xrv1','Xrv2','Xpar1','Xpar2'},...
                'Mvalues',Mvalues1);
            Xsd2 = common.outputs.SimulationData('Cnames',{'add1' 'sub1' 'linfunc1','Xrv1','Xrv2','Xpar1','Xpar2'},...
                'Mvalues',Mvalues2);
            Xsd = Xsd1 + Xsd2;
            testCase.assertEqual(Xsd.TableValues{:,:},Mvalues1 + Mvalues2);
        end
        
        function plusShouldFailforDifferentColumns(testCase)
            Mvalues1 = rand(10,2);
            Mvalues2 = rand(10,1);
            
            Xsd1 = common.outputs.SimulationData('Cnames',{'add1' 'sub1'},...
                'Mvalues',Mvalues1);
            Xsd2 = common.outputs.SimulationData('Cnames',{'add1'},...
                'Mvalues',Mvalues2);
            
            testCase.assertError(@() Xsd1.plus(Xsd2),...
                'openCOSSAN:SimulationData:plus');
        end
        
        function plusShouldFailforDifferentRows(testCase)
            Mvalues1 = rand(10,2);
            Mvalues2 = rand(15,2);
            
            Xsd1 = common.outputs.SimulationData('Cnames',{'add1' 'sub1'},...
                'Mvalues',Mvalues1);
            Xsd2 = common.outputs.SimulationData('Cnames',{'add1' 'sub1'},...
                'Mvalues',Mvalues2);
            
            testCase.assertError(@() Xsd1.plus(Xsd2),...
                'openCOSSAN:SimulationData:plus');
        end
        
        %% minus
        function minus(testCase)
            Mvalues1 = [0.8007  1.4056  2.4109  1.1032  -0.3025  1.5000  2.5000
                1.4631  2.1828  3.6341  1.8230  -0.3599  1.5000  2.5000
                0.5203  3.2296  6.1990  1.8749  -1.3547  1.5000  2.5000
                -0.5559 3.9562  8.1904  1.7001  -2.2561  1.5000  2.5000
                1.9063  2.0082  3.0632  1.9573  -0.0509  1.5000  2.5000];
            
            Mvalues2 = [2.6066  1.1044  0.9056  1.8555  0.7511   1.5000  2.5000
                1.5002  1.1882  1.6263  1.3442  0.1560   1.5000  2.5000
                0.1972  2.1291  4.1596  1.1632  -0.9659  1.5000  2.5000
                1.2604  1.7863  2.9425  1.5234  -0.2629  1.5000  2.5000
                2.0261  1.7854  2.5577  1.9058  0.1204   1.5000  2.5000];
            
            Xsd1 = common.outputs.SimulationData('Cnames',{'add1' 'sub1' 'linfunc1','Xrv1','Xrv2','Xpar1','Xpar2'},...
                'Mvalues',Mvalues1);
            Xsd2 = common.outputs.SimulationData('Cnames',{'add1' 'sub1' 'linfunc1','Xrv1','Xrv2','Xpar1','Xpar2'},...
                'Mvalues',Mvalues2);
            Xsd = Xsd1 - Xsd2;
            testCase.assertEqual(Xsd.TableValues{:,:},Mvalues1 - Mvalues2);
        end
        
        function minusShouldFailforDifferentColumns(testCase)
            Mvalues1 = rand(10,2);
            Mvalues2 = rand(10,1);
            
            Xsd1 = common.outputs.SimulationData('Cnames',{'add1' 'sub1'},...
                'Mvalues',Mvalues1);
            Xsd2 = common.outputs.SimulationData('Cnames',{'add1'},...
                'Mvalues',Mvalues2);
            
            testCase.assertError(@() Xsd1.minus(Xsd2),...
                'openCOSSAN:SimulationData:minus');
        end
        
        function minusShouldFailforDifferentRows(testCase)
            Mvalues1 = rand(10,2);
            Mvalues2 = rand(15,2);
            
            Xsd1 = common.outputs.SimulationData('Cnames',{'add1' 'sub1'},...
                'Mvalues',Mvalues1);
            Xsd2 = common.outputs.SimulationData('Cnames',{'add1' 'sub1'},...
                'Mvalues',Mvalues2);
            
            testCase.assertError(@() Xsd1.minus(Xsd2),...
                'openCOSSAN:SimulationData:minus');
        end
        
        %% merge
        function mergeHorizontally(testCase)
            Mvalues1 = rand(10,2);
            Mvalues2 = rand(10,2);
            
            Xsd1 = common.outputs.SimulationData('Cnames',{'var1' 'var2'},...
                'Mvalues',Mvalues1);
            Xsd2 = common.outputs.SimulationData('Cnames',{'var3' 'var4'},...
                'Mvalues',Mvalues2);
            
            Xsd = Xsd1.merge(Xsd2);
            
            testCase.assertEqual(Xsd.TableValues,array2table([Mvalues1 Mvalues2],...
                'VariableNames',{'var1' 'var2' 'var3' 'var4'}));
        end
        
        function mergeVertically(testCase)
            Mvalues1 = rand(10,2);
            Mvalues2 = rand(5,2);
            
            Xsd1 = common.outputs.SimulationData('Cnames',{'var1' 'var2'},...
                'Mvalues',Mvalues1);
            Xsd2 = common.outputs.SimulationData('Cnames',{'var1' 'var2'},...
                'Mvalues',Mvalues2);
            
            Xsd = Xsd1.merge(Xsd2);
            
            testCase.assertEqual(Xsd.TableValues,array2table([Mvalues1; Mvalues2],...
                'VariableNames',{'var1' 'var2'}));
        end
        
        %% addVariable
        function addVariable(testCase)
            Mvalues1 = rand(10,2);
            Mvalues2 = rand(10,1);
            
            Xsd1 = common.outputs.SimulationData('Cnames',{'var1' 'var2'},'Mvalues',Mvalues1);
            Xsd1 = Xsd1.addVariable('Cnames',{'var3'},'Mvalues',Mvalues2);
            
            testCase.assertEqual(Xsd1.TableValues,array2table([Mvalues1 Mvalues2],'VariableNames',{'var1' 'var2' 'var3'}));
        end
        
        function addVariableShouldFailForInvalidDimensions(testCase)
            Mvalues1 = rand(10,2);
            Mvalues2 = rand(1,10);
            
            Xsd1 = common.outputs.SimulationData('Cnames',{'var1' 'var2'},'Mvalues',Mvalues1);
            testCase.assertError(@() Xsd1.addVariable('Cnames',{'var3'},'Mvalues',Mvalues2),...
                'openCOSSAN:SimulationData:WrongSizeMvalue');
        end
        
        %% getValues
        function getValues(testCase)
            Mvalues = rand(10,2);
            Xsd = common.outputs.SimulationData('Cnames',{'var1' 'var2'},'Mvalues',Mvalues);
            
            Mout = Xsd.getValues();
            testCase.assertEqual(Mout, Mvalues);
        end
        
        function getValuesSelectable(testCase)
            Mvalues = rand(10,2);
            Xsd = common.outputs.SimulationData('Cnames',{'var1' 'var2'},'Mvalues',Mvalues);
            
            MoutVar1 = Xsd.getValues('Sname','var1');
            MoutVar2 = Xsd.getValues('Sname','var2');
            
            testCase.assertEqual(MoutVar1,Mvalues(:,1));
            testCase.assertEqual(MoutVar2,Mvalues(:,2));
        end
        
        function getValuesShouldFailIfNameNotPresent(testCase)
            Mvalues = rand(10,2);
            Xsd = common.outputs.SimulationData('Cnames',{'var1' 'var2'},'Mvalues',Mvalues);
            
            testCase.assertError(@() Xsd.getValues('Sname','huey'),...
                'openCOSSAN:outputs:SimulationData:getValue');
        end
        
        %% save/load
        function saveAndLoad(testCase)
            Mvalues = rand(10,2);
            Xsd = common.outputs.SimulationData('Cnames',{'var1' 'var2'},'Mvalues',Mvalues);
            
            Xsd.save('SfileName',fullfile(OpenCossan.getCossanWorkingPath,'SimulationDataTest'));
            testCase.assertEqual(exist(fullfile(OpenCossan.getCossanWorkingPath,'SimulationDataTest.mat'),'file'),2);
            
            XsdLoad = common.outputs.SimulationData.load('SfileName',...
                fullfile(OpenCossan.getCossanWorkingPath,'SimulationDataTest'));
            
            testCase.assertEqual(Xsd,XsdLoad);
            delete(fullfile(OpenCossan.getCossanWorkingPath,'SimulationDataTest.mat'))
        end
        
        function saveAndLoadWithParameters(testCase)
            Xrv = common.inputs.RandomVariable('Sdistribution','normal','mean',0,'std',1);
            Xrvset = common.inputs.RandomVariableSet('CXmembers',{Xrv},'CSmembers',{'Xrv'});
            Xpar = common.inputs.Parameter('Value',45);
            Xinput = common.inputs.Input('CXmembers',{Xrvset Xpar},'CSmembers',{'Xrvset' 'Xpar'});
            Xinput = Xinput.sample('Nsamples',10);
            Xev = workers.Evaluator;
            Xmdl = common.Model('Xinput',Xinput,'Xevaluator',Xev);
            Xsd = Xmdl.apply(Xinput);
            
            Xsd.save('SfileName',fullfile(OpenCossan.getCossanWorkingPath,'SimulationDataTest'));
            testCase.assertEqual(exist(fullfile(OpenCossan.getCossanWorkingPath,'SimulationDataTest.mat'),'file'),2);
            
            XsdLoad = common.outputs.SimulationData.load('SfileName',...
                fullfile(OpenCossan.getCossanWorkingPath,'SimulationDataTest'));
            
            testCase.assertEqual(Xsd,XsdLoad);
            delete(fullfile(OpenCossan.getCossanWorkingPath,'SimulationDataTest.mat'))
        end
        
        % TODO Save and Load with Dataseries/Stochastic Process
        
    end
    
end

