function pf = computeFailureProbability(obj, target)
    %COMPUTEFAILUREPROBABILITY method. This method computes the Failure Probability (pf) associate
    %to a ProbabilisticModel / SystemReliability / MetaModel by means of SubSet Simulation methods.
    %
    % See also: https://cossan.co.uk/wiki/index.php/computeFailureProbability@Simulation
    %
    % The following algorithm is based on the original implementation of Subset simulation proposed
    % by Au and Back in 2001
    % * Au, S.-K. & Beck, J.  Estimation of small failure probabilities in high dimensions by subset
    % simulation Probabilistic Engineering Mechanics, 2001, 16, 263-277)
    % * Patelli, E. & Au, S. K. Subset Simulation in finite-infinite dimensional space. Reliability
    % Engineering & System safety, 2015 (submitted)
    % * Patelli, E. & Au, I. Efficient Monte Carlo algorithm for rare failure event simulation 12th
    % International Conference on Applications of Statistics and Probability in Civil Engineering,
    % 2015
    
    %
    % Author: Edoardo Patelli Institute for Risk and Uncertainty, University of Liverpool, UK email
    % address: openengine@cossan.co.uk Website: http://www.cossan.co.uk
    
    % ===================================================================== This file is part of
    % openCOSSAN.  The open general purpose matlab toolbox for numerical analysis, risk and
    % uncertainty quantification.
    %
    % openCOSSAN is free software: you can redistribute it and/or modify it under the terms of the
    % GNU General Public License as published by the Free Software Foundation, either version 3 of
    % the License.
    %
    % openCOSSAN is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    % without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
    % the GNU General Public License for more details.
    %
    %  You should have received a copy of the GNU General Public License along with openCOSSAN.  If
    %  not, see <http://www.gnu.org/licenses/>.
    % =====================================================================
    
    import opencossan.common.inputs.random.RandomVariableSet
    import opencossan.common.inputs.random.UniformRandomVariable
    import opencossan.common.Samples
    import opencossan.common.MarkovChain
    import opencossan.simulations.SubsetOutput
    import opencossan.reliability.FailureProbability
    
    %% Check inputs
    [obj, input] = checkInputs(obj,target);
    
    %%  Initialize variables
    rejectedSamples = [];
    rejection = 0;
    
    % Preallocate memory
    failureProbabilities = zeros(obj.MaxLevels, 1); % Failure Probability of each level
    coefficientsOfVariation = zeros(obj.MaxLevels, 1); % CoV of the Pf of each level
    thresholds = zeros(obj.MaxLevels, 1); % Threshould of each level
    performances = cell(obj.MaxLevels, 1);  % Value of performance function at each level
    rejectionRates = zeros(obj.MaxLevels, 1); % rejection rate each level
    
    % Initialize Variable This variable stores the indices of the Markov Chains. It is used to
    % reconstruct and plot the Markov Chains.  The corresponding realizations are store in the
    % SubSetOutput object in the Tvalue field.
    
    chainIndices = zeros(obj.NumberOfChains, obj.SamplesPerChain, obj.MaxLevels);
    
    % The samples are gerenated in the standard normal space and automatically mapped in the
    % physical space
    [initial, MU] = initialSamples(obj, input);
    
    simData = apply(target, initial);    % Evaluate the model
    
    % Extract the values of the performance function
    subsetPerformances = simData.Samples.(target.PerformanceFunctionVariable);
    
    gAllLevels = subsetPerformances;
    samplesAllLevels = MU;
    
    opencossan.OpenCossan.cossanDisp('Initial samples generated and evaluated',3)
    
    %% Level of Subset simulations
    for	ilevel = 1:obj.MaxLevels
        opencossan.OpenCossan.cossanDisp(['Processing Level #' num2str(ilevel) '/' num2str(obj.MaxLevels)] ,3)
        
        % Sort performances
        [sortedPerformances, performanceIndices] = sort(subsetPerformances, 1, 'ascend');
        
        % Compute intermediary threshold level (defines) the current subset
        thresholds(ilevel) = sortedPerformances(obj.NumberOfChains);
        [failureProbabilities(ilevel), performances{ilevel}] = ...
            intermediateFailureProbability(obj, sortedPerformances, thresholds(ilevel));
        
        % Compute the CoV for this level
        coefficientsOfVariation(ilevel) = coefficientOfVariation(obj, ilevel, ...
            subsetPerformances, thresholds(ilevel), failureProbabilities(ilevel));
        
        % SubSim-MCMC
        if obj.KeepSeeds
            rejectionRates(ilevel) = rejection/(length(subsetPerformances) - obj.NumberOfChains);
        else
            rejectionRates(ilevel) = rejection/(length(subsetPerformances));
        end
        
        % Prepare message output
        k = min(length(obj.DeltaXi), ilevel);
        SmessagePropLevel=['Proposal PDF: uniform , window size: ' num2str(obj.DeltaXi(k))];
        
        % Store information of each level Show partial results
        if ilevel > 1
            Smessage = num2str(rejectionRates(ilevel));
        else
            Smessage = '0 (MCS)';
        end
        
        opencossan.OpenCossan.cossanDisp(['* Estimated probability < ',num2str(prod(failureProbabilities(1:ilevel)))],2)
        opencossan.OpenCossan.cossanDisp(['* Performance Function = ' num2str(thresholds(ilevel)) ...
            ', Failure probability (Pfl)= ' num2str(failureProbabilities(ilevel)) ...
            ', CoVPfl = ' num2str(coefficientsOfVariation(ilevel)) ...
            ', Rejection rate = ' Smessage ],2);
        
        opencossan.OpenCossan.cossanDisp(SmessagePropLevel,3);
        opencossan.OpenCossan.cossanDisp(' ',3);
        
        if thresholds(ilevel) <= 0
            % Stop the simulation once failure has been estimated
            opencossan.OpenCossan.cossanDisp( '* Failure region identified',2)
            break;
        elseif ilevel == obj.MaxLevels
            % Skip MCMC in the last level
            continue;
        end
        
        % keep only those samples (sorted) corresponding to the smallest performance function values
        Msort = MU(performanceIndices(1:obj.NumberOfChains),:); %sort samples
        
        %% SubSim-MCMC
        % use the original implementation of SubSet simulation (based on Monte Carlo Markov Chains).
        
        if ilevel==1
            VindexAbsolute=performanceIndices(1:obj.NumberOfChains);
            MindexAbsolute=reshape(1:obj.NumberOfChains*(obj.SamplesPerChain-1),obj.NumberOfChains,[])+obj.InitialSamples;
        else
            MpreviousChain=chainIndices(:,:,(ilevel-1));
            VindexAbsolute=MpreviousChain(performanceIndices(1:obj.NumberOfChains));
            MindexAbsolute=reshape(1:obj.NumberOfChains*(obj.SamplesPerChain-1),obj.NumberOfChains,[])+obj.InitialSamples+(ilevel-1)*(obj.SamplesPerChain-1)*obj.NumberOfChains;
        end
        
        chainIndices(:,:,ilevel) = [VindexAbsolute MindexAbsolute];
        
        % Initialize Markov Chains
        
        %set proposal PDF
        if length(obj.DeltaXi) >= ilevel
            deltaxi = obj.DeltaXi(ilevel);
        else
            deltaxi = obj.DeltaXi(end);
        end
        
        % Create Proposal distribution for the Markov Chain Different proposal distributions are
        % created for each RandomVariableSet defined in the Input object
        
        nrvsets = input.NumberOfRandomVariableSets;
        if input.NumberOfRandomVariables > 0
            nrvsets = nrvsets + 1;
        end
        
        %% Proposed rvsets
        proposedSets = opencossan.common.inputs.random.RandomVariableSet.empty(nrvsets, 0);
        
        names = [];
        % Add random variable sets
        for i = 1:input.NumberOfRandomVariableSets
            proposedSets(i) = RandomVariableSet.fromIidRandomVariables(...
                UniformRandomVariable('bounds', [-deltaxi, deltaxi]),...
                input.RandomVariableSets(i).Nrv);
            names = [names input.RandomVariableSets(i).Names];
        end
        
        % If separate rvs exists add a proposal set for them as well
        if input.NumberOfRandomVariables > 0
            proposedSets(end+1) = RandomVariableSet.fromIidRandomVariables(...
                UniformRandomVariable('bounds', [-deltaxi, deltaxi]),...
                input.NumberOfRandomVariables);
            names = [names input.RandomVariableNames];
        end
        
        %% Target rvsets
        targetSets = input.RandomVariableSets;
        
        % If separate rvs exists add a target set for them as well
        if input.NumberOfRandomVariables > 0
            targetSets(end+1) = RandomVariableSet('Members', input.RandomVariables, ...
                'Names', input.RandomVariableNames);
        end
        
        % Build MarkovCain: Initial points (seeds) are the points above the gFl(ilevel). The
        % constructor automatically generate Npoints states of the Markov Chain (The option
        % Npoints=0 forces the Markov Chain constructur to not generate new states of the chains)
        % The samples object is used to define the initial seeds
        
        initialMarkovChainSamples = initial(performanceIndices(1:obj.NumberOfChains), contains(initial.Properties.VariableNames, names));
        
        % Build Markov Chains
        markovChains = MarkovChain(...
            'TargetDistribution', targetSets, ...
            'ProposalDistribution', proposedSets, ...
            'Samples', initialMarkovChainSamples);
        
        % Vg_subset contains the values that have been kept to build the SubSet
        
        % Reset variables (new and independent Markov Chains are constructed for each level)
        subsetPerformances = zeros(obj.SamplesPerChain * obj.NumberOfChains,1);
        rejection = 0;
        MU = zeros(obj.InitialSamples, size(MU, 2));
        
        % Performance function of the SubSet (Vsort) and the corresponding samples (Msort) of the
        % SubSet
        subsetPerformances(1:obj.NumberOfChains) = sortedPerformances(1:obj.NumberOfChains);
        MU(1:obj.NumberOfChains,:) = Msort;
        
        %% Generate Markov Chains
        if obj.KeepSeeds == true
            chainStart = 2;
        else
            chainStart = 1;
        end
        
        for iBuildChain = chainStart:obj.SamplesPerChain
            markovChains = markovChains.sample(); % add 1 new state
            
            markovChainSamples = markovChains.Samples{end};
            markovChainSamples = input.addParametersToSamples(markovChainSamples);
            markovChainSamples = input.evaluateFunctionsOnSamples(markovChainSamples);
            
            % Evaluate perfomance function
            simDataChain = target.apply(markovChainSamples);
            
            % Merge SimulationData objectd rejected values are saved nevertheless
            simData = simData + simDataChain;
            
            % Get the new values of the performance function
            Vg_temp = simDataChain.Samples.(target.PerformanceFunctionVariable);
            
            % Identify the samples that have to be rejected. The rejected points correspond to the
            % samples whose performance function value is below the subset value (the removed states
            % of the chain are set equal to the previous ones)
            Vreject = find(Vg_temp > thresholds(ilevel));
            if iBuildChain == 1
                VrejectAbsPosition=(iBuildChain-1) * obj.NumberOfChains+Vreject;
                %does it only once and only if the seeds will be discarded
            else
                VrejectAbsPosition=(iBuildChain-2)*obj.NumberOfChains+Vreject;
            end
            rejectedSamples=[rejectedSamples; VrejectAbsPosition+(ilevel-1)*(obj.NumberOfChains-1)*obj.NumberOfChains + obj.InitialSamples]; %#ok<AGROW>
            
            % Update the vector of the performance function Please note that the MarkovChain object
            % does not store any information of the performance function
            Vg_temp(Vreject)=subsetPerformances(VrejectAbsPosition);
            
            % Identify current set of samples
            Vposition=(iBuildChain-1)*obj.NumberOfChains+1:iBuildChain*obj.NumberOfChains;
            % Update Vg_subset and the corresponding samples MU
            subsetPerformances(Vposition)=Vg_temp;
            
            if ~isempty(Vreject)
                % Remove points from Markov Chain
                markovChains = markovChains.reject('chains', Vreject);
                initial{Vposition, names} = markovChains.ChainEnd{:,:};
            end
            
            % Store the number of rejected samples
            rejection = rejection+length(Vreject);
            
            % Collect results
            gAllLevels = [gAllLevels; Vg_temp]; %#ok<AGROW>
            samplesAllLevels = [samplesAllLevels; markovChains.ChainEnd{:,:}]; %#ok<AGROW>
            
        end % end Markov chains
    end % end SubSet levels
    
    
    %% Compute failure probability
    % Remove not used levels
    failureProbabilities = failureProbabilities(1:ilevel);
    coefficientsOfVariation = coefficientsOfVariation(1:ilevel);
    rejectionRates = rejectionRates(1:ilevel);
    thresholds = thresholds(1:ilevel);
    
    % Compute the failure probability and the CoV
    if target.StdDeviationIndicatorFunction == 0    %in case smooth performance function is not applied, calculate Pf in usual way
        pF = prod(failureProbabilities);
    else    %in case smooth performance function is applied, calculate Pf using special formula
        p0 = obj.target_pf;  %target failure probability for each Subset
        Vweights = cumprod([1-p0,ones(1,ilevel-1)*p0]);  %compute weights associated with each Subset
        Vweights(end) = 1-sum(Vweights(1:end-1));         %correct weights to they add up to one
        pF = 0;    %initialize failure probability to zero
        for countLevel=1:ilevel
            gFSmoothInd     = normcdf(-performances{countLevel}, 0, ...
                target.StdDeviationIndicatorFunction);  %smooth indicator function
            pF = pF + mean(gFSmoothInd) * Vweights(countLevel);    %compute contribution to pF of each Subset
        end
    end
    covpF = sqrt( sum( coefficientsOfVariation.^2 ));
    
    pf = FailureProbability('value', pF, 'variance', covpF^2*pF^2, 'simulationdata', simData, 'simulation', obj);
    
    if ~isdeployed
        % add entries in simulation and analysis database at the end of the computation when not
        % deployed. The deployed version does this with the finalize command
        XdbDriver = opencossan.OpenCossan.getDatabaseDriver;
        if ~isempty(XdbDriver)
            XdbDriver.insertRecord('StableType','Result',...
                'Nid',getNextPrimaryID(opencossan.OpenCossan.getDatabaseDriver,'Result'),...
                'CcossanObjects',{Xpf},...
                'CcossanObjectsNames',{'Xpf'});
        end
    end
    
    opencossan.OpenCossan.getTimer().lap('description','End computeFailureProbability@SubsetOrigin');
    
    % Restore Global Random Stream
    restoreRandomStream(obj);
