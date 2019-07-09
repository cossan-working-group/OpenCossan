function [XMCout varargout]=coreMonteCarlo(varargin)
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
NfunctionEvaluation=0;
LperformanceFunction=false;
perturbation=[];
Coutputname=[];

gReference=[];
Nsim=[];
tolerance=0.1;

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
            assert(all([~isnan(varargin{k+1}) ~isinf(varargin{k+1})]), ...
                'openCOSSAN:sensitivity:coreFiniteDifferences',...
                 'The reference point can not contain NaN or Inf values\nProvided values: %s',...
                 sprintf('%e ',varargin{k+1}));                  
            VreferencePointUserDefined=varargin{k+1};
        case {'cnamesrandomvariable' 'csnames'}
            % Reference Point in PhysicalSpace
            Cnames=varargin{k+1};
        case {'xsamples'}
            Xsamples0=varargin{k+1};
        case {'cxsamples'}
            Xsamples0=varargin{k+1}{1};
        case {'functionvalue','fx0'}
            gReference=varargin{k+1};
        case {'perturbation'}
            perturbation=varargin{k+1};
        case {'valpha'}
            Valpha=varargin{k+1};
        case {'tolerance'}
            tolerance=varargin{k+1};
        case {'ndeltasampleset'}
            NdeltaSampleSet=varargin{k+1};
        case {'nsimulations'}
            Nsim=varargin{k+1};
        case {'nindicesbyfinitedifference','nindiciesbyfinitedifference'}
            NindiciesFD=varargin{k+1};
        case {'nmaxfailure'}
            NmaxFailure=varargin{k+1};
        otherwise
            error('openCOSSAN:sensitivity:coreMonteCarlo',...
                ['PropertyName ' varargin{k} ' not allowed']);
    end
end

% Check model and extract Input, perturbation and output names. 
[Xinput,perturbation,Coutputname]=Sensitivity.checkModel(Xtarget,perturbation,LperformanceFunction,Coutputname);

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
    
    assert(isempty(VindexDV),'openCOSSAN:sensitivity:coreMonteCarlo', ....
        strcat('The Monte Carlo method can not be to estimate the gradient if ',...
        'the quantity of interest is a Design Variable.'))
end


%% Set default values
if ~exist('NindiciesFD','var')
    % Define the number of components computed by means a Finite Difference
    % Analyis
    NindiciesFD=min(3,Ninputs);
end

if NindiciesFD>Ninputs
    warning('openCOSSAN:sensitivity:coreMonteCarlo',...
    'The number of indices computed by finite differences (%i) must be <= number of required components (%i)', ...
    NindiciesFD,Ninputs)
    NindiciesFD=Ninputs;
end


if ~exist('NmaxFailure','var')
    % Define the maximum number of components wrongly identified as
    % important before increase the poll of the samples set
    NmaxFailure=min(3,Ninputs);
end

if ~exist('NdeltaSampleSet','var')
    % Define the increasing of the poll of samples set
    NdeltaSampleSet=max(1,floor((Ninputs-NindiciesFD)/5));
end

%% Compute preliminary information
% Ndiag == k;
% n_dim == n;
% perturbation == gamma;

n_dim=Nrv; % number of input factors

if isempty(Nsim)
    if(n_dim<10)
        Nsim = min(Ninputs,max(1,ceil(n_dim/4)));
        Ndiag  = Nsim-1;
    else
        Nsim = min(Ninputs,max(2,ceil(n_dim/8)));
        Ndiag  = max(2,Nsim-2);
    end
else
    if(n_dim<10)
        Ndiag  = Nsim-1;
    else
        Ndiag  = max(2,Nsim-2);
    end
end

