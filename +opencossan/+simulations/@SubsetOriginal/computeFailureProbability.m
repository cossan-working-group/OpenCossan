function [Xpf,XsimOut]=computeFailureProbability(Xobj,Xtarget)
%COMPUTEFAILUREPROBABILITY method. This method computes the Failure
%Probability (pf) associate to a ProbabilisticModel / SystemReliability /
%MetaModel by means of SubSet Simulation methods.
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

import opencossan.common.inputs.random.RandomVariableSet
import opencossan.common.Samples
import opencossan.common.MarkovChain
import opencossan.simulations.SubsetOutput
import opencossan.reliability.FailureProbability

%% Check inputs
[Xobj,Xinput]=checkInputs(Xobj,Xtarget);

%%  Initialize variables
exitFlag=[];           % Flag for the simulation
rejectedSamples=[];
rejection=0;
Nrv =  Xinput.NrandomVariables; % Number of random variables
KeepSeeds = Xobj.KeepSeeds; % boolean if the seeds get saved or discarded for each level

%% Start SubSet simulation
while isempty(exitFlag)   % Cycle over the number of batches
    
    % Preallocate memory
    pFl    = zeros(Xobj.maxlevels,1); % Failure Probability of each level
    covpFl = zeros(Xobj.maxlevels,1); % CoV of the Pf of each level
    gFl    = zeros(Xobj.maxlevels,1); % Threshould of each level
    gFall  = cell(Xobj.maxlevels,1);  % Value of performance function at each level
    rejectionRate = zeros(Xobj.maxlevels,1); % rejection rate each level
    
    Xobj.ibatch = Xobj.ibatch + 1; % Update status of the batches
    
    % Lap time for each batch
    opencossan.OpenCossan.getTimer().lap('description',[' Batch #' num2str(Xobj.ibatch)]);
    
    
    if Xobj.ibatch == Xobj.Nbatches
        markovchains=Xobj.markovchainslastbatch; %number of markov chains in the current batch
        Ninitialsamples=Xobj.initialSimLastBatch; %number of initial samples in the current batch
    else
        markovchains=Xobj.markovchainssimxbatch ;
        Ninitialsamples=Xobj.initialSimxBatch;
    end
    
    % Initialize Variable
    % This variable stores the indices of the Markov Chains. It is used to
    % reconstruct and plot the Markov Chains.  The corresponding
    % realizations are store in the SubSetOutput object in the Tvalue field.
    
    chainIndices=zeros(markovchains,Xobj.markovchainsamples,Xobj.maxlevels);
    
    
    % The samples are gerenated in the standard normal space
    % and automatically mapped in the physical space
    Xinput=Xinput.sample('Nsamples',Ninitialsamples);
    
    % Retrive samples in Standard Normal Space
    MU=Xinput.Samples.MsamplesStandardNormalSpace;
    Xout_tmp= apply(Xtarget,Xinput);    % Evaluate the model
    XbatchSimOut=Xout_tmp;              % Collect the SimulationData
    
    % Extract the values of the performance function
    Vg_subset=XbatchSimOut.getValues('Sname',Xtarget.PerformanceFunctionVariable);
    
    gAllLevels=Vg_subset;
    samplesAllLevels=MU;
    
    opencossan.OpenCossan.cossanDisp('Initial samples generated and evaluated',3)
    
    
    %% Level of Subset simulations
    for	ilevel = 1:Xobj.maxlevels
        opencossan.OpenCossan.cossanDisp(['Processing Level #' num2str(ilevel) '/' num2str(Xobj.maxlevels)] ,3)
        %sort performance function
        [Vsort, Vindex] =sort(Vg_subset,1,'ascend');
        
        % Computes intermediary threshold level
        % (defines) the current subset
        gFl(ilevel) =Vsort(markovchains);
        
        % Computes intermediary failure probability
        if gFl(ilevel)<= 0 % final failure has been reached
            pFl(ilevel) = sum( Vsort <= 0 ) / Ninitialsamples;
            gFall{ilevel}  = Vsort;
        else
            pFl(ilevel) = sum( Vsort <= gFl(ilevel) ) / Ninitialsamples;
            gFall{ilevel}  = Vsort(Vsort > gFl(ilevel));
        end
        
        
        %% CoV estimation
        if ilevel ==1
            %CoV in the case of Monte Carlo simulation
            covpFl(1) = sqrt(  (1 - pFl(1)) / (pFl(1) * Ninitialsamples ));  %Eq. (28)
        else
            % correlation of the states of the markov chain
            Mg=reshape(Vg_subset ...
                (end-Xobj.markovchainsamples*markovchains+1:end), ...
                [],Xobj.markovchainsamples);
            Mindicator_g=Mg<max(gFl(ilevel),0);
            Mcorr = zeros(markovchains,Xobj.markovchainsamples);
            
            for isample=1:markovchains
                V = Mindicator_g(isample,:);
                for deltak = 0:(Xobj.markovchainsamples-1)
                    V1 = V(1:end-deltak);
                    V2 = V(1+deltak:end);
                    Mcorr(deltak+1,isample) = (1/length(V1))*sum(V1.*V2);
                end
            end %end correlation estimation
            
            %Eq. (25)
            VIcorr = sum(Mcorr,2) / markovchains - pFl(ilevel)^2;
            
            % Eq. 27
            Vrho = VIcorr / VIcorr(1);
            gammal=2*sum((1-(1:Xobj.markovchainsamples-1)* ...
                markovchains/Ninitialsamples).* ...
                Vrho(1:Xobj.markovchainsamples-1)');
            % Eq. 28
            covpFl(ilevel)=sqrt((1-pFl(ilevel))/ ...
                (pFl(ilevel)*Ninitialsamples)*(1+gammal));
        end
        
        
        % SubSim-MCMC
        if KeepSeeds
            rejectionRate(ilevel)=rejection/(length(Vg_subset)-markovchains);
        else
            rejectionRate(ilevel)=rejection/(length(Vg_subset));
        end
        
        % TODO: Add support for XproposedDistributionSet
        
        % Prepare message output
        k=min(length(Xobj.deltaxi),ilevel);
        SmessagePropLevel=['Proposal PDF: uniform , window size: ' num2str(Xobj.deltaxi(k))];
        
        
        TSS.Cvg{ilevel}=Vg_subset;
        % Store information of each level
        % Show partial results
        if ilevel>1
            Smessage    = num2str(rejectionRate(ilevel));
        else
            Smessage    = '0 (MCS)';
        end
        opencossan.OpenCossan.cossanDisp(['* Estimated probability < ',num2str(prod(pFl(1:ilevel)))],2)
        opencossan.OpenCossan.cossanDisp(['* Performance Function = ' num2str(gFl(ilevel)) ...
            ', Failure probability (Pfl)= ' num2str(pFl(ilevel)) ...
            ', CoVPfl = ' num2str(covpFl(ilevel)) ...
            ', Rejection rate = ' Smessage ],2);
        
        opencossan.OpenCossan.cossanDisp(SmessagePropLevel,3);
        opencossan.OpenCossan.cossanDisp(' ',3);
        
        %stop the simulation once failure has been estimated
        
        if gFl(ilevel)<= 0
            opencossan.OpenCossan.cossanDisp( '* Failure region identified',2)
            break;
        end
        
        % As long as the failure reagion hasn't been reached, a new
        % proposal samples are build
        
        %% Prepare samples for next level
        % Compute the conditional failure probality for the last level
        if ilevel==Xobj.maxlevels
            pFl(ilevel) = sum( Vg_subset <= 0 ) /  Ninitialsamples;
            continue
        end
        
        % keep only those samples (sorted)
        % corresponding to the smallest performance function values
        Msort=MU(Vindex(1:markovchains),:); %sort samples
        
        %% SubSim-MCMC
        % use the original implementation of SubSet simulation (based on Monte Carlo
        % Markov Chains).
        
        if ilevel==1
            VindexAbsolute=Vindex(1:markovchains);
            MindexAbsolute=reshape(1:markovchains*(Xobj.markovchainsamples-1),markovchains,[])+Xobj.initialSamples;
        else
            MpreviousChain=chainIndices(:,:,(ilevel-1));
            VindexAbsolute=MpreviousChain(Vindex(1:markovchains));
            MindexAbsolute=reshape(1:markovchains*(Xobj.markovchainsamples-1),markovchains,[])+Xobj.initialSamples+(ilevel-1)*(Xobj.markovchainsamples-1)*markovchains;
        end
        
        chainIndices(:,:,ilevel)=[VindexAbsolute MindexAbsolute];
        
        % Initialize Markov Chains
        
        %set proposal PDF
        if length(Xobj.deltaxi) >= ilevel,
            deltaxi = Xobj.deltaxi(ilevel);
        else
            deltaxi = Xobj.deltaxi(end);
        end
        
        % Create Proposal distribution for the Markov Chain
        % Different proposal distributions are created for each
        % RandomVariableSet defined in the Input object
        
        if isempty(Xobj.proposedDistributionSet)
            Xrv=opencossan.common.inputs.random.UniformRandomVariable(...
                'bounds',[-deltaxi, deltaxi]);
            Crvsetname=Xinput.RandomVariableSetNames;
            
            for irvs=1:length(Crvsetname)
                XproposalDistribution(irvs) = ...
                    RandomVariableSet.fromIidRandomVariables(Xrv, ...
                    Xinput.RandomVariableSets.(Crvsetname{irvs}).Nrv); %#ok<AGROW>
            end
            
        else
            % Use the user defined proposal distribution
            XproposalDistribution=Xobj.proposedDistributionSet;
        end
        
        % Extract RandomVariableSets as target distributions
        for n=1:length(Xinput.RandomVariableSetNames)
            XtargetDistribution(n)=Xinput.RandomVariableSets.(Xinput.RandomVariableSetNames{n}); %#ok<AGROW>
        end
        
        % Create Initial Samples from seeds identified by in the
        % previous level
        Xs=Samples('CXrvset',struct2cell(Xinput.RandomVariableSets),'MsamplesStandardNormalSpace',Msort);
        
        % Build MarkovCain: Initial points (seeds) are the points
        % above the gFl(ilevel). The constructor automatically
        % generate Npoints states of the Markov Chain
        % (The option Npoints=0 forces the Markov Chain constructur
        % to not generate new states of the chains)
        % The samples object is used to define the initial seeds
        
        Xmkv_l=MarkovChain('TargetDistribution', XtargetDistribution, ...
            'ProposalDistribution',XproposalDistribution, ...
            'Samples',Xs);
        
        
        % Vg_subset contains the values that have been kept to build
        % the SubSet
        
        % Reset variables (new and independent Markov Chains are
        % constructed for each level)
        Vg_subset=zeros(Xobj.markovchainsamples*markovchains,1);
        rejection=0;
        MU=zeros(Ninitialsamples,Nrv);
        
        % Performance function of the SubSet (Vsort) and the
        % corresponding samples (Msort) of the SubSet
        Vg_subset(1:markovchains)=Vsort(1:markovchains);
        MU(1:markovchains,:)=Msort;
        
        
        %% Generate Markov Chains
        if KeepSeeds == true
            chainStart = 2;
        else
            chainStart = 1;
        end
        
        for iBuildChain=chainStart:Xobj.markovchainsamples
            
            Xmkv_l=Xmkv_l.buildChain(1); %add 1 new state
            % Evaluate perfomance function
            Xout_tmp=Xtarget.apply(Xmkv_l.Samples(end));
            
            % Merge SimulationData objectd
            % rejected values are saved nevertheless
            XbatchSimOut=XbatchSimOut.merge(Xout_tmp);
            
            % Get the new values of the performance function
            Vg_temp=Xout_tmp.getValues('Sname',Xtarget.PerformanceFunctionVariable);
            
            % Identify the samples that have to be rejected. The
            % rejected points correspond to the samples whose
            % performance function value is below the subset value (the
            % removed states of the chain are set equal to the previous
            % ones)
            Vreject=find((Vg_temp > gFl(ilevel))==1);
            if iBuildChain == 1 
                VrejectAbsPosition=(iBuildChain-1)*markovchains+Vreject;
                %does it only once and only if the seeds will be discarded
            else
                VrejectAbsPosition=(iBuildChain-2)*markovchains+Vreject;
            end
            rejectedSamples=[rejectedSamples; VrejectAbsPosition+(ilevel-1)*(Xobj.markovchainsamples-1)*markovchains+Ninitialsamples]; %#ok<AGROW>
            
            % Update the vector of the performance function
            % Please note that the MarkovChain object does not
            % store any information of the performance function
            Vg_temp(Vreject)=Vg_subset(VrejectAbsPosition);
            
            % Identify current set of samples
            Vposition=(iBuildChain-1)*markovchains+1:iBuildChain*markovchains;
            % Update Vg_subset and the corresponding samples MU
            Vg_subset(Vposition)=Vg_temp;
            
            if ~isempty(Vreject)
                % Remove points from Markov Chain
                Xmkv_l =remove(Xmkv_l,'Vchain',Vreject);
                MU(Vposition,:)=Xmkv_l.Mlast;
            end
            
            % Store the number of rejected samples
            rejection=rejection+length(Vreject);
            
            % Collect results
            gAllLevels=[gAllLevels; Vg_temp]; %#ok<AGROW>
            samplesAllLevels=[samplesAllLevels; Xmkv_l.Mlast]; %#ok<AGROW>
            
        end % end Markov chains
    end % end SubSet levels
    
    
    %% Compute failure probability
    % Remove not used levels
    pFl = pFl(1:ilevel);
    covpFl = covpFl(1:ilevel);
    rejectionRate = rejectionRate(1:ilevel);
    gFl = gFl(1:ilevel);
    
    % Compute the failure probability and the CoV
    if isempty(Xtarget.StdDeviationIndicatorFunction),    %in case smooth performance function is not applied, calculate Pf in usual way
        pF = prod(pFl);
    else    %in case smooth performance function is applied, calculate Pf using special formula
        p0          = Xobj.target_pf;  %target failure probability for each Subset
        Vweights    = cumprod([1-p0,ones(1,ilevel-1)*p0]);  %compute weights associated with each Subset
        Vweights(end)   = 1-sum(Vweights(1:end-1));         %correct weights to they add up to one
        pF              = 0;    %initialize failure probability to zero
        for countLevel=1:ilevel,
            gFSmoothInd     = normcdf(-gFall{countLevel},0,...
                Xtarget.StdDeviationIndicatorFunction);  %smooth indicator function
            pF      = pF + mean(gFSmoothInd) * Vweights(countLevel);    %compute contribution to pF of each Subset
        end
    end
    covpF = sqrt( sum( covpFl.^2 ));
    
    %% output object dedicated to subset
    
    XssOut = SubsetOutput('performancefunctionname',Xtarget.PerformanceFunctionVariable,...
        'subsetfailureprobability',pFl, 'subsetThreshold',gFl,...
        'subsetSamples',samplesAllLevels,...
        'chainIndices',chainIndices,...
        'rejectedSamplesIndices',rejectedSamples,...
        'subsetCoV',covpFl,'subsetPerformance',gAllLevels,...
        'rejectionRates',rejectionRate,'markovchains',markovchains,...
        'initialSamples',Xobj.initialSamples,'markovchainsamples',Xobj.markovchainsamples);
    
    
    % Merge the SubsetOutput with the SimulationData
    XssOut=XssOut.merge(XbatchSimOut);
    
    
    %% Export SimulationData
    if Xobj.Lintermediateresults
        if Xobj.Lverbose
            TSS.VgFl=gFl;
            TSS.VpFl=pFl;
            TSS.VcovpFl=covpFl;
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
        Xpf=FailureProbability('CXmembers',{Xtarget},'Smethod','SubsetOrigin',...
            'Nsamples',XbatchSimOut.Nsamples,'pf',pF,'variancepf',covpF^2*pF^2);
    else
        Xpf=Xpf.addBatch('Nsamples',XbatchSimOut.Nsamples,'pf',pF,'variancepf',covpF^2*pF^2);
    end
    
    
    
    % check termination criteria
    exitFlag=checkTermination(Xobj,Xpf);
end

% Add termination criteria to the FailureProbability
Xpf.SexitFlag=exitFlag;

if ~isdeployed
    % add entries in simulation and analysis database at the end of the
    % computation when not deployed. The deployed version does this with
    % the finalize command
    XdbDriver = opencossan.OpenCossan.getDatabaseDriver;
    if ~isempty(XdbDriver)
        XdbDriver.insertRecord('StableType','Result',...
            'Nid',getNextPrimaryID(opencossan.OpenCossan.getDatabaseDriver,'Result'),...
            'CcossanObjects',{Xpf},...
            'CcossanObjectsNames',{'Xpf'});
    end
end

XssOut(end).SexitFlag=exitFlag;

%% Export the last SimulationData object if required
XsimOut=XssOut;
opencossan.OpenCossan.getTimer().lap('description','End computeFailureProbability@SubsetOrigin');

% Restore Global Random Stream
restoreRandomStream(Xobj);
