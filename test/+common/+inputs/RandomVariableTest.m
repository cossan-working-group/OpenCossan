classdef RandomVariableTest < matlab.unittest.TestCase
    % RANDOMVARIABLETEST Unit tests for the class
    % common.inputs.RandomVariable
    % see http://cossan.co.uk/wiki/index.php/@RandomVariable
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
        %% Constructor
        function constructorInvalidStd(testCase)
            testCase.assertError(@()common.inputs.RandomVariable('std',0),...
                'openCOSSAN:RandomVariable:RandomVariable');
            testCase.assertError(@()common.inputs.RandomVariable('std',-1),...
                'openCOSSAN:RandomVariable:RandomVariable');
        end
        
        function constructorInvalidCov(testCase)
            testCase.assertError(@()common.inputs.RandomVariable('cov',0),...
                'openCOSSAN:RandomVariable:RandomVariable');
            testCase.assertError(@()common.inputs.RandomVariable('cov',-1),...
                'openCOSSAN:RandomVariable:RandomVariable');
            testCase.assertError(@()common.inputs.RandomVariable('cov',inf),...
                'openCOSSAN:RandomVariable:RandomVariable');
            testCase.assertError(@()common.inputs.RandomVariable('cov',-inf),...
                'openCOSSAN:RandomVariable:RandomVariable');
        end
        
        function constructorInvalidVar(testCase)
            testCase.assertError(@()common.inputs.RandomVariable('var',0),...
                'openCOSSAN:RandomVariable:RandomVariable');
            testCase.assertError(@()common.inputs.RandomVariable('var',-1),...
                'openCOSSAN:RandomVariable:RandomVariable');
        end
        
        function constructorInvalidVFrequency(testCase)
            testCase.assertError(@()common.inputs.RandomVariable('Vfrequency',[0.5 0.5]),...
                'openCOSSAN:RandomVariable:RandomVariable');
        end
        
        function constructorInvalidVcensoring(testCase)
            testCase.assertError(@()common.inputs.RandomVariable('Vcensoring',[0.5 0.5]),...
                'openCOSSAN:RandomVariable:RandomVariable');
        end
        
        function constructorNoDistribution(testCase)
            testCase.assertError(@()common.inputs.RandomVariable('mean',100),...
                'openCOSSAN:RandomVariable:noDefinedDistribution');
        end
        
        function constructorMismatchingDimensions(testCase)
            testCase.assertError(@()common.inputs.RandomVariable('Vdata',[0 1 2],'Vfrequency',[0.5 0.5]),...
                'openCOSSAN:RandomVariable:RandomVariable');
            testCase.assertError(@()common.inputs.RandomVariable('Vdata',[0 1],'Vfrequency',[0.5 0.5 0.5]),...
                'openCOSSAN:RandomVariable:RandomVariable');
        end
        
        function constructorNonNumericParameters(testCase)
            testCase.assertError(@()common.inputs.RandomVariable('Cpar',{'par1','a';'par2','b'}),...
                'openCOSSAN:RandomVariable:RandomVariable');
        end
        
        function constructorUnsupportedDistribution(testCase)
            testCase.assertError(@()common.inputs.RandomVariable('Sdistribution','foobar'),...
                'openCOSSAN:RandomVariable:noSupportedDistribution');
        end
        
        %% Normal
        function normal(testCase)
            Xrv = common.inputs.RandomVariable('Sdistribution','normal','mean',100,'std',15);
            testCase.assertEqual(Xrv.Sdistribution,'NORMAL');
            testCase.assertEqual(Xrv.mean,100);
            testCase.assertEqual(Xrv.std,15);
            testCase.assertEqual(Xrv.CoV,15/100);
            testCase.assertLength(Xrv.sample('Nsamples',10),10);
        end
        
        function normalMissingInputs(testCase)
            testCase.assertError(@()common.inputs.RandomVariable('Sdistribution','normal'),...
                'openCOSSAN:RandomVariable:normal');
            testCase.assertError(@()common.inputs.RandomVariable('Sdistribution','normal','mean',100),...
                'openCOSSAN:RandomVariable:normal');
            testCase.assertError(@()common.inputs.RandomVariable('Sdistribution','normal','std',15),...
                'openCOSSAN:RandomVariable:normal');
        end
        
        %% Lognormal
        function logNormal(testCase)
            Xrv = common.inputs.RandomVariable('Sdistribution','lognormal','mean',100,'std',0.10);
            testCase.assertEqual(Xrv.Sdistribution,'LOGNORMAL');
            testCase.assertEqual(Xrv.mean,100);
            testCase.assertEqual(Xrv.std,0.10);
            testCase.assertEqual(Xrv.CoV,0.10/100);
            testCase.assertLength(Xrv.sample('Nsamples',10),10);
        end
        
        function logNormalCpar(testCase)
            Xrv = common.inputs.RandomVariable('Sdistribution','lognormal','Cpar',{'par1',10;'par2',0.1});
            testCase.assertEqual(Xrv.Sdistribution,'LOGNORMAL');
            testCase.assertEqual(Xrv.Cpar,{'mu',10;'sigma',0.1;[],[];[],[]});
            testCase.assertLength(Xrv.sample('Nsamples',10),10);
        end
        
        function logNormalMissingInputs(testCase)
            testCase.assertError(@()common.inputs.RandomVariable('Sdistribution','lognormal'),...
                'openCOSSAN:RandomVariable:lognormal');
            testCase.assertError(@()common.inputs.RandomVariable('Sdistribution','lognormal','mean',100),...
                'openCOSSAN:RandomVariable:lognormal');
            testCase.assertError(@()common.inputs.RandomVariable('Sdistribution','lognormal','std',15),...
                'openCOSSAN:RandomVariable:lognormal');
        end
        
        %% Uniform
        function uniformCpar(testCase)
            Xrv = common.inputs.RandomVariable('Sdistribution','uniform','Cpar',{'par1',1;'par2',2});
            testCase.assertEqual(Xrv.Sdistribution,'UNIFORM');
            testCase.assertEqual(Xrv.lowerBound,1);
            testCase.assertEqual(Xrv.upperBound,2);
            testCase.assertEqual(Xrv.mean,1.5);
            testCase.assertLength(Xrv.sample('Nsamples',10),10);
        end
        
        function uniform(testCase)
            Xrv = common.inputs.RandomVariable('Sdistribution','uniform','mean',100,'std',15);
            testCase.assertEqual(Xrv.mean,100);
            testCase.assertEqual(Xrv.std,15);
            testCase.assertEqual(Xrv.lowerBound,100-sqrt(3)*15);
            testCase.assertEqual(Xrv.upperBound,100+sqrt(3)*15);
            testCase.assertLength(Xrv.sample('Nsamples',10),10);
        end
        
        function uniformInvalidLimits(testCase)
            testCase.verifyError(@()common.inputs.RandomVariable('Sdistribution','uniform','Cpar',{'par1',3;'par2',2}),...
                'openCOSSAN:RandomVariable:uniform');
        end
        
        function uniformMissingParameters(testCase)
            testCase.verifyError(@()common.inputs.RandomVariable('Sdistribution','uniform','Cpar',{'par1',3;}),...
                'openCOSSAN:RandomVariable:uniform')
            testCase.verifyError(@()common.inputs.RandomVariable('Sdistribution','uniform','Cpar',{'par2',3;}),...
                'openCOSSAN:RandomVariable:uniform')
            testCase.verifyError(@()common.inputs.RandomVariable('Sdistribution','uniform','mean',100),...
                'openCOSSAN:RandomVariable:uniform');
            testCase.verifyError(@()common.inputs.RandomVariable('Sdistribution','uniform','std',15),...
                'openCOSSAN:RandomVariable:uniform');
        end
        
        %% Exponential
        function exponential(testCase)
            Xrv = common.inputs.RandomVariable('Sdistribution','exponential','mean',3,'std',2);
            testCase.assertEqual(Xrv.Cpar,{'1/lambda',2;'shifting',1;[],[];[],[]});
            testCase.assertEqual(Xrv.lowerBound,1);
            testCase.assertEqual(Xrv.upperBound,inf);
            testCase.assertLength(Xrv.sample('Nsamples',10),10);
        end
        
        function exponentialCpar(testCase) %test that a random variable is created with exponential distribution with 1/lambda set to 3 and shifting set to 2
            Xrv = common.inputs.RandomVariable('Sdistribution','exponential','Cpar',{'par1',3;'par2',2});
            testCase.assertEqual(Xrv.Cpar,{'1/lambda',3;'shifting',2;[],[];[],[]});
            testCase.assertEqual(Xrv.lowerBound,2);
            testCase.assertEqual(Xrv.upperBound,inf);
            testCase.assertLength(Xrv.sample('Nsamples',10),10);
        end  
        
        function exponentialMissingInputs(testCase)
            testCase.verifyError(@()common.inputs.RandomVariable('Sdistribution','exponential'),...
                'openCOSSAN:RandomVariable:exponential');
        end
        
        %% Rayleigh
        function rayleigh(testCase)
            Xrv = common.inputs.RandomVariable('Sdistribution','rayleigh','std',10,'shift',2);
            testCase.assertEqual(Xrv.std,10);
            testCase.assertEqual(Xrv.lowerBound,2);
            testCase.assertLength(Xrv.sample('Nsamples',10),10);
        end
        
        function rayleightCpar(testCase)
            Xrv = common.inputs.RandomVariable('Sdistribution','rayleigh','Cpar',{'par1',2});
            testCase.assertEqual(Xrv.Cpar{1,2},2);
            testCase.assertEqual(Xrv.lowerBound,0);
            testCase.assertLength(Xrv.sample('Nsamples',10),10);
        end
        
        function rayleighMissingInputs(testCase)
            testCase.verifyError(@()common.inputs.RandomVariable('Sdistribution','rayleigh'),...
                'openCOSSAN:RandomVariable:rayleigh');
            testCase.verifyError(@()common.inputs.RandomVariable('Sdistribution','rayleigh','mean',100,'std',15),...
                'openCOSSAN:RandomVariable:rayleigh');
            testCase.verifyError(@()common.inputs.RandomVariable('Sdistribution','rayleigh','mean',100,'cov',15),...
                'openCOSSAN:RandomVariable:rayleigh');
            testCase.verifyError(@()common.inputs.RandomVariable('Sdistribution','rayleigh','cov',1,'std',15),...
                'openCOSSAN:RandomVariable:rayleigh');
        end
        

        function testRandomVariableSmall(testCase) %tests the random variable is created with small-i distribution with mean=100 and CoV=0.10
            testSmall = common.inputs.RandomVariable('Sdistribution','small-i','mean',100,'cov',0.10);
            testCase.assertEqual(testSmall.mean,100);
            testCase.assertEqual(testSmall.CoV,0.10);
        end
        function testRandomVariableLarge(testCase) %tests the random variable is created with large-i distribution with mean=100 and CoV=0.10
            testLarge = common.inputs.RandomVariable('Sdistribution','large-i','mean',100,'cov',0.10);
            testCase.assertEqual(testLarge.mean,100);
            testCase.assertEqual(testLarge.CoV,0.10);
        end
        function testRandomVariableGumbel(testCase) %tests the random variable is created with gumbel distribution with mean=100 and CoV=0.10
            testGumble = common.inputs.RandomVariable('Sdistribution','gumbel','mean',100,'cov',0.10);
            testCase.assertEqual(testGumble.mean,100);
            testCase.assertEqual(testGumble.CoV,0.10);
        end
        function testRandomVariableWeibullFail(testCase) %test that the command fails as incorrect parameters set
            testCase.verifyError(@()common.inputs.RandomVariable('Sdistribution','weibull','mean',100,'cov',0.10),'openCOSSAN:RandomVariable:weibull')
        end
        function testRandomVariableWeibull(testCase) %tests the random variable is created with weibull distribution with mean=100 and CoV=0.10
            testWeibull = common.inputs.RandomVariable('Sdistribution','weibull','Cpar',{'par1',3;'par2',2});
            testCase.assertEqual(testWeibull.Cpar,{'a',3;'b',2;[],[];[],[]});
        end
        function testRandomVariableBeta(testCase) %tests the random variable is created with beta distribution with mean=100 and CoV=0.10
            testBeta = common.inputs.RandomVariable('Sdistribution','beta','Cpar',{'par1',3;'par2',2});
            testCase.assertEqual(testBeta.Cpar,{'a',3;'b',2;[],[];[],[]});
        end
        function testRandomVariableGamma(testCase) %tests the random variable is created with gamma distribution with mean=100 and CoV=0.10
            testGamma = common.inputs.RandomVariable('Sdistribution','gamma','Cpar',{'par1',3;'par2',2});
            testCase.assertEqual(testGamma.Cpar,{'k',3;'theta',2;[],[];[],[]});
        end
        function testRandomVariableF(testCase) %tests the random variable is created with f distribution with mean=100 and CoV=0.10
            testF = common.inputs.RandomVariable('Sdistribution','f','Cpar',{'par1',3;'par2',2});
            testCase.assertEqual(testF.Cpar,{'p1',3;'p2',2;[],[];[],[]});
        end
        function testRandomVariableStudent(testCase) %tests the random variable is created with student distribution with mean=100 and CoV=0.10
            testStudent = common.inputs.RandomVariable('Sdistribution','student','Cpar',{'par1',3;'par2',2});
            testCase.assertEqual(testStudent.Cpar,{'nu',3;[],2;[],[];[],[]});
        end
        function testRandomVariableLogistic(testCase) %tests the random variable is created with logistic distribution with mean=100 and CoV=0.10
            testLogistic = common.inputs.RandomVariable('Sdistribution','logistic','Cpar',{'par1',3;'par2',2});
            testCase.assertEqual(testLogistic.Cpar,{'m',3;'s',2;[],[];[],[]});
        end
        function testRandomVariableLogisticFail(testCase) %test that the command fails as incorrect parameters set
            testCase.verifyError(@()common.inputs.RandomVariable('Sdistribution','logistic','Cpar',{'par1',3;}),'openCOSSAN:RandomVariable:logistic')
        end
        function testRandomVariablePoisson(testCase) %tests the random variable is created with poisson distribution with lambda=12
            testPoisson = common.inputs.RandomVariable('Sdistribution','poisson','par1',12);
            testCase.assertEqual(testPoisson.Cpar,{'lambda',12;[],[];[],[];[],[]});
        end
        function testRandomVariablePoissonFail(testCase) %test that the command fails as incorrect parameters set
            testCase.verifyError(@()common.inputs.RandomVariable('Sdistribution','poisson'),'openCOSSAN:RandomVariable:poisson')
        end
        function testRandomVariablePoissonFail2(testCase) %test that the command fails as incorrect parameters set
            testCase.verifyError(@()common.inputs.RandomVariable('Sdistribution','poisson','par1',0),'openCOSSAN:RandomVariable:poisson')
        end
        function testRandomVariablePoissonFail3(testCase) %test that the command fails as incorrect parameters set
            testCase.verifyError(@()common.inputs.RandomVariable('Sdistribution','poisson','mean',0,'std',1),'openCOSSAN:RandomVariable:poisson')
        end
        function testRandomVariableUnidFail(testCase) %test that the command fails as lowerbound must be lower than upperbound
            testCase.verifyError(@()common.inputs.RandomVariable('Sdistribution','unid','lowerbound',3,'upperbound',2),'openCOSSAN:rv:uniformdiscrete')
        end
        function testRandomVariableUnidFail2(testCase) %test that the command fails as incorrect parameters set
            testCase.verifyError(@()common.inputs.RandomVariable('Sdistribution','unid','lowerbound',3),'openCOSSAN:rv:uniformdiscrete')
        end
        function testRandomVariableUnidFail3(testCase) %test that the command fails as incorrect parameters set
            testCase.verifyError(@()common.inputs.RandomVariable('Sdistribution','unid','mean',5,'std',1),'openCOSSAN:rv:uniformdiscrete')
        end
        function testRandomVariableNoDist(testCase) %test that the command fails as incorrect parameters set
            testCase.verifyError(@()common.inputs.RandomVariable('mean',5,'std',1),'openCOSSAN:RandomVariable:noDefinedDistribution')
        end
        
        function testRandomVariableGetpdf(testCase) %Test the computation of the emperical pdf for the normal distribution with default bin (100)
            testGetpdf = common.inputs.RandomVariable('Sdistribution','normal','mean',100,'std',0.10);
            a = testGetpdf.getPdf;
            testCase.assertLength(a,101);
        end
        function testRandomVAriableGetpdf2(testCase) %Test the computation of the emperical pdf for the normal distribution with 150 bins
            testGetpdf = common.inputs.RandomVariable('Sdistribution','normal','mean',100,'std',0.10);
            b = testGetpdf.getPdf('Nbins',150);
            testCase.assertLength(b,151);
        end
        function testRandomVariableFittingDistribution(testCase) % Checking that a 1 x100 array of realization data is created
            testFittingDistribution = common.inputs.RandomVariable('Sdistribution','normal','Vdata',rand(100,1));
            c = testFittingDistribution.Vdata;
            testCase.assertLength(c,100)
        end
        function testRandomVariable2DesignVariable(testCase) % checking that the value of the design variable is set to 7 (par1)
            testDesignVariable = common.inputs.RandomVariable('Sdistribution','negativebinomial','par1',7,'par2',0.5);
            d = testDesignVariable.randomVariable2designVariable;
            testCase.assertEqual(d.value,7);
        end
    end
    
end

