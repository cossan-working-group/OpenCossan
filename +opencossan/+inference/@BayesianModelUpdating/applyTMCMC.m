function [samplesOut, log_fD] = applyTMCMC(XBayes)
%% Transitional Markov Chain Monte Carlo
%
% This program implements a method described in:
% Ching, J. and Chen, Y. (2007). "Transitional Markov Chain Monte Carlo
% Method for Bayesian Model Updating, Model Class Selection, and Model
% Averaging." J. Eng. Mech., 133(7), 816-832.
% ------------------------------------------------------------------------
% who                    when         observations
%--------------------------------------------------------------------------
% Diego Andres Alvarez   Jul-24-2013  First algorithm
%--------------------------------------------------------------------------
% Diego Andres Alvarez - daalvarez@unal.edu.co

% We will assume in this algorithm that N0 = N1 = ... = Nm




    %% Number of cores, Not sure how to do this with openCossan's jobManager
    if ~isempty(gcp('nocreate'))
        pool = gcp;
        Ncores = pool.NumWorkers;
        fprintf('TMCMC isamples_fT_Ds running on %d cores.\n', Ncores);
    end


    %% Initialise properties from the XBayes object
    %Taking properties from the BayesianModelUpdating object
    Prior = XBayes.Prior;
    log_fD_T = XBayes.XLog;
    N = XBayes.Nsamples;
    samplesOut = opencossan.common.outputs.SimulationData;
    
    fprintf('Nsamples TMCMC = %d\n', N);
    
    %Prior Evaluation and Sampling function handles
    fT = @(x)Prior.evalpdf('Mxsamples',x);
    sample_from_fT = @(N) get(Prior.sample('Nsamples', N),'MsamplesPhysicalSpace');

    beta = 0.2; %<-- I think this is a paramter for the gaussian. <--Eq.17 used as the scaling factor in the covarience matrix
    S    = ones(1,50); %<-- read paper for more clarity, it is a vector of the mean wieghts in every step?? Eq.15
    with_replacement = true; % DO NOT CHANGE!!!
    plot_graphics    = XBayes.PlotGraphics;
    burnin           = 20;
    lastburnin       = 20;  % burnin in the last iteration

    %% Obtain N samples from the prior pdf f(T)
    j      = 0;
    thetaj = sample_from_fT(N);  % theta0 = N x D (these are the samples, initially just the prior, uniform in many cases)
    pj     = 0;                  % p0 = 0 (initial tempering parameter)
    D      = size(thetaj, 2);    % size of the vector theta

    %% Initialization of matrices and vectors
    thetaj1   = zeros(N, D);

    %This is just for visualisation, the -2 here must be changed to
    %length of Cinputnames - the total number of dimenstions on the outputSpace
    ext = zeros(9900,length(thetaj(1,:))-2);
    
    names = strcat(XBayes.Coutputnames,'_',num2str(j));
    samplesOut = samplesOut.addVariable('Cnames',names,'Mvalues',thetaj);
    
    %% Main loop
    while pj < 1
        %% Plot the sampled points
        if (plot_graphics)
            figure
            plot(thetaj(:,1), thetaj(:,2), 'b.');
            hold on;
            ax = axis;
            [xx, yy] = meshgrid(linspace(ax(1),ax(2),100), linspace(ax(3), ax(4), 99));
            if j == 0
                zz = reshape(fT([xx(:) yy(:) ext]), 99, 100);
                o=0;
            else
                zz = reshape(fj1([xx(:) yy(:) ext]), 99, 100);
                o=pj1;
            end
            contour(xx, yy, zz, 50);
            grid on;
            title(sprintf(...
                'Samples from transition pdf with Pj={%d}',o));
%             title(sprintf(...
%                 'Samples of f_{%d} and contour levels of f_{%d} (red) and f_{%d} (black)', ...
%                 j, j, j+1));
            drawnow
%             
%             figure
%             surf(xx,yy,zz);
            
          
        end;

        j = j+1;

        %% Calculate the tempering parameter p(j+1):
        log_fD_T_thetaj = log_fD_T.apply(thetaj);
        if any(isinf(log_fD_T_thetaj))
            error('The prior distribution is too far from the true region');
        end
        pj1 = calculate_pj1(log_fD_T_thetaj, pj);
        fprintf('TMCMC: Iteration j = %2d, pj1 = %f\n', j, pj1);
  
        %% Compute the plausibility weight for each sample wrt f_{j+1}
        fprintf('Computing the weights ...\n');
        % wj     = fD_T(thetaj).^(pj1-pj);         % N x 1 (eq 12)
        a       = (pj1-pj)*log_fD_T_thetaj;
        wj      = exp(a); %<- the log likelyhood is passed, the wieghts are 
        %calculated from the difference between the likelyhoods (no log) for
        %the two transitional steps (pj1-pj). It is a indication by how much
        %the likelyhood function is represenatative of the data. This is then
        %reflected in pj1.
        wj_norm = wj./sum(wj);                % normalization of the weights

        %% Compute S(j) = E[w{j}] (eq 15)
        S(j) = mean(wj);

        %% Do the resampling step to obtain N samples from f_{j+1}(theta) and
        % then perform Metropolis-Hastings on each of these samples using as a
        % stationary PDF "fj1"
        % fj1 = @(t) fT(t).*log_fD_T(t).^pj1;   % stationary PDF (eq 11) f_{j+1}(theta)
        log_fj1 = @(t) log(fT(t)) + pj1*log_fD_T.apply(t);

        if (plot_graphics)
            % In the definition of fj1 we are including the normalization
            % constant prod(S(1:j))
            fj1 = @(t) exp(log(fT(t)) + pj1*log_fD_T.apply(t)); %- sum(log(S(1:j))));
