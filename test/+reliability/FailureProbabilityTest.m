classdef FailureProbabilityTest < matlab.unittest.TestCase
    % FAILUREPROBABILITYTEST Unit tests for the class
    % reliability.FailureProbability
    % see http://cossan.co.uk/wiki/index.php/@FailureProbability
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
    
    properties
    end
    
    methods (Test)
        %% constructor
        function constructorEmpty(testCase)
            Xfp = reliability.FailureProbability();
            testCase.assertClass(Xfp,'reliability.FailureProbability');
        end
        
        function constructor(testCase)
            Xfp = reliability.FailureProbability('Sdescription','Unit Test FailureProbability',...
                'Smethod','UserDefined',...
                'SexitFlag','Exit',...
                'pf',0.01,...
                'variancePf',2,...
                'secondMoment',10,...
                'Nsamples',10);
            
            testCase.assertEqual(Xfp.Sdescription,'Unit Test FailureProbability');
            testCase.assertEqual(Xfp.Smethod,'UserDefined');
            testCase.assertEqual(Xfp.SexitFlag,'Exit');
            testCase.assertEqual(Xfp.Vpf(1),0.01);
            testCase.assertEqual(Xfp.VvariancePf(1),2);
            testCase.assertEqual(Xfp.VsecondMoment(1),10);
            testCase.assertEqual(Xfp.Nsamples,10);
        end
        
        function constructorShouldFailForInvalidArguments(testCase)
            testCase.assertError(@() reliability.FailureProbability('Sdescription','Unit Test FailureProbability'),...
                'openCOSSAN:output:FailureProbability');
        end
        
        %% addBatch
        function addBatchEqualWeights(testCase)
            Nsamples=2;
            Nbatches=1000;
            Vrand=rand(Nsamples*Nbatches,1)-1;
            Mrand = reshape(Vrand,Nsamples,Nbatches);
            
            pfs = mean(Mrand,1);
            pfs2 = mean(Mrand.^2,1);
            vars = var(Mrand,1);
            varpf= (pfs2-pfs.^2)/Nsamples;
            
            Xpf = reliability.FailureProbability('pf',pfs(1),...
                'variancePf',varpf(1),...
                'secondMoment',vars(1),...
                'Smethod','none',...
                'Nsamples',Nsamples);
            
            for ib=2:Nbatches
                Xpf = Xpf.addBatch('pf',pfs(ib),'variancePf',varpf(ib),'secondMoment',vars(ib),'Nsamples',Nsamples);
            end
            
            Totalpf = mean(Vrand);
            Totalpf2 = mean(Vrand.^2);
            Totalstdpf= (Totalpf2-Totalpf^2)/(Nsamples*Nbatches);
            Totalvar = var(Vrand);
            
            testCase.assertEqual(Totalpf,Xpf.pfhat,'AbsTol',1e6);
            testCase.assertEqual(Totalstdpf.^2,Xpf.variancePfhat,'AbsTol',1e6);
            testCase.assertEqual(Totalvar,Xpf.variance,'AbsTol',1e6);
        end
        
        function addBatchDifferentWeights(testCase)
            Nsamples=100;
            Nbatches=4;
            Vrand=rand(Nsamples*Nbatches,1)-1;
            TotS=length(Vrand);
            Samples = [0.1 0.1 0.25 0.45 0.05 0.05]*TotS;
            Ind = cumsum(Samples);
            
            pfs = zeros(length(Samples),1);
            vars = zeros(length(Samples),1);
            varpf = zeros(length(Samples),1);
            
            pfs(1) = mean(Vrand(1:Ind(1))) ;
            vars(1) = var(Vrand(1:Ind(1))) ;
            varpf(1) = var(Vrand(1:Ind(1)))/Samples(1);
            
            for i=2:length(Samples)
                pfs(i) = mean(Vrand(Ind(i-1)+1:Ind(i))) ;
                vars(i) = var(Vrand(Ind(i-1)+1:Ind(i))) ;
                varpf(i) = var(Vrand(Ind(i-1)+1:Ind(i)))/Samples(i) ;
            end
            
            Xpf = reliability.FailureProbability('pf',pfs(1),...
                'variancePf',varpf(1),...
                'secondMoment',vars(1),...
                'Smethod','none',...
                'Nsamples',Samples(1));
            
            for ib = 2:length(Samples)
                Xpf = Xpf.addBatch('pf',pfs(ib),'variancePf',varpf(ib),'secondMoment',vars(ib),'Nsamples',Samples(ib));
            end
            
            Totalpf = mean(Vrand);
            Totalstdpf = sqrt(var(Vrand)/(Nsamples*Nbatches));
            Totalvar = var(Vrand);
            
            testCase.assertEqual(Totalpf,Xpf.pfhat,'AbsTol',1e6);
            testCase.assertEqual(Totalstdpf.^2,Xpf.variancePfhat,'AbsTol',1e6);
            testCase.assertEqual(Totalvar,Xpf.variance,'AbsTol',1e6);
        end
        
        % TODO addBatch with SimulationData (currently too broken)
    end
    
end

