function [Xpf,varargout]=computeFailureProbability(Xobj,Xtarget)
%COMPUTEFAILUREPROBABILITY computes the failure probability using subset simulation 
% of the associate ProbabilisticModel.
%
% See also:
% https://cossan.co.uk/wiki/index.php/computeFailureProbability@Simulation
%
% The following algorithm is based on the original implementation of Subset
% simulation proposed by Au and Back in 2001
% * Au, S.-K. & Beck, J.  Estimation of small failure probabilities in high
% dimensions by subset simulation Probabilistic Engineering Mechanics,
% 2001, 16, 263-277)
% * Patelli, E. & Au, S. K. Subset Simulation in finite-infinite
% dimensional space. Reliability Engineering & System safety, 2015 (submitted)
% * Patelli, E. & Au, I. Efficient Monte Carlo algorithm for rare failure
% event simulation 12th International Conference on Applications of Statistics and Probability in Civil Engineering, 2015

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
%% Check inputs
if OpenCossan.getChecks
    [Xobj,Xinput]=checkInputs(Xobj,Xtarget);
end

%%  Initialize variables
SexitFlag=[];           % Flag for the simulation
VrejectedSamples=[];
VgAllLevelsSeedsIndex=[];  % Index of the performance function used as seeds
Nrejection=0;
Nrv =  Xinput.NrandomVariables; % Number of random variables

if isempty(Xobj.VproposalStd)
    Lstandard=true;  % Original implementation of SubSet (SubSim-MCMC)
else
    Lstandard=false; % Canonical  implementation of SubSet (SubSim-infinity)
end

