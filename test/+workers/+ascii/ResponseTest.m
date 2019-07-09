classdef ResponseTest < matlab.unittest.TestCase
    % RESPONSETEST Unit tests for the class
    % workers.ascii.Response
    % see http://cossan.co.uk/wiki/index.php/@Response
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
    end
    
    methods (Test)
        %% constructor
        function constructor(testCase)
            Xresp = workers.ascii.Response('Sname', 'OUT3', ...
                'Sfieldformat', '%5e', ...
                'Clookoutfor',{'N O D E   O U T P U T'}, ...
                'Svarname','OUT1','Sregexpression','<?*PinkCow*>',...
                'Ncolnum',30,'Nrownum',11,'Nrepeat',2);
            
            testCase.assertEqual(Xresp.Sname,'OUT3');
            testCase.assertEqual(Xresp.Sfieldformat,'%5e');
            testCase.assertEqual(Xresp.Clookoutfor,{'N O D E   O U T P U T'});
            testCase.assertEqual(Xresp.Svarname,'OUT1');
            testCase.assertEqual(Xresp.Sregexpression,'<?*PinkCow*>');
            testCase.assertEqual(Xresp.Ncolnum,30);
            testCase.assertEqual(Xresp.Nrownum,11);
            testCase.assertEqual(Xresp.Nrepeat,2);
        end
        
        function constructorDefault(testCase)
            Xresp = workers.ascii.Response('Sname','OUT3');
            
            testCase.assertEqual(Xresp.Sfieldformat,'%e');
            testCase.assertEqual(Xresp.Clookoutfor,{});
            testCase.assertEqual(Xresp.Svarname,'');
            testCase.assertEqual(Xresp.Sregexpression,'');
            testCase.assertEqual(Xresp.Ncolnum,1);
            testCase.assertEqual(Xresp.Nrownum,1);
            testCase.assertEqual(Xresp.Nrepeat,1);
        end
        
        function constructorShouldFailWithoutSname(testCase)
            testCase.assertError(@() workers.ascii.Response('Svarname','OUT1'),...
                'openCOSSAN:Response:Response');
        end
        
    end
    
end

