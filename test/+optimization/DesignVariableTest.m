classdef DesignVariableTest < matlab.unittest.TestCase
    % DESIGNVARIABLETEST Unit tests for the class
    % optimization.DesignVariable
    % see http://cossan.co.uk/wiki/index.php/@DesignVariable
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
    
    
    methods (Test)
        %% constructor
        function constructorEmpty(testCase)
            Xdv = optimization.DesignVariable;
            testCase.assertClass(Xdv,'optimization.DesignVariable');
        end
        
        function constructorDiscreteDesignVariable(testCase)
            Xdv = optimization.DesignVariable('Sdescription','Discrete DV','value', 2, 'Vsupport', 1:6);
            testCase.assertTrue(Xdv.Ldiscrete);
            testCase.assertEqual(Xdv.value,2);
            testCase.assertEqual(Xdv.Vsupport, 1:6);
            testCase.assertEqual(Xdv.Sdescription,'Discrete DV');
        end
        
        function constructorContinousDesignVariable(testCase)
            Xdv = optimization.DesignVariable('value', 2);
            testCase.assertEqual(Xdv.value,2);
            testCase.assertFalse(Xdv.Ldiscrete);
        end
        
        function constructorContinousDesignVariableWithBounds(testCase)
            Xdv = optimization.DesignVariable('value',2,'lowerbound',1,'upperbound',10);
            testCase.assertEqual(Xdv.value,2);
            testCase.assertEqual(Xdv.lowerBound,1);
            testCase.assertEqual(Xdv.upperBound,10);
        end
        
        function constructorShouldFailWithInconsistentBounds(testCase)
            testCase.assertError(@()(optimization.DesignVariable('value', 20, 'minvalue', 20, 'maxvalue', 5)),...
                'openCOSSAN:DesignOfExperiments:DesignOfExperiments');
        end
        
        function constructorShouldFailWithOutOfBoundsValue(testCase)
            testCase.assertError( @()(optimization.DesignVariable('value', 25,'minvalue', 20, 'maxvalue', 22)), 'openCOSSAN:DesignVariable:outOfBound' );
        end
        
        function constructorShouldFailOutsideSupport(testCase)
            % Currently the lowest possible value is used if the chosen
            % value is out of bounds
            % TODO: Figure out desired behaviour
            assumeFail(testCase); % Skip test for the time being
            testCase.assertError( @()optimization.DesignVariable('value', 25,'Vsupport',1:20),...
                'openCOSSAN:DesignVariable:outOfBound' );
        end
        
        %% sample
        function sample(testCase)
            Xdv = optimization.DesignVariable('value', 20, 'minvalue', 10, 'maxvalue', 30);
            Vout = Xdv.sample('Nsamples', 10);
            testCase.assertSize(Vout, [10 1]) ;
        end
        
        function sampleZeroPoints(testCase)
            assumeFail(testCase); % TODO Should this throw an error?
            Xdv = optimization.DesignVariable('value', 20, 'minvalue', 10, 'maxvalue', 30);
            testCase.assertError(@()Xdv.sample('Nsamples', 0),...
               'openCOSSAN:DesignVariable:sample');
        end
        
        function sampleShouldFailWithoutPertubationAndInifiniteBounds(testCase)
            Xdv = optimization.DesignVariable('value', 20);
            testCase.assertError(@()Xdv.sample('Nsamples',10),...
                'openCOSSAN:DesignVariable:sample');
        end
        
        function sampleShouldWarnAboutVboundsAndDiscreteVariable(testCase)
            Xdv = optimization.DesignVariable('value', 2, 'Vsupport', 1:6);
            testCase.assertWarning(@()Xdv.sample('Nsamples',10,'Vbounds',[1 6]),...
                'openCOSSAN:DesignVariable:sample');
        end
        
        %% getValue
        function getValue(testCase)
            Xdv = optimization.DesignVariable('value', 20, 'minvalue', 10, 'maxvalue', 30);
            Xdv.sample('Nsamples', 10);
            testCase.assertEqual(Xdv.getValue(0.1), 12);
            testCase.assertEqual(Xdv.getValue(0.2), 14);
            testCase.assertEqual(Xdv.getValue(1.0), 30);
        end
        
        %% getPercentile
        function getPercentile(testCase)
            Xdv = optimization.DesignVariable('value', 20, 'minvalue', 10, 'maxvalue', 30);
            Xdv.sample('Nsamples', 10);
            testCase.assertEqual(Xdv.getPercentile(20), 0.5);
            testCase.assertEqual(Xdv.getPercentile(14), 0.2);
            testCase.assertEqual(Xdv.getPercentile(26), 0.8);
        end        
        
        function getPercentileShouldFailOutsideBounds(testCase)
            Xdv = optimization.DesignVariable('value', 3, 'Vsupport',1:6);
            Xdv.sample('Nsamples', 10);
            testCase.assertError(@()Xdv.getPercentile(7),...
                'openCOSSAN:DesignVariable:percentile');
        end
                
    end
end