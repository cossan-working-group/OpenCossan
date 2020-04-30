function [pf, beta, betaOpt] = computeFailureProbability(obj, model)
    %Compute the FailureProbability
    %This method return the FailureProbability value associated to the
    %
    % See also:
    % https://cossan.co.uk/wiki/index.php/computeFailureProbability@Simulation
    %
    % Author: Silvia Tolo
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
    
    input = model.Input;
    names = input.RandomInputNames;
    dim = input.NumberOfRandomInputs;
    
    p0 = 1e-6;
    beta = sqrt(chi2inv(1-p0, dim));
    betaOpt = beta^2;
    
    rngOriginal = rng();
    
    cache = double.empty(0, dim + 1);
    
    % Dummy sample table
    sample = array2table(zeros(1, dim));
    sample.Properties.VariableNames = names;
    
    % Evaluate limit state value in origin
    origin = input.completeSamples(input.map2physical(sample));
    simData = model.apply(origin);
    g0 = simData.Samples.(model.PerformanceFunctionVariable);
    
    nsim = 0;
    nfail = 0;
    exit = false;
    
    while ~exit       
        % Sample in sns space
        u = randn(1, dim);
        b = norm(u);
        
        if b < beta
            % Continue to next sample if inside beta sphere
            continue;
        end
        
        if any(all(cache(:, 1:dim) == u, 2))
            continue;
        end
        
        nsim = nsim + 1;
        
        sample{:,:} = u;
        out = model.apply(input.completeSamples(input.map2physical(sample)));
        simData.Samples = [simData.Samples; out.Samples];
        
        g = out.Samples.(model.PerformanceFunctionVariable);
        
        cache(end + 1, :) = [u, g < 0]; %#ok<AGROW>
        
        if  g < 0 % Point inside failure domain
            nfail = nfail + 1;
            
            if b > betaOpt
                [pf, cov, exit, ~] = checkConvergance(obj, nfail, nsim, beta, dim);
                continue;
            end
            
            % Line search to update beta (maximum of 5 iterations)
            x = [0, b];
            y = [g0, g];
            line = @(z) interp1(x, y, z, 'linear');
            betaOpt = fzero(line, x);
            
            sample{:,:} = betaOpt/b * u;
            physical = input.completeSamples(input.map2physical(sample));
            
            out = model.apply(physical);
            gb = out.Samples.(model.PerformanceFunctionVariable);
            
            x = [x(1) betaOpt x(2)];
            y = [y(1) gb y(2)];
            
            while numel(x) <= 5
                curve = @(z) interp1(x, y, z, 'spline');
                newBeta = fzero(curve, betaOpt);
                deltaBeta = abs(newBeta - betaOpt);
                
                betaOpt = newBeta;
                
                if deltaBeta < 0.01
                    break;
                end

                sample{:,:} = betaOpt/b * u;
                physical = input.completeSamples(input.map2physical(sample));

                out = model.apply(physical);
                gb = out.Samples.(model.PerformanceFunctionVariable);
                
                x(end+1) = betaOpt; %#ok<AGROW>
                y(end+1) = gb; %#ok<AGROW>
                
                [x, idx] = sort(x, 'ascend');
                y = y(idx);
            end
            
            p0 = 1 - chi2cdf(betaOpt^2, dim);
            beta = sqrt(chi2inv(1 - p0/0.8, dim));
            
            fprintf("[ARBIS] Updated betaOpt: %f\n", betaOpt);
            fprintf("[ARBIS] Updated beta: %f\n", beta);
            
            [pf, cov, exit, ~] = checkConvergance(obj, nfail, nsim, beta, dim);
            
            rng(rngOriginal);
        else
            [pf, cov, exit, ~] = checkConvergance(obj, nfail, nsim, beta, dim);
            continue;
        end
    end
    
    pf = opencossan.reliability.FailureProbability('value', pf, 'variance', cov^2 * pf^2, ...
        'simulationdata', simData, 'simulation', obj);
    
    fprintf("[ARBIS] Final betaOpt: %f\n", betaOpt);
    fprintf("[ARBIS] Final beta: %f\n", beta);
end

function [pf, cov, exit, flag] = checkConvergance(obj, nfail, nsim, beta, n)   
    pfCond = nfail/nsim;
    p0 = 1 - chi2cdf(beta^2, n);
    pf = pfCond * p0;
    
    cov = sqrt((1 - pfCond) / nfail);
    
    [exit, flag] = obj.checkTermination('cov', cov);
end