end

function [samples, sns] = initialSamples(obj, input)
    % INITIALSAMPLES Creates the intial samples for subset simulation in standard normal space and
    % maps them to the physical space.
    
    nrv = 0;
    names = [];
    for set = input.RandomVariableSets
        nrv = nrv + set.Nrv;
        names = [names set.Names];
    end
    
    nrv = nrv + input.NumberOfRandomVariables;
    names = [names input.RandomVariableNames];
    
    sns = randn(obj.InitialSamples, nrv);
    samples = array2table(sns);
    samples.Properties.VariableNames = names;
    
    samples = map2physical(input, samples);
    samples = input.addParametersToSamples(samples);
    samples = input.evaluateFunctionsOnSamples(samples);
end

function [pf, g] = intermediateFailureProbability(obj, performances, threshold)
    if threshold <= 0
        % Final failure has been reached
        pf = sum(performances <= 0) / obj.InitialSamples;
        g = performances;
    else
        pf = sum(performances <= threshold) / obj.InitialSamples;
        g  = performances(performances > threshold);
    end
end

function cov = coefficientOfVariation(obj, level, performances, threshold, pf)
    if level == 1
        % Monte Carlo CoV
        cov = sqrt((1 - pf) / (pf * obj.InitialSamples ));  %Eq. (28)
    else
        % Correlation of the states of the markov chain
        g = reshape(performances ...
            (end - obj.SamplesPerChain * obj.NumberOfChains + 1:end), ...
            [], obj.SamplesPerChain);
        gIndicator = g < threshold;
        correlation = zeros(obj.NumberOfChains, obj.SamplesPerChain);
        
        for isample=1:obj.NumberOfChains
            v = gIndicator(isample,:);
            for deltak = 0:obj.SamplesPerChain-1
                v1 = v(1:end-deltak);
                v2 = v(1+deltak:end);
                correlation(deltak+1,isample) = (1/length(v1))*sum(v1.*v2);
            end
        end % end correlation estimation
        
        %Eq. (25)
        VIcorr = sum(correlation,2) / obj.NumberOfChains - pf^2;
        
        % Eq. 27
        Vrho = VIcorr / VIcorr(1);
        gammal = 2*sum((1-(1:obj.SamplesPerChain-1)* ...
            obj.NumberOfChains / obj.InitialSamples).* ...
            Vrho(1:obj.SamplesPerChain-1)');
        % Eq. 28
        cov = sqrt((1 - pf) / (pf * obj.InitialSamples) * (1 + gammal));
    end
end
