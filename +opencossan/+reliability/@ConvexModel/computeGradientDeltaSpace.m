function varargout=computeGradientDeltaSpace(varargin)


%% Initialize variables
Xsamples0=[];
fx0=[];
LperformanceFunction=false;
perturbation=[];
Coutputname=[];

%% Check inputs
OpenCossan.validateCossanInputs(varargin{:})
%% Process inputs
for k=1:2:nargin
    switch lower(varargin{k})
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
            assert(all([~isnan(varargin{k+1}) ~isinf(varargin{k+1})]), ...
                'openCOSSAN:sensitivity:coreFiniteDifferences',...
                 'The reference point can not contain NaN or Inf values\nProvided values: %s',...
                 sprintf('%e ',varargin{k+1}));                  
            VreferencePointUserDefined=varargin{k+1};
        case {'xsamples'}
            Xsamples0=varargin{k+1};
        case {'cnamesboundedvariable' 'csnames'}
            % Reference Point in PhysicalSpace
            Cnames=varargin{k+1};
        case {'cxsamples'}
            Xsamples0=varargin{k+1}{1};
        case {'functionvalue','fx0'}
            fx0=varargin{k+1};
        case {'perturbation'}
            perturbation=varargin{k+1}; 
        otherwise
            error('openCOSSAN:sensitivity:coreFiniteDifferences',...
                'PropertyName %s not allowed',varargin{k});
    end
end

% Check model and extract Input, perturbation and output names. 
[Xinput,perturbation,Coutputname]=Sensitivity.checkModel(Xtarget,perturbation,LperformanceFunction,Coutputname);
% Initialize variables
NfunctionEvaluation=0;
Nbv=Xinput.NboundedVariables;  % Number of BV dedined in the model


VindexBV=zeros(Nbv,1);
for n=1:Nbv
    VindexBV(n)= find(ismember(Cnames,Cnames(n)));
end
VindexBV(VindexBV==0)=[];

%% Generate Samples object from the Reference Point
if isempty(Xsamples0)
    % Construct Reference Point
    if exist('VreferencePointUserDefined','var')
        % Check mandatory fields
        assert(length(VreferencePointUserDefined)==Nbv, ...
            'openCOSSAN:sensitivity:coreMonteCarlo', ...
            strcat('The length of reference point (%i) must be equal to' , ...
            ' the number of random variables or bounded variables (%i)'), ...
            length(VreferencePointUserDefined),Nbv)       
        % Reordinate the VreferencePoint
        VreferencePointUserDefined=VreferencePointUserDefined(VindexBV);

    else
        Tdefault=Xinput.get('defaultvalues');        
        VreferencePointUserDefined=zeros(1,Nbv);
        for n=1:Nbv
            VreferencePointUserDefined(n)=Tdefault.(Xinput.CnamesBoundedVariable{n});
        end

    end
    Xsamples0=Samples('MsamplesPhysicalSpace',VreferencePointUserDefined,'Xinput',Xinput);

else
    
    assert(Xsamples0.Nsamples==1, 'openCOSSAN:sensitivity:coreMonteCarlo', ...
        'The Sample object must containts only 1 sample in order to define the reference point')
    VreferencePointUserDefined=Xsamples0.MsamplesPhysicalSpace;
end
if isempty(fx0)
    Xout0=Xtarget.apply(Xsamples0);
    NfunctionEvaluation=NfunctionEvaluation+Xout0.Nsamples;
    Vreference=Xout0.getValues('Cnames',Coutputname);
else
    Cvariables=Xsamples0.Cvariables;
    Cvariables(end+1)=Coutputname;
    Mfx0=[Xsamples0.MsamplesPhysicalSpace fx0];
    Xout0=SimulationData('Cnames',Cvariables,'Mvalues',Mfx0);
    Vreference=fx0;
end


%% Compute finite difference for each component
% Define the perturbation points in the DELTA SPACE
MsamplesDspace=repmat(Xsamples0.MsamplesDeltaSpace,Nbv,1);
Mperturbation=perturbation*eye(Nbv);
MsamplesDspace=MsamplesDspace+Mperturbation;

% Define a Samples object with the perturbated values
Xsmli=Samples('MsamplesDeltaSpace',MsamplesDspace,'Xinput',Xinput);

% Evaluate the model
Xdeltai     = Xtarget.apply(Xsmli);
if ~isempty(OpenCossan.getDatabaseDriver)
    insertRecord(OpenCossan.getDatabaseDriver,'StableType','Simulation', ...
        'Nid',getNextPrimaryID(OpenCossan.getDatabaseDriver,'Simulation'),...
        'XsimulationData',Xdeltai,'Nbatchnumber',0) 
end  
NfunctionEvaluation     = NfunctionEvaluation+Xdeltai.Nsamples;

%% Compute gradient (in DeltaSpace)
MgradientsDspace=zeros(Nbv,length(Coutputname));

for iout=1:length(Coutputname)
    MgradientsDspace(:,iout) = (Xdeltai.getValues('Cnames',Coutputname(iout)) - Vreference(iout) )./perturbation;
end

%% Compute the variance of the responce in standard normal space
Mindices=zeros(Nbv,length(Coutputname));

for iout=1:length(Coutputname)
    Mindices(:,iout) = (Xdeltai.getValues('Cnames',Coutputname(iout)) - ...
        Vreference(iout) )/perturbation;    
end
XsimData=Xout0.merge(Xdeltai); % Export SimulationData
%% Export results
varargout{2}=XsimData;

for n=1:length(Coutputname)
        varargout{1}(n)=Gradient('Sdescription',...
            ['Finite Difference Gradient estimation of ' Coutputname{n} ' computed in standard normal space'], ...
            'Cnames',Cnames, ...
            'LdeltaSpace',true, ...
            'NfunctionEvaluation',NfunctionEvaluation,...
            'Vgradient',MgradientsDspace(:,n),'Vreferencepoint',VreferencePointUserDefined,...
            'SfunctionName',Coutputname{n});   
end

if ~isdeployed
    % add entries in simulation and analysis database at the end of the
    % computation when not deployed. The deployed version does this with
    % the finalize command
    XdbDriver = OpenCossan.getDatabaseDriver;
    if ~isempty(XdbDriver)
        XdbDriver.insertRecord('StableType','Result',...
            'Nid',getNextPrimaryID(OpenCossan.getDatabaseDriver,'Result'),...
            'CcossanObjects',varargout(1),...
            'CcossanObjectsNames',{'Xgradient'});
    end
end

end