function [xb,Statistics,Gm, exitFlag] = sres(obj,objfun,cons,mm,lu,lambda,G,mu,pf,varphi)
    % SRES Evolution Strategy using Stochastic Ranking usage:
    %        [xb,Stats,Gm] = sres(objfun,cons,mm,lu,lambda,G,mu,pf,varphi) ;
    % where
    %        objfun    : name of objective function to be optimized (string or handle) cons      :
    %        name of constraint function to be optimized (string or handle) mm        : 'max' or
    %        'min' (for maximization or minimization) lu        : parameteric constraints (lower and
    %        upper bounds) lambda    : population size (number of offspring) (100 to 200) G
    %        : maximum number of generations mu        : parent number (mu/lambda usually 1/7) pf
    %        : pressure on fitness in [0 0.5] try around 0.45 varphi    : expected rate of
    %        convergence (usually 1)
    %
    %        xb        : best feasible individual found Stats     : [min(f(x)) mean(f(x))
    %        number_feasible(x)] Gm        : the generation number when "xb" was found
    
    % Copyright (C) 1998-1999 Thomas Philip Runarsson (e-mail: tpr@verk.hi.is)
    %
    % This program is free software; you can redistribute it and/or modify it under the terms of the
    % GNU General Public License as published by the Free Software Foundation; either version 2 of
    % the License, or (at your option) any later version.
    %
    % This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    % without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See
    % the GNU General Public License for more details.
    
    % Modified by MB  & EP to be used with COSSAN
    % ========================================================================= COSSAN - The next
    % generation of the computational stochastic analysis University of Liverpool, Copyright
    % 1993-2013 =========================================================================
    
    if strcmpi(mm,'max'), mm = -1 ; else mm = 1 ; end
    
    % Initialize Population
    n = size(lu,2) ;
    x = ones(lambda,1)*lu(1,:)+rand(lambda,n).*(ones(lambda,1)*(lu(2,:)-lu(1,:))) ;
    
    % Selection index vector
    sI = (1:mu)'*ones(1,ceil(lambda/mu)) ; sI = sI(1:lambda) ;
    
    % Initial parameter settings
    eta = ones(lambda,1)*(lu(2,:)-lu(1,:))/sqrt(n) ;
    tau  = varphi/(sqrt(2*sqrt(n))) ;
    tau_ = varphi/(sqrt(2*n)) ;
    ub = ones(lambda,1)*lu(2,:) ;
    lb = ones(lambda,1)*lu(1,:) ;
    eta_u = eta(1,:) ;
    BestMin = Inf ;
    nretry = 10 ;
    xb = [] ;
    
    % Preallocate memory
    Nbatch=100;
    
    Min=zeros(min(obj.MaxIterations,Nbatch),1);
    Mean=zeros(min(obj.MaxIterations,Nbatch),1);
    NrFeas=zeros(min(obj.MaxIterations,Nbatch),1);
    
    % Start Generation loop ...
    iteration = 0;
    while true
        iteration = iteration+1;
        
        if iteration>length(Min)
            Min=[Min; zeros(Nbatch,1)];         %#ok<AGROW>
            Mean=[Mean; zeros(Nbatch,1)];       %#ok<AGROW>
            NrFeas=[NrFeas; zeros(Nbatch,1)];   %#ok<AGROW>
        end
        
        % fitness evaluation COSSAN change from one feval to two (one for obj, one for con)
        f = feval(objfun,x);
        phi = feval(cons,x);
        Feasible = find((sum((phi>0),2)<=0)) ;
        
        % Performance / statistics
        if ~isempty(Feasible)
            [Min(iteration),MinInd] = min(f(Feasible)) ;
            MinInd = Feasible(MinInd) ;
            Mean(iteration) = mean(f(Feasible)) ;
        else
            Min(iteration) = NaN ; Mean(iteration) = NaN ;
        end
        
        NrFeas(iteration) = length(iteration) ;
        
        % Keep best individual found
        if (Min(iteration)<BestMin) && ~isempty(Feasible)
            xb = x(MinInd,:) ;
            BestMin = Min(iteration) ;
            Gm = iteration ;
        end
        
        % Compute penalty function "quadratic loss function" (or any other)
        phi(phi<=0) = 0 ;
        phi = sum(phi.^2,2);
        
        % Selection using stochastic ranking (see srsort.c)
        I = srsort(f,phi,pf) ;
        x = x(I(sI),:) ; eta = eta(I(sI),:) ;
        
        % Update eta (traditional technique with global intermediate recombination)
        eta = arithx(eta) ;
        eta = eta.*exp(tau_*randn(lambda,1)*ones(1,n)+tau*randn(lambda,n)) ;
        
        % Upper bound on eta (used?)
        for i=1:n
            I = find(eta(:,i)>eta_u(i)) ;
            eta(I,i) = eta_u(i)*ones(size(I)) ;
        end
        
        % Mutation
        x_ = x ; % make a copy of the individuals for repeat ...
        x = x + eta.*randn(lambda,n) ;
        
        % If variables are out of bounds retry "nretry" times
        I = find((x>ub) | (x<lb)) ;
        retry = 1 ;
        while ~isempty(I)
            x(I) = x_(I) + eta(I).*randn(length(I),1) ;
            I = find((x>ub) | (x<lb)) ;
            if (retry>nretry), break ; end
            retry = retry + 1 ;
        end
        % ignore failures
        if ~isempty(I)
            x(I) = x_(I) ;
        end
        
        % Export results and check termination criteria
        if abs(Mean(iteration)-Mean(max(iteration-1,1))) < obj.ObjectiveFunctionTolerance
            % Objective function tolerance reached
            x = x_; % Reset x for consistency
            exitFlag = 0;
            break;
        elseif iteration >= obj.MaxIterations
            % Maximum number of iterations reached
            x = x_; % Reset x for consistency
            exitFlag = 2;
            break;
        elseif sum(sum(abs(x-x_))) < obj.DesignVariableTolerance
            % Design variable tolerance reached
            x = x_; % Reset x for consistency
            exitFlag = 1;
            break;
        end
    end
    % Check Output
    if isempty(xb)
        [~,MinInd] = min(phi) ;
        xb = x(MinInd,:) ;
        Gm = iteration ;
        disp('warning: solution is infeasible') ;
    end
    
    if nargout > 1
        Statistics = [mm*[Min Mean] NrFeas] ;
    end
end
