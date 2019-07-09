function [Xfdout varargout]=monteCarloCore(varargin)
% FINITEDIFFERENCESCORE
% Private function for the sensitivity method
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/GradientMonteCarlo@Sensitivity
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/localMonteCarlo@Sensitivity
%
% ==============================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% ==============================================================================
%
% Copyright~1993-2011, COSSAN Working Group, University of Innsbruck, Austria
% Author: Edoardo Patelli

%% Initialize variables
Xsamples0=[];
fx0=[];
NfunctionEvaluation=0;
LperformanceFunction=false;

%% Check inputs
OpenCossan.validateCossanInputs(varargin{:})
%% Process inputs
for k=1:2:nargin
    switch lower(varargin{k})
        case {'lgradient'}
            Lgradient=varargin{k+1};
        case {'coutputname' 'coutputnames' }
            Coutputname=varargin{k+1};
        case {'lperformancefunction'}
            LperformanceFunction=varargin{k+1};
        case {'xtarget'}
            Xtarget=varargin{k+1};
        case {'cxtarget'}
            Xtarget=varargin{k+1}{1};
        case {'vreferencepoint'}
            % Reference Point in PhysicalSpace
            VreferencePointUserDefined=varargin{k+1};
        case {'cnamesrandomvariable' 'csnames'}
            % Reference Point in PhysicalSpace
            Cnames=varargin{k+1};
        case {'xsamples'}
            Xsamples0=varargin{k+1};
        case {'cxsamples'}
            Xsamples0=varargin{k+1}{1};
        case {'functionvalue','fx0'}
            fx0=varargin{k+1};
        case {'perturbation'}
            perturbation=varargin{k+1};
        otherwise
            error('openCOSSAN:sensitivity:monteCarloCore',...
                ['PropertyName ' varargin{k} ' not allowed']);
    end
end

switch class(Xtarget)
    case 'Model'
        Xinput=Xtarget.Xinput;
        if ~exist('perturbation','var')
            if isa(Xtarget.Xevaluator.CXsolvers{1},'Connector')
                perturbation=1e-2;
            else
                perturbation=1e-4;
            end
        end
        if ~exist('Coutputname','var')
            if length(Xtarget.Coutputnames)==1
                Coutputname=Xtarget.Coutputnames;
            else
                error('openCOSSAN:sensitivity:gradientMonteCarlo',...
                    'The model contains more than 1 outputs and it is necessary specify the quantity of interest');
            end
        end
        
    case 'ProbabilisticModel'
        Xinput=Xtarget.Xmodel.Xinput;
        if ~exist('Coutputname','var')
            if LperformanceFunction
                Coutputname={Xtarget.XperformanceFunction.Soutputname};
            else
                Coutputname=Xtarget.Coutputnames;
            end
        end
        
    case 'Function'
        %% Implement control of the perturbation
        error('openCOSSAN:sensitivity:gradientFiniteDifferences',...
            'Gradient estimation of a Function not implemented yet');
    otherwise
        
        error('openCOSSAN:sensitivity:gradientFiniteDifferences',...
            'Gradient estimation for this input not allowed');
end

if ~exist('perturbation','var')
    perturbation=1e-4;
end

%% Indentify the indices for the required inputs.
if ~exist('Cnames','var')
    % By default use all random variables
    Cnames=Xinput.CnamesRandomVariable;
end

Nrv=Xinput.NrandomVariables;  % Number of RV dedined in the model
Ndv=Xinput.NdesignVariables;  % Number of DV dedined in the model
Ninputs=length(Cnames);       % Number of required inputs

CnamesRV=Xinput.CnamesRandomVariable;
CnamesDV=Xinput.CnamesDesignVariable;

if Nrv>0
    VindexRV=zeros(Ninputs,1);
    for n=1:Ninputs
        VindexRV(n)= find(ismember(CnamesRV,Cnames(n)));
    end
    VindexRV(VindexRV==0)=[];
end

if Ndv>0
    VindexDV=zeros(Ninputs,1);
    for n=1:Ninputs
        VindexDV(n)= find(ismember(CnamesDV,Cnames(n)));
    end
    VindexDV(VindexDV==0)=[];
end

