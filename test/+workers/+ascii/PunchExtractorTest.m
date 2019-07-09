classdef PunchExtractorTest < matlab.unittest.TestCase
    % PUNCHEXTRACTORTEST Unit tests for the class
    % workers.ascii.PunchExtractor
    % see http://cossan.co.uk/wiki/index.php/@PunchExtractor
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
        workingDirectory = fullfile(OpenCossan.getCossanRoot(),'test','data','workers','ascii','PunchExtractor');
        relativeWorkingDirectory = fullfile(OpenCossan.getCossanRoot(),'test','data','workers','ascii');
        fileName = 'dofs.pch';
        data = load('punch.mat');
    end
    
    methods (Test)
        %% constructor
        function constructor(testCase)
            Xe = workers.ascii.PunchExtractor('Sdescription','Unit Test PunchExtractor',...
                'SworkingDirectory',testCase.relativeWorkingDirectory,...
                'Srelativepath','PunchExtractor',...
                'Sfile',testCase.fileName,...
                'Soutputname','dofs');
            
            testCase.assertEqual(Xe.Sdescription,'Unit Test PunchExtractor');
            testCase.assertEqual(Xe.Sworkingdirectory,testCase.relativeWorkingDirectory);
            testCase.assertEqual(Xe.Srelativepath,'PunchExtractor');
            testCase.assertEqual(Xe.Sfile,testCase.fileName);
            testCase.assertEqual(Xe.Soutputname,'dofs');
        end
        
        function constructorShouldFailForMissingFile(testCase)
           testCase.assertError(@() workers.ascii.PunchExtractor('SworkingDirectory',testCase.relativeWorkingDirectory,...
                'Sfile',testCase.fileName,...
                'Soutputname','dofs'),...
                'openCOSSAN:PunchExtractor');
        end
        
        function constructorShouldFailForMissingInputs(testCase)
            testCase.assertError(@() workers.ascii.PunchExtractor('SworkingDirectory',testCase.workingDirectory,...
                'Sfile',testCase.fileName),...
                'openCOSSAN:PunchExtractor');
            testCase.assertError(@() workers.ascii.PunchExtractor('SworkingDirectory',testCase.workingDirectory,...
                'Soutputname','dofs'),...
                'openCOSSAN:PunchExtractor');
        end
        
        %% extract
        function extract(testCase)
            Xe = workers.ascii.PunchExtractor('SworkingDirectory',testCase.workingDirectory,...
                'Sfile',testCase.fileName,...
                'Soutputname','dofs');
            
            [Tout, successful] = Xe.extract();
            testCase.assertTrue(successful);
            testCase.assertEqual(Tout.dofs,testCase.data.Mnodesdofs);
        end
        
        function extractRelative(testCase)
            Xe = workers.ascii.PunchExtractor('SworkingDirectory',testCase.relativeWorkingDirectory,...
                'Srelativepath','PunchExtractor',...
                'Sfile',testCase.fileName,...
                'Soutputname','dofs');
            
            [Tout, successful] = Xe.extract();
            testCase.assertTrue(successful);
            testCase.assertEqual(Tout.dofs,testCase.data.Mnodesdofs);
        end
        
    end
    
end

