classdef PoissonRandomVariableTest < matlab.unittest.TestCase
    %POISSONRANDOMVARIABLETEST Unit tests for the class
    % opencossan.common.inputs.random.RandomVariable
    % See also: opencossan.common.inputs.random.RandomVariable
    
    % =====================================================================
    % This file is part of *OpenCossan*: you can redistribute it and/or modify
    % it under the terms of the GNU General Public License as published by
    % the Free Software Foundation, either version 3 of the License.
    %
    % *OpenCossan* is distributed in the hope that it will be useful,
    % but WITHOUT ANY WARRANTY; without even the implied warranty of
    % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    % GNU General Public License for more details.
    %
    % You should have received a copy of the GNU General Public License
    % along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
    % =====================================================================
    
    methods (Test)
        %% Constructor
        function constructorEmpty(testCase)
            random = opencossan.common.inputs.random.PoissonRandomVariable();
            testCase.assertClass(random,'opencossan.common.inputs.random.PoissonRandomVariable');
        end
        
        function constructorFull(testCase)
            random = opencossan.common.inputs.random.PoissonRandomVariable('lambda',1,...
                'Description', "Test Description");
            testCase.verifyEqual(random.Lambda, 1);
            testCase.verifyEqual(random.Description, "Test Description");
        end
        
        %% fromMeanAndStd
        function fromMeanAndStdShouldThrowException(testCase)
            import opencossan.common.inputs.random.PoissonRandomVariable;
            testCase.verifyError(@() PoissonRandomVariable.fromMeanAndStd(),...
                'PoissonRandomVariable:UnsupportedOperation');
        end
        
        %% get.Std
        function getStdShouldCalculateStd(testCase)
            random = opencossan.common.inputs.random.PoissonRandomVariable('lambda',2);
            testCase.verifyEqual(sqrt(2), random.Std);
        end
        
        %% get.Mean
        function getMeanShouldCalculateMean(testCase)
            random = opencossan.common.inputs.random.PoissonRandomVariable('lambda',2);
            testCase.verifyEqual(2, random.Mean);   
        end
        
        %% shifting
        function shifting(testCase)
            random = opencossan.common.inputs.random.PoissonRandomVariable('lambda',1);
            random.Shift = 1;
            testCase.verifyEqual(2, random.Mean);
        end
        
         %% sample
        function SampleEmpty(testCase)
            random = opencossan.common.inputs.random.PoissonRandomVariable('lambda',1);
            value = random.sample();
            testCase.verifySize(value, [1,1]);
        end
        
        function SampleOnlyM(testCase)
            random = opencossan.common.inputs.random.PoissonRandomVariable('lambda',1);
            value = random.sample(2);
            testCase.verifySize(value, [2,1]);
        end
        
        function SampleWithMAndN(testCase)
            random = opencossan.common.inputs.random.PoissonRandomVariable('lambda',1);
            value = random.sample([2 2]);
            testCase.verifySize(value, [2,2]);
        end
        
        %% map2physical
        function map2physical(testCase)
            random = opencossan.common.inputs.random.PoissonRandomVariable('lambda',1);
            VX = random.map2physical(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        
        %% cdf2physical
        function cdf2physical(testCase)
            random = opencossan.common.inputs.random.PoissonRandomVariable('lambda',1);
            VX = random.cdf2physical(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        
        %% map2stdnorm
        function map2stdnorm(testCase)
            random = opencossan.common.inputs.random.PoissonRandomVariable('lambda',1);
            VX = random.map2stdnorm(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        
        %% physical2cdf
        function physical2cdf(testCase)
            random = opencossan.common.inputs.random.PoissonRandomVariable('lambda',1);
            VX = random.physical2cdf(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        
        %% evalpdf
        function evalpdf(testCase)
            random = opencossan.common.inputs.random.PoissonRandomVariable('lambda',1);
            VX = random.evalpdf(rand(10));
            testCase.verifySize(VX,[10 10]);
        end
        
        %% fit
        function fit(testCase)
            random = opencossan.common.inputs.random.PoissonRandomVariable('lambda',1);
            samples = random.sample(100);
            phat = opencossan.common.inputs.random.PoissonRandomVariable.fit(...
                'data',samples,'frequency',[],'censoring',[],'alpha',0.05);
            testCase.verifyEqual(phat.Lambda,1.0,'RelTol',0.2);
        end
        
        %qqplot
        function qqplotShouldReturnFigure(testCase)
            random = opencossan.common.inputs.random.PoissonRandomVariable('lambda',1);
            data = random.sample(100);
            [~, f] = opencossan.common.inputs.random.PoissonRandomVariable.fit(...
                'data',data,'frequency',[],'censoring',[],'alpha',0.05,'qqplot',true);
            testCase.assertClass(f,'matlab.ui.Figure');
            close(f);
        end
    end
end


