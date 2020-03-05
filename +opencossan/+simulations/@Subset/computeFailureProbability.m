function pf = computeFailureProbability(obj, model)
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
    import opencossan.common.MarkovChain
    import opencossan.simulations.SubsetData
    import opencossan.reliability.FailureProbability
    
   
    %%  Initialize variables
    rejection = 0;
    
    % Preallocate memory
    failureProbabilities = zeros(obj.MaxLevels, 1); % Failure Probability of each level
    coefficientsOfVariation = zeros(obj.MaxLevels, 1); % CoV of the Pf of each level
    thresholds = zeros(obj.MaxLevels, 1); % Threshould of each level
    performances = cell(obj.MaxLevels, 1);  % Value of performance function at each level
    rejectionRates = zeros(obj.MaxLevels, 1); % rejection rate each level
    
    % The samples are gerenated in the standard normal space and automatically mapped in the
    % physical space
    initial = initialSamples(obj, model.Input);
    
    simData = opencossan.common.outputs.SimulationData();
    
    simDataLevel = apply(model, initial);    % Evaluate the model
    simDataLevel.Samples.Level = ones(obj.InitialSamples, 1);
    subsetPerformances = simDataLevel.Samples.(model.PerformanceFunctionVariable);
    
    opencossan.OpenCossan.cossanDisp('Initial samples generated and evaluated',3)
    
    %% Level of Subset simulations
    for	level = 1:obj.MaxLevels
        opencossan.OpenCossan.cossanDisp(sprintf("\n[Subset] Level %i/%i", level, obj.MaxLevels), 3)
        
        simData = simData + simDataLevel;
        
        % Sort performances
        [sortedPerformances, performanceIndices] = sort(subsetPerformances);
        
        % Compute intermediary threshold level (defines) the current subset
        thresholds(level) = sortedPerformances(obj.NumberOfChains);
        [failureProbabilities(level), performances{level}] = ...
            intermediateFailureProbability(obj, sortedPerformances, thresholds(level));
        
        % Compute the CoV for this level
        coefficientsOfVariation(level) = coefficientOfVariation(obj, level, ...
            subsetPerformances, thresholds(level), failureProbabilities(level));
        
        if obj.KeepSeeds
            rejectionRates(level) = rejection/(length(subsetPerformances) - obj.NumberOfChains);
        else
            rejectionRates(level) = rejection/(length(subsetPerformances));
        end
        
        opencossan.OpenCossan.cossanDisp(sprintf("[Subset] Estimated pf < %d", prod(failureProbabilities(1:level))), 3);
        opencossan.OpenCossan.cossanDisp(sprintf(...
            "[Subset] Performance Function = %d, Failure probability = %d", thresholds(level), ...
            failureProbabilities(level)), 3);
        opencossan.OpenCossan.cossanDisp(sprintf(...
            "[Subset] CoV = %d, Rejection rate = %d", coefficientsOfVariation(level), ...
            rejectionRates(level)), 3);
        
        if thresholds(level) <= 0
            % Stop the simulation once failure has been estimated
            opencossan.OpenCossan.cossanDisp("[Subset] Failure region identified", 3);
            simData.ExitFlag = "Failure region identified";
            break;
        elseif level == obj.MaxLevels
            % Skip MCMC in the last level
            simData.ExitFlag = "Maximum number of levels reached.";
            continue;
        end
        
        seeds = simDataLevel.Samples(performanceIndices(1:obj.NumberOfChains), :);
        [subsetPerformances, simDataLevel, rejection] = obj.nextLevelSamples(level, thresholds(level), seeds, model);
    end
    
    %% Compute failure probability
    failureProbabilities = failureProbabilities(1:level);
    coefficientsOfVariation = coefficientsOfVariation(1:level);
    rejectionRates = rejectionRates(1:level);
    thresholds = thresholds(1:level);
    
    % Compute the failure probability and the CoV
    if model.StdDeviationIndicatorFunction == 0    %in case smooth performance function is not applied, calculate Pf in usual way
        pF = prod(failureProbabilities);
    else    %in case smooth performance function is applied, calculate Pf using special formula
        p0 = obj.target_pf;  %target failure probability for each Subset
        Vweights = cumprod([1-p0,ones(1,level-1)*p0]);  %compute weights associated with each Subset
        Vweights(end) = 1-sum(Vweights(1:end-1));         %correct weights to they add up to one
        pF = 0;    %initialize failure probability to zero
        for countLevel=1:level
            gFSmoothInd = normcdf(-performances{countLevel}, 0, ...
                model.StdDeviationIndicatorFunction);  %smooth indicator function
            pF = pF + mean(gFSmoothInd) * Vweights(countLevel);    %compute contribution to pF of each Subset
        end
    end
    covpF = sqrt( sum( coefficientsOfVariation.^2 ));
    
    simData = SubsetData('failureprobabilities', failureProbabilities, ...
        'covs', coefficientsOfVariation, ...
        'rejectionrates', rejectionRates, ...
        'thresholds', thresholds, ...
        'samples', simData.Samples, ...
        'exitflag', simData.ExitFlag);
    
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

function samples = initialSamples(obj, input)
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
        cov = sqrt((1 - pf) / (pf * obj.InitialSamples));  %Eq. (28)
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
