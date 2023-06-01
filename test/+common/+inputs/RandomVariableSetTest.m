classdef RandomVariableSetTest < matlab.unittest.TestCase
    % RANDOMVARIABLESETTEST Unit tests for the class
    % common.inputs.RandomVariableSet
    % see http://cossan.co.uk/wiki/index.php/@RandomVariableSet
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
        Xrv1;
        Xrv2;
    end
    
    methods (TestMethodSetup)
        function setup(testCase)
            testCase.Xrv1 = common.inputs.RandomVariable('Sdistribution','normal','mean',100,'std',15);
            testCase.Xrv2 = common.inputs.RandomVariable('Sdistribution','normal','mean',10,'cov',0.1);
        end
    end
    
    methods (Test)
        %% Constructor
        function constructorEmpty(testCase)
            Xrvs = common.inputs.RandomVariableSet();
            testCase.assertClass(Xrvs,'common.inputs.RandomVariableSet');
        end
        
        function constructorCXrv(testCase)
            Xrvs = common.inputs.RandomVariableSet('Cmembers',{'Xrv1','Xrv2'},'CXrv',{testCase.Xrv1,testCase.Xrv2});
            testCase.assertEqual(Xrvs.Cmembers,{'Xrv1','Xrv2'});
            testCase.assertEqual(Xrvs.Nrv,2);
            testCase.assertEqual(Xrvs.Xrv,{testCase.Xrv1,testCase.Xrv2});
        end
        
        function constructorWorkspace(testCase)
            rv1 = common.inputs.RandomVariable('Sdistribution','normal','mean',100,'std',15);
            rv2 = common.inputs.RandomVariable('Sdistribution','normal','mean',10,'cov',0.1);
            assignin('base','rv1',rv1);
            assignin('base','rv2',rv2);
            Xrvs = common.inputs.RandomVariableSet('Cmembers',{'rv1','rv2'});
            testCase.assertEqual(Xrvs.Cmembers,{'rv1','rv2'});
            testCase.assertEqual(Xrvs.Nrv,2);
            testCase.assertEqual(Xrvs.Xrv,{rv1,rv2});
        end
        
        function constructorWorkspaceAll(testCase)
            rv1 = common.inputs.RandomVariable('Sdistribution','normal','mean',100,'std',15);
            rv2 = common.inputs.RandomVariable('Sdistribution','normal','mean',10,'cov',0.1);
            assignin('base','rv1',rv1);
            assignin('base','rv2',rv2);
            Xrvs = common.inputs.RandomVariableSet('Cmembers',{'*all*'});
            testCase.assertEqual(Xrvs.Cmembers,{'rv1','rv2'});
            testCase.assertEqual(Xrvs.Nrv,2);
            testCase.assertEqual(Xrvs.Xrv,{rv1,rv2});
        end
        
        function constructorMCorrelation(testCase)
            Xrvs = common.inputs.RandomVariableSet('Cmembers',{'Xrv1','Xrv2'},'CXrv',{testCase.Xrv1,testCase.Xrv2},...
                'MCorrelation',[1.0,0.5;0.5,1.0]);
            testCase.assertEqual(Xrvs.Mcorrelation,sparse([1.0,0.5;0.5,1.0]));
        end
        
        function constructorMCorrelationInvalidInputs(testCase)
            testCase.assertError(@()common.inputs.RandomVariableSet('Cmembers',{'Xrv1','Xrv2'},'CXrv',{testCase.Xrv1,testCase.Xrv2},...
                'MCorrelation',[0.5,0.5;0.5,0.5]),...
                'openCOSSAN:Inputs:RandomVariableSet');
            testCase.assertError(@()common.inputs.RandomVariableSet('Cmembers',{'Xrv1','Xrv2'},'CXrv',{testCase.Xrv1,testCase.Xrv2},...
                'MCorrelation',[1.0,0.5,0.3;0.5,1.0,0.3]),...
                'openCOSSAN:Inputs:RandomVariableSet');
            testCase.assertError(@()common.inputs.RandomVariableSet('Cmembers',{'Xrv1','Xrv2'},'CXrv',{testCase.Xrv1,testCase.Xrv2},...
                'MCorrelation',[1.5,0.5;0.5,1.5]),...
                'openCOSSAN:Inputs:RandomVariableSet');
            testCase.assertError(@()common.inputs.RandomVariableSet('Cmembers',{'Xrv1','Xrv2'},'CXrv',{testCase.Xrv1,testCase.Xrv2},...
                'MCorrelation',[-1.5,0.5;0.5,-1.5]),...
                'openCOSSAN:Inputs:RandomVariableSet');
        end
        
        function constructorNrviid(testCase)
            Xrvs = common.inputs.RandomVariableSet('Cmembers',{'Xrv1'},'CXrv',{testCase.Xrv1},'Nrviid',2);
            testCase.assertEqual(Xrvs.Cmembers,{'Xrv1_1','Xrv1_2'});
            testCase.assertEqual(Xrvs.Nrv,2);
            testCase.assertEqual(Xrvs.Xrv,{testCase.Xrv1,testCase.Xrv1});
        end
        
        function constructorNrviidInvalidInputs(testCase)
            testCase.assertError(@()common.inputs.RandomVariableSet('Cmembers',{'Xrv1','Xrv2'},'CXrv',{testCase.Xrv1,testCase.Xrv2},'Nrviid',2),...
                'openCOSSAN:RandomVariableSet:WrongNumberRandomVariables');
            testCase.assertError(@()common.inputs.RandomVariableSet('Nrviid',2),...
                'openCOSSAN:RandomVariableSet:WrongNumberRandomVariables');
        end
        
        function constructorInvalidRv(testCase)
            testCase.assertError(@()common.inputs.RandomVariableSet('Cmembers',{'Xrv'}),...
                'openCOSSAN:RandomVariableSet');
            testCase.assertError(@()common.inputs.RandomVariableSet('Cmembers',{'Xrv'},'CXrv',{testCase.Xrv1,testCase.Xrv2}),...
                'openCOSSAN:Inputs:RandomVariableSet');
        end
        
        %% evalPdf
        function evalPdfMxsamples(testCase)
            Xrvs = common.inputs.RandomVariableSet('Cmembers',{'Xrv1','Xrv2'},'CXrv',{testCase.Xrv1,testCase.Xrv2});
            [Vpdf,Vpdfrv] = evalpdf(Xrvs,'Mxsamples',[1 2]);
            testCase.assertLength(Vpdf,1);
            testCase.assertLength(Vpdfrv,2);
        end
        
        %% map2physical
        function map2physical(testCase)
            Xrvs = common.inputs.RandomVariableSet('Cmembers',{'Xrv1','Xrv2'},'CXrv',{testCase.Xrv1,testCase.Xrv2});
            MX = map2physical(Xrvs,[0  0]);
            testCase.assertEqual(MX,[100 10]);
        end
        
        %% map2stdnorm
        function map2stdnorm(testCase)
            Xrvs = common.inputs.RandomVariableSet('Cmembers',{'Xrv1','Xrv2'},'CXrv',{testCase.Xrv1,testCase.Xrv2});
            MU = map2stdnorm(Xrvs,[0  0; 1 1]);
            testCase.assertSize(MU,[2 2]);
        end
        
        %% sample
        function sample(testCase)
            Xrvs = common.inputs.RandomVariableSet('Cmembers',{'Xrv1','Xrv2'},'CXrv',{testCase.Xrv1,testCase.Xrv2});
            Msamples = Xrvs.sample(1000);
            testCase.assertEqual(Msamples.Nsamples,1000);
            testCase.assertSize(Msamples.MsamplesPhysicalSpace,[1000 2]);
            testCase.assertSize(Msamples.MsamplesStandardNormalSpace,[1000 2]);
        end
        
        %% jacobianNataf
        function jacobianNataf(testCase)
            Xrvs = common.inputs.RandomVariableSet('Cmembers',{'Xrv1','Xrv2'},'CXrv',{testCase.Xrv1,testCase.Xrv2});
            MU = jacobianNataf(Xrvs,[0 0]);
            testCase.assertSize(MU,[2 2]);
        end
    end
    
end

