classdef TableExtractorTest < matlab.unittest.TestCase
    % TABLEEXTRACTORTEST Unit tests for the class
    % workers.ascii.TableExtractor
    % see http://cossan.co.uk/wiki/index.php/@TableExtractor
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
        workingDirectory = fullfile(OpenCossan.getCossanRoot(),'test','data','workers','ascii','TableExtractor');
        fileName = 'resultsResponse.txt';
        Xresp1;
        Xresp2;
    end
    
    methods (TestMethodSetup)
        function createResponse1(testCase)
            testCase.Xresp1 = workers.ascii.Response('Sname', 'displacement1', ...
                'Sfieldformat', ['%f','%*s','%f','%f','%f','%*d','\n','%*s','%f','%f','%f','%*d'], ...
                'Clookoutfor',{'POINT ID =          18'}, ...
                'Ncolnum',1, ...
                'Nrownum',1,...
                'Nrepeat',3);
        end
        
        function createResponse2(testCase)
            testCase.Xresp2 = workers.ascii.Response('Sname', 'displacement2', ...
                'Sfieldformat', ['%f','%*s','%f','%f','%f','%*d','\n','%*s','%f','%f','%f','%*d'], ...
                'Clookoutfor',{'POINT ID =          28'}, ...
                'Ncolnum',1, ...
                'Nrownum',1,...
                'Nrepeat',3);
        end
    end
    
    methods (Test)
        %% constructor
        function constructor(testCase)
            Xex = workers.ascii.TableExtractor('Sdescription', 'Unit Test TableExtractor',...
                'Sworkingdirectory',testCase.workingDirectory, ...
                'Sfile',testCase.fileName, ....
                'Xresponse',testCase.Xresp1);
            
            testCase.assertEqual(Xex.Sdescription,'Unit Test TableExtractor');
            testCase.assertEqual(Xex.Sfile,testCase.fileName);
            testCase.assertEqual(Xex.Xresponse,testCase.Xresp1);
            testCase.assertEqual(Xex.Sworkingdirectory,testCase.workingDirectory);
            testCase.assertEqual(Xex.Coutputnames,{'displacement1'});
        end
        
        % extract
        function extract(testCase)
            testCase.assumeFail(); % Skip until TableExtractor is fixed
            Xex = workers.ascii.TableExtractor('Sdescription', 'Unit Test TableExtractor',...
                'Sworkingdirectory',testCase.workingDirectory, ...
                'Sfile',testCase.fileName, ....
                'Xresponse',[testCase.Xresp1 testCase.Xresp2]);
            
            Mcoord_target = [0.000000E+00,  5.000000E-03,  1.000000E-02];
            Mdata_target =  [0.000000E+00,  2.779032E-06,  1.110885E-05;
                0.000000E+00,  3.331650E-06,  1.449050E-05;
                0.000000E+00, -1.591030E-05, -5.965713E-05;
                0.000000E+00,  3.538517E-04,  1.327156E-03;
                0.000000E+00,  8.607568E-05,  3.139196E-04;
                0.000000E+00,  1.402515E-04,  5.257608E-04];
            
            Tout = Xex.extract();
            testCase.assertEqual(Tout.displacement1.Mcoord,Mcoord_target);
            testCase.assertEqual(Tout.displacement2.Mcoord,Mcoord_target);
            testCase.assertEqual(Tout.displacement1.Mdata,Mdata_target);
            testCase.assertEqual(Tout.displacement2.Mdata,Mdata_target);
        end
        
        function extractTable(testCase)
            testCase.assumeFail(); % Skip until TableExtractor is fixed
            Xex = workers.ascii.TableExtractor('Sworkingdirectory',testCase.workingDirectory, ...
                'Sfile','resultsTable.txt', ....
                'Nheaderlines', 4, ...
                'Sdelimiter', ' ',...
                'Soutputname','displacement');
            
            Tout = extract(Xex)
        end
    end
    
end

