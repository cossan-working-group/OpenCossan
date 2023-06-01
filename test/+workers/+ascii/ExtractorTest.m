classdef ExtractorTest < matlab.unittest.TestCase
    % EXTRACTORTEST Unit tests for the class
    % workers.ascii.Extractor
    % see http://cossan.co.uk/wiki/index.php/@Extractor
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
    % Contains Properties that will be used in the test block.
    
    properties
        workingDirectory = fullfile(OpenCossan.getCossanRoot(),'test','data','workers','ascii','Extractor');
        relativePath = '.';
        fileName = '2D_Truss.dat';
        
        Xresp1;
        Xresp2;
        Xresp3;
        Xresp4;
    end
    
    methods (TestMethodSetup)
        function createResponse1(testCase)
            testCase.Xresp1 = workers.ascii.Response('Sname', 'OUT1', ...
             'Sfieldformat', '%11e', 'Clookoutfor',{'E L E M E N T   O U T P U T'}, ...
             'Ncolnum',24, 'Nrownum',11, 'Nrepeat',2); 
        end
        
        function createResponse2(testCase)
            testCase.Xresp2 = workers.ascii.Response('Sname', 'OUT1', ...
             'Sfieldformat', '%11e', 'Clookoutfor',{'E L E M E N T   O U T P U T'}, ...
             'Ncolnum',24, 'Nrownum',11, 'Nrepeat',2); 
        end
        
        function createResponse3(testCase)
            testCase.Xresp3 = workers.ascii.Response('Sname', 'OUT2', ...
             'Sfieldformat', '%11e', 'Svarname','OUT1', 'Ncolnum',24, ...
             'Nrownum',0, ... % position relative to the END of values associated to OUT1
             'Nrepeat',1);  
        end
        
        function createResponse4(testCase)
            testCase.Xresp4 = workers.ascii.Response('Sname', 'OUT3', ...
             'Sfieldformat', '%11e', 'Sregexpression',' E L E M E N T   O U T P U T', ...
             'Ncolnum',24, 'Nrownum',11, 'Nrepeat',1);      
        end
    end
    
    methods (Test)
        %% constructor
        function costructorEmpty(testCase)
            Xe = workers.ascii.Extractor();
            testCase.assertClass(Xe,'workers.ascii.Extractor');
        end
        
        function constructorOneResponse(testCase)
            Xe = workers.ascii.Extractor('Sdescription','Unit Test Extractor',...
             'SworkingDirectory',testCase.workingDirectory, ...
             'Srelativepath',testCase.relativePath, ...
             'Sfile',testCase.fileName, ...
             'Xresponse',testCase.Xresp1);
         
            testCase.assertEqual(Xe.Sdescription,'Unit Test Extractor');
            testCase.assertEqual(Xe.Sworkingdirectory,testCase.workingDirectory);
            testCase.assertEqual(Xe.Srelativepath,[testCase.relativePath filesep]);
            testCase.assertEqual(Xe.Sfile,testCase.fileName);
            testCase.assertEqual(Xe.Xresponse,testCase.Xresp1);
            testCase.assertEqual(Xe.Coutputnames,{'OUT1'});
        end
        
        function constructorCXresponse(testCase)
            Xe = workers.ascii.Extractor('Sdescription','Unit Test Extractor',...
             'SworkingDirectory',testCase.workingDirectory, ...
             'Srelativepath',testCase.relativePath, ...
             'Sfile',testCase.fileName, ...
             'CXresponse',{testCase.Xresp1 testCase.Xresp3 testCase.Xresp4});
         
            testCase.assertEqual(Xe.Xresponse,[testCase.Xresp1 testCase.Xresp3 testCase.Xresp4]);
            testCase.assertEqual(Xe.Coutputnames,{'OUT1';'OUT2';'OUT3'});
        end
        
        function constructorCCXresponse(testCase)
            CCXresp = {{testCase.Xresp1}, {testCase.Xresp3}, {testCase.Xresp4}};
            Xe = workers.ascii.Extractor('SworkingDirectory',testCase.workingDirectory, ...
             'Srelativepath',testCase.relativePath, ...
             'Sfile',testCase.fileName, ...
             'CCXresponse',CCXresp);
         
            testCase.assertEqual(Xe.Xresponse,[testCase.Xresp1 testCase.Xresp3 testCase.Xresp4]);
        end
        
        function constructorShouldForDuplicateOutputNames(testCase)
            testCase.assertError(@() workers.ascii.Extractor('SworkingDirectory',testCase.workingDirectory, ...
             'Srelativepath',testCase.relativePath, 'Sfile',testCase.fileName, ...
             'Xresponse',[testCase.Xresp1 testCase.Xresp2]),...
             'openCOSSAN:Extractor:Extractor');
        end
        
        %% add
        function addResponse(testCase)
            Xe = workers.ascii.Extractor('SworkingDirectory',testCase.workingDirectory, ...
             'Srelativepath',testCase.relativePath, ...
             'Sfile',testCase.fileName, ...
             'Xresponse',testCase.Xresp1);
         
            Xe = Xe.add('Xresponse',testCase.Xresp3);
            testCase.assertEqual(Xe.Xresponse,[testCase.Xresp1 testCase.Xresp3]);
            testCase.assertEqual(Xe.Coutputnames,{'OUT1';'OUT2'});
        end
        
        function addShouldFailForDuplicateOutputNames(testCase)
            Xe = workers.ascii.Extractor('SworkingDirectory',testCase.workingDirectory, ...
             'Srelativepath',testCase.relativePath, ...
             'Sfile',testCase.fileName, ...
             'Xresponse',testCase.Xresp1);
         
            testCase.assertError(@() Xe.add('Xresponse',testCase.Xresp2),...
                'openCOSSAN:Extractor:add');
        end
        
        %% remove
        function removeResponse(testCase)
            Xe = workers.ascii.Extractor('SworkingDirectory',testCase.workingDirectory, ...
             'Srelativepath',testCase.relativePath, ...
             'Sfile',testCase.fileName, ...
             'Xresponse',[testCase.Xresp1 testCase.Xresp3]);
         
            Xe = Xe.remove('OUT2');
            testCase.assertEqual(Xe.Xresponse,testCase.Xresp1);
            testCase.assertEqual(Xe.Coutputnames,{'OUT1'});
        end
        
        function removeShouldFailForUnknownOutput(testCase)
            Xe = workers.ascii.Extractor('SworkingDirectory',testCase.workingDirectory, ...
             'Srelativepath',testCase.relativePath, ...
             'Sfile',testCase.fileName, ...
             'Xresponse',testCase.Xresp1);
         
            testCase.assertError(@() Xe.remove('OUT2'),...
                'openCOSSAN:extractor:remove');
        end
        
        %% extract
        function extractByPosition(testCase)
            Xe = workers.ascii.Extractor('SworkingDirectory',testCase.workingDirectory, ...
             'Srelativepath',testCase.relativePath, ...
             'Sfile',testCase.fileName, ...
             'Xresponse',testCase.Xresp1);
         
            Tout = Xe.extract();
            testCase.assertEqual(Tout.OUT1.Vdata(1),-1.5175E8);
            testCase.assertEqual(Tout.OUT1.Vdata(2),-1.5175E8);
        end
        
        function extractByRelativePosition(testCase)
            Xe = workers.ascii.Extractor('SworkingDirectory',testCase.workingDirectory, ...
             'Srelativepath',testCase.relativePath, ...
             'Sfile',testCase.fileName, ...
             'Xresponse',[testCase.Xresp1 testCase.Xresp3]);
         
            Tout = Xe.extract();
            testCase.assertEqual(Tout.OUT1.Vdata(1),-1.5175E8);
            testCase.assertEqual(Tout.OUT1.Vdata(2),-1.5175E8);
            testCase.assertEqual(Tout.OUT2,3.0349E8);
        end
        
        function extractByRelativeToRegex(testCase)
            Xe = workers.ascii.Extractor('SworkingDirectory',testCase.workingDirectory, ...
             'Srelativepath',testCase.relativePath, ...
             'Sfile',testCase.fileName, ...
             'Xresponse',[testCase.Xresp1 testCase.Xresp4]);
         
            Tout = Xe.extract();
            testCase.assertEqual(Tout.OUT1.Vdata(1),-1.5175E8);
            testCase.assertEqual(Tout.OUT1.Vdata(2),-1.5175E8);
            testCase.assertEqual(Tout.OUT3,-1.5175E8);
        end
        
    end
    
end

