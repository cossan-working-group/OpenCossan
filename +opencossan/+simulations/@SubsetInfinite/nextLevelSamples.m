function [subsetPerformances, samples, rejection, simDataLevel] = nextLevelSamples(obj, level, threshold, seeds, model)
    
    seeds = repmat(seeds, obj.SamplesPerChain, 1);
    samples = seeds;
    subsetPerformances = seeds.(model.PerformanceFunctionVariable);
    
    if obj.UpdateStd
        simDataLevel = opencossan.common.outputs.SimulationData();
        
        seedsInStdNorm = model.Input.map2stdnorm(seeds);
        
        adaptAfterNsamples = floor(0.15*obj.NumberOfChains); %factor between 0.1 and 0.2
        scaleParamLambda = 0.6;
        optimalAcceptance = 0.44;
        
        %mean and variance across all seeds
        adaptVariance = var(seedsInStdNorm{1:obj.NumberOfChains,:});
        
        %change seed order randomly
        changeSeedOrder = randperm(obj.NumberOfChains);
        
        updateDistrib = abs(floor(obj.NumberOfChains/adaptAfterNsamples));
        proposedSamples = nan(size(seedsInStdNorm));
        g_newSamples = nan(height(seedsInStdNorm),1);
        
        for iter=1:updateDistrib
            % scaling parameters
            adaptsigma = min(1,scaleParamLambda.*sqrt(adaptVariance));
            scaleParamRho = sqrt(1 - (adaptsigma.^2));
            
            if iter == updateDistrib
                iterChains = ((iter-1)*adaptAfterNsamples + 1):obj.NumberOfChains;
            else
                iterChains = ((iter-1)*adaptAfterNsamples + 1):(iter*adaptAfterNsamples);
            end
            
            %updated mean and standard deviation
            means = scaleParamRho .* seedsInStdNorm{changeSeedOrder(iterChains),:};
            levelStd = sqrt(1 - scaleParamRho.^2);
            levelStd = repmat(levelStd, [size(means,1),1]);
            
            %create new samples
            currentSamples = nan(numel(iterChains)*(height(seeds)/obj.NumberOfChains),size(proposedSamples,2));
            for sc = 1:(height(seeds)/obj.NumberOfChains)
                tempSamples = normrnd(means,levelStd);
                currentSamples(sc:(height(seeds)/obj.NumberOfChains):((numel(iterChains)-1)*(height(seeds)/obj.NumberOfChains) + sc),:) = tempSamples;
                proposedSamples(changeSeedOrder(iterChains) + obj.NumberOfChains*(sc - 1),:) = tempSamples;
                absPositionSamples(sc:(height(seeds)/obj.NumberOfChains):((numel(iterChains)-1)*(height(seeds)/obj.NumberOfChains) + sc),1) = changeSeedOrder(iterChains) + obj.NumberOfChains*(sc - 1);
            end
            
            currentSamples = array2table(currentSamples);
            currentSamples.Properties.VariableNames = seedsInStdNorm.Properties.VariableNames;
            
            currentSamples = model.Input.map2physical(currentSamples);
            currentSamples = model.Input.addParametersToSamples(currentSamples);
            currentSamples = model.Input.evaluateFunctionsOnSamples(currentSamples);
            
            % Evaluate the model
            currentSimData = model.apply(currentSamples);
            currentSimData.Samples.Level = repmat(level + 1, height(currentSimData.Samples), 1);
            simDataLevel = simDataLevel + currentSimData;
            
            % Get the new values of the performance function
            currentPerformance = currentSimData.Samples.(model.PerformanceFunctionVariable);
            g_newSamples(absPositionSamples) = currentPerformance;
            samples(absPositionSamples, :) = currentSimData.Samples;
            
            %average accpetance rate per chain
            numberAccepted = currentPerformance <= threshold;
            numberAccepted = sum(reshape(numberAccepted,(height(seeds)/obj.NumberOfChains),[]),1)./(height(seeds)/obj.NumberOfChains);
            
            %average acceptance rate
            averageAcceptance = sum(numberAccepted) / numel(iterChains);
            %update scale parameter lambda
            scaleParamLambda = exp(log(scaleParamLambda) + (iter^(-0.5)) * (averageAcceptance - optimalAcceptance));
        end
        
        
        % Identify the samples that have to be rejected. The rejecte points corresponds to the
        % samples whose performance function value is below the subset value (the removed states are
        % set equal to the previous ones)
        accepted = g_newSamples <= threshold;
        
        % Update the vector of the performance function
        subsetPerformances(accepted) = g_newSamples(accepted);
        
        % Store the number of rejected samples
        rejection = sum(~accepted);
    else
        if length(obj.ProposalStd) >= level
            levelStd = obj.ProposalStd(level);
        else
            levelStd = obj.ProposalStd(end);
        end
        
        % Compute means of the Gaussian vector used to generate new samples.
        % a=sqrt(1-currentVariance); Here the same variance is used for each component.
        seedsInStdNorm = model.Input.map2stdnorm(seeds);
        
        means = sqrt(1 - levelStd.^2) .* seedsInStdNorm{:,:};
        
        % Generate candidate solutions normrnd takes as input mean and standard deviation. Hence the
        % new samples are generate from a Gaussian vector with independent components with means
        % vector Mmeans and std std=\sqrt(s_i^2)=\sqrt(currentVariance.^2)=currentStd
        
        proposedSamples = array2table(normrnd(means, levelStd));
        proposedSamples.Properties.VariableNames = seedsInStdNorm.Properties.VariableNames;
        
        proposedSamples = model.Input.map2physical(proposedSamples);
        proposedSamples = model.Input.addParametersToSamples(proposedSamples);
        proposedSamples = model.Input.evaluateFunctionsOnSamples(proposedSamples);
        
        % Evaluate the model
        simDataLevel = model.apply(proposedSamples);
        simDataLevel.Samples.Level = repmat(level + 1, height(simDataLevel.Samples), 1);
        
        levelPerformance = simDataLevel.Samples.(model.PerformanceFunctionVariable);
        
        accepted = levelPerformance <= threshold;

        subsetPerformances(accepted) = levelPerformance(accepted);
        samples(accepted, :) = simDataLevel.Samples(accepted, :);
        
        % Store the number of rejected samples
        rejection = sum(~accepted);
    end
end