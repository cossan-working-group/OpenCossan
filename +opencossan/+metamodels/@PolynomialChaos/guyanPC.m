function Xobj = guyanPC(Xobj)
%GUYANPC
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/guyanPC@PolynomialChaos
%
% =======================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% =======================================================================

global OPENCOSSAN

startTime = OPENCOSSAN.Xtimer.CurrentTime;

%% Retrieve the input

Xsfem       = Xobj.Xsfem;
NDOFs       = length(Xsfem.MnominalStiffness); % Obtain the no of DOFs
Xobj.Norder = Xsfem.Norder;                    % Obtain order of PC expansion

Xinp = Xsfem.Xmodel.Xinput;
Xrvs            = Xinp.Xrvset.(Xinp.CnamesRandomVariableSet{1});    % Obtain RVSET
Crvnames        = Xinp.CnamesRandomVariable;                  % Obtain RV names
Nrvs            = Xinp.NrandomVariables;                      % Obtain No of RVs
NmasterDOFs = size(Xsfem.MmasterDOFs,1);     % Obtain the Master DOFs

%% Load the deterministic coefficients from database

OpenCossan.cossanDisp('[PolynomialChaos.guyanPC] Loading the deterministic terms from the P-C database ',3);
load(fullfile(OPENCOSSAN.SmatlabDatabasePath,'PCterms','vcijk_coefficients', ...
    ['vcijk_coeffs_',num2str(Nrvs),'_',num2str(Xobj.Norder),'.mat']));
load(fullfile(OPENCOSSAN.SmatlabDatabasePath, 'PCterms','vpsii2_coefficients',...
    ['vpsii2_coeffs_',num2str(Nrvs),'_',num2str(Xobj.Norder),'.mat']));
load(fullfile(OPENCOSSAN.SmatlabDatabasePath,'PCterms','vci2jk_coefficients',...
    ['vci2jk_coeffs_',num2str(Nrvs), '_', num2str(Xobj.Norder), '.mat']));
load(fullfile(OPENCOSSAN.SmatlabDatabasePath, 'PCterms','vcik_coefficients',...
    ['vcik_coeffs_', num2str(Nrvs), '_', num2str(Xobj.Norder), '.mat']));
load(fullfile(OPENCOSSAN.SmatlabDatabasePath, 'PCterms','vci2k_coefficients',...
    ['vci2k_coeffs_',num2str(Nrvs), '_', num2str(Xobj.Norder), '.mat']));

%% Assemble the A matrix (Ax=b)

Xobj.Npccoefficients = pcnumber(Nrvs,Xobj.Norder);
MKPC                 = sparse(Xobj.Npccoefficients*NmasterDOFs,Xobj.Npccoefficients*NmasterDOFs);

% INSERT THE K_i TERMS
for i=1:length(Vcijk_i)
   j_start = 1 + (Vcijk_j(i)-1)*NmasterDOFs;
   k_start = 1 + (Vcijk_k(i)-1)*NmasterDOFs;
   j_end   = Vcijk_j(i)*NmasterDOFs;
   k_end   = Vcijk_k(i)*NmasterDOFs;
   if Vcijk_i(i)==1
       MKPC(j_start:j_end,k_start:k_end) = Vcijk(i)*Xsfem.MnominalStiffness; %#ok<*SPRIX>
   else
       MKPC(j_start:j_end,k_start:k_end) = Vcijk(i)*Xsfem.CMKi{Vcijk_i(i)-1};
   end
   % Inserting symetric parts
   MKPC(k_start:k_end,j_start:j_end) = MKPC(j_start:j_end,k_start:k_end); 
end

% INSERT THE K_ii TERMS
for i=1:length(Vci2jk_i)
   j_start = 1 + (Vci2jk_j(i)-1)*NmasterDOFs;
   k_start = 1 + (Vci2jk_k(i)-1)*NmasterDOFs;
   j_end   = Vci2jk_j(i)*NmasterDOFs;
   k_end   = Vci2jk_k(i)*NmasterDOFs;
   MKPC(j_start:j_end,k_start:k_end) = ...
       MKPC(j_start:j_end,k_start:k_end) + Vci2jk(i)*(Xsfem.CMKii{Vci2jk_i(i)}./2);
   % Inserting symetric parts
   MKPC(k_start:k_end,j_start:j_end) = MKPC(j_start:j_end,k_start:k_end); 
end

%% Assemble b vector (Ax=b)

% RHS (b) is assembled as follows:  (see Eq. 18 in Guyan PC paper)
%
% RHS => b = <fm,psi_k> - f_i<ksi_i,psi_k> - f_ii<ksi_i^2,psi_k>
%             -partI-        -partII-              -partIII-
%            
% assemble part corresponding to partI = <fm,psi_k>

% f_i will be calculated as:
%
% => PA  = fm - K_B
% => f_i = fm - PA
% where PA is what you output from NASTRAN
% fm is the force you have on the m-DOF

% then check the force on the m-DOF 
[~,i2,~]  = intersect(Xsfem.MmodelDOFs,Xsfem.MmasterDOFs,'rows');
fm        = Xsfem.VnominalForce(i2);

VfpcpartI = [fm',zeros(Xobj.Npccoefficients*NmasterDOFs-NmasterDOFs,1)']';

% assemble part corresponding to partII = f_i<ksi_i,psi_k>
VfpcpartII                = sparse(Xobj.Npccoefficients*NmasterDOFs,1);
VfpcpartII(1:NmasterDOFs) = (fm - Xsfem.VnominalRHS);
for i = 1:length(Vcik_i)
    index_start = (Vcik_k(i) - 1)*NmasterDOFs + 1;
    index_end   = Vcik_k(i)*NmasterDOFs;
    VfpcpartII(index_start:index_end) = Vcik(i)*Xsfem.CVfi{Vcik_i(i)};
end  

% assemble part corresponding to partIII = f_ii<ksi_i^2,psi_k>
VfpcpartIII    = sparse(Xobj.Npccoefficients*NmasterDOFs,1);
VfpcpartIII(1:NmasterDOFs) = (fm - Xsfem.VnominalRHS);
for i = 1:length(Vci2k_i)
    index_start = (Vci2k_k(i) - 1)*NmasterDOFs + 1;
    index_end   = Vci2k_k(i)*NmasterDOFs;
    VfpcpartIII(index_start:index_end) = (Xsfem.CVfii{Vci2k_i(i)}./2)*Vci2k(i);
end  

% bring all parts together
Vfpc = VfpcpartI - VfpcpartII - VfpcpartIII;

%% Solve for PC coefficients

Vpccoefficients = MKPC\Vfpc;

%% Store the PC coefficients in the Object

% Convert P-C coefficients vector to a matrix format such that
% Mci is a matrix with size NDOFs x Npcterms
Xobj.Mpccoefficients = reshape(Vpccoefficients,NDOFs,Xobj.Npccoefficients);
   
%% Stop  the clock

stopTime          = OPENCOSSAN.Xtimer.CurrentTime;
Xobj.Ccputimes{2} = stopTime - startTime;

Xobj.Ccputimes{1} = [];

return
