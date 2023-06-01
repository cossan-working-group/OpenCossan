classdef FaultTreeTest < matlab.unittest.TestCase
    % FAULTTREETEST Unit tests for the class
    % reliability.FaultTree
    % see http://cossan.co.uk/wiki/index.php/@FaultTree
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
        NodeTypes = {'Output','AND','Input','OR','Input','AND','Input','AND','Input','Input'};
        NodeNames = {'TopEvent','AND gate 1','C','OR gate 1','A','AND gate 2','B','AND gate 3','B','D'};
        NodeConnections = [0 1 2 2 4 4 6 6 8 8];
    end
    
    methods (Test)
        %% constructor
        function constructorEmpty(testCase)
            Xft = reliability.FaultTree();
            testCase.assertClass(Xft,'reliability.FaultTree');
        end
        
        function constructor(testCase)
            Xft = reliability.FaultTree('CnodeTypes',testCase.NodeTypes,...
                'CnodeNames',testCase.NodeNames,...
                'VnodeConnections',testCase.NodeConnections);
            
            testCase.assertEqual(Xft.CnodeTypes,testCase.NodeTypes);
            testCase.assertEqual(Xft.CnodeNames,testCase.NodeNames);
            testCase.assertEqual(Xft.VnodeConnections,testCase.NodeConnections);
        end
        
        function constructorShouldFailForDifferentInputLengths(testCase)
            testCase.assertError(@() reliability.FaultTree('CnodeTypes',testCase.NodeTypes(1:end-1),...
                'CnodeNames',testCase.NodeNames,'VnodeConnections',testCase.NodeConnections),...
                'openCOSSAN:reliability:FaultTree');
            testCase.assertError(@() reliability.FaultTree('CnodeTypes',testCase.NodeTypes,...
                'CnodeNames',testCase.NodeNames(1:end-1),'VnodeConnections',testCase.NodeConnections),...
                'openCOSSAN:reliability:FaultTree');
            testCase.assertError(@() reliability.FaultTree('CnodeTypes',testCase.NodeTypes,...
                'CnodeNames',testCase.NodeNames,'VnodeConnections',testCase.NodeConnections(1:end-1)),...
                'openCOSSAN:reliability:FaultTree');
        end
        
        function constructorShouldFailForInvalidNodeTypes(testCase)
            CwrongNodeTypes = {'Output','AND','Output','OR','Input','AND','Input','AND','Input','Input'};
            testCase.assertError(@() reliability.FaultTree('CnodeTypes',CwrongNodeTypes,...
                'CnodeNames',testCase.NodeNames,'VnodeConnections',testCase.NodeConnections),...
                'openCOSSAN:FaultTree');
            
            CwrongNodeTypes = {'Output','AND','Wrong','OR','Input','AND','Input','AND','Input','Input'};
            testCase.assertError(@() reliability.FaultTree('CnodeTypes',CwrongNodeTypes,...
                'CnodeNames',testCase.NodeNames,'VnodeConnections',testCase.NodeConnections),...
                'openCOSSAN:FaultTree');
        end
        
        %% findCutSets
        function findCutSets(testCase)
            Xft = reliability.FaultTree('CnodeTypes',testCase.NodeTypes,...
                'CnodeNames',testCase.NodeNames,...
                'VnodeConnections',testCase.NodeConnections);
            
            [~, Xcs] = Xft.findCutSets();
            testCase.assertEqual(Xcs{1},logical([0 0 1 0 1 0 0 0 0 0]'));
            testCase.assertEqual(Xcs{2},logical([0 0 1 0 0 0 1 0 1 1]'));
        end
        
        %% findMinimalCutSets
        function findMinimalCutSets(testCase)
            Xft = reliability.FaultTree('CnodeTypes',testCase.NodeTypes,...
                'CnodeNames',testCase.NodeNames,...
                'VnodeConnections',testCase.NodeConnections);
            
            [~, Xcs] = Xft.findMinimalCutSets();
            testCase.assertEqual(Xcs{1},{'C' 'A'});
            testCase.assertEqual(Xcs{2},{'C' 'B' 'D'});
        end
        
        %% removeNodes
        function removeOneNode(testCase)
            Xft = reliability.FaultTree('CnodeTypes',testCase.NodeTypes,...
                'CnodeNames',testCase.NodeNames,...
                'VnodeConnections',testCase.NodeConnections);
            
            Xft = Xft.removeNodes('VnodeIndex',10);
            
            testCase.assertEqual(Xft.CnodeTypes,testCase.NodeTypes(1:9));
            testCase.assertEqual(Xft.CnodeNames,testCase.NodeNames(1:9));
            testCase.assertEqual(Xft.VnodeConnections,testCase.NodeConnections(1:9));
        end
        
        function removeMultipleNodes(testCase)
            Xft = reliability.FaultTree('CnodeTypes',testCase.NodeTypes,...
                'CnodeNames',testCase.NodeNames,...
                'VnodeConnections',testCase.NodeConnections);
            
            Xft = Xft.removeNodes('VnodeIndex',[8 9 10]);
            
            testCase.assertEqual(Xft.CnodeTypes,testCase.NodeTypes(1:7));
            testCase.assertEqual(Xft.CnodeNames,testCase.NodeNames(1:7));
            testCase.assertEqual(Xft.VnodeConnections,testCase.NodeConnections(1:7));
        end
        
        function removeNodeShouldFailForUnknownNode(testCase)
            Xft = reliability.FaultTree('CnodeTypes',testCase.NodeTypes,...
                'CnodeNames',testCase.NodeNames,...
                'VnodeConnections',testCase.NodeConnections);
            
            testCase.assertError(@() Xft.removeNodes('VnodeIndex',13),...
                'openCOSSAN:reliability:FaultTree:removeNodes');
        end
        
        %% addNodes
        function addNodes(testCase)
            Xft = reliability.FaultTree('CnodeTypes',testCase.NodeTypes,...
                'CnodeNames',testCase.NodeNames,...
                'VnodeConnections',testCase.NodeConnections);
            
            CaddNodeTypes = {'AND' 'Input' 'Input'};
            CaddNodeNames = {'AND gate 4' 'D' 'E'};
            VaddNodeConnections = [8 10 10];
            
            Xft = Xft.addNodes('CnodeTypes',CaddNodeTypes,...
                'CnodeNames',CaddNodeNames,...
                'VnodeConnections',VaddNodeConnections);
            
            testCase.assertEqual(Xft.CnodeTypes,[testCase.NodeTypes CaddNodeTypes]);
            testCase.assertEqual(Xft.CnodeNames,[testCase.NodeNames CaddNodeNames]);
            testCase.assertEqual(Xft.VnodeConnections,[testCase.NodeConnections VaddNodeConnections]);
        end
        
    end
    
end