%% Generate Samples object from the Reference Point
if isempty(Xsamples0)
    % Construct Reference Point
    if exist('VreferencePointUserDefined','var')
        % Check mandatory fields
        assert(length(VreferencePointUserDefined)==Nrv, ...
            'openCOSSAN:sensitivity:coreMonteCarlo', ...
            strcat('The length of reference point (%i) must be equal to' , ...
            ' the number of random variables (%i)'), ...
            length(VreferencePointUserDefined),Nrv)
        
        %% Reordinate the VreferencePoint
        if Nrv>0
            VreferencePointUserDefinedRV=VreferencePointUserDefined(VindexRV);
        end
        if Ndv>0
            VreferencePointUserDefinedDV=VreferencePointUserDefined(Nrv+VindexDV);
        end
    else
        Tdefault=Xinput.get('defaultvalues');
        
        VreferencePointUserDefinedRV=zeros(1,Nrv);
        VreferencePointUserDefinedDV=zeros(1,Ndv);
        for n=1:Nrv
            VreferencePointUserDefinedRV(n)=Tdefault.(Xinput.CnamesRandomVariable{n});
        end
        for n=1:Ndv
            VreferencePointUserDefinedDV(n)=Tdefault.(Xinput.CnamesDesingVariable{n});
        end
        VreferencePointUserDefined=[VreferencePointUserDefinedRV VreferencePointUserDefinedDV];
        
        if Nrv>0 && Ndv>0
            Xsamples0=Samples('MsamplesPhysicalSpace',VreferencePointUserDefinedRV, ...
                'MsamplesdoeDesignVariables',VreferencePointUserDefinedDV,'Xinput',Xinput);
        elseif Nrv>0 && Ndv==0
            Xsamples0=Samples('MsamplesPhysicalSpace',VreferencePointUserDefinedRV,'Xinput',Xinput);
        else
            Xsamples0=Samples('MsamplesdoeDesignVariables',VreferencePointUserDefinedDV,'Xinput',Xinput);
        end
    end
else
    assert(Xsamples0.Nsamples==1, 'openCOSSAN:sensitivity:coreMonteCarlo', ...
        'The Sample object must containts only 1 sample in order to define the reference point')
    VreferencePointUserDefined=Xsamples0.MsamplesPhysicalSpace;
end
% Gradient Monte Carlo method requires values in Standard Normal SPace
Vx0=Xinput.map2stdnorm(VreferencePointUserDefined);

if ~exist('Valpha','var')
    Mbasevector=eye(n_dim);
else
    if size(Valpha,2)==1
        Va1=Valpha;
    else
        Va1=Valpha';
    end
    assert (length(Va1)==n_dim,'openCOSSAN:sensitivity:coreMonteCarlo',...
        strcat('The length of the important directon (%i) must be equal to the',...
        ' dimensionality of the problem (%i).'),length(Va1),n_dim);
    
    %% Construct matries to perform linear orthogonal transformation
    % Va1 == A1 dimension (n_dim x 1)
    % Va2 == A2 dimension (n_dim x ndiag)
    % Va3 == A3 dimension (n_dim x (n_dim-Ndiag-1));
    
    % Compute A1
    Va1 = Va1/norm(Va1); % Normalize the important direction
    
    % Compute A2
    % Sort the components of the approximate gradient
    [~, idx] = sort(abs(Va1),'descend');
    
    Ma2 = zeros(n_dim,min(n_dim-1,Ndiag)); % preallocate memory
    for i=1:min(n_dim-1,Ndiag)
        Ma2(idx(i),i) = 1; % see Eq. (22)
    end
    
    % Compute A3
    %Ma3=randn(n_dim,n_dim-Ndiag-1)/sqrt(n_dim);
    Ma3=randn(n_dim,n_dim-Ndiag-1); % According to the paper
    
    % Compose matrix A (Va)
    Ma=[Va1 Ma2 Ma3];
    
    % Compute orthonormal matrix from the Matrix A -> B
    Mbasevector  = gram_schmidt(Ma); % see Eq. 21
end

%% Compute perturbation points in the transforment space (see Eq. (23))
Mr  = randn(Nsim,Nrv); % Vector of random points in the SNS (r)
% Compute always the maximun number of points
%Mr =  gram_schmidt(Mr); %This step is most likely not necessary

Mdelta = transpose(perturbation*Mbasevector*transpose(Mr)); % Vector of perturbation points around the reference point (gamma*B*r)
Mpertubation  =  repmat(Vx0,Nsim,1)+Mdelta;

%% Define a Samples object from the samples P and evaluate it
XsmlP=Samples('MsamplesStandardNormalSpace',Mpertubation,'Xinput',Xinput);

