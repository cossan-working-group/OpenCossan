function physical = hypercube2physical(obj,hypercube)
    %HYPERCUBE2PHISICAL This methods converts realization defined in the
    %hypercube in the phisical space
    %
    % See also: http://cossan.co.uk/wiki/index.php/hypercube2physical@Input
    %
    % Author: Edoardo Patelli
    % Institute for Risk and Uncertainty, University of Liverpool, UK
    % email address: openengine@cossan.co.uk
    % Website: http://www.cossan.co.uk
    
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
    %  You should have received a copy of the GNU General Public License
    %  along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
    % =====================================================================
    
    physical = table();
    
    c = 1; % counter of columns
    
    % Map RandomVariables
    rvs = obj.RandomVariables;
    names = obj.RandomVariableNames;
    for i = 1:obj.NumberOfRandomVariables
        physical.(names(i)) = map2physical(rvs(i), norminv(hypercube(:, c)));
        c = c + 1;
    end
    
    % Map RandomVariableSets
    sets = obj.RandomVariableSets;
    for i = 1:obj.NumberOfRandomVariableSets
        n = sets(i).Nrv;
        mappedSamples = array2table(map2physical(sets(i), norminv(hypercube(:, c:c+n-1))));
        mappedSamples.Properties.VariableNames = sets(i).Names;
        physical = [physical mappedSamples];
        c = c + n;
    end
    
    
%     
%     Nrv = Xinput.NumberOfRandomVariables;
%     for set = Xinput.RandomVariableSets
%         Nrv = Nrv + set.Nrv;
%     end
%     Ndv = Xinput.NumberOfDesignVariables;
%     Nsp = Xinput.NumberOfStochasticProcesses;
%     Nsamples = size(MsamplesHypercube,1);
%     Cset=Xinput.RandomVariableSetNames;
%     Cgrvs=Xinput.GaussianMixtureRandomVariableSetNames;
%     Cdv = Xinput.DesignVariableNames;
%     
%     assert(size(MsamplesHypercube,2)==Nrv+length(Cgrvs)+Ndv,...
%         'openCOSSAN:Input:hypercube2physical',...
%         ['The number of columns of the hypercube matrix (%d) is smaller ',...
%         'than the required number of columns (%d)\n',...
%         'Required columns:\n - Nr. of total random variables: %d\n',...
%         ' - Nr. of Gaussian mixture random variable sets: %d\n',...
%         ' - Nr. of design variables: %d'],size(MsamplesHypercube,2),...
%         Nrv+length(Cgrvs)+Ndv,Nrv,length(Cgrvs),Ndv);
%     
%     % initialize counters
%     irv=0;
%     igmrvset=0;
%     if Nrv~=0
%         %% Map the sample from the UNCORRELATED hypercube to physical space
%         MphysicalSpace=zeros(Nsamples,Nrv);
%         
%         % Map samples for the RandomVariableSet
%         for set = Xinput.RandomVariableSets
%             Nrv = set.Nrv;
%             
%             MsamplesSNS=norminv(MsamplesHypercube(:,irv+igmrvset+(1:Nrv)));
%             MphysicalSpace(:,irv+(1:Nrv))= ...
%                 Xinput.RandomVariableSets.(Cset{n}).map2physical(MsamplesSNS);
%             irv=irv+Nrv;
%         end
%         
% %         for set = Xinput.GaussianMixtureRandomVariableSet
% %             Nrv = set.Nrv;
% %             % Map samples for the GaussianMixtureRandomVariableSet
% %             MphysicalSpace(:,irv+(1:Nrv))= ...
% %                 Xinput.RandomVariableSets.(Cset{n}).uncorrelatedCDF2PhysicalSpace(MsamplesHypercube(:,irv+igmrvset+(1:Nrv+1)));
% %             % Update Counter variable
% %             igmrvset=igmrvset+1;
% %         end
%         
%     end
%     
%     if Ndv~=0
%         %% Map samples for the design variables. The samples of the dv are
%         % assumed to be generated uniformly.
%         MsamplesDV = zeros(Nsamples,Ndv);
%         for n=1:Ndv
%             assert(~isinf(Xinput.DesignVariables(n).LowerBound) && ...
%                 ~isinf(Xinput.DesignVariables(n).UpperBound),...
%                 'openCOSSAN:LatinHypercubeSampling:sample',...
%                 'Only continuos design variables with finite support can be used with Latin Hypercube sampling')
%             MsamplesDV(:,n)=Xinput.DesignVariables(n).LowerBound + ...
%                 (Xinput.DesignVariables(n).UpperBound - Xinput.DesignVariables(n).LowerBound)*MsamplesHypercube(:,irv+igmrvset+n);
%         end
%     else
%         MsamplesDV=[];
%     end
%     
%     if Nsp~=0
%         %% TODO: implement sampling of stochastic process with imposed rv values from quasi-MC methods
%     end
    
end
