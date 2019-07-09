function Xsm = sobolIndices(varargin)
%SOBOLINDICES Summary of this function goes here
%   This method estimate the Sobol' indices adopting a Monte-Carlo based
%   numerical procedure for computing the full-set of first-order and
%   total-effect indices.
%   Ref: Saltelli et al. 2009 Global Sensitivity Analysis: The primer,
%   Wiley ISBN: 978-0-470-05997-5
%
% Sobol' indices estimation (Saltelli 2002)
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/SobolIndices@Sensitivity
%
% Author: Edoardo Patelli
%
% Institute for Risk and Uncertainty, University of Liverpool, UK
%
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

warning('OpenCossan:Sensitivity',...
    strcat('DEPRECATED METHOD!!!!',...
    '\n This static method will be remove soon!!!',...
    '\n More info:  http://cossan.cfd.liv.ac.uk/wiki/index.php/@Sensitivity'))

    OpenCossan.setLaptime('description','[Sensitivity:sobolIndices] Start sensitivity analysis')


%% Check inputs
OpenCossan.validateCossanInputs(varargin{:})
Nbootstrap=100;

%% Process inputs
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'xsimulation'}
            if isa(varargin{k+1},'MonteCarlo') || ...
                    isa(varargin{k+1},'SobolSampling') || ...
                    isa(varargin{k+1},'HaltonSampling') || ...
                    isa(varargin{k+1},'LatinHypercubeSampling')
                Xsimulation=varargin{k+1};
            else
                error('openCOSSAN:sensitivity:sobolIndices',...
                    'Object of class %s  can not be used',class(varargin{k+1}));
            end
        case {'cxsimulation'}
            if isa(varargin{k+1}{1},'MonteCarlo') || ...
                    isa(varargin{k+1}{1},'SobolSampling') || ...
                    isa(varargin{k+1}{1},'HaltonSampling') || ...
                    isa(varargin{k+1}{1},'LatinHypercubeSampling')
                Xsimulation=varargin{k+1}{1};
            else
                error('openCOSSAN:sensitivity:sobolIndices',...
                    ['Object of class ' class(varargin{k+1}{1}) ' can not be used']);
            end
        case {'sevaluatedobjectname'}
            Sevaluatedobjectname=varargin{k+1};
        case {'xmodel','xtarget'}
            Xtarget=varargin{k+1};
        case {'cxmodel','cxtarget'}
            Xtarget=varargin{k+1}{1};
        case {'nbootstrap'}
            Nbootstrap=varargin{k+1};
        case {'csinputnames','cinputnames'}
            Cinputnames=varargin{k+1};
        case {'csoutputnames','coutputnames'}
            Coutputnames=varargin{k+1};
        otherwise
            error('openCOSSAN:sensitivity:sobolIndices',...
                ['PropertyName ' varargin{k} ' not allowed']);
    end
end

if ~exist('Sevaluatedobjectname','var')
    Sevaluatedobjectname=class(Xtarget);
end

assert(logical(exist('Xtarget','var')), ...
    'openCOSSAN:sensitivity:sobolIndices',...
    'It is mandatory to pass a valid Model object to the Sobol'' indices')

assert(logical(exist('Xsimulation','var')), ...
    'openCOSSAN:sensitivity:sobolIndices',...
    'It is mandatory to pass a valid Simulation object zo the Sobol'' indices')
    
    OpenCossan.setAnalysisID;
    if ~isdeployed && isempty(OpenCossan.getAnalysisName)
    OpenCossan.setAnalysisName('sobolIndices');
end
%% Extract the number of Random Variable and Input object
% All the model that return a SimulationData object can be used in to
% compute the sobolIndices.

switch class(Xtarget)
    case {'Model'}
        Xinput=Xtarget.Xinput;
    case {'PolyharmonicSplines','NeuralNetwork','ResponseSurface'}
        if ~isempty(Xtarget.XFullmodel)
            Xinput=Xtarget.XFullmodel.Xinput;
        else
            Xinput=Xtarget.XcalibrationInput;
        end
    case 'ProbabilisticModel'
        Xinput=Xtarget.Xmodel.Xinput;
    otherwise
        error('openCOSSAN:sensitivity:sobolIndices',...
            ['support for object of class ' class(Xtarget) ' to be implemented'])
end

% If the output names are not defined the sensitivity indices are computed
% for all the output variables
if ~exist('Coutputnames','var')
    Coutputnames=Xtarget.Coutputnames;
else
    for k=1:length(Coutputnames)
        assert(any(ismember(Xtarget.Coutputnames,Coutputnames(k))), ...
            'openCOSSAN:sensitivity:sobolIndices',...
            strcat('Coutputnames (', sprintf('%s ',Coutputnames{k}), ...
            ') not defined in the model'))
    end
end

Noutput=length(Coutputnames);

% If the input names are not defined the sensitivity indices are computed
% for all the input variables
if ~exist('Cinputnames','var')
    Cinputnames=Xinput.CnamesRandomVariable;
else
    for k=1:Noutput
        assert(any(ismember(Xtarget.Cinputnames,Cinputnames(k))), ...
            'openCOSSAN:sensitivity:sobolIndices',...
            strcat('Cinputnames (', sprintf('%s ',Cinputnames{k}), ...
            ') not defined in the model'))
    end
end

Ninput=length(Cinputnames);
Nsamples=Xsimulation.Nsamples;
OpenCossan.cossanDisp(['Total number of model evaluations ' num2str(Nsamples*(Ninput+2))],2)

%% Estimate sensitivity indices
% Generate samples
OpenCossan.cossanDisp(['Generating samples from the ' class(Xsimulation) ],4)

