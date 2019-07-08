function Xobj = solveGalerkinSystem(Xobj)
%solveGalerkinSystem
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/solveGalerkinSystem@PolynomialChaos
%
% =======================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% =======================================================================

global OPENCOSSAN

OverallstartTime = OPENCOSSAN.Xtimer.currentTime;

%% Get the input quantities

Mpreconditioner      = Xobj.Mpreconditioner;            % Obtain the preconditioner
Xsfem                = Xobj.Xsfem;                      % Obtain the SFEM P-C object
Vfpc                 = Xobj.Vfpc;                       % Obtain the the right hand side for P-C system
Ndofs                = length(Xsfem.MnominalStiffness); % Obtain the no of DOFs
Norder               = Xsfem.Norder;                    % Obtain order of P-C
Lautoconvergence     = Xsfem.Lautoconvergence;          % Obtain flag for the auto convergence algorithm
Nmaxiterations       = Xsfem.Nmaxiterations;            % Obtain max no of iterations
convergenceparameter = Xsfem.convergenceparameter;      % Obtain convergence parameter
convergencetolerance = Xsfem.convergencetolerance;      % Obtain convergence tolerance
Npccoefficients      = Xobj.Npccoefficients;            % Obtain no of Coefficients
Xinp                 = Xsfem.Xmodel.Xinput;             % Obtain Input
Nrvs                 = Xinp.NrandomVariables;           % Obtain No of RVs




%% Load the deterministic coefficients from database

OpenCossan.cossanDisp('[PolynomialChaos.solveGalerkinSystem] Loading the deterministic terms from the P-C database ',3);

load(fullfile(OPENCOSSAN.SmatlabDatabasePath,'PCterms','vcijk_coefficients', ...
    ['vcijk_coeffs_',num2str(Nrvs),'_',num2str(Xobj.Norder),'.mat']));
load(fullfile(OPENCOSSAN.SmatlabDatabasePath, 'PCterms','vpsii2_coefficients',...
    ['vpsii2_coeffs_',num2str(Nrvs),'_',num2str(Xobj.Norder),'.mat']));
load(fullfile(OPENCOSSAN.SmatlabDatabasePath,'PCterms','vci2jk_coefficients',...
    ['vci2jk_coeffs_',num2str(Nrvs), '_', num2str(Xobj.Norder), '.mat']));

%% Determine a response DOF in order to check the convergence
%  NOTE: The DOF corresponding to Maximum Response is used for this purpose

[~, maxresponsedof] = max(abs(Xobj.Vupc(1:Ndofs)));

%% Define the function handles to perform MAT-VEC product
  
Afun = @(x)matrixVectorProduct(x,Npccoefficients,Xsfem.NinputApproximationOrder,...
                      Vcijk_i,Vcijk_j,Vcijk_k,Vcijk,Xsfem.MnominalStiffness,Xsfem.CMKi,Ndofs,...
                      Vci2jk,Vci2jk_i,Vci2jk_j,Vci2jk_k,Xsfem.CMKii); 
   
Mfun = @(b)preconditioning(b,Npccoefficients,Ndofs,Vpsii2,Mpreconditioner);

%%  Perform the solution with the PCG Solver

OpenCossan.cossanDisp('[PolynomialChaos.solveGalerkinSystem] Solution with PCG Iterative Solver started ',2);

