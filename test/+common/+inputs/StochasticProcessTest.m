classdef StochasticProcessTest < matlab.unittest.TestCase
    % STOCHASTICPROCESSTEST Unit tests for the class
    % common.inputs.StochasticProcess
    % see http://cossan.co.uk/wiki/index.php/@StochasticProcess
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
        Vmat;
        Xcovfun;
        Npoints=7
        MmatrixPositive=[4 7  5 ; 1  7 4 ;  7  4   7 ];
    end
    
    methods (TestClassSetup)
        function defineMatrices(testCase)
            testCase.Vmat = linspace(0,50,testCase.Npoints);
        end
        
        function defineCovarianceFunction(testCase)
            testCase.Xcovfun  = common.inputs.CovarianceFunction('Sdescription','covariance function', ...
                'Sformat','structure',...
                'Cinputnames',{'t1','t2'},... % Define the inputs
                'Sscript', 'sigma = 1; b = 0.5; for i=1:length(Tinput), Toutput(i).fcov  = sigma^2*exp(-1/b*abs(Tinput(i).t2-Tinput(i).t1)); end', ...
                'Coutputnames',{'fcov'}); % Define the outputs
        end
        
    end
    
    methods (Test)
        %% Constructor
        function constructorEmpty(testCase)
            Xsp = common.inputs.StochasticProcess;
            testCase.assertClass(Xsp,'common.inputs.StochasticProcess');
        end
        
        function constructorFull(testCase)
            Xsp = common.inputs.StochasticProcess('Sdescription','Process 1','Sdistribution',...
                'normal','mean',0,'Xcovariancefunction',testCase.Xcovfun,'Mcoord',1:0.01:5,'Lhomogeneous',true);
            testCase.assertEqual(Xsp.Sdescription,'Process 1');
            testCase.assertEqual(Xsp.Sdistribution,'normal');
            testCase.assertEqual(Xsp.Mcoord,1:0.01:5);
            testCase.assertEqual(Xsp.Vmean,zeros(size(Xsp.Mcoord)));
            testCase.assertLength(Xsp.Vmean(Xsp.Vmean==0),length(Xsp.Mcoord));
            testCase.assertTrue(Xsp.Lhomogeneous);
        end
        
        function constructorNoMcoord(testCase)
            testCase.assertError(@()common.inputs.StochasticProcess('Sdescription', 'Description'),...
                'openCOSSAN:StochasticProcess:StochasticProcess' );
        end
        
        function constructorNoMean(testCase)
            testCase.assertError(@()common.inputs.StochasticProcess('Sdescription', 'Description','Mcoord',1:0.01:5),...
                'openCOSSAN:StochasticProcess:StochasticProcess:WrongMeanCoordinate');
        end
        
        function constructorInvalidDimensions(testCase)
            testCase.assertError(@()common.inputs.StochasticProcess('Mcoord', testCase.Vmat, 'Vmean', 1:testCase.Npoints+1, 'XcovarianceFunction',testCase.Xcovfun),...
                'openCOSSAN:StochasticProcess:StochasticProcess:WrongMeanCoordinate');
            testCase.assertError(@()common.inputs.StochasticProcess('Mcoord', testCase.Vmat, 'Vmean', 1:testCase.Npoints-1, 'XcovarianceFunction',testCase.Xcovfun),...
                'openCOSSAN:StochasticProcess:StochasticProcess:WrongMeanCoordinate');
        end
        
        function constructorNoNormalDistribution(testCase)
            testCase.assertError(@()common.inputs.StochasticProcess('Sdistribution', 'uniform', 'Mcoord', testCase.Vmat, 'Vmean', 20),...
                'openCOSSAN:StochasticProcess:checkDistribution' );
        end
        
        function constructorInvalidCovFun(testCase) % should fail on initial input, can put in @Parameter object
            testCase.assertError(@()common.inputs.StochasticProcess('XcovarianceFunction',common.inputs.Parameter),...
                'openCOSSAN:StochasticProcess:checkCovarianceFunction' );
        end
        
        function constructorCXcovarianceFunction (testCase)
            Xsp = common.inputs.StochasticProcess('Sdescription', 'Description', 'Mcoord', testCase.Vmat, 'Vmean', 20, 'CXcovarianceFunction', {testCase.Xcovfun});
            testCase.assertEqual(Xsp.Xcovariancefunction.Sscript, 'sigma = 1; b = 0.5; for i=1:length(Tinput), Toutput(i).fcov  = sigma^2*exp(-1/b*abs(Tinput(i).t2-Tinput(i).t1)); end');
        end
        
        function constructorCXcovariancex2Function (testCase) % TODO Should this throw an error? Do we even need to pass cells?
            Xcovfun2  = common.inputs.CovarianceFunction('Sdescription','covariance function 2', ...
                'Sformat','structure',...
                'Cinputnames',{'t1','t2'},... % Define the inputs
                'Sscript', 'sigma = 1; b = 0.5; for i=1:length(Tinput), Toutput(i).fcov  = sigma^2.5*exp(-1/b*abs(Tinput(i).t2+Tinput(i).t1)); end', ...
                'Coutputnames',{'fcov'}); % Define the outputs'
            Xsp = common.inputs.StochasticProcess('Sdescription', 'Description', 'Mcoord', testCase.Vmat, 'Vmean', 20, 'CXcovarianceFunction', {testCase.Xcovfun Xcovfun2}); % but I can also add {testCase.Xcovfun}
            testCase.assertEqual(Xsp.Xcovariancefunction.Sscript, 'sigma = 1; b = 0.5; for i=1:length(Tinput), Toutput(i).fcov  = sigma^2*exp(-1/b*abs(Tinput(i).t2-Tinput(i).t1)); end');
        end
        
        function constructorMcovariance(testCase)
            Xsp = common.inputs.StochasticProcess('Sdescription', 'Description', 'Mcoord', testCase.Vmat, 'Vmean', 20, 'Mcovariance', eye(testCase.Npoints)); % change it to 50 to not make it work
            testCase.assertSize(Xsp.Mcovariance, [testCase.Npoints testCase.Npoints]);
        end
        
        function constructorInvalidMcovariance(testCase)
            testCase.assertError(@()common.inputs.StochasticProcess('Sdescription', 'Description', 'Mcoord', testCase.Vmat, 'Vmean', 20, 'Mcovariance', eye(50)),...
                'openCOSSAN:StochasticProcess:StochasticProcess');
        end
        
        function constructorMLBcovariance(testCase)
            Xsp = common.inputs.StochasticProcess('Sdescription', 'Description', 'Mcoord', testCase.Vmat, 'Vmean', 20, 'MLBcovariance', tril(eye(testCase.Npoints)));
            testCase.assertSize(Xsp.Mcovariance, [testCase.Npoints testCase.Npoints]);
        end
        
        function constructorDefaultValues(testCase)
            Xsp = common.inputs.StochasticProcess('Sdescription', 'Description', 'Mcoord', testCase.Vmat, 'Vmean', 20, 'XcovarianceFunction',testCase.Xcovfun);
            testCase.assertEmpty(Xsp.McovarianceEigenvectors);
            testCase.assertEmpty(Xsp.VcovarianceEigenvalues)
            testCase.assertFalse(Xsp.Lhomogeneous);
        end
        
        function constructorWithCovfunAndMCovariance(testCase)
            testCase.assertWarning(@()common.inputs.StochasticProcess('Sdescription', 'Description',...
                'Mcoord', testCase.Vmat, 'Vmean', 20, 'CXcovarianceFunction', {testCase.Xcovfun},...
                'Mcovariance', eye(testCase.Npoints)),'openCOSSAN:StochasticProcess:StochasticProcess');
        end
        
        %% KL_terms
        function klTermsWithMLB(testCase)
            Xsp = common.inputs.StochasticProcess('Sdescription', 'Description', 'Mcoord', testCase.Vmat, 'Vmean', 20, 'MLBcovariance', tril(eye(testCase.Npoints)) );
            Xsp = KL_terms(Xsp, 'NKL_terms', 2);
            testCase.assertSize(Xsp.McovarianceEigenvectors, [testCase.Npoints 2]);
        end
        
        function klTermsWithCovfun(testCase)
            Xsp = common.inputs.StochasticProcess('Sdescription', 'Description', 'Mcoord', testCase.Vmat, 'Vmean', 20, 'XcovarianceFunction',testCase.Xcovfun, 'Lhomogeneous', false);
            Xsp = KL_terms(Xsp, 'NKL_terms',5);
            testCase.assertSize(Xsp.McovarianceEigenvectors, [testCase.Npoints 5]);
        end
        
        function klTermsWithMcovariance(testCase)
            Xsp = common.inputs.StochasticProcess('Sdescription', 'Description', 'Mcoord', testCase.Vmat, 'Vmean', 20, 'Mcovariance', eye(testCase.Npoints));
            Xsp = KL_terms(Xsp, 'NKL_terms', 5);
            testCase.assertSize(Xsp.VcovarianceEigenvalues, [5 1]);
            testCase.assertSize(Xsp.McovarianceEigenvectors, [testCase.Npoints 5]);
        end
        
        %% sample
        function sample(testCase)
            Xsp = common.inputs.StochasticProcess('Sdescription', 'Description', 'Mcoord', testCase.Vmat, 'Vmean', 20, 'XcovarianceFunction',testCase.Xcovfun, 'Lhomogeneous', false);
            Xsp = KL_terms(Xsp, 'NKL_terms',5);
            Xsp.sample('Nsamples', 5);
        end
        
        function sampleWithoutKlTerms(testCase)
            Xsp = common.inputs.StochasticProcess('Sdescription', 'Description', 'Mcoord', testCase.Vmat, 'Vmean', 20, 'XcovarianceFunction',testCase.Xcovfun, 'Lhomogeneous', false);
            testCase.assertError(@()Xsp.sample('Nsamples', 5),'openCOSSAN:StochasticProcess:sample');
        end
        
    end
end