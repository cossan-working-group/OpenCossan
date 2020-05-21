function [performances, samples, rejection, simDataLevel] = nextLevelSamples(obj, level, threshold, seeds, model)
    
    performances = zeros(obj.SamplesPerChain * obj.NumberOfChains,1);
    performances(1:obj.NumberOfChains) = seeds.(model.PerformanceFunctionVariable);
    
    rejection = 0;
    
    % set proposal PDF
    if length(obj.DeltaXi) >= level
        deltaxi = obj.DeltaXi(level);
    else
        deltaxi = obj.DeltaXi(end);
    end
    
    opencossan.OpenCossan.cossanDisp(sprintf("[Subset] Proposal PDF: Uniform [-%f, %f]", deltaxi, deltaxi),3);
    
    markovChains = buildMarkovChains(deltaxi, seeds, model);
    
    if obj.KeepSeeds == true
        chainStart = 2;
        samples = seeds(:, ~contains(seeds.Properties.VariableNames, "Level"));
    else
        chainStart = 1;
    end
    
    simDataLevel = opencossan.common.outputs.SimulationData();
    
    for chainIndex = chainStart:obj.SamplesPerChain
        markovChains = markovChains.sample(); % add 1 new state
        
        markovChainSamples = markovChains.Samples{end};
        markovChainSamples = model.Input.completeSamples(markovChainSamples);
        
        % Evaluate perfomance function
        simDataChain = model.apply(markovChainSamples);
        
        % Merge SimulationData objectd rejected values are saved nevertheless
        simDataLevel = simDataLevel + simDataChain;
        
        % Get the new values of the performance function
        chainPerformance = simDataChain.Samples.(model.PerformanceFunctionVariable);
        
        % Perform additional rejection. All samples above the current failure threshold will be
        % rejected.
        samplesToReject = find(chainPerformance > threshold);
        if chainIndex == 1
            globalRejectionIndices = (chainIndex - 1) * obj.NumberOfChains + samplesToReject;
        else
            globalRejectionIndices = (chainIndex - 2) * obj.NumberOfChains + samplesToReject;
        end
        chainPerformance(samplesToReject) = performances(globalRejectionIndices);
        
        chainSamples = simDataChain.Samples;
        chainSamples(samplesToReject, :) = samples(globalRejectionIndices, :);
        samples = [samples; chainSamples];
        
        globalIndices = (chainIndex - 1) * obj.NumberOfChains + 1:chainIndex * obj.NumberOfChains;
        performances(globalIndices) = chainPerformance;
        
        if ~isempty(samplesToReject)
            % Remove points from Markov Chain
            markovChains = markovChains.reject('chains', samplesToReject);
        end
        
        % Store the number of rejected samples
        rejection = rejection + length(samplesToReject);
    end
    
    simDataLevel.Samples.Level = repmat(level + 1, height(simDataLevel.Samples), 1);
end

function markovChains = buildMarkovChains(deltaxi, seeds, model)
    import opencossan.common.inputs.random.RandomVariableSet
    import opencossan.common.inputs.random.UniformRandomVariable
    import opencossan.common.MarkovChain
    
    % Create Proposal distribution for the Markov Chain Different proposal distributions are created
    % for each RandomVariableSet defined in the Input object
    
    nrvsets = model.Input.NumberOfRandomVariableSets;
    if model.Input.NumberOfRandomVariables > 0
        nrvsets = nrvsets + 1;
    end
    
    %% Proposed rvsets
    proposedSets = opencossan.common.inputs.random.RandomVariableSet.empty(nrvsets, 0);
    
    names = [];
    % Add random variable sets
    for i = 1:model.Input.NumberOfRandomVariableSets
        proposedSets(i) = RandomVariableSet.fromIidRandomVariables(...
            UniformRandomVariable('bounds', [-deltaxi, deltaxi]),...
            model.Input.RandomVariableSets(i).Nrv);
        names = [names model.Input.RandomVariableSets(i).Names];
    end
    
    % If separate rvs exists add a proposal set for them as well
    if model.Input.NumberOfRandomVariables > 0
        proposedSets(end+1) = RandomVariableSet.fromIidRandomVariables(...
            UniformRandomVariable('bounds', [-deltaxi, deltaxi]),...
            model.Input.NumberOfRandomVariables);
        names = [names model.Input.RandomVariableNames];
    end
    
    %% Target rvsets
    targetSets = model.Input.RandomVariableSets;
    
    % If separate rvs exists add a target set for them as well
    if model.Input.NumberOfRandomVariables > 0
        targetSets(end+1) = RandomVariableSet('Members', model.Input.RandomVariables, ...
            'Names', model.Input.RandomVariableNames);
    end
    
    % Build MarkovCain: Initial points (seeds) are the points above the gFl(ilevel). The constructor
    % automatically generate Npoints states of the Markov Chain (The option Npoints=0 forces the
    % Markov Chain constructur to not generate new states of the chains) The samples object is used
    % to define the initial seeds
    
    initialMarkovChainSamples = seeds(:, ...
        contains(seeds.Properties.VariableNames, names));
    
    % Build Markov Chains
    markovChains = MarkovChain(...
        'TargetDistribution', targetSets, ...
        'ProposalDistribution', proposedSets, ...
        'Samples', initialMarkovChainSamples);
    
end