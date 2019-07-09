classdef PerformanceFunctionTest < matlab.unittest.TestCase
    % PERFORMANCEFUNCTIONTEST Unit tests for the class
    % reliability.PerformanceFunction
    % see http://cossan.co.uk/wiki/index.php/@PerformanceFunction
    %
    % @author Jasper Behrensdorf <behrensdorf@irz.uni-hannover.de>
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
    
    methods (Test)
        %% constructor
        function constructorEmpty(testCase)
            Xpf = reliability.PerformanceFunction();
            testCase.assertClass(Xpf,'reliability.PerformanceFunction');
        end
        
        function constructorFull(testCase)
            Xpf = reliability.PerformanceFunction('OutputName','vg',...
                'Sdescription','Unit Test PerformanceFunction',...
                'Capacity','Xvar2',...
                'Demand','Xvar1',...
                'StdDeviationIndicatorFunction',0.1);
            
            testCase.assertEqual(Xpf.Sdescription,'Unit Test PerformanceFunction');
            testCase.assertEqual(Xpf.Capacity,'Xvar2');
            testCase.assertEqual(Xpf.Demand,'Xvar1');
            testCase.assertEqual(Xpf.StdDeviationIndicatorFunction,0.1);
            testCase.assertEqual(Xpf.Cinputnames,{'Xvar2' 'Xvar1'});
            testCase.assertEqual(Xpf.Coutputnames,{'vg'});
        end
        
        function constructorShouldFailWithoutOutput(testCase)
            testCase.assertError(@() reliability.PerformanceFunction('Capacity','Xvar2',...
                'Demand','Xvar1'),'OpenCossan:PerformanceFunction:MissingRequiredParameter');
        end
    end
    
end