%              zz = reshape(fj1([xx(:) yy(:) ext]), 99, 100);
%             contour(xx, yy, zz, 50, 'k');
            drawnow
        end

        % and using as proposal PDF a Gaussian centered at thetaj(idx,:) and
        % with covariance matrix equal to an scaled version of the covariance
        % matrix of fj1:

        % weighted mean
        mu = zeros(1, D);
        for l = 1:N
            mu = mu + wj_norm(l)*thetaj(l,:); % 1 x N
        end

        % scaled covariance matrix of fj1 (eq 17)
        cov_gauss = zeros(D);
        for k = 1:N
            % this formula is slightly different to eq 17 (the transpose)
            % because of the size of the vectors)m and because Ching and Chen
            % forgot to normalize the weight wj:
            tk_mu = thetaj(k,:) - mu;
            cov_gauss = cov_gauss + wj_norm(k)*(tk_mu'*tk_mu);
        end
        cov_gauss = beta^2 * cov_gauss;
        assert(~isinf(cond(cov_gauss)),'Something is wrong with the likelihood.')
        % proposal distribution
        proppdf = @(x,y) problemA_proppdf(x, y, cov_gauss, fT); %q(x,y) = q(x|y).
        proprnd = @(x)   problemA_proprnd(x, cov_gauss, fT);    %mvnrnd(x, cov_gauss, 1);

        %% During the last iteration we require to do a better burnin in order
        % to guarantee the quality of the samples:
        if pj1 == 1
            burnin = lastburnin;
        end;

        %% Start N different Markov chains
        fprintf('Markov chains ...\n\n');
        idx = randsample(N, N, with_replacement, wj_norm);
        for i = 1:N
        %% Sample one point with probability wj_norm
        
        % smpl = mhsample(start, nsamples,
        %                'pdf', pdf, 'proppdf', proppdf, 'proprnd', proprnd);
        % start = row vector containing the start value of the Markov Chain,
        % nsamples = number of samples to be generated
        [thetaj1(i,:), acceptance_rate] = mhsample(thetaj(idx(i), :), 1, ...
            'logpdf',  log_fj1, ...
            'proppdf', proppdf, ...
            'proprnd', proprnd, ...
            'thin',    3,       ...
            'burnin',  burnin);
            % this works only because we are generating only one samples from 
            % each chain
            %thetaj1(idx==i,:) = squeeze(chains)';         
            % According to Cheung and Beck (2009) - Bayesian model updating ...,
            % the initial samples from reweighting and the resample of samples of
            % fj, in general, do not exactly follow fj1, so that the Markov
            % chains must "burn-in" before samples follow fj1, requiring a large
            % amount of samples to be generated for each level.

            %% Adjust the acceptance rate (optimal = 23%)
            % See: http://www.dms.umontreal.ca/~bedard/Beyond_234.pdf <READ
            %{
          if acceptance_rate < 0.3
             % Many rejections means an inefficient chain (wasted computation
             %time), decrease the variance
             beta = 0.99*beta;
          elseif acceptance_rate > 0.5
             % High acceptance rate: Proposed jumps are very close to current
             % location, increase the variance
             beta = 1.01*beta;
          end
            %}
            %fprintf('Done Iteration!!!!!! %d\n                  %d \n\n',i,pj1);
        end
        fprintf('\n');

        %% Prepare for the next iteration
        thetaj = thetaj1;
        pj     = pj1;
        names = strcat(XBayes.Coutputnames,'_',num2str(j));
        samplesOut = addVariable(samplesOut,'Cnames',names,'Mvalues',thetaj);
        
    end
    samplesOut = addVariable(samplesOut,'Cnames',XBayes.Coutputnames,'Mvalues',thetaj);

return



%% Calculate the tempering parameter p(j+1)
function pj1 = calculate_pj1(log_fD_T_thetaj, pj)

%This is some optimization problem

% find pj1 such that COV <= threshold, that is
%
%  std(wj)
% --------- <= threshold
%  mean(wj)
%
% here
% size(thetaj) = N x D,
% wj = fD_T(thetaj).^(pj1 - pj)
% e = pj1 - pj

threshold = 1; % 100% = threshold on the COV

% wj = @(e) fD_T_thetaj^e; % N x 1
% Note the following trick in order to calculate e:
% Take into account that e>=0
wj = @(e) exp(abs(e)*log_fD_T_thetaj); % N x 1
%fmin = @(e) std(wj(e))/mean(wj(e)) - threshold;
fmin = @(e) std(wj(e)) - threshold*mean(wj(e)) + realmin;
e = abs(fzero(fmin, 0)); % e is >= 0, and fmin is an even function
if isnan(e)
    error('There is an error finding e');
end

pj1 = min(1, pj + e);

% 
% figure
% p = linspace(0,0.3,10000);
% hold on
% plot(p, arrayfun(fmin, p));
% plot(e,0,'rx');
% grid minor;
% 

return; % bye, bye

function y = problemA_proppdf(x, mu, covmat, box)
% Proposal PDF for the Markov Chain.
% Take into account that for problem A, box is the uniform PDF in the
% feasible region. So if a point is out of bounds, this function will
% return 0.
y = mvnpdf(x, mu, covmat).*box(x); %q(x,y) = q(x|y).
return;


function t = problemA_proprnd(mu, covmat, box)
% Sampling from the proposal PDF for the Markov Chain.
while true
    t = mvnrnd(mu(1,:), covmat, size(mu,1));
    if box(t)
        % For problem A, box is the uniform PDF in the feasible region. So if
        % a point is out of bounds, this function will return 0 = false
        break;
    end
end

return