%% Generate Samples object from the Reference Point
if isempty(Xsamples0)
    % Construct Reference Point
    if exist('VreferencePointUserDefined','var')
        % Check mandatory fields
        assert(length(VreferencePointUserDefined)==Nrv+Ndv, ...
            'openCOSSAN:sensitivity:gradientFiniteDifferences', ...
            strcat('The length of reference point (%i) must be equal to' , ...
            ' the sum of the number of random variables (%i) and the number',...
            ' of design variables (%i)'), ...
            length(VreferencePointUserDefined),Nrv,Ndv)
    else
        Tdefault=Xinput.get('defaultvalues');
        
        VreferencePointUserDefined=zeros(1,Nrv+Ndv);
        for n=1:Nrv
            VreferencePointUserDefined(n)=Tdefault.(Xinput.CnamesRandomVariable{n});
        end
        for n=1:Ndv
            VreferencePointUserDefined(Nrv+n)=Tdefault.(Xinput.CnamesDesingVariable{n});
        end
    end
    
    if Nrv>0 && Ndv>0
        Xsamples0=Samples('MsamplesPhysicalSpace',VreferencePointUserDefined(1:Nrv), ...
            'MsamplesdoeDesignVariables',VreferencePointUserDefined(Nrv+1:end),'Xinput',Xinput);
    elseif Nrv>0 && Ndv==0
        Xsamples0=Samples('MsamplesPhysicalSpace',VreferencePointUserDefined,'Xinput',Xinput);
    else
        Xsamples0=Samples('MsamplesdoeDesignVariables',VreferencePointUserDefined,'Xinput',Xinput);
    end
    
else
    VreferencePointUserDefined=Xsamples0.MsamplesPhysicalSpace;
end

if isempty(fx0)
    Xout0=Xtarget.apply(Xsamples0);
    NfunctionEvaluation=NfunctionEvaluation+Xout0.Nsamples;
else
    Cvariables=Xsamples0.Cvariables;
    Cvariables(end+1)=Coutputname;
    Mfx0=[Xsamples0.MsamplesPhysicalSpace fx0];
    Xout0=SimulationData('Cnames',Cvariables,'Mvalues',Mfx0);
end

%% Compute finite difference for each component
MUi=repmat(Xsamples0.MsamplesStandardNormalSpace,Ninputs,1);
MDVp=repmat(Xsamples0.MdoeDesignVariables,Ninputs,1);

for ic=1:Ninputs
    if ic<=length(VindexRV)
        MUi(ic,VindexRV(ic))  = MUi(ic,VindexRV(ic)) + perturbation;
    else
        MDVp(ic,VindexDV(ic)) = MDVp(ic,VindexDV(ic)) + perturbation*MDVp(ic,VindexDV(ic));
    end
end

% Define a Samples object with the perturbated values
if Nrv>0 && Ndv>0
    Xsmli=Samples('MsamplesStandardNormalSpace',MUi, ...
        'MsamplesdoeDesignVariables',MDVp,'Xinput',Xinput);
elseif Nrv>0 && Ndv==0
    Xsmli=Samples('MsamplesStandardNormalSpace',MUi,'Xinput',Xinput);
else
    Xsmli=Samples('MsamplesdoeDesignVariables',MDVp,'Xinput',Xinput);
end

% Store values in physical space
MsamplesPhysicalSpace=Xsmli.MsamplesPhysicalSpace;
Xdeltai     = Xtarget.apply(Xsmli);
NfunctionEvaluation     = NfunctionEvaluation+Xdeltai.Nsamples;

%% Compute quantity of interest
if Lgradient
    %% Compute Gradient
    
    Vperturbation=zeros(Ninputs,1);
    for n=1:Ninputs
        if n<=length(VindexRV)
            Vperturbation(n)  = MsamplesPhysicalSpace(n,VindexRV(n)) + -VreferencePointUserDefined(VindexRV(n));
        else
            Vperturbation(n) = MDVp(n,VindexDV(n)) + -VreferencePointUserDefined(VindexDV(n));
        end
    end
    
    Vgradient = (Xdeltai.getValues('Cnames',Coutputname) - Xout0.getValues('Cnames',Coutputname) )./Vperturbation;
    
    NfunctionEvaluation     = NfunctionEvaluation+Xdeltai.Nsamples;
    
    
    %% Export results
    Xfdout=Gradient('Sdescription',...
        ['Finite Difference Gradient estimation of ' Coutputname{:}], ...
        'Cnames',Cnames, ...
        'NfunctionEvaluation',NfunctionEvaluation,...
        'Vgradient',Vgradient,'Vreferencepoint',VreferencePointUserDefined,...
        'SfunctionName',Coutputname{1});   
else
    % Compute the variance of the responce in standard normal space
    for n=1:length(Coutputname)
        Vmeasures = (Xdeltai.getValues('Cnames',Coutputname(n)) - ...
            Xout0.getValues('Cnames',Coutputname(n)) )/perturbation;
        
        %% Export results
        Xfdout(n)=LocalSensitivityMeasures('Sdescription',...
            ['Finite Difference estimation the local sensitivity analysis of ' Coutputname{n}], ...
            'Cnames',Cnames, ...
            'NfunctionEvaluation',NfunctionEvaluation,...
            'Vmeasures',Vmeasures,'Vreferencepoint',VreferencePoint,...
            'SfunctionName',Coutputname{n}); %#ok<AGROW>
    end
end

varargout{1}=Xout0.merge(Xdeltai); % Export SimulationData
varargout{1}.SexitFlag='All (selected) input variables perturebated';