% Create two samples object each with half of the samples
OpenCossan.cossanDisp('Creating Samples object',4)
XA=Xsimulation.sample('Xinput',Xinput);
XB=Xsimulation.sample('Xinput',Xinput);


% Evaluate the model
OpenCossan.cossanDisp('Evaluating the model ' ,4)
XoutA=Xtarget.apply(XA); % y_A=f(A)
XoutB=Xtarget.apply(XB); % y_B=f(B)

% Expectation values of the output variables
OpenCossan.cossanDisp('Extract quantity of interest from SimulationData ' ,4)

%for nout=1:length(Coutputnames)

%MoutA=XoutA.getValues('Cnames',Coutputnames(nout));
%MoutB=XoutB.getValues('Cnames',Coutputnames(nout));


MoutA=XoutA.getValues('Cnames',Coutputnames);
MoutB=XoutB.getValues('Cnames',Coutputnames);

%OpenCossan.cossanDisp(['Compute Vf02 for ' Coutputnames{nout}],4)
Vf02=(sum([MoutA;MoutB],1)/(2*Nsamples)).^2; % fo²

%% Define a function handle to estimate the parameters
% This function handle is also used by the bootstraping method to estimate
% the variance of the estimators.
hcomputeindices=@(MxA,MxB)sum(MxA.*MxB)/(size(MxA,1))- Vf02;

% Compute the Total variance of the outputs
%VD=sum([MoutA;MoutB].^2,1)/(2*Nsamples) - Vf02;
VD=hcomputeindices([MoutA;MoutB],[MoutA;MoutB]);

if Nbootstrap>0
    VDbs=bootstrp(Nbootstrap,hcomputeindices,[MoutA;MoutB],[MoutA;MoutB]);
end

% Preallocate memory
Dz=zeros(Ninput,Noutput);
Dy=zeros(Ninput,Noutput);

% Extract matrices of samples
MA=XA.MsamplesHyperCube;
MB=XB.MsamplesHyperCube;
Dybs=zeros(Ninput,Nbootstrap,Noutput);
Dzbs=zeros(Ninput,Nbootstrap,Noutput);
for irv=1:Ninput
    OpenCossan.cossanDisp(['[Status] Compute Sensitivity indices ' num2str(irv) ' of ' num2str(Ninput)],2)
    Vpos=strcmp(XA.Cvariables,Cinputnames{irv});
    MC=MB;
    MC(:,Vpos)=MA(:,Vpos); % Create matrix C_i
    % Construct Samples object
    XC=Samples('Xinput',Xinput,'MsamplesHyperCube',MC);
    
    % Evaluate the model
    XoutC=Xtarget.apply(XC); % y_C_i=f(C_i)
    MoutC=XoutC.getValues('Cnames',Coutputnames);
    
    %estimate V(E(Y|X_i))
    Dy(irv,:)=hcomputeindices(MoutA,MoutC);
    %Dy(irv,:)=sum(MoutA.*MoutC)/Nsamples- Vf02; %
    
    %estimate V(E(Y|X~i))
    %Dz(irv,:)=sum(MoutB.*MoutC)/Nsamples- Vf02; %
    Dz(irv,:)=hcomputeindices(MoutB,MoutC);
    
    if Nbootstrap>0
        Dybs(irv,:,:)=bootstrp(Nbootstrap,hcomputeindices,MoutA,MoutC);
        Dzbs(irv,:,:)=bootstrp(Nbootstrap,hcomputeindices,MoutB,MoutC);
    end
end

%% According to the Saltelli manuscipt (Sensitivity Analysis practices.
% Strategies for model-based inference) the Sobol indices and total
% indices are defined by Dy/D and 1-Dz/D, respectively. However, the
% numerical results tell us that this two relation are inverted.

%% Construct SensitivityMeasure object
for n=1:Noutput
    
    % Compute First order Sobol' indices
    MfirstOrder=Dy(:,n)/VD(n);
    
    % Compute the Total Sensitivity indices
    Mtotal=1-Dz(:,n)/VD(n);
    
    if Nbootstrap>0
        VfirstOrderCoV=std(squeeze(Dybs(:,:,n))'./repmat(VDbs(:,n),1,Ninput))./abs(MfirstOrder');
        VtotalCoV=std(1-squeeze(Dzbs(:,:,n))'./repmat(VDbs(:,n),1,Ninput))./abs(Mtotal');
        
        Xsm(n)=SensitivityMeasures('Cinputnames',Cinputnames, ...
            'Soutputname',  Coutputnames{n},'Xevaluatedobject',Xtarget, ...
            'Sevaluatedobjectname',Sevaluatedobjectname, ...
            'VtotalIndices',Mtotal','VsobolFirstOrder',MfirstOrder', ...
            'VtotalIndicesCoV',VtotalCoV,'VsobolFirstOrderCoV',VfirstOrderCoV, ...
            'Sestimationmethod','Sensitivity.sobolIndices'); %#ok<AGROW>
    else
        Xsm(n)=SensitivityMeasures('Cinputnames',Cinputnames, ...
            'Soutputname',  Coutputnames{n},'Xevaluatedobject',Xtarget, ...
            'Sevaluatedobjectname',Sevaluatedobjectname, ...
            'VtotalIndices',Mtotal','VsobolFirstOrder',MfirstOrder', ...
            'Sestimationmethod','Sensitivity.sobolIndices'); %#ok<AGROW>
    end
end

OpenCossan.setLaptime('description','[Sensitivity:sobolIndices] Stop sensitivity analysis')
