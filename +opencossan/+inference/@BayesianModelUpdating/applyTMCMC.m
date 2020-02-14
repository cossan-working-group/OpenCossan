function [samplesOut, log_fD] = applyTMCMC2(Bayes)
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


VerboseSave =opencossan.OpenCossan.getVerbosityLevel;
opencossan.OpenCossan.setVerbosityLevel(1);

    %% Number of cores, Not sure how to do this with openCossan's jobManager
    if ~isempty(gcp('nocreate'))
        pool = gcp;
        Ncores = pool.NumWorkers;
        fprintf('TMCMC isamples_fT_Ds running on %d cores.\n', Ncores);
    end


    %% Initialise properties from the XBayes object
    %Taking properties from the BayesianModelUpdating object
    Prior = Bayes.Prior;
    log_fD_T = @(theta) Bayes.LogLikelihood.apply(theta);
    Nm = Bayes.Nsamples;
    Np = length(Bayes.OutputNames);
    samplesOut = opencossan.common.outputs.SimulationData;
    
    fprintf('Nsamples TMCMC = %d\n', Nm);
    
    %Prior Evaluation and Sampling function handles
    fT = @(x)Prior.evalpdf('Mxsamples',x);
    sample_fT = @(N) get(Prior.sample(N),'MsamplesPhysicalSpace');

    beta2  = 0.01;  % Square of scaling parameter (MH algorithm)
    Nstage = 20;    % Preallocation of number of stages

    %% PREALLOCATION
    Th_j    = cell(Nstage,1);
    alpha_j = zeros(Nstage,1);
    Lp_j     = cell(Nstage,1);
    Log_S_j = zeros(Nstage,1);
    wn_j    = cell(Nstage,1);

    %% OPTIMIZATION PROCESS

    j = 1; alpha_j(1) = 0;

    % First stage simulation - Sample from prior distribution
    Th_j{j} = sample_fT(Nm)';  % initial sample = Nd x Nm

    %   Log-likelihood function
    Th0 = Th_j{j}; Lp0 = zeros(Nm,1);
    
    names = strcat(Bayes.OutputNames,'_',num2str(j-1));
    samplesOut = samplesOut.addVariable('Cnames',names,'Mvalues',Th0');
    
    Lp0 = log_fD_T(Th0');
    
    Lp_j{j} = Lp0;

    % for kkk = 2:Nstage  % Maximum number of stages
    while alpha_j(j) < 1
        %----------------------------------------------------------------------
        % CHOOSE ALPHA_{j+1}    (Bisection method)
        %----------------------------------------------------------------------
        low_alpha = alpha_j(j); up_alpha = 2; Lp_adjust = max(Lp_j{j});
        while (up_alpha - low_alpha)/((up_alpha + low_alpha)/2) > 1e-6
            x1 = (up_alpha + low_alpha)/2;
            wj_test = exp((x1-alpha_j(j))*(Lp_j{j}-Lp_adjust));
            cov_w   = std(wj_test)/mean(wj_test);
            if cov_w > 1, up_alpha = x1; else, low_alpha = x1; end
        end
        alpha_j(j+1) = min(1,x1);

        %----------------------------------------------------------------------
        % WEIGTHS, LOG-EVIDENCE AND NORMALIZED WEIGHTS FOR CURRENT STAGE
        %----------------------------------------------------------------------
        %   Adjusted weights
        w_j = exp((alpha_j(j+1)-alpha_j(j))*(Lp_j{j}-Lp_adjust));

        %   Log-evidence of j-th intermediate distribution
        Log_S_j(j) = log(mean(exp((Lp_j{j}-Lp_adjust)*(alpha_j(j+1)-alpha_j(j)))))+(alpha_j(j+1)-alpha_j(j))*Lp_adjust;

        %   Normalized weights
        wn_j{j} = w_j/(sum(w_j));

        %----------------------------------------------------------------------
        % WEIGHTED MEAN AND COVARIANCE MATRIX (PROPOSAL DISTRIBUTION)
        %----------------------------------------------------------------------
        %   Weighted mean of parameters
        Th_wm = Th_j{j}*wn_j{j};

        %   Covariance matrix
        SIGMA_j  = zeros(Np);
        for l = 1:Nm
            SIGMA_j = SIGMA_j + beta2*wn_j{j}(l)*(Th_j{j}(:,l)-Th_wm)*(Th_j{j}(:,l)-Th_wm)';
        end
        SIGMA_j = (SIGMA_j'+SIGMA_j)/2; % Enforcing symmetry

        %----------------------------------------------------------------------
        % GENERATION OF CONDITIONAL SAMPLES (METROPOLIS-HASTING ALGORITHM)
        %----------------------------------------------------------------------
        %   Cumulative probability mass of each sample
        wn_j_csum = cumsum(wn_j{j});

        %   Definition of Markov chains: seed sample
        mkchain_ind = zeros(Nm,1);
        for i_mc = 1:Nm
            mkchain_ind(i_mc) = find( rand < wn_j_csum ,1,'first');
        end
        seed_index = unique(mkchain_ind);
    %     if kkk>2, N_Mc_old = N_Mc; else N_Mc_old=0; end
        N_Mc = numel(seed_index);

        %   Definition of Markov chains: lengths
        lengths = zeros(size(seed_index));
        for i_mc = 1:numel(lengths); lengths(i_mc)=sum(seed_index(i_mc)==mkchain_ind); end


        %   Preallocation
        Th_j{j+1} = zeros(Np,Nm);
        Lp_j{j+1} = zeros(Nm,1);
        a_j1      = alpha_j(j+1); 
        THJ       = Th_j{j}(:,seed_index);
        LPJ       = Lp_j{j}(seed_index);
        Th_new    = cell(1,N_Mc);
        Lp_new    = cell(N_Mc,1);

        %   Parallel generation of chains
        parfor n_markovchain = 1:N_Mc
            Th_lead = THJ(:,n_markovchain);
            Lp_lead = LPJ(n_markovchain);
            Th_new{n_markovchain} = zeros(Np,lengths(n_markovchain));
            Lp_new{n_markovchain} = zeros(lengths(n_markovchain),1);
            fT_for = fT;
            log_fD_T_for = log_fD_T;
            for l = 1:lengths(n_markovchain)
                %------------------------------------------------------------------
                % Candidate sample generation (normal over feasible space)
                %------------------------------------------------------------------
                while true
                    Th_cand = mvnrnd(Th_lead,SIGMA_j)';
                    if fT_for(Th_cand')
                        break;
                    end
                end

                %------------------------------------------------------------------
                % Log-likelihood of candidate sample
                %------------------------------------------------------------------
                if fT_for(Th_cand') == 0
                    GAMMA   = 0;
                    Lp_cand = Lp_lead;
                else
                    Lp_cand = log_fD_T_for(Th_cand');
                    GAMMA = exp(a_j1*(Lp_cand - Lp_lead))*fT_for(Th_cand')/fT_for(Th_lead'); % pdf ratio
                end

                %------------------------------------------------------------------
                % Rejection step
                %------------------------------------------------------------------
                if rand <= min(1,GAMMA)
                    Th_new{n_markovchain}(:,l) = Th_cand;
                    Lp_new{n_markovchain}(l)   = Lp_cand;
                    Th_lead = Th_cand;
                    Lp_lead = Lp_cand;
                else
                    Th_new{n_markovchain}(:,l) = Th_lead;
                    Lp_new{n_markovchain}(l)   = Lp_lead;
                end
            end

        end

        Th_j{j+1} = cell2mat(Th_new);
        Lp_j{j+1} = cell2mat(Lp_new);

        names = strcat(Bayes.OutputNames,'_',num2str(j));
        samplesOut = addVariable(samplesOut,'Cnames',names,'Mvalues',Th_j{j}');
        % Update iteration step
        j = j+1;
    end

    m = j;

    Th_j     = Th_j(1:m);
    alpha_j  = alpha_j(1:m);
    Lp_j     = Lp_j(1:m);
    Log_S_j  = Log_S_j(1:(m-1));
    Log_S    = sum(Log_S_j(1:(m-1)));

    Th_posterior = Th_j{m};
    Lp_posterior = Lp_j{m};

    
    opencossan.OpenCossan.setVerbosityLevel(VerboseSave);
    samplesOut = addVariable(samplesOut,'Cnames',Bayes.OutputNames,'Mvalues',Th_j{m}');
end

