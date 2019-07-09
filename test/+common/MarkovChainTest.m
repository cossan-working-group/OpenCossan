classdef MarkovChainTest < matlab.unittest.TestCase
    %MARKOVCHAINTEST Unit tests for the class common.MarkovChain
    % see http://cossan.co.uk/wiki/index.php/@MarkovChain
    %
    % @author Jasper Behrensdorf<behrensdorf@irz.uni-hannover.de>
    % @date   15.08.2016
    %
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
        Xrvsbase;
        Xrvsoff;
        Xin;
        Xs;
    end
    
    methods (TestClassSetup)
        function setup(testCase)
            XrvN=common.inputs.RandomVariable('Sdistribution','normal','mean',0,'std',1);
            testCase.Xrvsbase = common.inputs.RandomVariableSet('Xrv',XrvN,'Nrviid',3);
            XrvU=common.inputs.RandomVariable('Sdistribution','uniform','lowerbound',-0.5,'upperbound',0.5);
            testCase.Xrvsoff = common.inputs.RandomVariableSet('Xrv',XrvU,'Nrviid',3);
            testCase.Xin=common.inputs.Input('CXmembers',{testCase.Xrvsbase},'CSmembers',{'Xrvsbase'});
            testCase.Xin=sample(testCase.Xin,'Nsamples',10);
            testCase.Xs=testCase.Xin.Xsamples;
        end
    end
    
    methods (Test)
        
        %% Test constructor
        function constructorEmpty(testCase)
            Xmc = common.MarkovChain();
            testCase.assertClass(Xmc,'common.MarkovChain');
        end
        
        function constructorShouldFailWithoutBase(testCase)
            testCase.assertError(@()common.MarkovChain('Xoffsprings',testCase.Xrvsoff),...
                'openCOSSAN:MarkovChain:noTargetDistribution');
        end
        
        function constructorShouldFailWithoutOffspring(testCase)
            testCase.assertError(@()common.MarkovChain('Xbase',testCase.Xrvsbase),...
                'openCOSSAN:MarkovChain:noProposedDistribution');
        end
        
        function constructorShouldFailWithoutSamples(testCase)
            testCase.assertError(@()common.MarkovChain('Xbase',testCase.Xrvsbase,...
                'Xoffsprings',testCase.Xrvsoff),...
                'openCOSSAN:MarkovChain:noSamples');
        end
        
        function constructorShouldFailWithUnknownProperty(testCase)
            testCase.assertError(@()common.MarkovChain('Sunknown','unknown'),...
                'openCOSSAN:MarkovChain:MarkovChain');
        end
        
        function constructorMinimalInputShouldCreateTwoPoints(testCase)
            Xmc = common.MarkovChain('Xbase',testCase.Xrvsbase,'Xoffsprings',testCase.Xrvsoff,...
                'Xsamples',testCase.Xs);
            testCase.assertEqual(Xmc.lengthChains,2);
        end
        
        function constructorShouldCreateNPoints(testCase)
            Xmc = common.MarkovChain('Xbase',testCase.Xrvsbase,'Xoffsprings',testCase.Xrvsoff,...
                'Xsamples',testCase.Xs,'Npoints',9);
            testCase.assertEqual(Xmc.lengthChains,10);
        end
        
        function constructorThinShouldOmitPoints(testCase)
            Xmc = common.MarkovChain('Xbase',testCase.Xrvsbase,'Xoffsprings',testCase.Xrvsoff,...
                'Xsamples',testCase.Xs,'Npoints',9,'thin',2);
            testCase.assertEqual(Xmc.lengthChains,5);
            Xmc = common.MarkovChain('Xbase',testCase.Xrvsbase,'Xoffsprings',testCase.Xrvsoff,...
                'Xsamples',testCase.Xs,'Npoints',9,'thin',3);
            testCase.assertEqual(Xmc.lengthChains,4);
        end
        
        function constructorBurninShouldOmitPoints(testCase)
            Xmc = common.MarkovChain('Xbase',testCase.Xrvsbase,'Xoffsprings',testCase.Xrvsoff,...
                'Xsamples',testCase.Xs,'Npoints',9,'burnin',4);
            testCase.assertEqual(Xmc.lengthChains,6);
            Xmc = common.MarkovChain('Xbase',testCase.Xrvsbase,'Xoffsprings',testCase.Xrvsoff,...
                'Xsamples',testCase.Xs,'Npoints',9,'burnin',7);
            testCase.assertEqual(Xmc.lengthChains,3);
        end
        
        %% Test buildChain
        
        function buildChainWillOverrideSamples(testCase)
            Xmc = common.MarkovChain('Xbase',testCase.Xrvsbase,'Xoffsprings',testCase.Xrvsoff,...
                'Xsamples',testCase.Xs,'Npoints',5);
            Chains = Xmc.getChain('Vchain',1:6);
            Xmc = Xmc.buildChain(5);
            testCase.assertNotEqual(Chains,Xmc.getChain('Vchain',1:6));
        end
        
        %% Test add
        function addPoints(testCase)
            Xmc = common.MarkovChain('Xbase',testCase.Xrvsbase,'Xoffsprings',testCase.Xrvsoff,...
                'Xsamples',testCase.Xs,'Npoints',5);
            Xmc = Xmc.add('Npoints',4);
            testCase.assertEqual(Xmc.lengthChains,10);
        end
        
        %% Test remove
        function removeShouldRecreateSpecificChainElements(testCase)
            Xmc = common.MarkovChain('Xbase',testCase.Xrvsbase,'Xoffsprings',testCase.Xrvsoff,...
                'Xsamples',testCase.Xs,'Npoints',5);
            Chains135 = Xmc.getChain('Vchain',[1 3 5]);
            Chains246 = Xmc.getChain('Vchain',[2 4 6]);
            Xmc = Xmc.remove('Vchain',[1 3 5]);
            testCase.assertNotEqual(Chains135,Xmc.getChain('Vchain',[1 3 5]));
            testCase.assertEqual(Chains246,Xmc.getChain('Vchain',[2 4 6]));
        end
        
        function removeShouldShortenChains(testCase)
            Xmc = common.MarkovChain('Xbase',testCase.Xrvsbase,'Xoffsprings',testCase.Xrvsoff,...
                'Xsamples',testCase.Xs,'Npoints',5);
            Xmc = Xmc.remove('Npoints',3);
            testCase.assertEqual(Xmc.lengthChains,3);
        end
        
    end
    
end