if isempty(gReference)
    %Xsamples0=Samples('MsamplesStandardNormalSpace',Vx0*Mbasevector,'Xinput',Xinput);
    Xsamples0=Samples('MsamplesStandardNormalSpace',Vx0,'Xinput',Xinput);
    
    % Merge the samples object
    % The first sample should be the reference point
    XsmlP=Xsamples0.add('Xsamples',XsmlP);
end

OpenCossan.cossanDisp(['[Status:gradientMC ]     * Compute ' num2str(XsmlP.Nsamples) '  points'],3)
XsimData=Xtarget.apply(XsmlP);
% Retrive values from the SimulationData object
Vout=XsimData.getValues('Cnames',Coutputname);

gReference=Vout(1); % Function evaluated at the reference point (g(x) in the paper)
gPertubation=Vout(2:end); % Function evaluated at the points (g(x+gamma*r) in the paper)


%% HERE WE GO

%% Compute b
% see Eq. (6) Vb==b
Vb   = zeros(max(n_dim,Nsim),1); %preallocate memory

%% Step 2
% set I_U
Lunknown =true(n_dim,1);

%% Step 3
%evaluate Delta y in SNS
Vb(1:Nsim) = (gPertubation-gReference);%/Ndelta;
% Set C_U(j)
Vc_U = Vb(1:Nsim);

if(Nsim>=n_dim)
    Vgradient = Mdelta\Vb; % see Eq. (9) of 1)
