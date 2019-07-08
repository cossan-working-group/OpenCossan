%SFEM   Abstract class for SFEM
%
%   Sfem:  This is the superclass (i.e. container) for the SFE methods 
%
% ==================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% ==================================================================

classdef Sfem 
   
   properties % Public access
      Xmodel                        % Xmodel object which contains the RVSET and Evaluator
      Sdescription                  % Description of the object
      Sinputfile                    % Name of the FE input file to be processed
      Sanalysis='Static'            % Analysis Type
      Smethod='Galerkin'            % This field only applies to P-C
      Sjobname                      % Name of the current analysis (matrix outputs, etc. are named accordingly)
      Simplementation='Regular'     % Type of the implementation
      Norder=1                      % Order of the method
      NinputApproximationOrder=1    % Order of the taylor approximation applied for input
      CyoungsModulusRVs             % Cell array of RV names assigned to model Youngs Modulus
      CdensityRVs                   % Cell array of RV names assigned to model density
      CthicknessRVs                 % Cell array of RV names assigned to model thickness
      CforceRVs                     % Cell array of RV names assigned to model force
      CcrossSectionRVs              % Cell array of RV names assigned to model cross sectional properties
      MnominalStiffness             % Nominal Stiffness matrix
      MnominalMass                  % Nominal Mass Matrix
      VnominalForce                 % Nominal Force Vector
      VnominalDisplacement          % Nominal Displacements Vector
      MnominalEigenvalues           % Nominal Eigenvalues
      MnominalEigenvectors          % Nominal Eigenvectors         
      CMpositivePerturbedStiffness  % Cell array of positive perturbed stiffness matrices 
      CMnegativePerturbedStiffness  % Cell array of negative perturbed stiffness matrices 
      CMnominalComponentStiffness   % Cell array of nominal stiffness matrices of components (used only within componentwise implementation)
      CMnominalComponentMass        % Cell array of nominal stiffness matrices of components (used only within componentwise implementation)
      CVpositivePerturbedForce      % Cell array of positive perturbed force vectors
      CVnegativePerturbedForce      % Cell array of negative perturbed force vectors
      CMpositivePerturbedMass       % Cell array of positive perturbed mass matrices
      CMnegativePerturbedMass       % Cell array of negative perturbed mass matrices
      MmodelDOFs                    % Cell array of matrices of DOFs 
      CMcomponentDOFs               % Cell array of matrices of DOFs corresponding to each component (used only within componentwise implementation) 
      CstepDefinition               % Cell array of strings to define the part STEP - ENDSTEP in ABAQUS (every cell correponds to one line)
      MconstrainedDOFs              % Matrix of constrained DOFs in the model (only valid for ABAQUS)
      CMKi                          % Cell array of matrices of the K_i terms in Taylor Series Expansion
      CMKii                         % Cell array of matrices of the K_ii terms in Taylor Series Expansion
      CVfi                          % Cell array of vectors of the f_i terms in Taylor Series Expansion
      CVfii                         % Cell array of vectors of the f_ii terms in Taylor Series Expansion
      CMMi                          % Cell array of matrices of the M_i terms in Taylor Series Expansion
      CMMii                         % Cell array of matrices of the M_ii terms in Taylor Series Expansion
      VnominalRHS                   % This vector is required for the Guyan P-C (RHS: Right Hand Side)
      CVpositivePerturbedRHS        % Cell array of perturbed RHS vectors (positive)
      CVnegativePerturbedRHS        % Cell array of perturbed RHS vectors (negative)
      Ccputimes                     % Cell array to store of CPU times spent in each section
      maxresponseDOF                % DOF no corresponding to max value of response (if max response is requested)
      Tresponses                    % Structure to store the responses
      MmasterDOFs                   % Nodes and DOFs to be assigned as master (only for Guyan-PC)
      LrandomStiffness=false        % Flag indicating that K contains RVs
      LrandomForce=false            % Flag indicating that F contains RVs
      LrandomMass=false             % Flag indicating that M contains RVs
      Lcleanfiles=true              % Flag to clean the generated files
      Lstoreinput=false             % Flag whether the generated system quantities (CMsfemmat &CMsfemdofs) should be stored or not 
      Lfesolverexecuted=false       % Flag to determine whether second step of analysis (running FE solver) can be skipped or not
      Ltransfercompleted=false      % Flag to determine whether third step of analysis (transfer of system matrices) can be skipped or not
   end
   
   properties (Constant)
      CdmapFileNames = {'dmapoutputstiffness.dat','dmapoutputforce.dat','dmapoutputmass.dat',...
                        'dmapoutputnominalstatic.dat','dmapoutputnominalmodal.dat',...
                        'dmapoutputnominalguyan.dat','dmapoutputstiffnessandforceguyan.dat',...
                        'dmapoutputstiffnesscomponentwise.dat','dmapoutputmasscomponentwise.dat',...
                        'dmapoutputdisplacements.dat','dmapoutputdofs.dat'};        
   end
   
   methods (Abstract)            
      Xoutput_SFEM=postprocess(Xobj,varargin);
   end 
   
   methods
      Xobj = checkInput(Xobj);
      Xobj = prepareInputFilesNASTRANComponentwise(Xobj);
      Xobj = prepareInputFilesNASTRANRegular(Xobj);
      Xobj = prepareInputFilesANSYS(Xobj);
      Xobj = prepareInputFilesABAQUS(Xobj);
      Xobj = runFESolverSequential(Xobj);
      Xobj = runFESolverParallel(Xobj);
      Xobj = fileManagementXgrid(Xobj,Sfoldername,Smaininputfile)
      Xobj = calculateDerivatives(Xobj);
      Xobj = transferSystemQuantites(Xobj);
      display(Xobj);
   end 
end


