function [MphysicalSpace,MsamplesDV] = hypercube2physical(Xinput,MsamplesHypercube)
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

Nrv = Xinput.NrandomVariables;
Ndv = Xinput.NumberOfDesignVariables;
Nsp = Xinput.NstochasticProcesses;
Nsamples = size(MsamplesHypercube,1);
Cset=Xinput.RandomVariableSetNames;
Cgrvs=Xinput.GaussianMixtureRandomVariableSetNames;
Cdv = Xinput.DesignVariableNames;

assert(size(MsamplesHypercube,2)==Nrv+length(Cgrvs)+Ndv,...
    'openCOSSAN:Input:hypercube2physical',...
    ['The number of columns of the hypercube matrix (%d) is smaller ',...
    'than the required number of columns (%d)\n',...
    'Required columns:\n - Nr. of total random variables: %d\n',...
    ' - Nr. of Gaussian mixture random variable sets: %d\n',...
    ' - Nr. of design variables: %d'],size(MsamplesHypercube,2),...
    Nrv+length(Cgrvs)+Ndv,Nrv,length(Cgrvs),Ndv);

% initialize counters
irv=0;
igmrvset=0;
if Nrv~=0
    %% Map the sample from the UNCORRELATED hypercube to physical space
    MphysicalSpace=zeros(Nsamples,Nrv);
    
    % Map samples for the RandomVariableSet
    for n=1:length(Cset)
        Nrv=Xinput.RandomVariableSets.(Cset{n}).Nrv;
        if isa(Xinput.RandomVariableSets.(Cset{n}),'opencossan.common.inputs.random.RandomVariableSet')
            MsamplesSNS=norminv(MsamplesHypercube(:,irv+igmrvset+(1:Nrv)));
            MphysicalSpace(:,irv+(1:Nrv))= ...
                Xinput.RandomVariableSets.(Cset{n}).map2physical(MsamplesSNS);
        elseif isa(Xinput.RandomVariableSets.(Cset{n}),'opencossan.common.inputs.random.GaussianMixtureRandomVariableSet')
            % Map samples for the GaussianMixtureRandomVariableSet
            MphysicalSpace(:,irv+(1:Nrv))= ...
                Xinput.RandomVariableSets.(Cset{n}).uncorrelatedCDF2PhysicalSpace(MsamplesHypercube(:,irv+igmrvset+(1:Nrv+1)));
            % Update Counter variable
            igmrvset=igmrvset+1;
        else
            error('openCOSSAN:LatinHypercubeSampling:sample', ...
                'Object of class %s can not be used here',class(Xinput.RandomVariableSets.(Cset{n})))
        end
        irv=irv+Nrv;
    end
else
    MphysicalSpace=[];
end

if Ndv~=0
    %% Map samples for the design variables. The samples of the dv are
    % assumed to be generated uniformly.
    MsamplesDV = zeros(Nsamples,Ndv);
    for n=1:Ndv
        assert(~isinf(Xinput.DesignVariables(n).LowerBound) && ...
            ~isinf(Xinput.DesignVariables(n).UpperBound),...
            'openCOSSAN:LatinHypercubeSampling:sample',...
            'Only continuos design variables with finite support can be used with Latin Hypercube sampling')
        MsamplesDV(:,n)=Xinput.DesignVariables(n).LowerBound + ...
            (Xinput.DesignVariables(n).UpperBound - Xinput.DesignVariables(n).LowerBound)*MsamplesHypercube(:,irv+igmrvset+n);
    end
else
    MsamplesDV=[];
end

if Nsp~=0
    %% TODO: implement sampling of stochastic process with imposed rv values from quasi-MC methods
end

end
