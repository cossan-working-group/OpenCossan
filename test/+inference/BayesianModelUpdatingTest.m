classdef BayesianModelUpdatingTest < matlab.unittest.TestCase
    %BAYESIANMODELUPDATING Unit tests for the class
    % inference.BayesianModelUpdating
    % see http://cossan.co.uk/wiki/index.php/@BayesianModelUpdating
    %
    % @author Ander Gray<ander.gray@liv.ac.uk>
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
        Prior
        LikeLi
    end
    
    methods (Test)
        %% Constructor
        
        function constructorMissingInputs(testCase)
            testcase.Prior = opencossan.common.RandomVariable('Sdistribution', 'normal','mean',0,'std',1);
            testcase.LikeLi = opencossan.inference.LogLikelihood();
            testCase.assumeError(@()opencossan.inference.BayesianModelUpdating('Prior',testcase.Prior),...
                'openCOSSAN:inference:BayesianModelUpdating');
            testCase.assumeError(@()opencossan.inference.BayesianModelUpdating('XLogLikelihood',testcase.LikeLi),...
                'openCOSSAN:inference:BayesianModelUpdating');
        end
    end
end

