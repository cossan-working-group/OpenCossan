classdef Op4ExtractorTest < matlab.unittest.TestCase
    % OP4EXTRACTORTEST Unit tests for the class
    % workers.ascii.Op4Extractor
    % see http://cossan.co.uk/wiki/index.php/@Op4Extractor
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
        workingDirectory = fullfile(OpenCossan.getCossanRoot(),'test','data','workers','ascii','Op4Extractor');
        relativeWorkingDirectory = fullfile(OpenCossan.getCossanRoot(),'test','data','workers','ascii');
        fileName = 'stiffness.op4';
    end
    
    methods (Test)
        %% constructor
        function constructor(testCase)
            Xe = workers.ascii.Op4Extractor('Sdescription','Unit Test Op4Extractor',...
                'SworkingDirectory',testCase.workingDirectory,...
                'Srelativepath','relative',...
                'Sfile',testCase.fileName,...
                'Soutputname','stiffness');
            
            testCase.assertEqual(Xe.Sdescription,'Unit Test Op4Extractor');
            testCase.assertEqual(Xe.Sworkingdirectory,testCase.workingDirectory);
            testCase.assertEqual(Xe.Srelativepath,'relative');
            testCase.assertEqual(Xe.Sfile,testCase.fileName);
            testCase.assertEqual(Xe.Soutputname,'stiffness');
        end
        
        %% extract
        function extract(testCase)
            Xe = workers.ascii.Op4Extractor('SworkingDirectory',testCase.workingDirectory,...
                'Sfile',testCase.fileName,...
                'Soutputname','stiffness');
            
            [Tout, successful] = Xe.extract();
            testCase.assertTrue(successful);
            testCase.assertSize(Tout.stiffness,[45 45]);
        end
        
        function extractRelative(testCase)
            Xe = workers.ascii.Op4Extractor('SworkingDirectory',testCase.relativeWorkingDirectory,...
                'Srelativepath','Op4Extractor',...
                'Sfile',testCase.fileName,...
                'Soutputname','stiffness');
            
            [Tout, successful] = Xe.extract();
            testCase.assertTrue(successful);
            testCase.assertSize(Tout.stiffness,[45 45]);
        end
        
        function extractShouldFailForMissingFile(testCase)
            Xe = workers.ascii.Op4Extractor('SworkingDirectory',testCase.workingDirectory,...
                'Sfile','missing.op4',...
                'Soutputname','stiffness');
            
            testCase.assertError(@() Xe.extract(),...
                'openCOSSAN:OP4Extractor:extract');
        end
        
        function extractShouldBeUnsuccessfulForEmptyFile(testCase)
            Xe = workers.ascii.Op4Extractor('SworkingDirectory',testCase.workingDirectory,...
                'Sfile','empty.op4',...
                'Soutputname','stiffness');
            
            [Tout, successful] = Xe.extract();
            testCase.assertFalse(successful);
            testCase.assertEqual(Tout,NaN);
        end
    end
    
end

