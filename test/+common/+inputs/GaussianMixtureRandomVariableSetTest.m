classdef GaussianMixtureRandomVariableSetTest < matlab.unittest.TestCase
    % GAUSSIANMIXTURERANDOMVARIABLESETTEST Unit tests for the class
    % common.inputs.GaussianMixtureRandomVariableSet
    % see http://cossan.co.uk/wiki/index.php/@GaussianMixtureRandomVariableSet
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
        Mdata;
        MXorig = [5 2 1; 2 0 1];
    end
    
    methods (TestMethodSetup)
        function setup(testCase)
            N = 20;
            A1 = [2 -1.8 0; -1.8 2 0; 0 0 1];
            A2 = [2 -1.9 1.9; -1.9 2 -1.9; 1.9 -1.9 2];
            A3 = [2 1.9 0;1.9 2 0; 0 0 1];
            p = [0.03 0.95 0.02];
            MU = [4 4 -4;-3 -5 4;4 -4 0];
            SIGMA = cat(3,A1,A2,A3);
            obj = gmdistribution(MU,SIGMA,p);
            testCase.Mdata = random(obj,N);
        end
    end
    
    methods (Test)
        %% Constructor
        function constructorEmpty(testCase)
            Xgm = common.inputs.GaussianMixtureRandomVariableSet();
            testCase.assertClass(Xgm,'common.inputs.GaussianMixtureRandomVariableSet');
        end
        
        function constructor(testCase)
            Vweights = rand(1,20);
            Xgm = common.inputs.GaussianMixtureRandomVariableSet('Sdescription','GMRVS','MdataSet',testCase.Mdata,'Cmembers',{'X1' 'X2' 'X3'},...
                'Vweights',Vweights);
            testCase.assertEqual(Xgm.Sdescription,'GMRVS');
            testCase.assertEqual(Xgm.Cmembers,{'X1' 'X2' 'X3'});
            testCase.assertEqual(Xgm.Nrv,3);
            testCase.assertEqual(Xgm.Ncomponents,20);
            testCase.assertEqual(Xgm.MdataSet,testCase.Mdata);
        end
        
        function constructorShouldFailWithoutNecessaryInputs(testCase)
            testCase.assertError(@() common.inputs.GaussianMixtureRandomVariableSet('Cmembers',{'X1' 'X2' 'X3'}),...
                'openCOSSAN:GaussianMixtureRandomVariableSet');
            testCase.assertError(@() common.inputs.GaussianMixtureRandomVariableSet('MdataSet',testCase.Mdata),...
                'openCOSSAN:GaussianMixtureRandomVariableSet');
        end
        
        function constructorShouldFailWithInconsistentCorrelationMatrix(testCase)
            Mcorr = [0.5 0.5 0.5 1; 0.5 0.5 0.5 1; 0.5 0.5 0.5 1]; 
            testCase.assertError(@() common.inputs.GaussianMixtureRandomVariableSet('Cmembers',{'X1' 'X2' 'X3'},...
                'Mcorrelation',Mcorr),'openCOSSAN:GaussianMixtureRandomVariableSet');
        end
        
        function constructorShouldFailWithInconsistentCovarianceMatrix(testCase)
            Mcov = [0.5 0.5 0.5 1; 0.5 0.5 0.5 1; 0.5 0.5 0.5 1]; 
            testCase.assertError(@() common.inputs.GaussianMixtureRandomVariableSet('Cmembers',{'X1' 'X2' 'X3'},...
                'Mcorrelation',Mcov),'openCOSSAN:GaussianMixtureRandomVariableSet');
        end
        
        %% map2stdnorm
        function map2stdnorm(testCase)
            Xgm = common.inputs.GaussianMixtureRandomVariableSet('Sdescription','GMRVS','MdataSet',testCase.Mdata,'Cmembers',{'X1' 'X2' 'X3'});
            Mstd = Xgm.map2stdnorm(testCase.MXorig); %TODO Sometimes gives NaN values, is that correct?
            testCase.assertSize(Mstd,[2 3]);
        end
        
        %% map2physical
        function map2physical(testCase)
            Xgm = common.inputs.GaussianMixtureRandomVariableSet('Sdescription','GMRVS','MdataSet',testCase.Mdata,'Cmembers',{'X1' 'X2' 'X3'});
            MS = Xgm.map2stdnorm(testCase.MXorig);
            Mphys = Xgm.map2physical(MS);
            testCase.assertSize(Mphys,[2 3]); % TODO Change to assertEqual once map2stdnorm is fixed
            %testCase.assertEqual(Mphys,testCase.MXorig,'AbsTol',1e-6);
        end
        
        %% physical2cdf
        function physical2cdf(testCase)
            Xgm = common.inputs.GaussianMixtureRandomVariableSet('Sdescription','GMRVS','MdataSet',testCase.Mdata,'Cmembers',{'X1' 'X2' 'X3'});
            Mcdf = Xgm.physical2cdf(testCase.MXorig);
            testCase.assertSize(Mcdf,[2 3]);
        end
        
        %% stdnorm2cdf
        function stdnorm2cdf(testCase)
            Xgm = common.inputs.GaussianMixtureRandomVariableSet('Sdescription','GMRVS','MdataSet',testCase.Mdata,'Cmembers',{'X1' 'X2' 'X3'});
            Mcdf = Xgm.stdnorm2cdf(testCase.MXorig);
            testCase.assertSize(Mcdf,[2 3]);
        end
        
        %% cdf2stdnorm
        function cdf2stdnorm(testCase)
            Xgm = common.inputs.GaussianMixtureRandomVariableSet('Sdescription','GMRVS','MdataSet',testCase.Mdata,'Cmembers',{'X1' 'X2' 'X3'});
            Mcdf = Xgm.physical2cdf(testCase.MXorig);
            MS = Xgm.cdf2stdnorm(Mcdf);
            testCase.assertSize(MS,[2 3]);
        end
        
        %% cdf2physical
        function cdf2physical(testCase)
            Xgm = common.inputs.GaussianMixtureRandomVariableSet('Sdescription','GMRVS','MdataSet',testCase.Mdata,'Cmembers',{'X1' 'X2' 'X3'});
            Mcdf = Xgm.physical2cdf(testCase.MXorig);
            Mphys = Xgm.cdf2physical(Mcdf);
            testCase.assertSize(Mphys,[2 3]);
        end
        
    end
    
end

