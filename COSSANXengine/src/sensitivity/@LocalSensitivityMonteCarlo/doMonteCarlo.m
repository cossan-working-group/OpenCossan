function [Vgradient, NfunctionEvaluation, XsimData]=doMonteCarlo(Xobj)
% FINITEDIFFERENCESCORE
% Private function for the LocalSensitivityMonteCarlo
% See also:
% https://cossan.co.uk/wiki/index.php/@LocalSensitivityMonteCarlo
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


%% Initialize variables
NfunctionEvaluation=0;
gReference=[];

Nrv=Xobj.Xinput.NrandomVariables;  % Number of RV dedined in the model
Ndv=Xobj.Xinput.NdesignVariables;  % Number of DV dedined in the model
Ninputs=length(Xobj.Cinputnames);       % Number of required inputs
Nsim=Xobj.NsamplesSize;

CnamesRV=Xobj.Xinput.CnamesRandomVariable;
CnamesDV=Xobj.Xinput.CnamesDesignVariable;

if Nrv>0
    VindexRV=zeros(Ninputs,1);
    for n=1:Ninputs
        VindexRV(n)= find(ismember(CnamesRV,Xobj.Cinputnames(n)));
    end
    VindexRV(VindexRV==0)=[];
end

if Ndv>0
    VindexDV=zeros(Ninputs,1);
    for n=1:Ninputs
        VindexDV(n)= find(ismember(CnamesDV,Xobj.Cnames(n)));
    end
    VindexDV(VindexDV==0)=[];
    
    assert(isempty(VindexDV),'openCOSSAN:sensitivity:doMonteCarlo', ....
        strcat('The Monte Carlo method can not be to estimate the gradient if ',...
        'the quantity of interest is a Design Variable.'))
end


%% Set default values

% Define the maximum number of components wrongly identified as
% important before increase the poll of the samples set

%% Compute preliminary information
% Ndiag == k;
% n_dim == n;
% perturbation == gamma;

n_dim=Nrv; % number of input factors

if(n_dim<10)
    Ndiag  = Nsim-1;
else
    Ndiag  = max(2,Nsim-2);
end

% Gradient Monte Carlo method requires values in Standard Normal SPace
Vx0=Xobj.Xinput.map2stdnorm(Xobj.VreferencePoint);

if isempty(Xobj.Valpha)
    Mbasevector=eye(n_dim);
else
    if size(Xobj.Valpha,2)==1
        Va1=Xobj.Valpha;
    else
        Va1=Xobj.Valpha';
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

Mdelta = transpose(Xobj.perturbation*Mbasevector*transpose(Mr)); % Vector of perturbation points around the reference point (gamma*B*r)
Mpertubation  =  repmat(Vx0,Nsim,1)+Mdelta;

%% Define a Samples object from the samples P and evaluate it
XsmlP=Samples('MsamplesStandardNormalSpace',Mpertubation,'Xinput',Xobj.Xinput);

if isempty(gReference)
    %Xsamples0=Samples('MsamplesStandardNormalSpace',Vx0*Mbasevector,'Xinput',Xinput);
    Xobj.Xsamples0=Samples('MsamplesStandardNormalSpace',Vx0,'Xinput',Xobj.Xinput);
    
    % Merge the samples object
    % The first sample should be the reference point
    XsmlP=Xobj.Xsamples0.add('Xsamples',XsmlP);
end

OpenCossan.cossanDisp(['[Status:gradientMC ]     * Compute ' num2str(XsmlP.Nsamples) '  points'],3)
XsimData=Xobj.Xtarget.apply(XsmlP);
ibatch=0;
if ~isempty(OpenCossan.getDatabaseDriver)
    insertRecord(OpenCossan.getDatabaseDriver,'StableType','Simulation', ...
        'Nid',getNextPrimaryID(OpenCossan.getDatabaseDriver,'Simulation'),...
        'XsimulationData',XsimData,'Nbatchnumber',ibatch) 
