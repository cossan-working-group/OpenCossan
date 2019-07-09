classdef InjectorTest < matlab.unittest.TestCase
    % INJECTORTEST Unit tests for the class
    % workers.ascii.Injector
    % see http://cossan.co.uk/wiki/index.php/@Injector
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
        workingDirectory = fullfile(OpenCossan.getCossanRoot(),'test','data','workers','ascii','Injector');
    end
    
    methods (Test)
        %% constructor
        function constructor(testCase)
            Xinj = workers.ascii.Injector('Stype','scan', ....
                'Sscanfilepath',testCase.workingDirectory,...
                'Sscanfilename', 'properties.cossan',...
                'Sworkingdirectory',testCase.workingDirectory,...
                'Sfile','properties.dat');
            
            testCase.assertEqual(Xinj.Sdescription,['Injector created from file ' testCase.workingDirectory filesep 'properties.cossan']);
            testCase.assertEqual(Xinj.Stype,'scan');
            testCase.assertSize(Xinj.Xidentifier,[1 9]);
            testCase.assertEqual(Xinj.Cinputnames,{'Emod','nu','rho','t'});
        end
        
        %% inject
        function inject(testCase)
            Xinj = workers.ascii.Injector('Stype','scan', ....
                'Sscanfilepath',testCase.workingDirectory,...
                'Sscanfilename', 'properties.cossan',...
                'Sworkingdirectory',testCase.workingDirectory,...
                'Sfile','properties.dat');
            
            TsamplesPhysicalSpace.Emod = 1.7583399048e+11;
            TsamplesPhysicalSpace.nu = 0.3;
            TsamplesPhysicalSpace.t = 1.0881851415e-02;
            TsamplesPhysicalSpace.rho = 8056.1;
            
            Xinj.inject(TsamplesPhysicalSpace);
            testCase.assertEqual(fileread([testCase.workingDirectory filesep 'properties.dat']),...
                fileread([testCase.workingDirectory filesep 'properties.injected']));
        end
        
        function injectShouldFailWithoutStructure(testCase)
            Xinj = workers.ascii.Injector('Stype','scan', ....
                'Sscanfilepath',testCase.workingDirectory,...
                'Sscanfilename', 'properties.cossan',...
                'Sworkingdirectory',testCase.workingDirectory,...
                'Sfile','properties.dat');
            
            testCase.assertError(@()Xinj.inject([1 2 3 4]),'openCOSSAN:injector:inject');
        end
        
        function injectShouldForWithInvalidNumbersOfRealizations(testCase)
            Xinj = workers.ascii.Injector('Stype','scan', ....
                'Sscanfilepath',testCase.workingDirectory,...
                'Sscanfilename', 'properties.cossan',...
                'Sworkingdirectory',testCase.workingDirectory,...
                'Sfile','properties.dat');
            
            Tsamples.Emod = [1.7583399048e+11 1.7583399048e+11];
            Tsamples.nu = [0.3 0.3];
            Tsamples.t = [1.0881851415e-02 1.0881851415e-02];
            Tsamples.rho = [8056.1 8056.1];
            
            testCase.assertError(@()Xinj.inject(Tsamples),'openCOSSAN:injector:inject');
        end
        
        function injectAbaqus(testCase)
            testCase.assumeFail(); % TODO Fix Abaqus injection
            Xinj = workers.ascii.Injector('Stype','scan', ....
                'Sscanfilename', 'Abaqus.cossan',...
                'Sscanfilepath',testCase.workingDirectory,...
                'Sworkingdirectory',testCase.workingDirectory,...
                'Sfile','Abaqus.dat');
            
            time   = 0:0.05:0.5;
            Mdata = [1.2597160e+00, 1.1887828e+00, 9.7755398e-01, 8.2960914e-01, ...
                8.2150161e-01, 8.6554467e-01, 8.8637816e-01, 9.4003183e-01, ...
                1.1033306e+00, 1.3002285e+00, 1.3353142e+00];
            Xds = common.Dataseries('Mcoord',time,'Mdata',Mdata);
            
            Tsamples = struct('SP1',Xds);
            Xinj.inject(Tsamples);
            
            testCase.assertEqual(fileread([testCase.workingDirectory filesep 'properties.dat']),...
                fileread([testCase.workingDirectory filesep 'properties.injected']));
        end
        
        function injectNastran(testCase)
            testCase.assumeFail(); % TODO Fix Nastran injection
            Xinj = workers.ascii.Injector('Stype','scan', ....
                'Sscanfilename', 'Nastran.cossan',...
                'Sscanfilepath',testCase.workingDirectory,...
                'Sworkingdirectory',testCase.workingDirectory,...
                'Sfile','Nastran.dat');
            
            time   = 0:0.05:0.5;
            Mdata = [1.2597160e+00, 1.1887828e+00, 9.7755398e-01, 8.2960914e-01, ...
                8.2150161e-01, 8.6554467e-01, 8.8637816e-01, 9.4003183e-01, ...
                1.1033306e+00, 1.3002285e+00, 1.3353142e+00];
            Xds = common.Dataseries('Mcoord',time,'Mdata',Mdata);
            
            Tsamples = struct('SP1',Xds);
            Xinj.inject(Tsamples);
            
            testCase.assertEqual(fileread([testCase.workingDirectory filesep 'properties.dat']),...
                fileread([testCase.workingDirectory filesep 'properties.injected']));
        end
        
    end
    
end