if Lautoconvergence
    % initialize convergence residual values (starting value 0.1)
    pcgtolerance = 0.1;
    OpenCossan.cossanDisp(['[PolynomialChaos.solveGalerkinSystem] Starting iterative solver PCG with convergence threshold ' num2str(pcgtolerance)],3);
    startTime  = OPENCOSSAN.Xtimer.currentTime;
    % perform first solution with the solver
    [Vpccoefficients,Lsolverflag,~,iter] = ...
    pcg(Afun,Vfpc,pcgtolerance,Nmaxiterations,Mfun,[],Xobj.Vupc);  
    stopTime  = OPENCOSSAN.Xtimer.currentTime;
    % store the first results
    Vpccoefficients1 = Vpccoefficients;
    cputime_solver = stopTime - startTime; 
    if Lsolverflag == 0
        OpenCossan.cossanDisp(['[PolynomialChaos.solveGalerkinSystem] Iterative solver converged in ' num2str(cputime_solver) ' sec after ' num2str(iter) ' iterations'],3);
    elseif Lsolverflag == 1 
        OpenCossan.cossanDisp(['[PolynomialChaos.solveGalerkinSystem] Iterative solver iterated max times but did not converge in  ' num2str(cputime_solver) ' sec '],3);
    elseif Lsolverflag == 2 
        OpenCossan.cossanDisp('[PolynomialChaos.solveGalerkinSystem] Preconditioner was ill-conditioned ',3);
    elseif Lsolverflag == 3  
        OpenCossan.cossanDisp('[PolynomialChaos.solveGalerkinSystem] Iterative solver stagnated ',3);
    elseif Lsolverflag == 4
        OpenCossan.cossanDisp('[PolynomialChaos.solveGalerkinSystem] One of the scalar quantities calculated during pcg became too small or too large to continue computing ',3);
    end
    % Convert P-C coefficients vector to a matrix format such that
    % Mci is a matrix with size NDOFs x Npcterms
    Mpccoefficients = reshape(Vpccoefficients,Ndofs,Npccoefficients);
    % Calculating mean,std and cov of response
    % the first coefficients determine the mean for each DOF
    Vmean = full(Mpccoefficients(:,1));
    % Calculate Variance of response
    variance = 0;
    % the indexing is done such that the first coefficients are ignored
    % since they are used only for the mean calculation
    for i=2:Npccoefficients
        variance = variance + Vpsii2(i).*Mpccoefficients(:,i).^2;
    end
    Vstd = full(sqrt(variance));
    Vcov = abs(Vstd./Vmean);
    OpenCossan.cossanDisp(['[PolynomialChaos.solveGalerkinSystem] Mean of the maximum response is ' num2str(Vmean(maxresponsedof))],3);
    OpenCossan.cossanDisp(['[PolynomialChaos.solveGalerkinSystem] CoV of the maximum response is ' num2str(Vcov(maxresponsedof))],3);
    % initialize the variable to measure the variation in the COV (between two consequetive runs of PCG solver)
    % of response as a high value
    covdifference = 50; meandifference = 50;
    % iterate with the calls to PCG until the difference between two
    % CoV calculations of the response is less than %1
    while covdifference > convergenceparameter || meandifference > convergenceparameter
        % decrease the convergence criteria
        pcgtolerance = pcgtolerance/10;
        OpenCossan.cossanDisp(['[PolynomialChaos.solveGalerkinSystem] Starting iterative solver PCG with convergence threshold ' num2str(pcgtolerance)],3);
        startTime  = OPENCOSSAN.Xtimer.currentTime;
        % Run the solver again using the previous results
        [Vpccoefficients,Lsolverflag,~,iter] = ...
        pcg(Afun,Vfpc,pcgtolerance,Nmaxiterations,Mfun,[],Vpccoefficients1);
        % store the results
        Vpccoefficients1 = Vpccoefficients;
        stopTime  = OPENCOSSAN.Xtimer.currentTime;
        cputime_solver = stopTime - startTime;
        if Lsolverflag == 0
            OpenCossan.cossanDisp(['[PolynomialChaos.solveGalerkinSystem] Iterative solver converged in ' num2str(cputime_solver) ' sec after ' num2str(iter) ' iterations'],3);
        elseif Lsolverflag == 1
            OpenCossan.cossanDisp(['[PolynomialChaos.solveGalerkinSystem] Iterative solver iterated max times but did not converge in  ' num2str(cputime_solver) ' sec '],3);
        elseif Lsolverflag == 2
            OpenCossan.cossanDisp('[PolynomialChaos.solveGalerkinSystem] Preconditioner was ill-conditioned ',3);
        elseif Lsolverflag == 3
            OpenCossan.cossanDisp('[PolynomialChaos.solveGalerkinSystem] Iterative solver stagnated ',3);
        elseif Lsolverflag == 4
            OpenCossan.cossanDisp('[PolynomialChaos.solveGalerkinSystem] One of the scalar quantities calculated during pcg became too small or too large to continue computing ',3);
        end
        % Convert P-C coefficients vector to a matrix format such that
        % Mci = a matrix with size NDOFs x Npcterms
        Mpccoefficients = reshape(Vpccoefficients,Ndofs,Npccoefficients);
        % Calculating mean,std and cov of response
        % the first coefficients determine the mean for each DOF
        Vmean_new = full(Mpccoefficients(:,1));
        % Calculate Variance of response
        variance = 0;
        % the indexing is done such that the first coefficients are ignored
        % since they are used only for the mean calculation
        for i=2:Npccoefficients
            variance = variance + Vpsii2(i).*Mpccoefficients(:,i).^2;
        end
        Vstd     = full(sqrt(variance));
        Vcov_new = abs(Vstd./Vmean);
        OpenCossan.cossanDisp(['[PolynomialChaos.solveGalerkinSystem] Mean of the maximum response is ' num2str(Vmean(maxresponsedof))],3);
        OpenCossan.cossanDisp(['[PolynomialChaos.solveGalerkinSystem] CoV of the maximum response is ' num2str(Vcov(maxresponsedof))],3);
        % Proceed with the checking the difference in the CoV and mean
        % of the response 
        meandifference = 100*abs((Vmean_new(maxresponsedof) - Vmean(maxresponsedof)))/Vmean(maxresponsedof);
        % Calculate the difference in CoV as percentage
        covdifference = 100*abs((Vcov_new(maxresponsedof) - Vcov(maxresponsedof)))/Vcov(maxresponsedof);
        OpenCossan.cossanDisp(['[PolynomialChaos.solveGalerkinSystem] Change in the Mean of response w.r.t previous solution is ' num2str(meandifference) 'percent'],3);
        OpenCossan.cossanDisp(['[PolynomialChaos.solveGalerkinSystem] Change in the CoV of response w.r.t previous solution is ' num2str(covdifference) 'percent'],3);
        % overwrite the previous CoV value (in order to be able to calculate the difference with the next CoV)
        Vcov = Vcov_new; Vmean = Vmean_new;
    end
