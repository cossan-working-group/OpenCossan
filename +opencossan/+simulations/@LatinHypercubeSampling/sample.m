function samples = sample(Xobj,varargin)
    %SAMPLE
    % This method generate a Samples object using the LatinHypercube algorithms
    %
    % WARINING: The StochasticProcess are ALWAYS generate using plain Monte Carlo sample (i.e. using
    % function randn).
    %
    %
    %  Usage: SAMPLE(XLHS,'Nsamples',NSIM) E.g.:  [Xinput MSAMPLES]=SAMPLE(XRVS,'Nsamples',10)
    %  produces ten samples (rows)
    %
    % See Also: http://cossan.co.uk/wiki/index.php/sample@LatinHypercube
    
    % Author: Edoardo Patelli Institute for Risk and Uncertainty, University of Liverpool, UK email
    % address: openengine@cossan.co.uk Website: http://www.cossan.co.uk
    
    % ===================================================================== This file is part of
    % openCOSSAN.  The open general purpose matlab toolbox for numerical analysis, risk and
    % uncertainty quantification.
    %
    % openCOSSAN is free software: you can redistribute it and/or modify it under the terms of the
    % GNU General Public License as published by the Free Software Foundation, either version 3 of
    % the License.
    %
    % openCOSSAN is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    % without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
    % the GNU General Public License for more details.
    %
    %  You should have received a copy of the GNU General Public License along with openCOSSAN.  If
    %  not, see <http://www.gnu.org/licenses/>.
    % =====================================================================
    
    import opencossan.*
    import opencossan.common.Samples
    
    %% Process inputs
    Nsamples=Xobj.NumberOfSamples;
    
    for k=1:2:length(varargin)
        switch lower(varargin{k})
            case {'samples'}
                Nsamples=varargin{k+1};
            case 'input'
                Xinput=varargin{k+1};
                Nrv=Xinput.NumberOfRandomVariables;
                Ndv=Xinput.NumberOfDesignVariables;
                for set = Xinput.RandomVariableSets
                    Nrv = Nrv + set.Nrv;
                end
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
    % The Latin Hypercube Sample method generates values in uncorrelated unit hypercube Show values
    % of the variable passed to lhsdesign
    
    opencossan.OpenCossan.cossanDisp('calling lhsdesign',3)
    opencossan.OpenCossan.cossanDisp(['* Nsamples: ' num2str(Nsamples)],3)
    opencossan.OpenCossan.cossanDisp(['* Nrv: ' num2str(Nrv)],3)
    opencossan.OpenCossan.cossanDisp(['* iteration: ' num2str(Xobj.Iterations)],3)
    opencossan.OpenCossan.cossanDisp(['* criterion: ' Xobj.Criterion],3)
    opencossan.OpenCossan.cossanDisp(['* smooth: ' Xobj.Smooth_],3)
    
    
    if exist('Xrvset','var')
        samples=lhsdesign(double(Nsamples),double(Nrv),...
            'iteration',Xobj.Iterations, ...
            'criterion',Xobj.Criterion, ...
            'smooth',Xobj.Smooth_);
        
        % Map the samples in the Standard Normal Space
        MsamplesSNS=norminv(samples);
        Xsamples = Samples('Xrvset',Xrvset,'MsamplesStandardNormalSpace',MsamplesSNS);
    elseif exist('Xgrvset','var')
        % Generate Samples in a N+1 dimensional space
        samples=lhsdesign(double(Nsamples),double(Nrv+1),...
            'iteration',Xobj.NIterations, ...
            'criterion',Xobj.Criterion, ...
            'smooth',Xobj.Smooth_);
        MphysicalSpace=Xgrvset.uncorrelatedCDF2PhysicalSpace(samples);
        
        Xsamples = Samples('Xgrvset',Xgrvset,'MsamplesPhysicalSpace',MphysicalSpace);
    else
        % Input object passed
        Cgrvs=Xinput.GaussianMixtureRandomVariableSetNames;
        % Generate samples Generate uncorrelated samples in the hypercube
        samples = lhsdesign(double(Nsamples),double(Nrv)+length(Cgrvs)+double(Ndv),...
            'iteration',Xobj.Iterations, ...
            'criterion',Xobj.Criterion, ...
            'smooth',Xobj.Smooth_);
        
        % Map the hypercube samples to the physical space of rvs, doe space of dvs
        samples = Xinput.hypercube2physical(samples);
        samples = Xinput.addParametersToSamples(samples);
        samples = Xinput.evaluateFunctionsOnSamples(samples);
        
%         if ~isempty(Xinput.StochasticProcesses)
%             % TODO: Sample stochastic processes
%         end
    end
end



