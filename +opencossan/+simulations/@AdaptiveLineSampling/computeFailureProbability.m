function pf = computeFailureProbability(obj, model)
    % COMPUTEFAILUREPROBABILITY method. This method compute the
    % FailureProbability associate to a ProbabilisticModel/SystemReliability/MetaModel
    % by means of the AdvancedLineSampling object
    %
    % See also:
    % https://cossan.co.uk/wiki/index.php/computeFailureProbability@AdaptiveLineSampling
    %
    % Author: Marco de Angelis and Edoardo Patelli
    % Institute for Risk and Uncertainty, University of Liverpool, UK
    
    import opencossan.OpenCossan
    import opencossan.simulations.LineSamplingData
    import opencossan.reliability.FailureProbability
    import opencossan.sensitivity.*
    
    obj = obj.initialize();
    
    % Compute alpha on demand if it was not given
    if isempty(obj.Alpha)
        OpenCossan.cossanDisp("[AdaptiveLineSampling] Computing important direction", 3);
        
        lsfd = LocalSensitivityFiniteDifference('Xmodel', model, ...
            'Coutputname', model.PerformanceFunctionVariable);
        
        localSensitivity = lsfd.computeGradientStandardNormalSpace();
        
        % The performance function decreases towards failure
        obj.Alpha = -localSensitivity.Valpha;
    end
    
    % Make sure the important direction is a column vector
    obj.Alpha = obj.Alpha ./ norm(obj.Alpha);
    
    if ~isempty(obj.RandomStream)
        prevstream = RandStream.setGlobalStream(obj.RandomStream);
    end
    
    %% Initialize
    alpha = obj.Alpha;
    k = zeros(obj.NumberOfLines, 1);
    
    u = randn(model.Input.NumberOfRandomInputs, obj.NumberOfLines);
    u = u - alpha * (alpha' * u);
    
    k(1) = getNextLineIndex(u, []);
    
    pfLines = zeros(obj.NumberOfLines, 1);
    
    %% Find c0
    cBase = fzero(@(c) evaluatePointOnLine(c, zeros(size(alpha')), alpha', model), 0);
    c0 = cBase;
    
    for i = 1:obj.NumberOfLines        
        cstar = fzero(@(c) evaluatePointOnLine(c, u(:, k(i))', alpha', model), c0);
        pfLines(i) = normcdf(-1 * cstar);
        
        if i < obj.NumberOfLines
            k(i + 1) = getNextLineIndex(u, k, i);
            c0 = cstar;
            
            candidate = norm(u(:, k(i)) + cstar * alpha);
            if candidate < cBase
                cBase = candidate;
                alpha = (u(:, k(i)) + cstar * alpha) / cBase;
                fmt = ['[AdaptiveLineSampling] Updated alpha to: [' , ...
                    repmat('%g, ', 1, numel(alpha)-1), '%g]\n'];
                fprintf(fmt, alpha);
            end
        end
    end
    
    fprintf("[AdaptiveLineSampling] Final c0: %g\n", cBase);
    
    pf = mean(pfLines);
    variance = sum((pfLines-pf).^2)/(obj.NumberOfLines*(obj.NumberOfLines-1));
    
    pf = opencossan.reliability.FailureProbability('value', pf, 'variance', variance, ...
        'simulation', obj, 'simulationdata', opencossan.common.outputs.SimulationData());
    
    if ~isempty(obj.RandomStream)
        RandStream.setGlobalStream(prevstream);
    end
    
end

function c = evaluatePointOnLine(c, u, alpha, model)
    samples = array2table(u + c * alpha);
    samples.Properties.VariableNames = model.Input.RandomInputNames;
    
    samples = model.Input.map2physical(samples);
    samples = model.Input.addParametersToSamples(samples);
    samples = model.Input.evaluateFunctionsOnSamples(samples);
    
    out = model.apply(samples);
    
    c = out.Samples.(model.PerformanceFunctionVariable);
end

function k = getNextLineIndex(u, k, i)
    if isempty(k)
        uk = zeros(size(u, 1), 1);
    else
        uk = u(:, k(i));
    end
    
    distances = sqrt(sum((u - uk).^2,1));
    distances(ismember(1:size(u, 2), k)) = Inf;
    
    [~, k] = sort(distances);
    k = k(1);
end