% if the user wants to setup the convergence value himself   
else
    OpenCossan.cossanDisp(' ',3);
    OpenCossan.cossanDisp(['[PolynomialChaos.solveGalerkinSystem] Starting iterative solver PCG with convergence threshold ' num2str(convergencetolerance)],3);
    startTime  = OPENCOSSAN.Xtimer.currentTime;
    % perform first solution with the solver
    [Vpccoefficients,Lsolverflag,~,iter] = pcg(Afun,Vfpc,convergencetolerance,Nmaxiterations,Mfun,[],Xobj.Vupc); 
    stopTime  = OPENCOSSAN.Xtimer.currentTime;
    cputime   = stopTime - startTime; 
    if Lsolverflag == 0
        OpenCossan.cossanDisp(['[PolynomialChaos.solveGalerkinSystem] Iterative solver converged in ' num2str(cputime) ' sec after ' num2str(iter) ' iterations'],3);
    elseif Lsolverflag == 1
        OpenCossan.cossanDisp(['[PolynomialChaos.solveGalerkinSystem] Iterative solver iterated max times but did not converge in  ' num2str(cputime) ' sec '],3);
    elseif Lsolverflag == 2
        OpenCossan.cossanDisp('[PolynomialChaos.solveGalerkinSystem] Preconditioner was ill-conditioned ',3);
    elseif Lsolverflag == 3
        OpenCossan.cossanDisp('[PolynomialChaos.solveGalerkinSystem] Iterative solver stagnated ',3);
    elseif Lsolverflag == 4
        OpenCossan.cossanDisp('[PolynomialChaos.solveGalerkinSystem] One of the scalar quantities calculated during pcg became too small or too large to continue computing ',3);
    end
    % Convert P-C coefficients vector to a matrix format such that
    % Mci is a matrix with size NDOFs x Npcterms
    Mpccoefficients = reshape(Vpccoefficients,Ndofs,Npccoefficients);
end

%% Stop time

OverallstopTime  = OPENCOSSAN.Xtimer.currentTime;
Xobj.Ccputimes{2} = OverallstopTime - OverallstartTime;

OpenCossan.cossanDisp(['[PolynomialChaos.solveGalerkinSystem] Solution with PCG Iterative Solver completed in ' num2str(Xobj.Ccputimes{2}) 'sec'],2);
OpenCossan.cossanDisp(' ',2)

%% Store the PC coefficients in the Object

Xobj.Mpccoefficients = Mpccoefficients;

return
