classdef InjectorTest < matlab.unittest.TestCase
    % INJECTORTEST Unit tests for the class
    % opencossan.workers.ascii.Injector
    % see http://cossan.co.uk/wiki/index.php/@Injector
    %
    % @author Matteo Broggi<broggi@irz.uni-hannover.de>
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
        Xin;
        workingDirectoryFunctions = fullfile(opencossan.OpenCossan.getRoot,'test','data','workers','Mio','functions');
        workingDirectoryFunctionsDeployed = fullfile(opencossan.OpenCossan.getRoot,'test','data','workers','Mio','functionsDeployed');
        workingDirectoryScripts = fullfile(opencossan.OpenCossan.getRoot,'test','data','workers','Mio','scripts');
        isdeployedDirectory = fullfile(opencossan.OpenCossan.getRoot,'test','data','workers','Mio','isdeployed');
    end
    
    methods (TestClassSetup)
        function skip(testCase)
            testCase.assumeFail();
        end
    end
    
    
    
    
    
    
    
end