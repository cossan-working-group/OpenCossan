function Xsm = fast(varargin)
%FAST Fourier Amplitude Sensitivity Test
%   This method estimate the Sobol' indices based on selecting N design
%   points. 
%   numerical procedure for computing the full-set of first-order and
%   total-effect indices.
%   Ref: Saltelli et al. 2009 Global Sensitivity Analysis: The primer,
%   Wiley ISBN: 978-0-470-05997-5
%
% Sobol' indices estimation (Saltelli 2002)
% 
% 

warning('OpenCossan:Sensitivity',...
    strcat('DEPRECATED METHOD!!!!',...
    '\n This static method will be remove soon!!!',...
    '\n More info:  http://cossan.cfd.liv.ac.uk/wiki/index.php/@Sensitivity'))

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
                Sevaluatedobjectname=inputname(k+1);
            else
              	error('openCOSSAN:sensitivity:sobolIndices',...
				['Object of class ' class(varargin{k+1}) ' can not be used']);  
            end
		case {'xmodel','xtarget'}
			Xmodel=varargin{k+1};
        case {'nbootstrap'}
			Nbootstrap=varargin{k+1};
		case {'csinputnames','cinputnames'}
			Cinputnames=varargin{k+1};
        case {'csoutputnames','coutputnames'}
			Coutputnames=varargin{k+1}; 
		otherwise
			warning('openCOSSAN:sensitivity:sobolIndices',...
				['PropertyName ' varargin{k} ' not allowed']);
	end	
end



%% Extract the number of Random Variable and Input object
% All the model that return a SimulationData object can be used in to
% compute the sobolIndices.

switch class(Xmodel)
    case 'Model'
        Xinput=Xmodel.Xinput;
    case {'PolyharmonicSplines','NeuralNetwork','ResponseSurface'}
        if ~isempty(Xtarget.XFullmodel)
            Xinput=Xtarget.XFullmodel.Xinput;
        else
            Xinput=Xtarget.XcalibrationInput;
        end
    otherwise
        error('openCOSSAN:sensitivity:sobolIndices',...
            ['support for object of class ' class(Xmodel) ' to be implemented'])
end

% If the output names are not defined the sensitivity indices are computed
% for all the output variables
if ~exist('Coutputnames','var')
    Coutputnames=Xmodel.Coutputnames;
end

% If the input names are not defined the sensitivity indices are computed
% for all the input variables
if ~exist('Cinputnames','var')
    Cinputnames=Xinput.CnamesRandomVariable;
end
Nrv=Xinput.NrandomVariables;
Nsamples=Xsimulation.Nsamples;
OpenCossan.cossanDisp(['Total number of model evaluation ' num2str(Nsamples*(length(Cinputnames)+2))],2)

%% Estimate sensitivity indices
% Generate samples
OpenCossan.cossanDisp(['Generating samples from the ' class(Xsimulation) ],4)
MsampleSNSA=Xsimulation.sample('Nrv',Nrv); % Matrix A
MsampleSNSB=Xsimulation.sample('Nrv',Nrv); % Matrix B

% Create two samples object each with half of the samples
OpenCossan.cossanDisp('Creating Samples object',4)
XA=Samples('Xinput',Xinput,'MsamplesStandardNormalSpace',MsampleSNSA);
XB=Samples('Xinput',Xinput,'MsamplesStandardNormalSpace',MsampleSNSB);


% Evaluate the model 
OpenCossan.cossanDisp('Evaluating the model ' ,4)
XoutA=Xmodel.apply(XA); % y_A=f(A)
XoutB=Xmodel.apply(XB); % y_B=f(B)

% Expectation values of the output variables
OpenCossan.cossanDisp('Extract quantity of interest from SimulationData ' ,4)
MoutA=XoutA.getValues('Cnames',Coutputnames);
MoutB=XoutB.getValues('Cnames',Coutputnames);

OpenCossan.cossanDisp('Compute Vf02 ' ,4)
Vf02=(sum([MoutA;MoutB],1)/(2*Nsamples))^2; % fo²

%% Define a function handle to estimate the parameters
% This function handle is also used by the bootstraping method to estimate
% the variance of the estimators.
hcomputeindices=@(MxA,MxB)sum(MxA.*MxB)/(size(MxA,1))- Vf02;

% Compute the Total variance of the outputs
%VD=sum([MoutA;MoutB].^2,1)/(2*Nsamples) - Vf02;
VD=hcomputeindices([MoutA;MoutB],[MoutA;MoutB]);
VDbs=bootstrp(Nbootstrap,hcomputeindices,[MoutA;MoutB],[MoutA;MoutB]);

% Preallocate memory
Dz=zeros(length(Cinputnames),length(Coutputnames));
Dy=zeros(length(Cinputnames),length(Coutputnames));

% Extract matrices of samples
MA=XA.MsamplesHyperCube;
MB=XB.MsamplesHyperCube;
    


for irv=1:length(Cinputnames)
    Vpos=strcmp(XA.Cvariables,Cinputnames{irv});
    MC=MB;
    MC(:,Vpos)=MA(:,Vpos); % Create matrix C_i 
    % Construct Samples object
    XC=Samples('Xinput',Xinput,'MsamplesHyperCube',MC);

    % Evaluate the model 
    XoutC=Xmodel.apply(XC); % y_C_i=f(C_i)
    MoutC=XoutC.getValues('Cnames',Coutputnames);
    
    %estimate V(E(Y|X_i))
    Dy(irv,:)=hcomputeindices(MoutA,MoutC);
    %Dy(irv,:)=sum(MoutA.*MoutC)/Nsamples- Vf02; %

    %estimate V(E(Y|X~i))
    %Dz(irv,:)=sum(MoutB.*MoutC)/Nsamples- Vf02; %
    Dz(irv,:)=hcomputeindices(MoutB,MoutC);
    
    Dybs(irv,:)=bootstrp(Nbootstrap,hcomputeindices,MoutA,MoutC);
    Dzbs(irv,:)=bootstrp(Nbootstrap,hcomputeindices,MoutB,MoutC);
end

%% Accordi to the Saltelli manuscipt (Sensitivity Analysis practices.
% Strategies for model-based inference) the Sobol indices and total
% indices are defined by Dy/D and 1-Dz/D, respectively. However, the
% numerical results tell us that this two relation are inverted.


% Compute First order Sobol' indices
MfirstOrder=Dy./VD;



% Compute the Total Sensitivity indices
Mtotal=1-Dz./VD;



%% Construct SensitivityMeasure object
for n=1:length(Coutputnames)
    
    VfirstOrderCoV=std(Dybs'./repmat(VDbs,1,length(Cinputnames)))./MfirstOrder(:,n)';
    VtotalCoV=std(1-Dzbs'./repmat(VDbs,1,length(Cinputnames)))./Mtotal(:,n)';
    
    Xsm(n)=SensitivityMeasures('Cinputnames',Cinputnames, ... 
    'soutputname',  Coutputnames{n},'Xevaluatedobject',Xmodel, ...
    'Sevaluatedobjectname',Sevaluatedobjectname, ...
    'VtotalIndices',Mtotal(:,n),'VsobolFirstOrder',MfirstOrder(:,n), ...
    'VtotalIndicesCoV',VtotalCoV,'VsobolFirstOrderCoV',VfirstOrderCoV, ...
    'Sestimationmethod','Sensitivity.sobolIndices'); %#ok<AGROW>
end

