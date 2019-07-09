classdef KarhunenLoeveTest < matlab.unittest.TestCase
    % KARHUNENLOEVETEST Unit tests for the class
    % opencossan.common.inputs.stochasticprocess.KarhunenLoeve
    % see opencossan.common.inputs.stochasticprocess.StochasticProcess
    %
    % @author Edoardo Patelli <edoardo.patelli@liverpool.ac.uk>
    % =====================================================================
    % This file is part of OpenCossan.  The open general purpose matlab
    % toolbox for numerical analysis, risk and uncertainty quantification.
    %
    % OpenCossan is free software: you can redistribute it and/or modify
    % it under the terms of the GNU General Public License as published by
    % the Free Software Foundation, either version 3 of the License.
    %
    % OpenCossan is distributed in the hope that it will be useful,
    % but WITHOUT ANY WARRANTY; without even the implied warranty of
    % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    % GNU General Public License for more details.
    %
    % You should have received a copy of the GNU General Public License
    % along with OpenCossan.  If not, see <http://www.gnu.org/licenses/>.
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
            testCase.Xcovfun  = opencossan.common.inputs.stochasticprocess.CovarianceFunction( ...
                'Description','covariance function', ...
                'Format','structure',...
                'InputNames',{'t1','t2'},... % Define the inputs
                'Script', strcat('sigma = 1; b = 0.5;', ... 
                'for i=1:length(Tinput), Toutput(i).fcov  =', ...
                'sigma^2*exp(-1/b*abs(Tinput(i).t2-Tinput(i).t1));', ...
                'end'),'OutputNames',{'fcov'}); % Define the outputs
        end
        
    end
    
    methods (Test)
        %% Constructor
        function constructorEmpty(testCase)
            Xsp = opencossan.common.inputs.stochasticprocess.KarhunenLoeve;
            testCase.assertClass(Xsp,'opencossan.common.inputs.stochasticprocess.KarhunenLoeve');
        end
        
        function constructorFull(testCase)
            Xsp = opencossan.common.inputs.stochasticprocess.KarhunenLoeve(...
                'Description','Process 1','Distribution',...
                'normal','Mean',0,'CovarianceFunction',testCase.Xcovfun,...
                'Coordinates',1:0.01:5,'IsHomogeneous',true);
            testCase.verifyEqual(Xsp.Description,"Process 1");
            testCase.verifyEqual(Xsp.Distribution,"normal");
            testCase.verifyEqual(Xsp.Coordinates,1:0.01:5);
            testCase.verifyEqual(Xsp.Mean,zeros(size(Xsp.Coordinates)));
            testCase.verifyLength(Xsp.Mean(Xsp.Mean==0),length(Xsp.Coordinates));
            testCase.verifyTrue(Xsp.IsHomogeneous);
        end
        
        function constructorNoMcoord(testCase)
            testCase.verifyError(@()opencossan.common.inputs.stochasticprocess.KarhunenLoeve(...
                'Description', 'myDescription'),...
                'OpenCossan:KarhunenLoeve:noCoordinates' );
        end
        
        function constructorNoMean(testCase)
            testCase.verifyError(@()opencossan.common.inputs.stochasticprocess.KarhunenLoeve(...
                'Description', 'myDescription','Coordinates',1:0.01:5),...
                'OpenCossan:KarhunenLoeve:WrongMeanCoordinate');
        end
        
        function constructorInvalidDimensions(testCase)
            testCase.verifyError(@()opencossan.common.inputs.stochasticprocess.KarhunenLoeve(...
                'Coordinates', testCase.Vmat, 'Mean', 1:testCase.Npoints+1, ...
                'CovarianceFunction',testCase.Xcovfun),...
                'OpenCossan:KarhunenLoeve:WrongMeanCoordinate');
            testCase.verifyError(@()opencossan.common.inputs.stochasticprocess.KarhunenLoeve(...
                'Coordinates', testCase.Vmat, 'Mean', 1:testCase.Npoints-1, ...
                'CovarianceFunction',testCase.Xcovfun),...
                'OpenCossan:KarhunenLoeve:WrongMeanCoordinate');
        end
        
        function constructorNoNormalDistribution(testCase)
            testCase.assertError(@()opencossan.common.inputs.stochasticprocess.KarhunenLoeve(...
                'Distribution', 'uniform', 'Coordinates', testCase.Vmat, 'Mean', 20),...
                'OpenCossan:KarhunenLoeve:unsupportedDistribution' );
        end
        
        function constructorInvalidCovFun(testCase) % should fail on initial input, can put in @Parameter object
            testCase.assertError(@()opencossan.common.inputs.stochasticprocess.KarhunenLoeve(...
                'CovarianceFunction',opencossan.common.inputs.Parameter),...
                'MATLAB:UnableToConvert' );
        end
               
        function constructorMcovariance(testCase)
            Xsp = opencossan.common.inputs.stochasticprocess.KarhunenLoeve(...
                'Description', 'myDescription', 'Coordinates', testCase.Vmat, ...
                'Mean', 20, 'CovarianceMatrix', eye(testCase.Npoints));
            % change it to 50 to not make it work
            testCase.assertSize(Xsp.CovarianceMatrix, [testCase.Npoints testCase.Npoints]);
        end
        
        function constructorWrongMcovariance(testCase)
            testCase.assertError(@()opencossan.common.inputs.stochasticprocess.KarhunenLoeve(...
                'Description', 'myDescription', 'Coordinates', testCase.Vmat, ...
                'Mean', 20, 'CovarianceMatrix', eye(50)),...
                'OpenCossan:KarhunenLoeve:WrongCovarianceMatrix' );
         end
                
        
        function constructorDefaultValues(testCase)
            Xsp = opencossan.common.inputs.stochasticprocess.KarhunenLoeve(...
                'Description', 'myDescription', 'Coordinates', testCase.Vmat,...
                'Mean', 20, 'CovarianceFunction',testCase.Xcovfun);
            testCase.verifyEmpty(Xsp.EigenVectors);
            testCase.verifyEmpty(Xsp.EigenValues);
            testCase.verifyFalse(Xsp.IsHomogeneous);
        end
        
        function constructorWithCovfunAndMCovariance(testCase)
            %TODO
            Xsp=opencossan.common.inputs.stochasticprocess.KarhunenLoeve(...
                'Description', 'myDescription', 'Coordinates', testCase.Vmat,...
                'Mean', 20, 'CovarianceFunction',testCase.Xcovfun,...
                'CovarianceMatrix', eye(testCase.Npoints));
            testCase.assertWarning(@()Xsp.computeTerms, ...
                'OpenCossan:KarhunenLoeve:computeTerms:CovarianceFunctionAndMatrixDefined');            
        end
        
        %% KL_terms
        function klTermsWithMLB(testCase)
            Xsp=opencossan.common.inputs.stochasticprocess.KarhunenLoeve(...
                'Description', 'myDescription', 'Coordinates', testCase.Vmat,...
                'Mean', 20, 'CovarianceFunction',testCase.Xcovfun,...
                'CovarianceMatrix', tril(eye(testCase.Npoints)));
            Xsp = computeTerms(Xsp, 'NumberTerms', 2);
            testCase.assertSize(Xsp.EigenVectors, [testCase.Npoints 2]);
        end
        
        function klTermsWithCovfun(testCase)
                Xsp=opencossan.common.inputs.stochasticprocess.KarhunenLoeve(...
                'Description', 'myDescription', 'Coordinates', testCase.Vmat,...
                'Mean', 20, 'CovarianceFunction',testCase.Xcovfun,...
                'IsHomogeneous',false);
                Xsp = computeTerms(Xsp, 'NumberTerms', 5);
                testCase.assertSize(Xsp.EigenVectors, [testCase.Npoints 5]);
        end
        
        function klTermsWithMcovariance(testCase)
                Xsp=opencossan.common.inputs.stochasticprocess.KarhunenLoeve(...
                'Description', 'myDescription', 'Coordinates', testCase.Vmat,...
                'Mean', 20, 'CovarianceMatrix',eye(testCase.Npoints));
                 Xsp = computeTerms(Xsp, 'NumberTerms', 5);
                 testCase.verifySize(Xsp.EigenValues, [5 1]);
                 testCase.verifySize(Xsp.EigenVectors, [testCase.Npoints 5]);
        end
        
        %% sample
        function sample(testCase)
            Xsp=opencossan.common.inputs.stochasticprocess.KarhunenLoeve(...
            'Description', 'myDescription', 'Coordinates', testCase.Vmat,...
                'Mean', 20, 'CovarianceFunction',testCase.Xcovfun,...
                'IsHomogeneous',false);
            Xsp = computeTerms(Xsp, 'NumberTerms', 5);
            Xsp.sample('Samples', 5);
        end
        
        function sampleWithoutKlTerms(testCase)
                  Xsp=opencossan.common.inputs.stochasticprocess.KarhunenLoeve(...
            'Description', 'myDescription', 'Coordinates', testCase.Vmat,...
                'Mean', 20, 'CovarianceFunction',testCase.Xcovfun,...
                'IsHomogeneous',false);
                 testCase.assertError(@()Xsp.sample('Samples', 5),...
                     'OpenCossan:KarhunenLoeve:sample:NoTermsComputed');
        end
        
    end
end