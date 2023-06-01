classdef MTXExtractorTest < matlab.unittest.TestCase
    % MTXEXTRACTORTEST Unit tests for the class
    % workers.ascii.MappingExtractor
    % see http://cossan.co.uk/wiki/index.php/@MTXExtractor
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
        workingDirectory = fullfile(OpenCossan.getCossanRoot(),'test','data','workers','ascii','MTXExtractor');
        relativeWorkingDirectory = fullfile(OpenCossan.getCossanRoot(),'test','data','workers','ascii');
        fileName = 'stiffness.mtx';
    end
    
    methods (Test)
        %% constructor
        function constructor(testCase)
            Xmtx = workers.ascii.MTXExtractor('Sdescription', 'Unit Test MTXExtractor',...
                'Sworkingdirectory',testCase.workingDirectory,...
                'Srelativepath','relative',...
                'Sfile',testCase.fileName, ....
                'Soutputname','stiffness');
            
            testCase.assertEqual(Xmtx.Sdescription,'Unit Test MTXExtractor');
            testCase.assertEqual(Xmtx.Sworkingdirectory,testCase.workingDirectory);
            testCase.assertEqual(Xmtx.Srelativepath,'relative');
            testCase.assertEqual(Xmtx.Sfile,testCase.fileName);
            testCase.assertEqual(Xmtx.Soutputname,'stiffness');
        end
        
        %% extract
        function extract(testCase)
            Xmtx = workers.ascii.MTXExtractor('Sdescription', 'Unit Test MTXExtractor',...
                'Sworkingdirectory',testCase.workingDirectory,...
                'Sfile',testCase.fileName, ....
                'Soutputname','stiffness');
            
            [Tout, Lsuccessful, Vnodes, Vdof] = Xmtx.extract();
            testCase.assertTrue(Lsuccessful);
            testCase.assertSize(Vnodes,[10 1]);
            testCase.assertSize(Vdof,[10 1]);
            testCase.assertSize(Tout.stiffness,[10 10]);
        end
        
        function extractRelative(testCase)
            Xmtx = workers.ascii.MTXExtractor('Sdescription', 'Unit Test MTXExtractor',...
                'Sworkingdirectory',testCase.relativeWorkingDirectory,...
                'Srelativepath','MTXExtractor',...
                'Sfile',testCase.fileName, ....
                'Soutputname','stiffness');
            
            [Tout, Lsuccessful, Vnodes, Vdof] = Xmtx.extract();
            testCase.assertTrue(Lsuccessful);
            testCase.assertSize(Vnodes,[10 1]);
            testCase.assertSize(Vdof,[10 1]);
            testCase.assertSize(Tout.stiffness,[10 10]);
        end
    end
    
end