%% Start SubSet simulation
while isempty(SexitFlag)   % Cycle over the number of batches
    
    % Preallocate memory
    VpFl    = zeros(Xobj.Nmaxlevels,1); % Failure Probability of each level
    VcovpFl = zeros(Xobj.Nmaxlevels,1); % CoV of the Pf of each level
    VgFl    = zeros(Xobj.Nmaxlevels,1); % Threshould of each level
    CgFall  = cell(Xobj.Nmaxlevels,1);  % Value of performance function at each level
    VrejectionRate = zeros(Xobj.Nmaxlevels,1); % rejection rate each level
    
    Xobj.ibatch = Xobj.ibatch + 1; % Update status of the batches
    
    % Lap time for each batch
    OpenCossan.setLaptime('Sdescription',[' Batch #' num2str(Xobj.ibatch)]);
    
    
    if Xobj.ibatch == Xobj.Nbatches
        Nmarkovchains=Xobj.Nmarkovchainslastbatch; %number of markov chains in the current batch
        Ninitialsamples=Xobj.NinitialSimLastBatch; %number of initial samples in the current batch
    else
        Nmarkovchains=Xobj.Nmarkovchainssimxbatch ;
        Ninitialsamples=Xobj.NinitialSimxBatch;
    end
    
    % Initialize Variable
    % This variable stores the indices of the Markov Chains. It is used to
    % reconstruct and plot the Markov Chains.  The corresponding
    % realizations are store in the SubSetOutput object in the Tvalue field.
    
    MchainIndices=zeros(Nmarkovchains,Xobj.Nmarkovchainsamples,Xobj.Nmaxlevels);
    
    
    % The samples are gerenated in the standard normal space
    % and automatically mapped in the physical space
    Xinput=Xinput.sample('Nsamples',Ninitialsamples);
    
    % Retrive samples in Standard Normal Space
    MU=Xinput.Xsamples.MsamplesStandardNormalSpace;
    Xout_tmp= apply(Xtarget,Xinput);    % Evaluate the model
    XbatchSimOut=Xout_tmp;              % Collect the SimulationData
    
    % Extract the values of the performance function
    Vg_subset=XbatchSimOut.getValues('Sname',Xtarget.XperformanceFunction.Soutputname);
    
    VgAllLevels=Vg_subset;
    MsamplesAllLevels=MU;
    
    OpenCossan.cossanDisp('Initial samples generated and evaluated',3)
    
    
    %% Level of Subset simulations
    for	ilevel = 1:Xobj.Nmaxlevels
        OpenCossan.cossanDisp(['Processing Level #' num2str(ilevel) '/' num2str(Xobj.Nmaxlevels)] ,3)
        %sort performance function
        [Vsort, Vindex] =sort(Vg_subset,1,'ascend');
        
        % Computes intermediary threshold level
        % (defines) the current subset
        VgFl(ilevel) =Vsort(Nmarkovchains);
        
        % Computes intermediary failure probability
        if VgFl(ilevel)<= 0, % final failure has been reached
            VpFl(ilevel) = sum( Vsort <= 0 ) / Ninitialsamples;
            CgFall{ilevel}  = Vsort;
        else
            VpFl(ilevel) = sum( Vsort <= VgFl(ilevel) ) / Ninitialsamples;
            CgFall{ilevel}  = Vsort(Vsort > VgFl(ilevel));
        end
        
        
        %% CoV estimation
        if ilevel ==1
            %CoV in the case of Monte Carlo simulation
            VcovpFl(1) = sqrt(  (1 - VpFl(1)) / (VpFl(1) * Ninitialsamples ));  %Eq. (28)
        else
            % correlation of the states of the markov chain (or initial
            % seeds)
            Mg=reshape(Vg_subset ...
                (end-Xobj.Nmarkovchainsamples*Nmarkovchains+1:end), ...
                [],Xobj.Nmarkovchainsamples);
            Mindicator_g=Mg<VgFl(ilevel);
            Mcorr = zeros(Nmarkovchains,Xobj.Nmarkovchainsamples);
            
            for isample=1:Nmarkovchains
                V = Mindicator_g(isample,:);
                for deltak = 0:(Xobj.Nmarkovchainsamples-1),
                    V1 = V(1:end-deltak);
                    V2 = V(1+deltak:end);
                    Mcorr(deltak+1,isample) = (1/length(V1))*sum(V1.*V2);
                end
            end %end correlation estimation
            
            %Eq. (25)
            VIcorr = sum(Mcorr,2) / Nmarkovchains - VpFl(ilevel)^2;
            
            % Eq. 27
            Vrho = VIcorr / VIcorr(1);
            gammal=2*sum((1-(1:Xobj.Nmarkovchainsamples-1)* ...
                Nmarkovchains/Ninitialsamples).* ...
                Vrho(1:Xobj.Nmarkovchainsamples-1)');
            % Eq. 28
            VcovpFl(ilevel)=sqrt((1-VpFl(ilevel))/ ...
                (VpFl(ilevel)*Ninitialsamples)*(1+gammal));
        end
        
        
        
        if Lstandard
            % SubSim-MCMC
            % TODO: Do not preserve the initial seeds.
            VrejectionRate(ilevel)=Nrejection/(length(Vg_subset)-Nmarkovchains);
            
            % TODO: Add support for XproposedDistributionSet
            
            % Prepare message output
            k=min(length(Xobj.Vdeltaxi),ilevel);
            SmessagePropLevel=['Proposal PDF: uniform , window size: ' num2str(Xobj.Vdeltaxi(k))];
        else
            % Using the SubSim-\infty algorithm the initial seeds are not
            % preserved. Hence all the samples can be rejected.
            VrejectionRate(ilevel)=Nrejection/(length(Vg_subset));
            
            k=min(length(Xobj.VproposalStd),ilevel);
            SmessagePropLevel=['Proposal standard deviation: ' num2str(Xobj.VproposalStd(k))];
        end
        
        TSS.Cvg{ilevel}=Vg_subset;
        % Store information of each level
        % Show partial results
        if ilevel>1
            Smessage    = num2str(VrejectionRate(ilevel));
        else
            Smessage    = '0 (MCS)';
        end
        OpenCossan.cossanDisp(['* Estimated probability < ',num2str(prod(VpFl(1:ilevel)))],2)
        OpenCossan.cossanDisp(['* Performance Function = ' num2str(VgFl(ilevel)) ...
            ', Failure probability (Pfl)= ' num2str(VpFl(ilevel)) ...
            ', CoVPfl = ' num2str(VcovpFl(ilevel)) ...
            ', Rejection rate = ' Smessage ],2);
        
        OpenCossan.cossanDisp(SmessagePropLevel,3);
        OpenCossan.cossanDisp(' ',3);
        
        %stop the simulation once failure has been estimated
        
        if VgFl(ilevel)<= 0
            OpenCossan.cossanDisp( '* Failure region identified',2)
            break;
        end
        
        % As long as the failure reagion hasn't been reached, a new
        % proposal samples are build
        
        %% Prepare samples for next level
        % Compute the conditional failure probality for the last level
        if ilevel==Xobj.Nmaxlevels
            VpFl(ilevel) = sum( Vg_subset <= 0 ) /  Ninitialsamples;
            continue
        end
        
        % keep only those samples (sorted)
        % corresponding to the smallest performance function values
        Msort=MU(Vindex(1:Nmarkovchains),:); %sort samples
        
        if Lstandard
            %% SubSim-MCMC
            % use the original implementation of SubSet simulation (based on Monte Carlo
            % Markov Chains).
            
            % TODO: do not preserve seeds
            
            if ilevel==1
                VindexAbsolute=Vindex(1:Nmarkovchains);
                MindexAbsolute=reshape(1:Nmarkovchains*(Xobj.Nmarkovchainsamples-1),Nmarkovchains,[])+Xobj.NinitialSamples;
            else
                MpreviousChain=MchainIndices(:,:,(ilevel-1));
                VindexAbsolute=MpreviousChain(Vindex(1:Nmarkovchains));
                MindexAbsolute=reshape(1:Nmarkovchains*(Xobj.Nmarkovchainsamples-1),Nmarkovchains,[])+Xobj.NinitialSamples+(ilevel-1)*(Xobj.Nmarkovchainsamples-1)*Nmarkovchains;
            end
            
            MchainIndices(:,:,ilevel)=[VindexAbsolute MindexAbsolute];
            
            % Initialize Markov Chains
            
            %set proposal PDF
            if length(Xobj.Vdeltaxi) >= ilevel,
                deltaxi = Xobj.Vdeltaxi(ilevel);
            else
                deltaxi = Xobj.Vdeltaxi(end);
            end
            
            % Create Proposal distribution for the Markov Chain
            % Different proposal distributions are created for each
            % RandomVariableSet defined in the Input object
            
            if isempty(Xobj.XproposedDistributionSet)
                Xrv=RandomVariable('Sdistribution','uniform', ...
                    'par1',-deltaxi,'par2', deltaxi);
                Crvsetname=Xinput.CnamesRandomVariableSet;
                
                for irvs=1:length(Crvsetname)
                    XproposalDistribution(irvs)=RandomVariableSet('Xrv',Xrv, ...
                        'Nrviid',Xinput.Xrvset.(Crvsetname{irvs}).Nrv); %#ok<AGROW>
                end
                
            else
                % Use the user defined proposal distribution
                XproposalDistribution=Xobj.XproposedDistributionSet;
            end
            
            % Extract RandomVariableSets as target distributions
            for n=1:length(Xinput.CnamesRandomVariableSet)
                XtargetDistribution(n)=Xinput.Xrvset.(Xinput.CnamesRandomVariableSet{n}); %#ok<AGROW>
            end
            
            % Create Initial Samples from seeds identified by in the
            % previous level
            Xs=Samples('CXrvset',struct2cell(Xinput.Xrvset),'MsamplesStandardNormalSpace',Msort);
            
            % Build MarkovCain: Initial points (seeds) are the points
            % above the VgFl(ilevel). The constructor automatically
            % generate Npoints states of the Markov Chain
            % (The option Npoints=0 forces the Markov Chain constructur
            % to not generate new states of the chains)
            % The samples object is used to define the initial seeds
            
            Xmkv_l=MarkovChain('XtargetDistribution', XtargetDistribution, ...
                'XproposedDistribution',XproposalDistribution, ...
                'Xsamples',Xs,'Npoints',0);
            
            
            % Vg_subset contains the values that have been kept to build
            % the SubSet
            
            % Reset variables (new and independent Markov Chains are
            % constructed for each level)
            Vg_subset=zeros(Xobj.Nmarkovchainsamples*Nmarkovchains,1);
            Nrejection=0;
            MU=zeros(Ninitialsamples,Nrv);
            
            % Performance function of the SubSet (Vsort) and the
            % corresponding samples (Msort) of the SubSet
            Vg_subset(1:Nmarkovchains)=Vsort(1:Nmarkovchains);
            MU(1:Nmarkovchains,:)=Msort;
            
            
            MprososedSamples=zeros(Nmarkovchains*Xobj.Nmarkovchainsamples,Nrv); % initialize variable
            
            
            %% Generate Markov Chains
            for iBuildChain=2:Xobj.Nmarkovchainsamples
                
                Xmkv_l=Xmkv_l.buildChain(1); %add 1 new state
                % Evaluate perfomance function
                Xout_tmp=Xtarget.apply(Xmkv_l.Xsamples(end));
                
                % Merge SimulationData objectd
                % rejected values are saved nevertheless
                XbatchSimOut=XbatchSimOut.merge(Xout_tmp);
                
                % Get the new values of the performance function
                Vg_temp=Xout_tmp.getValues('Sname',Xtarget.XperformanceFunction.Soutputname);
                
                % Identify the samples that have to be rejected. The
                % rejected points correspond to the samples whose
                % performance function value is below the subset value (the
                % removed states of the chain are set equal to the previous
                % ones)
                Vreject=find((Vg_temp > VgFl(ilevel))==1);
                VrejectAbsPosition=(iBuildChain-2)*Nmarkovchains+Vreject;
                VrejectedSamples=[VrejectedSamples; VrejectAbsPosition+(ilevel-1)*(Xobj.Nmarkovchainsamples-1)*Nmarkovchains+Ninitialsamples]; %#ok<AGROW>
                
                % Update the vector of the performance function
                % Please note that the MarkovChain object does not
                % store any information of the performance function
                Vg_temp(Vreject)=Vg_subset(VrejectAbsPosition);
                
                % Identify current set of samples
                Vposition=(iBuildChain-1)*Nmarkovchains+1:iBuildChain*Nmarkovchains;
                % Update Vg_subset and the corresponding samples MU
                Vg_subset(Vposition)=Vg_temp;
                
                if ~isempty(Vreject)
                    % Remove points from Markov Chain
                    Xmkv_l =remove(Xmkv_l,'Vchain',Vreject);
                    MU(Vposition,:)=Xmkv_l.Mlast;
                end
                
                % Store the number of rejected samples
                Nrejection=Nrejection+length(Vreject);
                
                % Collect results
                VgAllLevels=[VgAllLevels; Vg_temp]; %#ok<AGROW>
                MsamplesAllLevels=[MsamplesAllLevels; Xmkv_l.Mlast]; %#ok<AGROW>
                
            end % end Markov chains
            
        else
            %% SUBSET INFTY
            % Genegrating samples using the new Subset algorithm
            % This approach does not use Markov Chains but the canonical
            % algorithm for conditional sampling
            
            MchainIndices(:,:,ilevel)=reshape(1:Ninitialsamples,Nmarkovchains,[])+Xobj.NinitialSamples*(ilevel);
            
            if length(Xobj.VproposalStd) >= ilevel,
                currentStd = Xobj.VproposalStd(ilevel);
            else
                currentStd = Xobj.VproposalStd(end);
            end
            
            % Performance function of the SubSet (Vsort) and the
            % corresponding samples (Msort) of the SubSet
            Vg_subset=repmat(Vsort(1:Nmarkovchains),Xobj.Nmarkovchainsamples,1);
            
            % This approach generates proposed samples starting from
            % the common initial points
            % Define initial points (Xobj.Nmarkovchainsamples,components of the samples)
            MU=repmat(Msort,Xobj.Nmarkovchainsamples,1);
            
            % Compute means of the Gaussian vector used to generate new
            % samples. a=sqrt(1-currentVariance);
            % Here the same variance is used for each component.
            Mmeans=sqrt(1-currentStd.^2).*MU;
            
            % Generate candidate solutions
            % normrnd takes as input mean and standard deviation. Hence the
            % new samples are generate from a Gaussian vector with
            % independent components with means vector Mmeans and std
            % std=\sqrt(s_i^2)=\sqrt(currentVariance.^2)=currentStd
            
            MprososedSamples=normrnd(Mmeans,currentStd);
            
            Xs=Samples('CXrvset',struct2cell(Xinput.Xrvset),'MsamplesStandardNormalSpace',MprososedSamples);
            
            % Evaluate the model
            Xout_tmp=Xtarget.apply(Xs);
            
            % Merge SimulationData objects. Please note that the
            % SimulationData contains all the model evaluations
            % including the rejected values
            XbatchSimOut=XbatchSimOut.merge(Xout_tmp);
            
            % Get the new values of the performance function
            %Vg_temp=[Vsort(1:Nmarkovchains); Xout_tmp.getValues('Sname',Xtarget.XperformanceFunction.Soutputname)];
            Vg_temp=Xout_tmp.getValues('Sname',Xtarget.XperformanceFunction.Soutputname);
            %MSamples_temp=[Msort; MprososedSamples];
            % Identify the samples that have to be rejected. The
            % rejecte points corresponds to the samples whose
            % performance function value is below the subset value (the
            % removed states of the chain are set equal to the previous
            % ones)
            Vaccepted=find((Vg_temp <= VgFl(ilevel))==1);
            VrejectAbsPosition=find((Vg_temp > VgFl(ilevel))==1);
            VrejectedSamples=[VrejectedSamples; VrejectAbsPosition+(ilevel-1)*length(Vg_subset)+Ninitialsamples]; %#ok<AGROW>
            
            % Update the vector of the performance function
            Vg_subset(Vaccepted)= Vg_temp(Vaccepted);
            MU(Vaccepted,:)=MprososedSamples(Vaccepted,:);
            % Store the number of rejected samples
            Nrejection=length(VrejectAbsPosition);
            
            % Collect results
            VgAllLevels=[VgAllLevels; Vg_subset]; %#ok<AGROW>
            
            if ilevel>1
                MpreviousChain=MchainIndices(:,:,(ilevel-1));
                VindexAbsolute=MpreviousChain(Vindex(1:Nmarkovchains));
                VgAllLevelsSeedsIndex=[VgAllLevelsSeedsIndex; VindexAbsolute]; %#ok<AGROW>
            else
                VgAllLevelsSeedsIndex=Vindex(1:Nmarkovchains);
            end
            MsamplesAllLevels=[MsamplesAllLevels; MU]; %#ok<AGROW>
        end
        
    end % end SubSet levels
    
    
    %% Compute failure probability
    % Remove not used levels
    VpFl = VpFl(1:ilevel);
    VcovpFl = VcovpFl(1:ilevel);
    VrejectionRate = VrejectionRate(1:ilevel);
    VgFl = VgFl(1:ilevel);
    
    % Compute the failure probability and the CoV
    if isempty(Xtarget.XperformanceFunction.stdDeviationIndicatorFunction),    %in case smooth performance function is not applied, calculate Pf in usual way
        pF = prod(VpFl);
    else    %in case smooth performance function is applied, calculate Pf using special formula
        p0          = Xobj.Ntarget_pf;  %target failure probability for each Subset
        Vweights    = cumprod([1-p0,ones(1,ilevel-1)*p0]);  %compute weights associated with each Subset
        Vweights(end)   = 1-sum(Vweights(1:end-1));         %correct weights to they add up to one
        pF              = 0;    %initialize failure probability to zero
        for countLevel=1:ilevel,
            gFSmoothInd     = normcdf(-CgFall{countLevel},0,...
                Xtarget.XperformanceFunction.stdDeviationIndicatorFunction);  %smooth indicator function
            pF      = pF + mean(gFSmoothInd) * Vweights(countLevel);    %compute contribution to pF of each Subset
        end
    end
    covpF = sqrt( sum( VcovpFl.^2 ));
    
    %% output object dedicated to subset
    switch class(Xtarget)
        case {'Model','MetaModel'}
            SoutputName=Xtarget.Coutputnames{1};
        case {'ProbabilisticModel'}
            SoutputName=Xtarget.XperformanceFunction.Soutputname;
        case {'SystemReliability'}
            % TO BE IMPLEMENTED
            error('OpenCossan:SubSetSimulation:SystemReliabilityNotImplemented',...
                'Not implemented for SystemReliability')
    end
    
    XssOut = SubsetOutput('Sperformancefunctionname',SoutputName,...
        'Vsubsetfailureprobability',VpFl, 'VsubsetThreshold',VgFl,...
        'MsubsetSamples',MsamplesAllLevels,...
        'MchainIndices',MchainIndices,...
        'VrejectedSamplesIndices',VrejectedSamples,...
        'VsubsetCoV',VcovpFl,'VsubsetPerformance',VgAllLevels,...
        'VseedsIndices',VgAllLevelsSeedsIndex,...
        'VrejectionRates',VrejectionRate,'Nmarkovchains',Nmarkovchains,...
        'NinitialSamples',Xobj.NinitialSamples,'Nmarkovchainsamples',Xobj.Nmarkovchainsamples);
    
    % Merge the SubsetOutput with the SimulationData
    XssOut=XssOut.merge(XbatchSimOut);
    
    
    %% Export SimulationData
    if Xobj.Lintermediateresults
        if Xobj.Lverbose
            TSS.VgFl=VgFl;
            TSS.VpFl=VpFl;
            TSS.VcovpFl=VcovpFl;
            %             Xobj.exportResults('XsimulationOutput',XbatchSimOut,TSS);
            Xobj.exportResults('Xsubsetoutput',XssOut);
        else
            Xobj.exportResults('Xsubsetoutput',XssOut);
        end
        % Keep in memory only the SimulationData of the last batch
        %         XsimOut=XbatchSimOut;
    end
    
    
    %% Update FailureProbability object
    
    if Xobj.ibatch==1
        % Initialize FailureProbability object
        Xpf=FailureProbability('CXmembers',{Xtarget},'Smethod','SubSet',...
            'Nsamples',XbatchSimOut.Nsamples,'pf',pF,'variancepf',covpF^2*pF^2);
    else
        Xpf=Xpf.addBatch('Nsamples',XbatchSimOut.Nsamples,'pf',pF,'variancepf',covpF^2*pF^2);
    end
    
    
    
    % check termination criteria
    SexitFlag=checkTermination(Xobj,Xpf);
end

% Add termination criteria to the FailureProbability
Xpf.SexitFlag=SexitFlag;

if ~isdeployed
    % add entries in simulation and analysis database at the end of the
    % computation when not deployed. The deployed version does this with
    % the finalize command
    XdbDriver = OpenCossan.getDatabaseDriver;
    if ~isempty(XdbDriver)
        XdbDriver.insertRecord('StableType','Result',...
            'Nid',getNextPrimaryID(OpenCossan.getDatabaseDriver,'Result'),...
            'CcossanObjects',{Xpf},...
            'CcossanObjectsNames',{'Xpf'});
    end
end

XssOut(end).SexitFlag=SexitFlag;

%% Export the last SimulationData object if required
varargout{1}=XssOut;
varargout{2}=XssOut;
OpenCossan.setLaptime('Sdescription','End computeFailureProbability@SubSet');

% Restore Global Random Stream
restoreRandomStream(Xobj);
