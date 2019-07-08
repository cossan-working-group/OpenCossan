function Xobj = preparePreconditioner(Xobj)
%PREPARE_PRECONDITIONER  prepares the preconditioner for the PCG solver
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/preparePreconditioner@PolynomialChaos
%
% =======================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% =======================================================================

global OPENCOSSAN

OpenCossan.cossanDisp('[PolynomialChaos.preparePreconditioner] Preparation of the Preconditioner started',2);

OverallstartTime = OPENCOSSAN.Xtimer.currentTime;

%% First get some necessary data from the object

Xsfem               = Xobj.Xsfem;
Lautofactorization  = Xsfem.Lautofactorization;
Vdroptolerancerange = Xsfem.Vdroptolerancerange;
droptolerance       = Xsfem.droptolerance;

%% Prepare the Preconditioner

% 5 Factors are calculated in this algorithm
% => the one which converges in the min. time with the nominal solution is
%    selected as the preconditioner to be used for P-C solution in PCG
% 
% NOTE: following notation is followed for the preconditioners
%
% MKU1 : MKU prepared with lower D value
% MKU2 : MKU prepared with upper D value 
% MKU3 : MKU prepared by removing 0.25 quantile
% MKU4 : MKU prepared by removing 0.50 quantile
% MKU5 : MKU prepared by removing 0.75 quantile
%
% Default values used in PCG for the nominal solution are
% 
% threshold = 1e-1, Nmaxiter = 1000

