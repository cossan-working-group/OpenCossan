function Xobj = iterativeGalerkin(Xobj)
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/iterativeGalerkin@PolynomialChaos
%
% =======================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% =======================================================================

global OPENCOSSAN

%% Retrieve the input

Xsfem       = Xobj.Xsfem;                      % Obtain the SFEM P-C object
Ndofs       = length(Xsfem.MnominalStiffness); % Obtain No of DOFs
Xobj.Norder = Xsfem.Norder;                    % Obtain the order of P-C expansion
Xinp        = Xsfem.Xmodel.Xinput;             % Obtain Input
Nrvs        = Xinp.NrandomVariables;           % Obtain No of RVs


%% Reduce the bandwith of Nominal K & Reorder all System Quantities accordingly

Xobj = reduceBandwith(Xobj);

%% Construct The Preconditioner for the iterative PCG Solver

Xobj = preparePreconditioner(Xobj);

%% Assemble b for Galerkin P-C system (Ax=b)

% NOTE: if the force is deterministic, only first portion of the
%       force vector is nonzero (= nominal force), the rest is all zeros

Xobj.Npccoefficients = pcnumber(Nrvs,Xobj.Norder);
Xobj.Vfpc            = sparse(Xobj.Npccoefficients*Ndofs,1);
Xobj.Vfpc(1:Ndofs)   = Xsfem.VnominalForce;

% IF FORCE IS STOCHASTIC
if Xsfem.LrandomForce
    % load vcik coefficients
    load(fullfile(OPENCOSSAN.SmatlabDatabasePath, 'PCterms','vcik_coefficients',...
        'vcik_coeffs_', num2str(Nrvs), '_', num2str(Xobj.Norder), '.mat'));
    for i = 1:length(Vcik_i)
        index_start = (Vcik_k(i) - 1) * Ndofs + 1;
        index_end   = Vcik_k(i)*Ndofs;
        Xobj.Vfpc(index_start:index_end) = Xsfem.CVfi{Vcik_i(i)}*Vcik(i);
    end  
    if Xsfem.NinputApproximationOrder == 2
        load(fullfile(OPENCOSSAN.SmatlabDatabasePath,'PCterms','vci2k_coefficients', ...
            'vci2k_coeffs_',num2str(Nrvs), '_', num2str(Xobj.Norder), '.mat'));
        VfpcII = sparse(Xobj.Npccoefficients*Ndofs,1);
        for i = 1:length(Vci2k_i)
            index_start = (Vci2k_k(i) - 1)*Ndofs + 1;
            index_end   = Vci2k_k(i)*Ndofs;
            VfpcII(index_start:index_end) = (Xsfem.CVfii{Vci2k_i(i)}./2)*Vci2k(i); %#ok<*SPRIX>
        end
        Xobj.Vfpc = Xobj.Vfpc - VfpcII;
    end    
end

%% Assemble the initial guess of x for Galerkin PC system (Ax=b) 

% It is a vector of length Ndofs*Npcterms, starts with Vunom, rest is just zero
Xobj.Vupc          = sparse(Xobj.Npccoefficients*Ndofs,1);
Xobj.Vupc(1:Ndofs) = Xsfem.VnominalDisplacement;

%% Solve the Galerkin System 

Xobj = solveGalerkinSystem(Xobj);

return
