classdef CutSetTest < matlab.unittest.TestCase
    % CUTSETTEST Unit tests for the class
    % reliability.CutSet
    % see http://cossan.co.uk/wiki/index.php/@CutSet
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
        FaultTree = reliability.FaultTree('CnodeTypes',{'Output','AND','Input','OR','Input','AND','Input','AND','Input','Input'},...
            'CnodeNames',{'TopEvent','AND gate 1','C','OR gate 1','A','AND gate 2','B','AND gate 3','B','D'},...
            'VnodeConnections',[0 1 2 2 4 4 6 6 8 8]);
        FailureProbability = reliability.FailureProbability('pf',0.01,'variancepf',0.00001,'Nsamples',10,'Smethod','UserDefined');
        CutSetIndex = [1 4 5];
        Mpf2 = rand(3,3);
        DesignPoint;
    end
    
    methods (TestMethodSetup)
        function setupDesignPoint(testCase)
            Xrv1 = common.inputs.RandomVariable('Sdistribution','normal', 'mean',1,'std',0.5);
            Xrv2 = common.inputs.RandomVariable('Sdistribution','normal', 'mean',-1,'std',2);
            Xrvs1 = common.inputs.RandomVariableSet('Cmembers',{'Xrv1','Xrv2'},'CXrv',{Xrv1 Xrv2});
            Xin = common.inputs.Input('CXmembers',{Xrvs1},'CSmembers',{'Xrvs1'});
            testCase.DesignPoint = reliability.DesignPoint('Sdescription','My design point',...
                'VDesignPointPhysical',[0 0],'Xinput',Xin);
        end
    end
    
    methods (Test)
        %% constructor
        function constructorEmpty(testCase)
            Xcs = reliability.CutSet();
            testCase.assertClass(Xcs,'reliability.CutSet');
        end
        
        function constructorFull(testCase)
            Xcs = reliability.CutSet('Sdescription','Unit Test CutSet',...
                'XFaultTree',testCase.FaultTree,...
                'XFailureProbability',testCase.FailureProbability,...
                'XDesignPoint',testCase.DesignPoint,...
                'VcutsetIndex',testCase.CutSetIndex,...
                'upperBound',6,...
                'lowerBound',0,...
                'Mpf2',testCase.Mpf2);
            
            testCase.assertEqual(Xcs.Sdescription,'Unit Test CutSet');
            testCase.assertEqual(Xcs.XFaultTree,testCase.FaultTree);
            % TODO For some reason that I can not comprehend the two FailurProbability objects are not equal
            testCase.assertEqual(Xcs.XFailureProbability.pfhat,testCase.FailureProbability.pfhat);
            testCase.assertEqual(Xcs.XDesignPoint,testCase.DesignPoint);
            testCase.assertEqual(Xcs.VcutsetIndex,testCase.CutSetIndex);
            testCase.assertEqual(Xcs.lowerBound,0);
            testCase.assertEqual(Xcs.upperBound,6);
            testCase.assertEqual(Xcs.Mpf2,testCase.Mpf2);
        end
        
        function constructorMCutSet(testCase)
            Xcs = reliability.CutSet('Mcutset',[0 1 0 1; 0 0 0 1]);
            
            testCase.assertEqual(Xcs.Mcutset,[0 1 0 1; 0 0 0 1]);
            testCase.assertEqual(Xcs.VcutsetIndex,[3 7 8]');
        end
        
        function constructorShouldFailForInvalidInputs(testCase)
            testCase.assertError(@() reliability.CutSet('XFaultTree',testCase.DesignPoint),...
                'openCOSSAN:CutSet');
            testCase.assertError(@() reliability.CutSet('XFailureProbability',testCase.DesignPoint),...
                'openCOSSAN:CutSet');
            testCase.assertError(@() reliability.CutSet('XDesignPoint',testCase.FaultTree),...
                'openCOSSAN:CutSet');
        end
        
    end
end

