classdef SamplesTest < matlab.unittest.TestCase
    % SAMPLESTEST Unit tests for the class common.Samples
    % see http://cossan.co.uk/wiki/index.php/@Samples 
    %
    % @author Jasper Behrensdorf<behrensdorf@irz.uni-hannover.de>
    % @date   09.08.2016
    
    properties
        Xrvs;
        Xrvs2;
        Xin;
        Xin2;
        Xin3;
        Xin4;
        Xdv1;
        Xdv2;
        Xdv3;
        Xsp;
    end
    
    methods (TestClassSetup)
        function setup(testCase)
            Xrv1 = common.inputs.RandomVariable('Sdistribution','weibull','Cpar',{'par1',363.28;'par2',62.11});
            Xrv2 = common.inputs.RandomVariable('Sdistribution','gumbel-i','mean',480,'std',48);
            Xrv4 = common.inputs.RandomVariable('Sdistribution','lognormal','mean',50,'std',15);
            Xrv3 = common.inputs.RandomVariable('Sdistribution','normal','mean',100,'std',20);
            Xrv5 = common.inputs.RandomVariable('Sdistribution','normal','mean',10,'std',10);
            Xrv6 = common.inputs.RandomVariable('Sdistribution','normal','mean',100,'std',1);
            
            testCase.Xdv1 = optimization.DesignVariable('value',31);
            testCase.Xdv2 = optimization.DesignVariable('value',0.54,'lowerBound',0.02,'upperBound',1);
            testCase.Xdv3 = optimization.DesignVariable('value',1,'Vsupport',[1 4 6 7]);
            
            testCase.Xrvs = common.inputs.RandomVariableSet('Cmembers',{'Xrv1','Xrv2','Xrv3','Xrv4'}...
                ,'Xrv',[Xrv1,Xrv2,Xrv3,Xrv4]);
            
            testCase.Xrvs2 = common.inputs.RandomVariableSet('Cmembers',{'Xrv5','Xrv6'}...
                ,'Xrv',[Xrv5,Xrv6]);
            
            Xcovfun = common.inputs.CovarianceFunction('Sdescription','covariance function', ...
                'Sscript','sigma = 1;b = 0.5;for i=1:length(Tinput),t1  = Tinput(i).t1;t2  = Tinput(i).t2;Toutput(i).fcov  = sigma^2*exp(-1/b*abs(t2-t1));end', ...
                'Lfunction',false, ...
                'Sformat','structure', ...
                'Coutputnames',{'fcov'},...
                'Cinputnames',{'t1','t2'});
            
            testCase.Xsp = common.inputs.StochasticProcess('Sdistribution','normal','Vmean',0,'Xcovariancefunction',Xcovfun,'Mcoord',0:0.1:99,'Lhomogeneous',true);
            testCase.Xsp = KL_terms(testCase.Xsp,'NKL_terms',30,'LcovarianceAssemble',false);
            
            testCase.Xin = common.inputs.Input;
            testCase.Xin = add(testCase.Xin,'Xmember',testCase.Xrvs,'Sname','Xrvs');
            testCase.Xin2 = add(testCase.Xin,'Xmember',testCase.Xrvs2,'Sname','Xrvs2');
            testCase.Xin3 = add(testCase.Xin,'Xmember',testCase.Xsp,'Sname','Xsp');
            testCase.Xin4 = add(testCase.Xin,'Xmember',testCase.Xdv1,'Sname','Xdv1');
            testCase.Xin4 = add(testCase.Xin4,'Xmember',testCase.Xdv2,'Sname','Xdv2');
            testCase.Xin4 = add(testCase.Xin4,'Xmember',testCase.Xdv3,'Sname','Xdv3');
        end
    end
    
    methods (Test)
        
        %% Test constructor
        function constructorShouldAcceptRandomVariableSet(testCase)
            testCase.assertClass(common.Samples('Xrvset',testCase.Xrvs,'MsamplesHyperCube',rand(100,4)),...
                'common.Samples');
            testCase.assertClass(common.Samples('Xrvset',testCase.Xrvs,'MsamplesStandardNormalSpace',rand(100,4)),...
                'common.Samples');
            testCase.assertClass(common.Samples('Xrvset',testCase.Xrvs,'MsamplesPhysicalSpace',rand(100,4)),...
                'common.Samples');
        end
        
        function constructorShouldAcceptInput(testCase)
            testCase.assertClass(common.Samples('Xinput',testCase.Xin,'MsamplesHyperCube',[0.1 0.1 0 0.1]),...
                'common.Samples');
            testCase.assertClass(common.Samples('Xinput',testCase.Xin,'MsamplesPhysicalSpace',rand(100,4)),...
                'common.Samples');
            testCase.assertClass(common.Samples('Xinput',testCase.Xin2,'MsamplesStandardNormalSpace',rand(100,6)),...
                'common.Samples');
        end
        
        function constructorShouldFailWithInvalidNumberOfColumns(testCase)
            testCase.assertError(@()common.Samples('Xinput',testCase.Xin,'MsamplesHyperCube',rand(100,2)),...
                'openCOSSAN:Samples:set');
            testCase.assertError(@()common.Samples('Xrvset',testCase.Xrvs,'MsamplesPhysicalSpace',rand(100,8)),...
                'openCOSSAN:Samples:set');
            testCase.assertError(@()common.Samples('Xrvset',testCase.Xrvs,'MsamplesStandardNormalSpace',rand(100,8)),...
                'openCOSSAN:Samples:set');
        end
        
        function constructorShouldAcceptMultipleRandomVariableSets(testCase)
            testCase.assertClass(common.Samples('Cxrvset',{testCase.Xrvs testCase.Xrvs2},'MsamplesStandardNormalSpace',rand(100,6)),...
                'common.Samples');
        end
        
        function contructorShouldIgnoreRandomVariableSetsInVector(testCase)
            %TODO Does this behaviour make sense? Should an error be thrown
            %instead of all elements but Xrvset(1)?
            testCase.assertError(@()common.Samples('Xrvset',[testCase.Xrvs testCase.Xrvs2],'MsamplesStandardNormalSpace',rand(100,6)),...
                'openCOSSAN:Samples:set');
        end
        
        function constructorShouldAcceptStochasticProcessAndDataseries(testCase)
            Xs = sample(testCase.Xsp,'Nsamples',10);
            Xds = Xs.Xdataseries;
            testCase.assertClass(common.Samples('XstochasticProcess',testCase.Xsp,'CnamesStochasticProcess',{'Xsp'},...
                'Xdataseries',Xds),'common.Samples');
        end
        
        function constructorShouldAcceptInputWithRvsAndDataseries(testCase)
            Xs = sample(testCase.Xsp,'Nsamples',10);
            Xds = Xs.Xdataseries;
            testCase.assertClass(common.Samples('Xinput',testCase.Xin3,'Xdataseries',Xds,'MsamplesStandardNormalSpace',randn(10,4)),...
                'common.Samples');
        end
        
        function constructorShouldAcceptDoeDesignVariables(testCase)
            testCase.assertClass(common.Samples('Xinput',testCase.Xin4,'MsamplesStandardNormalSpace',rand(20,4),'MsamplesDoeDesignVariables',rand(20,3)),...
                'common.Samples');
            
            MsampleDoe(:,1)=testCase.Xdv1.sample('Nsamples',20,'perturbation',2);
            MsampleDoe(:,2)=testCase.Xdv2.sample('Nsamples',20,'perturbation',2);
            MsampleDoe(:,3)=testCase.Xdv3.sample('Nsamples',20);
            
            testCase.assertClass(common.Samples('Xinput',testCase.Xin4,'MsamplesStandardNormalSpace',rand(20,4),'MsamplesDoeDesignVariables',MsampleDoe),...
                'common.Samples');
        end
        
        function constructorShouldFailForInconsistentSampleSizes(testCase)
            testCase.assertError(@()common.Samples('Xinput',testCase.Xin4,'MsamplesStandardNormalSpace',rand(20,4),'MsamplesDoeDesignVariables',rand(10,3)),...
                'openCOSSAN:Samples:InconsistentSamplesSize');
            testCase.assertError(@()common.Samples('Xinput',testCase.Xin4,'MsamplesStandardNormalSpace',rand(20,4),'MsamplesDoeDesignVariables',rand(30,3)),...
                'openCOSSAN:Samples:InconsistentSamplesSize');
        end
        
        %% Test add method
        function addShouldAcceptSamplesWithSameInputsButDifferentSizes(testCase)
            Xs1 = common.Samples('Xinput',testCase.Xin,'MsamplesStandardNormalSpace',rand(20,4));
            Xs2 = common.Samples('Xinput',testCase.Xin,'MsamplesStandardNormalSpace',rand(10,4));
            Xstot = Xs1.add('Xsamples',Xs2);
            testCase.assertEqual(Xstot.Nsamples,30);
        end
        
        function addShouldAcceptSamplesWithDifferentInputsButSameSizes(testCase)
            Xs1 = common.Samples('Xrvset',testCase.Xrvs,'MsamplesStandardNormalSpace',rand(20,4));
            Xs2 = common.Samples('Xrvset',testCase.Xrvs2,'MsamplesStandardNormalSpace',rand(20,2));
            Xstot = Xs1.add('Xsamples',Xs2);
            testCase.assertEqual(Xstot.Nsamples,20);
            testCase.assertEqual(length(Xstot.Cvariables),6);
        end
        
        function addShouldFailForSamplesOfDifferentSizes(testCase)
            Xs1 = common.Samples('Xrvset',testCase.Xrvs,'MsamplesStandardNormalSpace',rand(20,4));
            Xs2 = common.Samples('Xrvset',testCase.Xrvs2,'MsamplesStandardNormalSpace',rand(10,2));
            testCase.assertError(@()Xs1.add('Xsamples',Xs2),'openCOSSAN:Samples:add');
            Xs1 = common.Samples('Xrvset',testCase.Xrvs2,'MsamplesStandardNormalSpace',rand(10,2));
            Xs2 = common.Samples('Xrvset',testCase.Xrvs,'MsamplesStandardNormalSpace',rand(20,4));
            testCase.assertError(@()Xs1.add('Xsamples',Xs2),'openCOSSAN:Samples:add');
        end
        
        function addShouldAddSamplesOfTheSameSize(testCase)
            Xs = common.Samples('Xrvset',testCase.Xrvs,'MsamplesStandardNormalSpace',rand(20,4));
            Xs = Xs.add('MsamplesStandardNormalSpace',rand(10,4));
            testCase.assertEqual(Xs.Nsamples,30);
            Xs = Xs.add('MsamplesHyperCube',rand(10,4));
            testCase.assertEqual(Xs.Nsamples,40);
            Xs = Xs.add('MsamplesPhysicalSpace',rand(10,4));
            testCase.assertEqual(Xs.Nsamples,50);
        end
        
        function addShouldFailForInvalidSamplesSizes(testCase)
            Xs = common.Samples('Xrvset',testCase.Xrvs,'MsamplesStandardNormalSpace',rand(20,4));
            testCase.assertError(@()Xs.add('MsamplesStandardNormalSpace',rand(10,3)),...
                'openCOSSAN:Samples:add');
            testCase.assertError(@()Xs.add('MsamplesHyperCube',rand(10,3)),...
                'openCOSSAN:Samples:add');
            testCase.assertError(@()Xs.add('MsamplesPhysicalSpace',rand(10,3)),...
                'openCOSSAN:Samples:add');
            testCase.assertError(@()Xs.add('MsamplesStandardNormalSpace',rand(10,5)),...
                'openCOSSAN:Samples:add');
            testCase.assertError(@()Xs.add('MsamplesHyperCube',rand(10,5)),...
                'openCOSSAN:Samples:add');
            testCase.assertError(@()Xs.add('MsamplesPhysicalSpace',rand(10,5)),...
                'openCOSSAN:Samples:add');
        end
        
        function addShouldAddToSamplesContainingDataseries(testCase)
            Xs = sample(testCase.Xsp,'Nsamples',10);
            Xds = Xs.Xdataseries;
            Xs1 = common.Samples('XstochasticProcess',testCase.Xsp,'CnamesStochasticProcess',{'Xsp'},'Xdataseries',Xds);
            Xs = sample(testCase.Xsp,'Nsamples',15);
            Xs1 = Xs1.add('Xsamples',Xs);
            testCase.assertEqual(length(Xs1.Cvariables),2);
            
            Xs = sample(testCase.Xsp,'Nsamples',10);
            Xds = Xs.Xdataseries;
            Xs1 = common.Samples('XstochasticProcess',testCase.Xsp,'CnamesStochasticProcess',{'Xsp'},'Xdataseries',Xds);
            Xs2 = common.Samples('XstochasticProcess',testCase.Xsp,'CnamesStochasticProcess',{'Xsp'},'Xdataseries',Xds);
            Xs1 = Xs1.add('Xsamples',Xs2);
            testCase.assertEqual(Xs1.Nsamples,20);
        end
        
        function addShouldAddToSamplesContainingDataseriesAndRvs(testCase)
            Xs = sample(testCase.Xsp,'Nsamples',10);
            Xds = Xs.Xdataseries;
            Xs1 = common.Samples('Xinput',testCase.Xin3,'Xdataseries',Xds,'MsamplesStandardNormalSpace',randn(10,4));
            Xs2 = sample(testCase.Xin3,'Nsamples',15);
            Xs3 = Xs1.add('Xsamples',Xs2.Xsamples);
            testCase.assertEqual(Xs3.Nsamples, 25);
        end
        
        %% Test chop method
        
        function chopShouldRemoveSamplesFromRandomVariableSet(testCase)
            Xs1 = common.Samples('Xrvset',testCase.Xrvs,'MsamplesHyperCube',rand(20,4));
            Xs2 = Xs1.chop('Vchopsamples',[2 7]);
            testCase.assertEqual(Xs2.Nsamples, 18);
        end
        
        function chopShouldFailWhenNumberOfSamplesExceeds(testCase)
            Xs1 = common.Samples('Xrvset',testCase.Xrvs,'MsamplesHyperCube',rand(20,4));
            testCase.assertError(@()Xs1.chop('Vchopsamples',[2 21]),...
                'openCOSSAN:Samples:chop:ExceedNumberOfSamples');
        end
        
        function chopShouldRemoveSamplesFromDataseries(testCase)
            Xs = sample(testCase.Xsp,'Nsamples',10);
            Xds = Xs.Xdataseries;
            Xs1 = common.Samples('XstochasticProcess',testCase.Xsp,'CnamesStochasticProcess',{'Xsp'},'Xdataseries',Xds);
            Xs1 = Xs1.chop('Vchopsamples',[2 7]);
            testCase.assertEqual(Xs1.Xdataseries(1).Nsamples,8);
            
            Xs1 = common.Samples('Xinput',testCase.Xin3,'Xdataseries',Xds,'MsamplesStandardNormalSpace',rand(10,4));
            Xs1 = Xs1.chop('Vchopsamples',[2 7]);
            testCase.assertEqual(Xs1.Xdataseries(1).Nsamples,8);
        end
        
        %% Test cumulativeFrequencies
        function cumulativeFrequenciesShouldAcceptValidTarget(testCase)
            Xs1 = common.Samples('Xrvset',testCase.Xrvs,'MsamplesStandardNormalSpace',rand(20,4));
            [Vcf, V2] = Xs1.cumulativeFrequencies('Starget','Xrv1');
            testCase.assertEqual(length(Vcf),20);
            testCase.assertEqual(length(V2),20);
        end
        
        function cumulativeFrequenciesShouldFailForInvalidTarget(testCase)
            Xs1 = common.Samples('Xrvset',testCase.Xrvs,'MsamplesStandardNormalSpace',rand(20,4));
            testCase.assertError(@()Xs1.cumulativeFrequencies('Starget','Xrv5'),...
                'openCOSSAN:Samples:cumulativeFrequencies');
        end
        
        %% Test relativeFrequencies
        function relativeFrequenciesShouldAcceptValidTarget(testCase)
            Xs1 = common.Samples('Xrvset',testCase.Xrvs,'MsamplesStandardNormalSpace',rand(20,4));
            [Vrf, Vval] = Xs1.relativeFrequencies('Starget','Xrv1');
            testCase.assertEqual(length(Vrf),20);
            testCase.assertEqual(length(Vval),20);
        end
        
        function relativeFrequenciesShouldFailForInvalidTarget(testCase)
            Xs1 = common.Samples('Xrvset',testCase.Xrvs,'MsamplesStandardNormalSpace',rand(20,4));
            testCase.assertError(@()Xs1.relativeFrequencies('Starget','Xrv5'),...
                'openCOSSAN:Samples:relative_frequencies');
        end
        
        %% Test sort
        function sortShouldSortDescending(testCase)
            Xs1 = common.Samples('Xrvset',testCase.Xrvs,'MsamplesStandardNormalSpace',rand(20,4));
            [Xs, Vsorted, Vindex] = Xs1.sort('Starget','Xrv1','Stype','descend');
            testCase.assertEqual(Vsorted,Xs.MsamplesHyperCube(:,1));
            for i = 1:20
                testCase.assertEqual(Vsorted(i),Xs1.MsamplesHyperCube(Vindex(i)));
            end
            for i = 2:20
                testCase.verifyLessThan(Vsorted(i),Vsorted(i-1));
                testCase.verifyLessThan(Xs.MsamplesHyperCube(i,1),Xs.MsamplesHyperCube(i-1,1));
                testCase.verifyLessThan(Xs.MsamplesStandardNormalSpace(i,1),Xs.MsamplesStandardNormalSpace(i-1,1));
                testCase.verifyLessThan(Xs.MsamplesPhysicalSpace(i,1),Xs.MsamplesPhysicalSpace(i-1,1));
            end
        end
        
        function sortShouldSortAscending(testCase)
            Xs1 = common.Samples('Xrvset',testCase.Xrvs,'MsamplesStandardNormalSpace',rand(20,4));
            [Xs, Vsorted, Vindex] = Xs1.sort('Starget','Xrv1','Stype','ascend');
            testCase.assertEqual(Vsorted,Xs.MsamplesHyperCube(:,1));
            for i = 1:20
                testCase.assertEqual(Vsorted(i),Xs1.MsamplesHyperCube(Vindex(i)));
            end
            for i = 2:20
                testCase.verifyGreaterThan(Vsorted(i),Vsorted(i-1));
                testCase.verifyGreaterThan(Xs.MsamplesHyperCube(i,1),Xs.MsamplesHyperCube(i-1,1));
                testCase.verifyGreaterThan(Xs.MsamplesStandardNormalSpace(i,1),Xs.MsamplesStandardNormalSpace(i-1,1));
                testCase.verifyGreaterThan(Xs.MsamplesPhysicalSpace(i,1),Xs.MsamplesPhysicalSpace(i-1,1));
            end
        end
        
        function sortShouldAcceptVindex(testCase)
            Xs1 = common.Samples('Xrvset',testCase.Xrvs,'MsamplesStandardNormalSpace',rand(5,4));
            [Xs, ~, Vindex] = Xs1.sort('Starget','Xrv1','Stype','ascend','Vindex',[1 3 4 5 2]);
            for i = 1:5
                testCase.assertEqual(Xs.MsamplesHyperCube(i,1),Xs1.MsamplesHyperCube(Vindex(i),1));
            end
        end
        
        function sortShouldFailWithInvalidTarget(testCase)
            Xs1 = common.Samples('Xrvset',testCase.Xrvs,'MsamplesStandardNormalSpace',rand(20,4));
            testCase.assertError(@()Xs1.sort('Starget','Xrv5','Stype','ascend'),...
                'openCOSSAN:Samples:sort');
        end
        
        function sortShouldFailWithInvalidType(testCase)
            Xs1 = common.Samples('Xrvset',testCase.Xrvs,'MsamplesStandardNormalSpace',rand(20,4));
            testCase.assertError(@()Xs1.sort('Starget','Xrv1','Stype','invalid'),...
                'openCOSSAN:Samples:sort');
        end
    end
    
end

