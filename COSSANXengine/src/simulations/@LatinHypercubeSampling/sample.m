function Xsamples = sample(Xobj,varargin)
%SAMPLE
% This method generate a Samples object using the LatinHypercube algorithms
%
% WARINING: The StochasticProcess are ALWAYS generate using plain Monte
% Carlo sample (i.e. using function randn).
%
%
%  Usage: SAMPLE(XLHS,'Nsamples',NSIM)
%  E.g.:  [Xinput MSAMPLES]=SAMPLE(XRVS,'Nsamples',10) produces ten samples (rows)
%
% See Also: http://cossan.co.uk/wiki/index.php/sample@LatinHypercube

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

%% Validate input arguments
OpenCossan.validateCossanInputs(varargin{:})

%% Process inputs
Nsamples=Xobj.Nsamples;

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'nsamples'}
            Nsamples=varargin{k+1};
        case 'xinput'
            Xinput=varargin{k+1};
            Nrv=Xinput.NrandomVariables;
            Ndv=Xinput.NdesignVariables;
        case 'xrandomvariableset'
            Xrvset=varargin{k+1};
            Nrv=length(Xrvset.Cmembers);
            Ndv=0;
        case 'xgaussianrandomvariableset'
            Xgrvset=varargin{k+1};
            Nrv=length(Xrvset.Cmembers);
            Ndv=0;
        otherwise
            error('openCOSSAN:LatinHypercubeSampling:sample',...
                ['Input parameter ' varargin{k} ' not allowed '])
    end
    
end

if ~exist('Xrvset','var') && ~exist('Xinput','var') && ~exist('Xgrvset','var')
    error('openCOSSAN:LatinHypercubeSampling:sample',...
        'An Input object or a RandomVariableSet/GaussianRandomVariableSet is required')
end

%% generate samples
% The Latin Hypercube Sample method generates values in uncorrelated unit
% hypercube
% Show values of the variable passed to lhsdesign

OpenCossan.cossanDisp('calling lhsdesign',3)
OpenCossan.cossanDisp(['* Nsamples: ' num2str(Nsamples)],3)
OpenCossan.cossanDisp(['* Nrv: ' num2str(Nrv)],3)
OpenCossan.cossanDisp(['* iteration: ' num2str(Xobj.Niterations)],3)
OpenCossan.cossanDisp(['* criterion: ' Xobj.Scriterion],3)
OpenCossan.cossanDisp(['* smooth: ' Xobj.Ssmooth],3)


if exist('Xrvset','var')
    Msamples=lhsdesign(double(Nsamples),double(Nrv),...
        'iteration',Xobj.Niterations, ...
        'criterion',Xobj.Scriterion, ...
        'smooth',Xobj.Ssmooth);
    
    % Map the samples in the Standard Normal Space
    MsamplesSNS=norminv(Msamples);
    Xsamples = Samples('Xrvset',Xrvset,'MsamplesStandardNormalSpace',MsamplesSNS);
elseif exist('Xgrvset','var')
    % Generate Samples in a N+1 dimensional space
    Msamples=lhsdesign(double(Nsamples),double(Nrv+1),...
        'iteration',Xobj.Niterations, ...
        'criterion',Xobj.Scriterion, ...
        'smooth',Xobj.Ssmooth);
    MphysicalSpace=Xgrvset.uncorrelatedCDF2PhysicalSpace(Msamples);
    
    Xsamples = Samples('Xgrvset',Xgrvset,'MsamplesPhysicalSpace',MphysicalSpace);
else
    % Input object passed
    Cgrvs=Xinput.CnamesGaussianMixtureRandomVariableSet;
    % Generate samples
    % Generate uncorrelated samples in the hypercube
    Msamples=lhsdesign(double(Nsamples),double(Nrv)+length(Cgrvs)+double(Ndv),...
        'iteration',Xobj.Niterations, ...
        'criterion',Xobj.Scriterion, ...
        'smooth',Xobj.Ssmooth);
    
    % Map the hypercube samples to the physical space of rvs, doe space of dvs
    [MphysicalSpace, Msamplesdoe] = Xinput.hypercube2physical(Msamples);  
    
    %% Process StochasticProcesses
    % generates samples for the Stochastic Process and append to the object
    % of type Samples
    
    CStochasticProcess=Xinput.CnamesStochasticProcess;
    if isempty(CStochasticProcess)
        %% Create Samples Object
        Xsamples = Samples('Xinput',Xinput,'MsamplesPhysicalSpace',MphysicalSpace,'Msamplesdoedesignvariables',Msamplesdoe);
    else
        for j=1:Xinput.NstochasticProcesses
            [~,Xds(j)]=Xinput.Xsp.(CStochasticProcess{j}).sample('Nsamples',Nsamples,'Sname',CStochasticProcess{j});
        end
        
        %% Create Samples Object
        Xsamples = Samples('Xinput',Xinput,'MsamplesPhysicalSpace',MphysicalSpace,'Msamplesdoedesignvariables',Msamplesdoe,'Xdataseries',Xds);
    end
    
end



