classdef MappingExtractorTest < matlab.unittest.TestCase
    % MAPPINGEXTRACTORTEST Unit tests for the class
    % workers.ascii.MappingExtractor
    % see http://cossan.co.uk/wiki/index.php/@MappingExtractor
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
        workingDirectory = fullfile(OpenCossan.getCossanRoot(),'test','data','workers','ascii','MappingExtractor');
        fileName = 'Ansys_K_NOMINAL.mapping';
    end
    
    methods (Test)
        %% constructor
        function constructor(testCase)
            Xme = workers.ascii.MappingExtractor('Sdescription', 'Unit Test MappingExtractor',...
                'Sworkingdirectory',testCase.workingDirectory,...
                'Sfile',testCase.fileName,....
                'Soutputname','DOFs');
            
            testCase.assertEqual(Xme.Sdescription,'Unit Test MappingExtractor');
            testCase.assertEqual(Xme.Sworkingdirectory,testCase.workingDirectory);
            testCase.assertEqual(Xme.Sfile,testCase.fileName);
            testCase.assertEqual(Xme.Soutputname,'DOFs');
        end
        
        function constructorShouldFailWithoutFileName(testCase)
            testCase.assertError(@() workers.ascii.MappingExtractor('Sdescription', 'Unit Test MappingExtractor',...
                'Sworkingdirectory',testCase.workingDirectory,...
                'Soutputname','DOFs'),'openCOSSAN:MappingExtractor');
        end
        
        function constructorShouldFailWithoutOutputName(testCase)
            testCase.assertError(@() workers.ascii.MappingExtractor('Sdescription', 'Unit Test MappingExtractor',...
                'Sworkingdirectory',testCase.workingDirectory,...
                'Sfile',testCase.fileName),'openCOSSAN:MappingExtractor');
        end
        
        function constructorShouldFailWithNonExistingFile(testCase)
            testCase.assertError(@() workers.ascii.MappingExtractor('Sdescription', 'Unit Test MappingExtractor',...
                'Sworkingdirectory',testCase.workingDirectory,...
                'Sfile','missing.mapping','Soutputname','DOFs'),'openCOSSAN:MappingExtractor');
        end
        
        %% extract
        function extract(testCase)
            Xme = workers.ascii.MappingExtractor('Sdescription', 'Unit Test MappingExtractor',...
                'Sworkingdirectory',testCase.workingDirectory,...
                'Sfile',testCase.fileName,....
                'Soutputname','DOFs');
            
            Tout = Xme.extract();
            testCase.assertSize(Tout.DOFs,[51420 2]);
        end
        
        
        
    end
    
end