if  Lautofactorization
    OpenCossan.cossanDisp(' ',3);
    OpenCossan.cossanDisp(['[PolynomialChaos.preparePreconditioner] Using drop tolerance range [' num2str(Vdroptolerancerange(1)) ',' num2str(Vdroptolerancerange(2)) '] '],3);
    % Perform factorization with the lower D value
    OpenCossan.cossanDisp(' ',3);
    OpenCossan.cossanDisp(['[PolynomialChaos.preparePreconditioner] Starting incomplete Cholesky Factorization for Nominal K with Drop Tolerance ' num2str(Vdroptolerancerange(1))],3);
    startTime = OPENCOSSAN.Xtimer.currentTime;
    MKU = cholinc(Xsfem.MnominalStiffness,Vdroptolerancerange(1));
    stopTime = OPENCOSSAN.Xtimer.currentTime;
    Factime = stopTime - startTime; 
    OpenCossan.cossanDisp(['[PolynomialChaos.preparePreconditioner] Factorization completed in ' num2str(Factime) ' sec'],3);
    % Check memory allocation needed for MKU
    memory_alloc = whos;
    % Get the memory allocation for the factor matrix MKU
    Memory_MKU = memory_alloc(4).bytes;
    OpenCossan.cossanDisp(['[PolynomialChaos.preparePreconditioner] Memory allocation needed for the resulting factor is ' num2str((Memory_MKU/1e6)) ' MB'],3);
    % Measure nominal solution time
    startTime = OPENCOSSAN.Xtimer.currentTime;
    [~,flag,~,iter] = pcg(Xsfem.MnominalStiffness,Xsfem.VnominalForce,1e-1,1000,MKU',MKU); 
    stopTime = OPENCOSSAN.Xtimer.currentTime;
    sol_time(1) = stopTime - startTime;
    % NOTE: The optimum preconditioner is selected according to the best
    % time achieved with the nominal solution (Ku=f). During this
    % selection, the MKU's which don't converge or are ill-conditioned are
    % excluded.
    if flag == 0
        OpenCossan.cossanDisp(['[PolynomialChaos.preparePreconditioner] Iterative solver converged for the Nominal system in ' num2str(sol_time(1)) ' sec after ' num2str(iter) ' iterations'],3);
    elseif flag == 1  
        OpenCossan.cossanDisp('[PolynomialChaos.preparePreconditioner] Iterative solver iterated max times for the Nominal system but did not converge',3);
        OpenCossan.cossanDisp('[PolynomialChaos.preparePreconditioner] Therefore this preconditioner will not be used in the solver',3);
        % set the solution time to an arbitrary high value to make sure
        % that this preconditioner will not be selected at the end 
        % (I select the preconditioner with the min. sol_time)
        % NOTE: I dont delete the calculated MKU, since I need it later to
        % identify the difference between MKU1 & MKU2
        sol_time(1) = 5000;
    elseif flag == 2 
        OpenCossan.cossanDisp('[PolynomialChaos.preparePreconditioner] Preconditioner used for the Nominal system was ill-conditioned',3);
        OpenCossan.cossanDisp('[PolynomialChaos.preparePreconditioner] Therefore this preconditioner will not be used in the solver',3);
        sol_time(1) = 5000;
    elseif flag == 3  
        OpenCossan.cossanDisp('[PolynomialChaos.preparePreconditioner] Iterative solver for the Nominal system stagnated',3);
        OpenCossan.cossanDisp('[PolynomialChaos.preparePreconditioner] Therefore this preconditioner will not be used in the solver',3);
        sol_time(1) = 5000;
    elseif flag == 4
        OpenCossan.cossanDisp('[PolynomialChaos.preparePreconditioner] One of scalar quant. calculated became too small/large to continue computing',3);
        OpenCossan.cossanDisp('[PolynomialChaos.preparePreconditioner] Therefore this preconditioner will not be used in the solver',3);
        sol_time(1) = 5000;  
    end
    % save the MKU to a file in order to reduce memory allocation
    save MKU1 MKU
    clear MKU
    % Perform factorization with the upper D value
    OpenCossan.cossanDisp('',3);
    OpenCossan.cossanDisp(['[PolynomialChaos.preparePreconditioner] Starting incomplete Cholesky Factorization for Nominal K with Drop Tolerance ' num2str(Vdroptolerancerange(2))],3);
    startTime = OPENCOSSAN.Xtimer.currentTime;
    MKU = cholinc(Xsfem.MnominalStiffness,Vdroptolerancerange(2));
    stopTime = OPENCOSSAN.Xtimer.currentTime;
    Factime = stopTime - startTime; 
    OpenCossan.cossanDisp(['[PolynomialChaos.preparePreconditioner] Factorization completed in ' num2str(Factime) ' sec'],3);
    % Check memory allocation needed for MKU
    memory_alloc = whos;
    % Get the memory allocation for the factor matrix MKU
    Memory_MKU = memory_alloc(4).bytes;
    OpenCossan.cossanDisp(['[PolynomialChaos.preparePreconditioner] Memory allocation needed for the resulting factor is ' num2str((Memory_MKU/1e6)) ' MB'],3);
    startTime = OPENCOSSAN.Xtimer.currentTime;
    [~,flag,~,iter] = pcg(Xsfem.MnominalStiffness,Xsfem.VnominalForce,1e-1,1000,MKU',MKU); 
    stopTime = OPENCOSSAN.Xtimer.currentTime;
    sol_time(2) = stopTime - startTime;
    if flag == 0
        OpenCossan.cossanDisp(['[PolynomialChaos.preparePreconditioner] Iterative solver converged for the Nominal system in ' num2str(sol_time(2)) ' sec after ' num2str(iter) ' iterations'],3);
    elseif flag == 1  
        OpenCossan.cossanDisp('[PolynomialChaos.preparePreconditioner] Iterative solver iterated max times for the Nominal system but did not converge',3);
        OpenCossan.cossanDisp('[PolynomialChaos.preparePreconditioner] Therefore this preconditioner will not be used in the solver',3);
        sol_time(1) = 5000;
    elseif flag == 2 
        OpenCossan.cossanDisp('[PolynomialChaos.preparePreconditioner] Preconditioner used for the Nominal system was ill-conditioned',3);
        OpenCossan.cossanDisp('[PolynomialChaos.preparePreconditioner] Therefore this preconditioner will not be used in the solver',3);
        sol_time(1) = 5000;
    elseif flag == 3  
        OpenCossan.cossanDisp('[PolynomialChaos.preparePreconditioner] Iterative solver for the Nominal system stagnated',3);
        OpenCossan.cossanDisp('[PolynomialChaos.preparePreconditioner] Therefore this preconditioner will not be used in the solver',3);
        sol_time(1) = 5000;
    elseif flag == 4
        OpenCossan.cossanDisp('[PolynomialChaos.preparePreconditioner] One of scalar quant. calculated became too small/large to continue computing',3);
        OpenCossan.cossanDisp('[PolynomialChaos.preparePreconditioner] Therefore this preconditioner will not be used in the solver',3);
        sol_time(1) = 5000;  
    end  
    % save the MKU to a file in order to reduce memory allocation
    save MKU2 MKU
    MKU2 = MKU;
    clear MKU
    load MKU1
    MKU1 = MKU;
    clear MKU
    % obtain the nonzero indices of the two factors MKU1 & MKU2
    nnza = find(MKU1);
    nnzb = find(MKU2);
    % get the indices of the difference
    nnzdiff = setdiff(nnzb,nnza);
    % NOTE: if there is no difference between the Preconditioners
    % calculated with the two D values (this case has been encountered in 
    % some examples), then the code simply takes one of the MKU and
    % moves on
    if isempty(nnzdiff)
         Mpreconditioner      = MKU1;
         toc6                 = toc;
         cputime              = toc6 - toc9;
         Xobj.Ccputimes{1}    = cputime;
         Xobj.Mpreconditioner = Mpreconditioner;
         OpenCossan.cossanDisp(['[PolynomialChaos.preparePreconditioner] Preparation of the Preconditioner completed in ' num2str(cputime) ' sec'],2);
         delete *.mat
         return
    end
    clear nnza nnzb MKU1
    % assign these to a matrix
    Vdiff    = MKU2(nnzdiff);
    Vdiff    = abs(Vdiff);
    % obtain then the values corresponding to certain quantiles
    Vdummy   = sort(Vdiff);
    Vindex(1)= round(length(Vdummy)/4);
    Vindex(2)= round(length(Vdummy)/2);
    Vindex(3)= round(length(Vdummy)*3/4);
    Vquan(1) = Vdummy(Vindex(1));
    Vquan(2) = Vdummy(Vindex(2));
    Vquan(3) = Vdummy(Vindex(3));
    Vquantil = [0 1.00 0.25 0.50 0.75]; 
    clear Vdummy
    for k=1:length(Vquan)
       OpenCossan.cossanDisp('',3);
       OpenCossan.cossanDisp(['[PolynomialChaos.preparePreconditioner] Obtaining the preconditioner with quantile ' num2str(Vquantil(k+2))],3);
       index1 = Vdiff < Vquan(k);
       index2 = nnzdiff(index1);
       MKU = MKU2;
       MKU(index2) = 0;
       clear index1 index2
       [i,j,s] = find(MKU);
       MKU = sparse(i,j,s);
       clear i j s
       % Check memory allocation needed for MKU
       memory_alloc = whos;
       % Get the memory allocation for the factor matrix MKU
       Memory_MKU = memory_alloc(4).bytes;
       OpenCossan.cossanDisp(['[PolynomialChaos.preparePreconditioner] Memory allocation needed for the resulting factor is ' num2str((Memory_MKU/1e6)) ' MB'],3);
       startTime = OPENCOSSAN.Xtimer.currentTime;
       [~,flag,~,iter] = pcg(Xsfem.MnominalStiffness,Xsfem.VnominalForce,1e-1,1000,MKU',MKU); 
       stopTime = OPENCOSSAN.Xtimer.currentTime;
       sol_time(k+2) = stopTime - startTime;
       if flag == 0
            OpenCossan.cossanDisp(['[PolynomialChaos.preparePreconditioner] Iterative solver converged for the Nominal system in ' num2str(sol_time(k+2)) ' sec after ' num2str(iter) ' iterations '],3);
       elseif flag == 1  
            OpenCossan.cossanDisp('[PolynomialChaos.preparePreconditioner] Iterative solver iterated max times for the Nominal system but did not converge ',3);
            OpenCossan.cossanDisp('[PolynomialChaos.preparePreconditioner] Therefore this preconditioner will not be used in the solver ',3);
            sol_time(k+2) = 5000;
            MKU = [];
       elseif flag == 2 
            OpenCossan.cossanDisp('[PolynomialChaos.preparePreconditioner] Preconditioner used for the Nominal system was ill-conditioned ',3);
            OpenCossan.cossanDisp('[PolynomialChaos.preparePreconditioner] Therefore this preconditioner will not be used in the solver ',3);
            sol_time(k+2) = 5000; %#ok<*AGROW>
            MKU = [];
       elseif flag == 3  
            OpenCossan.cossanDisp('[PolynomialChaos.preparePreconditioner] Iterative solver for the Nominal system stagnated ',3);
            OpenCossan.cossanDisp('[PolynomialChaos.preparePreconditioner] Preconditioner used for the Nominal system was ill-conditioned ',3);
            OpenCossan.cossanDisp('[PolynomialChaos.preparePreconditioner] Therefore this preconditioner will not be used in the solver ',3);
            sol_time(k+2) = 5000;
            MKU = [];
       elseif flag == 4
            OpenCossan.cossanDisp('[PolynomialChaos.preparePreconditioner] One of scalar quant. calculated became too small/large to continue computing ',3);
            OpenCossan.cossanDisp('[PolynomialChaos.preparePreconditioner] Therefore this preconditioner will not be used in the solver ',3);
            sol_time(k+2) = 5000;
            MKU = [];
       end   
       eval(['save MKU' num2str(k+2) ' MKU']);
       clear MKU
    end
    clear nnzdiff Vdiff MKU2
    Besttime = min(sol_time);
    if Besttime == 5000
       error('openCOSSAN:PolynomialChaos:preparePreconditioner','[PolynomialChaos.preparePreconditioner] None of the preconditioners provided convergence ') 
    end
    optindex = find(sol_time == Besttime);
    eval(['load MKU' num2str(optindex)]);
    Mpreconditioner = MKU;
% Use the User Defined Drop tolerance   
else
    OpenCossan.cossanDisp(['[PolynomialChaos.preparePreconditioner] Starting incomplete Cholesky Factorization for Nominal K with Drop Tolerance ' num2str(droptolerance)],3);
    Mpreconditioner = cholinc(Xsfem.MnominalStiffness,droptolerance);
    % Check memory allocation needed for MKU
    memory_alloc = whos;
    % Get the memory allocation for the factor matrix MKU
    Memory_MKU = memory_alloc(3).bytes;
    OpenCossan.cossanDisp(['[PolynomialChaos.preparePreconditioner] Memory allocation needed for the resulting factor is ' num2str((Memory_MKU/1e6)) ' MB'],3);
end

%% Clean the mat files

if  Lautofactorization
    delete('MKU1.mat');
    delete('MKU2.mat');
    delete('MKU3.mat');
    delete('MKU4.mat');
    delete('MKU5.mat');
end

%% Stop the clock

OverallstopTime      = OPENCOSSAN.Xtimer.currentTime;
cputime              = OverallstopTime - OverallstartTime;
Xobj.Ccputimes{1}    = cputime;
Xobj.Mpreconditioner = Mpreconditioner;

OpenCossan.cossanDisp(['[PolynomialChaos.preparePreconditioner] Preparation of the Preconditioner completed in ' num2str(cputime) ' sec'],2);

return
