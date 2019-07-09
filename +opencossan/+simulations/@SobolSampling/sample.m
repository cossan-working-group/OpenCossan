function Xsamples = sample(Xobj,varargin)
%SAMPLE 
% This method generate a Samples object using the Sobol' algorithms 

import opencossan.common.Samples

%% Validate input arguments
opencossan.OpenCossan.validateCossanInputs(varargin{:})

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
    error('openCOSSAN:SobolSampling:sample',...
        'An Input object or a RandomVariableSet/GaussianRandomVariableSet is required')
end

opencossan.OpenCossan.cossanDisp('calling SobolSampling',4)
opencossan.OpenCossan.cossanDisp(['* Nsamples: ' num2str(Nsamples)],4)
opencossan.OpenCossan.cossanDisp(['* Nskip: ' num2str(Xobj.Nskip)],4)
opencossan.OpenCossan.cossanDisp(['* Nleap: ' num2str(Xobj.Nleap)],4)
opencossan.OpenCossan.cossanDisp(['* ScrambleMethod: ' Xobj.ScrambleMethod ],4)


%% Case of RandomVariableSet
if exist('Xrvset','var')
    % Initialize SobolSampling set
    Xqmc = sobolset(Nrv,'Skip',Xobj.Nskip,'Leap',Xobj.Nleap); % construct QMC object
    
    if ~isempty(Xobj.ScrambleMethod)
        Xqmc=scramble(Xqmc,Xobj.ScrambleMethod);
    end
    
    %% Generate samples
    % The Quasi-Monte Carlo method generate always the same values
    Msamples=net(Xqmc,Nsamples); % Samples in the unit hypercube
    
    % Map the samples in the Standard Normal Space
    MsamplesSNS=norminv(Msamples);
    % Export Samples object
    Xsamples = Samples('Xrvset',Xrvset,'MsamplesStandardNormalSpace',MsamplesSNS);
    
elseif exist('Xgrvset','var')
  %% Case of GaussiamMixtureRandomVariableSet  
    % Generate Samples in a N+1 dimensional space
    % Initialize SobolSampling set
    Xqmc = sobolset(Nrv+1,'Skip',Xobj.Nskip,'Leap',Xobj.Nleap); % construct QMC object
    
    if ~isempty(Xobj.ScrambleMethod)
        Xqmc=scramble(Xqmc,Xobj.ScrambleMethod);
    end
    
    %% Generate samples
    % The Quasi-Monte Carlo method generate always the same values
    Msamples=net(Xqmc,Nsamples); % Samples in the unit hypercube

    MphysicalSpace=Xgrvset.uncorrelatedCDF2PhysicalSpace(Msamples);
    
    % Export Samples object
    Xsamples = Samples('Xgrvset',Xgrvset,'MsamplesPhysicalSpace',MphysicalSpace);
else
    %% Case of Input
    % Input object passed
    Cset=Xinput.CnamesSet;
    Cgrvs=Xinput.CnamesGaussianMixtureRandomVariableSet;
    % Generate samples
    
    % Initialize SobolSampling set
    Xqmc = sobolset(Nrv+length(Cgrvs)+Ndv,'Skip',Xobj.Nskip,'Leap',Xobj.Nleap); % construct QMC object
    
    if ~isempty(Xobj.ScrambleMethod)
        Xqmc=scramble(Xqmc,Xobj.ScrambleMethod);
    end
    
    %% Generate samples
    % The Quasi-Monte Carlo method generate always the same values
    Msamples=net(Xqmc,Nsamples); % Samples in the unit hypercube
        
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