end  
ibatch = ibatch+1;
% Retrive values from the SimulationData object
Vout=XsimData.getValues('Cnames',Xobj.Coutputnames);

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
        Mpertubation  =  repmat(Vx0,Xobj.NindiciesFD,1);
        
        for ic=1:Xobj.NindiciesFD
            Mpertubation(ic,VindexRV(Vindices(ic))) = Mpertubation(ic,VindexRV(Vindices(ic))) + Xobj.perturbation;
        end
        XsmlFD=Samples('MsamplesStandardNormalSpace',Mpertubation,'Xinput',Xobj.Xinput);
        OpenCossan.cossanDisp(['[Status:gradientMC ]     * Compute ' num2str(XsmlFD.Nsamples) '  points'],3)
        % compute the response
        XoutFD=Xobj.Xtarget.apply(XsmlFD);
        if ~isempty(OpenCossan.getDatabaseDriver)
            insertRecord(OpenCossan.getDatabaseDriver,'StableType','Simulation', ...
                'Nid',getNextPrimaryID(OpenCossan.getDatabaseDriver,'Simulation'),...
                'XsimulationData',XoutFD,'Nbatchnumber',ibatch) 
        end  
        ibatch = ibatch+1;
        
        % Collect SimulationData
        XsimData=XsimData.merge(XoutFD);
        
        NfunctionEvaluation=NfunctionEvaluation+ Xobj.NindiciesFD;
        Vgradient(Vindices(1:Xobj.NindiciesFD)) = (XoutFD.getValues('Cnames',Xobj.Coutputnames) - gReference )/Xobj.perturbation;
        
        %% Step 8
        % Update IU
        Lunknown(VindexRV(Vindices(1:Xobj.NindiciesFD))) = 0;
        % Update C_U
        Vc_U = Vc_U-Mdelta(:,Vindices(1:Xobj.NindiciesFD))*Vgradient(Vindices(1:Xobj.NindiciesFD));
        
        %% Step 9
        % check the exit criterion
        % check if all components have been estimated
        if all(Lunknown(VindexRV)==0)
            break
        end
        
        %
        norm_c = norm(Vc_U);
        norm_b = norm(Vb);
        cosAlpha=sqrt(norm_c^2/norm_b^2-1);
        OpenCossan.cossanDisp(['[Sensitivity:gradientMonteCarlo] Accuracy (cos(alpha)): ' num2str(cosAlpha)],3)
        if  1-cosAlpha<=Xobj.tolerance
            break
        end
        
        if NfunctionEvaluation>n_dim
            break
        end
        
        %% Step 10
        % Check if the parameter estimated is important or not
        % update the failure criteria
        ifailure=ifailure+ sum(Vgradient(Vindices(1:Xobj.NindiciesFD)).^2<1/n_dim);
        
        %% Step 11
        if ifailure>Xobj.NmaxFailure
            % Increase sample size
            
            %% Step 12
            % Increase the sample set. NdeltaSampleSet are updated
            %% Compute perturbation points in the transforment space (see Eq. (23))
            Mr  = randn(Xobj.NdeltaSampleSet,n_dim); % Vector of random points in the SNS (r)
            MdeltaN = transpose(Xobj.perturbation*Mbasevector*transpose(Mr)); % Vector of perturbation points around the reference point (gamma*B*r)
            Mdelta=[Mdelta; MdeltaN]; %#ok<AGROW>
            Mpertubation  =  repmat(Vx0,Xobj.NdeltaSampleSet,1)+MdeltaN;
            XsmlDN=Samples('MsamplesStandardNormalSpace',Mpertubation,'Xinput',Xobj.Xinput);
            
            %% Step 13
            % compute the response
            XoutDN=Xobj.Xtarget.apply(XsmlDN);
            if ~isempty(OpenCossan.getDatabaseDriver)
                insertRecord(OpenCossan.getDatabaseDriver,'StableType','Simulation', ...
                    'Nid',getNextPrimaryID(OpenCossan.getDatabaseDriver,'Simulation'),...
                    'XsimulationData',XoutDN,'Nbatchnumber',ibatch) 
            end  
            ibatch = ibatch+1;
            
            % Collect SimulationData
            XsimData=XsimData.merge(XoutDN);
            % Update counter function evaluations
            NfunctionEvaluation=NfunctionEvaluation+ XoutDN.Nsamples;
            
            % Extract quantity of interest
            gPertubationDN=XoutDN.getValues('Cnames',Xobj.Coutputnames);
            Vb(Nsim+1:Nsim+Xobj.NdeltaSampleSet) = (gPertubationDN-gReference);
            
            %% Step 14
            % substract from the new set of response variation the contribution of
            % all gradient components that have been idividually determined so far
            %        Vc_U = VbDN-Vb*Mdelta(Vindices(1:Nsim),:)';
            
            Vc_U(Nsim+1:Nsim+Xobj.NdeltaSampleSet)=Vb(Nsim+1:Nsim+Xobj.NdeltaSampleSet)-MdeltaN(:,Vindices(1:Xobj.NindiciesFD))*Vgradient(Vindices(1:Xobj.NindiciesFD));
            
            %% Step 15
            % Increase counter fot the sample size
            % Update counter function evaluation
            Nsim=Nsim+Xobj.NdeltaSampleSet;
            ifailure=0;
        end
        
        %% Return to step 5
    end
    
    B=Mdelta(1:Nsim,Vindices(Vindices));
    Vgradient(Vindices) =Vgradient(Vindices) + B\Vc_U(1:Nsim);
end


