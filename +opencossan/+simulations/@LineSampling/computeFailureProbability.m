function pf = computeFailureProbability(obj, model)
    %computeFailureProbability method. This method compute the FailureProbability associate to a
    % ProbabilisticModel/SystemReliability/MetaModel by means of a LineSampling object
    %
    % See also: https://cossan.co.uk/wiki/index.php/computeFailureProbability@LineSampling
    %
    % Author: Edoardo Patelli and Marco de Angelis Institute for Risk and Uncertainty, University of
    % Liverpool, UK email address: openengine@cossan.co.uk Website: http://www.cossan.co.uk
    
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
    
    import opencossan.OpenCossan
    import opencossan.simulations.LineSamplingOutput
    import opencossan.reliability.FailureProbability
    import opencossan.sensitivity.*
    
    obj = obj.initialize();
    
    % Compute alpha on demand if it was not given
    if isempty(obj.Alpha)
        OpenCossan.cossanDisp("[LineSampling] Computing important direction", 3);
        
        lsfd = LocalSensitivityFiniteDifference('Xmodel', model, ...
            'Coutputname', model.PerformanceFunctionVariable);
        
        localSensitivity = lsfd.computeGradientStandardNormalSpace();
        
        % The performance function decreases towards failure
        obj.Valpha= -localSensitivity.Valpha;
    end
    
    % Make sure the important direction is a column vector
    obj.Alpha = obj.Alpha ./ norm(obj.Alpha);
    
    simData = opencossan.common.outputs.SimulationData();
    batch = 0;
    pf = 0;
    variance = 0;
    
    if ~isempty(obj.RandomStream)
        prevstream = RandStream.setGlobalStream(obj.RandomStream);
    end
    
    %% BEGIN LineSampling simulation
    while true
        % Reset Variables
        batch = batch + 1;
        
        opencossan.OpenCossan.cossanDisp(...
            sprintf("[LineSampling] Batch #%i (%i lines)", batch, obj.NumberOfLines), 3);
        
        %% Simulation with standard Line sampling
        % Standard LineSampling uses a fixed direction and a fixed grid of points (Vset) where the
        % performance function is evaluated.
        
        % Gererate all samples at once
        samples = obj.sample('input', model.Input);
        
        % Evaluate the model
        XpartialSimOut= apply(model, samples);
        XpartialSimOut.Samples.Batch = repmat(batch, XpartialSimOut.NumberOfSamples, 1);
        
        simData = simData + XpartialSimOut;
        
        % Extract the values of the performance function
        Vg = XpartialSimOut.Samples.(model.PerformanceFunctionVariable);
        Mg = reshape(Vg, length(obj.PointsOnLine), obj.NumberOfLines);
        
        % Compute coordinates of points on the hyperplane
        %     Msamples = model.Input.map2stdnorm(samples); Msamples = Msamples{:,:};
        
        pfLine = zeros(1, obj.NumberOfLines);
        distanceLimitState = zeros(1, obj.NumberOfLines);
        numPointsLine = zeros(1, obj.NumberOfLines);
        
        distancePlaneFine = linspace(min(obj.PointsOnLine), max(obj.PointsOnLine), obj.NumberOfInterpolationPoints)';
        
        % Process lines
        for iLine = 1:obj.NumberOfLines
            
            % Interpolate for better accuracy
            VgFine  = interp1(obj.PointsOnLine, Mg(:,iLine), distancePlaneFine, 'spline');
            
            [~,indexRoot] = min(abs(VgFine));
            if min(VgFine) > 0 % line is all in the survival domain
                distanceLimitState = Inf;
                opencossan.OpenCossan.cossanDisp(...
                    sprintf("[LineSampling] Line %i is entirely in the survival domain.", ...
                    iLine), 3);
                
            elseif max(VgFine) < 0 % line is all in the failure domain
                distanceLimitState = -Inf;
                opencossan.OpenCossan.cossanDisp(...
                    sprintf("[LineSampling] Line %i is entirely in the failure domain.", ...
                    iLine), 3);
            else % limit state met regurarly on the positive half-space
                distanceLimitState = distancePlaneFine(indexRoot);
            end
            
            numPointsLine(iLine) = length(obj.PointsOnLine);
            
            % Compute conditional probability on the current line
            pfLine(iLine) = normcdf(-distanceLimitState);
            distanceLimitState(iLine) = distanceLimitState;
            
        end
        
        %% Compute Failure Probability
        pfhat = mean(pfLine);
        variancepf = sum((pfLine-pfhat).^2)/(obj.NumberOfLines*(obj.NumberOfLines-1));
        
        pf = (pf * (batch - 1) + pfhat) / batch;
        variance = (variance * (batch - 1) + variancepf) / batch;
        
        % check termination criteria
        [exit, flag] = checkTermination(obj, 'cov', sqrt(variance) * pf, 'batch', batch);
        if exit
            % Add termination criteria to the FailureProbability
            simData.ExitFlag = flag;
            break;
        end
    end
    
    pf = opencossan.reliability.FailureProbability('value', pf, 'variance', variance, ...
        'simulationdata', simData, 'simulation', obj);
    
    if ~isempty(obj.RandomStream)
        RandStream.setGlobalStream(prevstream);
    end
    
    if ~isdeployed
        obj.exportResult(pf);
    end
end