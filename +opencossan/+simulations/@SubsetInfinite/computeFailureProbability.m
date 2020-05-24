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

import opencossan.common.inputs.random.RandomVariableSet.*
import opencossan.common.Samples
import opencossan.simulations.SubsetOutput
import opencossan.reliability.FailureProbability

%% Check inputs
[Xobj,Xinput]=checkInputs(Xobj,Xtarget);

%%  Initialize variables
exitFlag=[];           % Flag for the simulation
rejectedSamples=[];
gAllLevelsSeedsIndex=[];  % Index of the performance function used as seeds
rejection=0;

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
        Nseeds=Xobj.seedslastbatch; %number of seeds in the current batch
        Ninitialsamples=Xobj.initialSimLastBatch; %number of initial samples in the current batch
    else
        Nseeds=Xobj.seedssimxbatch ;
        Ninitialsamples=Xobj.initialSimxBatch;
    end
    
    % Initialize Variable
    % This variable stores the indices of the seeds. It is used to
    % reconstruct and plot the seeds.  The corresponding
    % realizations are store in the SubSetOutput object in the Tvalue field.
    
    seedIndices=zeros(Nseeds,Xobj.seedsamples,Xobj.maxlevels);
    
    
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
    
    if Xobj.updateStd
        adaptAfterNsamples = floor(0.15*Nseeds); %factor between 0.1 and 0.2
        scaleParamLambda = 0.6;
        optimalAcceptance = 0.44;
    end
    
    %% Level of Subset simulations
    for	ilevel = 1:Xobj.maxlevels
        opencossan.OpenCossan.cossanDisp(['Processing Level #' num2str(ilevel) '/' num2str(Xobj.maxlevels)] ,3)
        %sort performance function
        [Vsort, Vindex] =sort(Vg_subset,1,'ascend');
        
        % Computes intermediary threshold level
        % (defines) the current subset
        gFl(ilevel) =Vsort(Nseeds);
        
        % Computes intermediary failure probability
        if gFl(ilevel)<= 0, % final failure has been reached
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
            % correlation of the states of the initial seeds
            Mg=reshape(Vg_subset ...
                (end-Xobj.seedsamples*Nseeds+1:end), ...
                [],Xobj.seedsamples);
            Mindicator_g=Mg<gFl(ilevel);
            Mcorr = zeros(Nseeds,Xobj.seedsamples);
            
            for isample=1:Nseeds
                V = Mindicator_g(isample,:);
                for deltak = 0:(Xobj.seedsamples-1),
                    V1 = V(1:end-deltak);
                    V2 = V(1+deltak:end);
                    Mcorr(deltak+1,isample) = (1/length(V1))*sum(V1.*V2);
                end
            end %end correlation estimation
            
            %Eq. (25)
            VIcorr = sum(Mcorr,2) / Nseeds - pFl(ilevel)^2;
            
            % Eq. 27
            Vrho = VIcorr / VIcorr(1);
            gammal=2*sum((1-(1:Xobj.seedsamples-1)* ...
                Nseeds/Ninitialsamples).* ...
                Vrho(1:Xobj.seedsamples-1)');
            % Eq. 28
            covpFl(ilevel)=sqrt((1-pFl(ilevel))/ ...
                (pFl(ilevel)*Ninitialsamples)*(1+gammal));
        end
        
        
        % Using the SubSim-\infty algorithm the initial seeds are not
        % preserved. Hence all the samples can be rejected.
        rejectionRate(ilevel)=rejection/(length(Vg_subset));
        
        if Xobj.updateStd
            SmessagePropLevel = 'Proposal standard deviation: adaptive';
        else
            k=min(length(Xobj.proposalStd),ilevel);
            SmessagePropLevel=['Proposal standard deviation: ' num2str(Xobj.proposalStd(k))];
        end
        
        
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
        Msort=MU(Vindex(1:Nseeds),:); %sort samples
        
        %% SUBSET INFTY
        % Genegrating samples using the new Subset algorithm
        % This approach does not use Markov Chains but the canonical
        % algorithm for conditional sampling
        
        seedIndices(:,:,ilevel)=reshape(1:Ninitialsamples,Nseeds,[])+Xobj.initialSamples*(ilevel);
        
        % Performance function of the SubSet (Vsort) and the
        % corresponding samples (Msort) of the SubSet
        Vg_subset=repmat(Vsort(1:Nseeds),Xobj.seedsamples,1);
        
        % This approach generates proposed samples starting from
        % the common initial points
        % Define initial points (Xobj.Nseedsamples,components of the samples)
        MU=repmat(Msort,Xobj.seedsamples,1);
        
        if Xobj.updateStd
            %mean and variance across all seeds
            adaptMean = sum(MU(1:Nseeds,:),1)./Nseeds;
            adaptVariance = sum((MU(1:Nseeds,:) - adaptMean).^2,1)./(Nseeds-1);
            
            %change seed order randomly
            changeSeedOrder = randperm(Nseeds);
            
            updateDistrib = abs(floor(Nseeds/adaptAfterNsamples));
            MprososedSamples = nan(size(MU));
            g_newSamples = nan(size(MU,1),1);
            
            for iter=1:updateDistrib
                % scaling parameters
                adaptsigma = min(1,scaleParamLambda.*sqrt(adaptVariance));
                scaleParamRho = sqrt(1 - (adaptsigma.^2));
                
                if iter == updateDistrib
                    iterChains = ((iter-1)*adaptAfterNsamples + 1):Nseeds;
                else
                    iterChains = ((iter-1)*adaptAfterNsamples + 1):(iter*adaptAfterNsamples);
                end
                
                %updated mean and standard deviation
                Mmeans = scaleParamRho.*MU(changeSeedOrder(iterChains),:);
                currentStd = sqrt(1 - scaleParamRho.^2);
                currentStd = repmat(currentStd, [size(Mmeans,1),1]);
                
                %create new samples
                currentSamples = nan(numel(iterChains)*(size(MU,1)/Nseeds),size(MprososedSamples,2));
                for sc = 1:(size(MU,1)/Nseeds)
                    tempSamples = normrnd(Mmeans,currentStd);
                    currentSamples(sc:(size(MU,1)/Nseeds):((numel(iterChains)-1)*(size(MU,1)/Nseeds) + sc),:) = tempSamples;
                    MprososedSamples(changeSeedOrder(iterChains) + Nseeds*(sc - 1),:) = tempSamples;
                    absPositionSamples(sc:(size(MU,1)/Nseeds):((numel(iterChains)-1)*(size(MU,1)/Nseeds) + sc),1) = changeSeedOrder(iterChains) + Nseeds*(sc - 1);
                end
                
                Xs=Samples('CXrvset',struct2cell(Xinput.RandomVariableSets),'MsamplesStandardNormalSpace',currentSamples);
                
                % Evaluate the model
                Xout_tmp=Xtarget.apply(Xs);
                
                % Merge SimulationData objects. Please note that the
                % SimulationData contains all the model evaluations
                % including the rejected values
                XbatchSimOut=XbatchSimOut.merge(Xout_tmp);
                
                % Get the new values of the performance function
                Vg_temp=Xout_tmp.getValues('Sname',Xtarget.PerformanceFunctionVariable);
                g_newSamples(absPositionSamples) = Vg_temp;
                
                %average accpetance rate per chain
                numberAccepted = (Vg_temp <= gFl(ilevel))==1;
                numberAccepted = sum(reshape(numberAccepted,(size(MU,1)/Nseeds),[]),1)./(size(MU,1)./Nseeds);
                
                %average acceptance rate
                averageAcceptance = sum(numberAccepted)/numel(iterChains);
                %update scale parameter lambda
                scaleParamLambda = exp(log(scaleParamLambda) + (iter^(-0.5))*(averageAcceptance - optimalAcceptance));
            end
            
            % Identify the samples that have to be rejected. The
            % rejecte points corresponds to the samples whose
            % performance function value is below the subset value (the
            % removed states are set equal to the previous
            % ones)
            Vaccepted=find((g_newSamples <= gFl(ilevel))==1);
            VrejectAbsPosition=find((g_newSamples > gFl(ilevel))==1);
            rejectedSamples=[rejectedSamples; VrejectAbsPosition+(ilevel-1)*length(Vg_subset)+Ninitialsamples];
            
            % Update the vector of the performance function
            Vg_subset(Vaccepted)= g_newSamples(Vaccepted);
            MU(Vaccepted,:)=MprososedSamples(Vaccepted,:);
            % Store the number of rejected samples
            rejection=length(VrejectAbsPosition);
            
        else
            if length(Xobj.proposalStd) >= ilevel,
                currentStd = Xobj.proposalStd(ilevel);
            else
                currentStd = Xobj.proposalStd(end);
            end
            
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
            
            
            Xs=Samples('CXrvset',struct2cell(Xinput.RandomVariableSets),'MsamplesStandardNormalSpace',MprososedSamples);
            
            % Evaluate the model
            Xout_tmp=Xtarget.apply(Xs);
            
            % Merge SimulationData objects. Please note that the
            % SimulationData contains all the model evaluations
            % including the rejected values
            XbatchSimOut=XbatchSimOut.merge(Xout_tmp);
            
            % Get the new values of the performance function
            %Vg_temp=[Vsort(1:Nseeds); Xout_tmp.getValues('Sname',Xtarget.XperformanceFunction.Soutputname)];
            Vg_temp=Xout_tmp.getValues('Sname',Xtarget.PerformanceFunctionVariable);
            %MSamples_temp=[Msort; MprososedSamples];
            % Identify the samples that have to be rejected. The
            % rejecte points corresponds to the samples whose
            % performance function value is below the subset value (the
            % removed states are set equal to the previous
            % ones)
            Vaccepted=find((Vg_temp <= gFl(ilevel))==1);
            VrejectAbsPosition=find((Vg_temp > gFl(ilevel))==1);
            rejectedSamples=[rejectedSamples; VrejectAbsPosition+(ilevel-1)*length(Vg_subset)+Ninitialsamples]; %#ok<AGROW>
            
            % Update the vector of the performance function
            Vg_subset(Vaccepted)= Vg_temp(Vaccepted);
            MU(Vaccepted,:)=MprososedSamples(Vaccepted,:);
            % Store the number of rejected samples
            rejection=length(VrejectAbsPosition);
        end
        
        % Collect results
        gAllLevels=[gAllLevels; Vg_subset]; %#ok<AGROW>
        
        if ilevel>1
            MpreviousChain=seedIndices(:,:,(ilevel-1));
            VindexAbsolute=MpreviousChain(Vindex(1:Nseeds));
            gAllLevelsSeedsIndex=[gAllLevelsSeedsIndex; VindexAbsolute]; %#ok<AGROW>
        else
            gAllLevelsSeedsIndex=Vindex(1:Nseeds);
        end
        samplesAllLevels=[samplesAllLevels; MU]; %#ok<AGROW>
        
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
    switch class(Xtarget)
        case {'Model','MetaModel'}
            SoutputName=Xtarget.Coutputnames{1};
        case {'ProbabilisticModel'}
            SoutputName=Xtarget.SperformanceFunctionVariable;
        case {'SystemReliability'}
            % TO BE IMPLEMENTED
            error('OpenCossan:SubSetSimulation:SystemReliabilityNotImplemented',...
                'Not implemented for SystemReliability')
    end
    
    
    XssOut = SubsetOutput('performancefunctionname',Xtarget.PerformanceFunctionVariable,...
        'subsetfailureprobability',pFl, 'subsetThreshold',gFl,...
        'subsetSamples',samplesAllLevels,...
        'chainIndices',seedIndices,...
        'rejectedSamplesIndices',rejectedSamples,...
        'subsetCoV',covpFl,'subsetPerformance',gAllLevels,...
        'seedsIndices',gAllLevelsSeedsIndex,...
        'rejectionRates',rejectionRate,'markovchains',Nseeds,...
        'initialSamples',Xobj.initialSamples,'markovchainsamples',Xobj.seedsamples);
    
    
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
        Xpf=FailureProbability('CXmembers',{Xtarget},'Smethod','SubsetInfinite',...
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
opencossan.OpenCossan.getTimer().lap('description','End computeFailureProbability@SubsetInfinite');

% Restore Global Random Stream
restoreRandomStream(Xobj);