else
    Vgradient = zeros(Ninputs,1); % Preallocate memory
    ifailure=0; % Initialize variable
    %% Computing the most important gradient components
    % This part is based on the Section 2.5 of " Relative importance of
    % uncertain structural prameters"
    %
    % The relative importance of D (Ndiag) components have been already computed
    % with the indices I_D (idx)
    
    %% Step 4
    % check if the potentially important parameters are provided based on
    % subjective engineering jugdment
    
    if exist('Valpha','var')
        % Go to step 7 to determined the most important components by finite
        % difference
        
    end
    
    while 1
        %% Step 5
        % Esitmate y_k where Vc_u is used instead of Vb.
        Vy_U = (Mdelta'*Vc_U);
        Vy_U(~Lunknown)=0;
        % should be normalized?
        %Vnorm=sum(Mdelta(:,VIU).^2,1)';
        %Vy_U(VIU)=Vy_U(VIU)./Vnorm;
        
        %% Step 6
        % estimator order according to their absolute values.
        [~,Vindices] = sort(abs(Vy_U(VindexRV)),'descend');
        % keep only Nsim values
        
        %% Step 7
        % compute gradient for the NindiciesFD components by means of finite
        % differences
        
        % Only random variables
        Mpertubation  =  repmat(Vx0,NindiciesFD,1);
        
        for ic=1:NindiciesFD
            Mpertubation(ic,VindexRV(Vindices(ic))) = Mpertubation(ic,VindexRV(Vindices(ic))) + perturbation;
        end
        XsmlFD=Samples('MsamplesStandardNormalSpace',Mpertubation,'Xinput',Xinput);
        OpenCossan.cossanDisp(['[Status:gradientMC ]     * Compute ' num2str(XsmlFD.Nsamples) '  points'],3)
        % compute the response
        XoutFD=Xtarget.apply(XsmlFD);
        
        % Collect SimulationData
        XsimData=XsimData.merge(XoutFD);
        
        NfunctionEvaluation=NfunctionEvaluation+ NindiciesFD;
        Vgradient(Vindices(1:NindiciesFD)) = (XoutFD.getValues('Cnames',Coutputname) - gReference )/perturbation;
        
        %% Step 8
        % Update IU
        Lunknown(VindexRV(Vindices(1:NindiciesFD))) = 0;
        % Update C_U
        Vc_U = Vc_U-Mdelta(:,Vindices(1:NindiciesFD))*Vgradient(Vindices(1:NindiciesFD));
        
        %% Step 9
        % check the exit criterion
        % check if all components have been estimated
        if all(Lunknown(VindexRV)==0)
            break
        end
        
        %
        norm_c = norm(Vc_U);
        norm_b = norm(Vb);
        cosAlpha=sqrt(1-norm_c^2/norm_b^2);
        OpenCossan.cossanDisp(['[Sensitivity:gradientMonteCarlo] Accuracy (cos(alpha)): ' num2str(sqrt(1-norm_c^2/norm_b^2))],3)
        if  1-cosAlpha<=tolerance
            break
        end
        
        if NfunctionEvaluation>n_dim
            break
        end
        
        %% Step 10
        % Check if the parameter estimated is important or not
        % update the failure criteria
        ifailure=ifailure+ sum(Vgradient(Vindices(1:NindiciesFD)).^2<1/n_dim);
        
        %% Step 11
        if ifailure>NmaxFailure
            % Increase sample size
            
            %% Step 12
            % Increase the sample set. NdeltaSampleSet are updated
            %% Compute perturbation points in the transforment space (see Eq. (23))
            Mr  = randn(NdeltaSampleSet,n_dim); % Vector of random points in the SNS (r)
            MdeltaN = transpose(perturbation*Mbasevector*transpose(Mr)); % Vector of perturbation points around the reference point (gamma*B*r)
            Mdelta=[Mdelta; MdeltaN]; %#ok<AGROW>
            Mpertubation  =  repmat(Vx0,NdeltaSampleSet,1)+MdeltaN;
            XsmlDN=Samples('MsamplesStandardNormalSpace',Mpertubation,'Xinput',Xinput);
            
            %% Step 13
            % compute the response
            XoutDN=Xtarget.apply(XsmlDN);
            
            % Collect SimulationData
            XsimData=XsimData.merge(XoutDN);
            % Update counter function evaluations
            NfunctionEvaluation=NfunctionEvaluation+ XoutDN.Nsamples;
            
            % Extract quantity of interest
            gPertubationDN=XoutDN.getValues('Cnames',Coutputname);
            Vb(Nsim+1:Nsim+NdeltaSampleSet) = (gPertubationDN-gReference);
            
            %% Step 14
            % substract from the new set of response variation the contribution of
            % all gradient components that have been idividually determined so far
            %        Vc_U = VbDN-Vb*Mdelta(Vindices(1:Nsim),:)';
            
            Vc_U(Nsim+1:Nsim+NdeltaSampleSet)=Vb(Nsim+1:Nsim+NdeltaSampleSet)-MdeltaN(:,Vindices(1:NindiciesFD))*Vgradient(Vindices(1:NindiciesFD));
            
            %% Step 15
            % Increase counter fot the sample size
            % Update counter function evaluation
            Nsim=Nsim+NdeltaSampleSet;
            ifailure=0;
        end
        
        %% Return to step 5
    end
    
    B=Mdelta(1:Nsim,Vindices(Vindices));
    Vgradient(Vindices) =Vgradient(Vindices) + B\Vc_U(1:Nsim);
end

%% Compute quantity of interest
if Lgradient
    
    %% Export results
    %Vgradient = Mbasevector*sol;
    %Valpha = Vgrad/norm(Vgrad);
    
    XMCout=Gradient('Sdescription',...
        ['Monte Carlo Gradient estimation of ' Coutputname{:}], ...
        'Cnames',Cnames, ...
        'NfunctionEvaluation',NfunctionEvaluation,...
        'Vgradient',Vgradient,'Vreferencepoint',VreferencePointUserDefined,...
        'SfunctionName',Coutputname{1});
    
    
else
    %% Export results
    Vmeasures = Vgradient; % Preallocate memory
    
    for n=1:length(Cnames)
        XrvTmp=Xinput.get('Xrv',Cnames{n});
        Vmeasures(n) = Vmeasures(n)*XrvTmp.std;
    end
    
    %% Export results
    XMCout=LocalSensitivityMeasures('Sdescription',...
        'Monte Carlo estimation of local sensitivity analysis', ...
        'Cnames',Cnames, ...
        'NfunctionEvaluation',NfunctionEvaluation,...
        'Vmeasures',Vmeasures,'Vreferencepoint',VreferencePointUserDefined,...
        'SfunctionName',Coutputname{1});
    
    
end

varargout{1}=XsimData; % Export SimulationData
varargout{1}.SexitFlag='All (selected) input variables perturebated';
