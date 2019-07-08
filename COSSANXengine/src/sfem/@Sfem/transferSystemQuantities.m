function Xobj = transferSystemQuantities(Xobj)
%TRANSFERSYSTEMQUANTITIES  Method to perform SFEM Analysis
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/transferSystemQuantities@SFEM
%
% =======================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% =======================================================================

% Start measuring CPU time for matrix transfer 
global OPENCOSSAN
startTime = OPENCOSSAN.Xtimer.currentTime;
OpenCossan.cossanDisp('[SFEM.transferSystemQuantities] Transfer of System matrices/vectors started',1);

%% Retrieve input data
Xinp            = Xobj.Xmodel.Xinput;                                 % Obtain Input
assert(length(Xinp.CnamesRandomVariableSet)==1,'openCOSSAN:SFEM:checkInput',...
    'Only 1 Random Variable Set is allowed in SFEM.')
Xrvs            = Xinp.Xrvset.(Xinp.CnamesRandomVariableSet{1});    % Obtain RVSET
Crvnames        = Xinp.CnamesRandomVariable;                  % Obtain RV names
Nrvs            = Xinp.NrandomVariables;                      % Obtain No of RVs
Sfesolver       = Xobj.Xmodel.Xevaluator.CXsolvers{1}.Stype;          % Obtain FE solver type
    
%% Read the nominal quantities

% Read the DOFs
% If NASTRAN is used, read from PUNCH format
if strcmpi(Sfesolver(1:5),'nastr')
    Xobj.Sjobname   = upper(Xobj.Sjobname);  % Since NASTRAN is case-insensitive
    dummy = PunchExtractor('Sworkingdirectory',OpenCossan.getCossanWorkingPath,'Sfile',[Xobj.Sjobname '_DOFS.PCH'],'Soutputname','dofs');
    Tout = extract(dummy);
    Xobj.MmodelDOFs = Tout.dofs;
% If ANSYS is used, read from MAPPING format
elseif strcmpi(Sfesolver,'ansys')
    dummy = MappingExtractor('Sworkingdirectory',OpenCossan.getCossanWorkingPath,'Sfile',[Xobj.Sjobname '_K_NOMINAL.mapping'],'Soutputname','dofs');
    Tout = extract(dummy);
    Xobj.MmodelDOFs = Tout.dofs;
% If ABAQUS is used, read from MTX file
% NOTE: in case of ABAQUS, stiffness matrix is also output, so this is
% read here as well
elseif strcmpi(Sfesolver,'abaqus')
    dummy = MTXExtractor('Sworkingdirectory',OpenCossan.getCossanWorkingPath,'Sfile',[Xobj.Sjobname '_K_NOMINAL.mtx'],'Soutputname','stiffness');
    [Tout, ~, Vnodes, Vdofs]  = extract(dummy);
    % Since ABAQUS output matrices in global size, i.e. without removing
    % the constrained DOFs, it is necessary to remove those DOFs here
    MglobalDOFs     = [Vnodes Vdofs];
    [Xobj.MmodelDOFs VunconstrainedEntries] = setdiff(MglobalDOFs,Xobj.MconstrainedDOFs,'rows');
end

% Read the NOMINAL STIFFNESS
% If NASTRAN is used, read from OP4 format
if strcmpi(Sfesolver(1:5),'nastr')
    dummy = Op4Extractor('Sworkingdirectory',OpenCossan.getCossanWorkingPath,'Sfile',[Xobj.Sjobname '_K_NOMINAL.OP4'],'Soutputname','stiffness');
    Tout  = extract(dummy);
    Xobj.MnominalStiffness = Tout.stiffness;
% If ANSYS is used, read from HB format
elseif strcmpi(Sfesolver,'ansys')
    dummy = HBExtractor('Sworkingdirectory',OpenCossan.getCossanWorkingPath,'Sfile',[Xobj.Sjobname '_K_NOMINAL'],'Soutputname','stiffness');
    Tout  = extract(dummy);
    Xobj.MnominalStiffness = Tout.stiffness;
elseif strcmpi(Sfesolver,'abaqus')
    % NOTE: In case of ABAQUS, note that K_nominal has been read
    % already during the transfer of DOFs
    Xobj.MnominalStiffness = Tout.stiffness;
    Xobj.MnominalStiffness = Xobj.MnominalStiffness(VunconstrainedEntries,VunconstrainedEntries);
end

% Read RHS PA (Only If Guyan P-C is selected)
if strcmpi(Xobj.Smethod,'Guyan') && strcmpi(Sfesolver(1:5),'nastr')
   dummy = Op4Extractor('Sworkingdirectory',OpenCossan.getCossanWorkingPath,'Sfile',[Xobj.Sjobname '_PA_NOMINAL.OP4'],'Soutputname','rhs');
   Tout  = extract(dummy);
   Xobj.VnominalRHS = Tout.rhs;
end
       
% Read NOMINAL FORCE 
if strcmpi(Xobj.Sanalysis,'Static') && strcmpi(Sfesolver(1:5),'nastr')
    dummy = Op4Extractor('Sworkingdirectory',OpenCossan.getCossanWorkingPath,'Sfile',[Xobj.Sjobname '_F_NOMINAL.OP4'],'Soutputname','force');
    Tout  = extract(dummy);
    if isempty (fields(Tout))
       error('COSSAN:sfem','The force vector is empty. Please make sure that a loading is applied to the structure'); 
    end
    Xobj.VnominalForce = Tout.force;
elseif  strcmpi(Xobj.Sanalysis,'Static') && strcmpi(Sfesolver,'ansys')
    dummy = HBExtractor('Sworkingdirectory',OpenCossan.getCossanWorkingPath,'Sfile',[Xobj.Sjobname '_K_NOMINAL'],'Soutputname','force');
    Tout  = extract(dummy);
    Xobj.VnominalForce = Tout.force;
elseif  strcmpi(Xobj.Sanalysis,'Static') && strcmpi(Sfesolver,'abaqus')
    dummy = MTXExtractor('Sworkingdirectory',OpenCossan.getCossanWorkingPath,'Sfile','nominal_LOAD2.mtx','Soutputname','force');
    Tout  = extract(dummy,'Vnodes',Vnodes,'Vdofs',Vdofs);
    Xobj.VnominalForce = Tout.force;     
end

% Read NOMINAL DISPLACEMENTS
if strcmpi(Xobj.Sanalysis,'Static') && strcmpi(Xobj.Smethod,'Guyan') == 0 ...
   && strcmpi(Sfesolver(1:5),'nastr')
    % Read the nominal response
    dummy = Op4Extractor('Sworkingdirectory',OpenCossan.getCossanWorkingPath,'Sfile',[Xobj.Sjobname '_U_NOMINAL.OP4'],'Soutputname','displacements');
    Tout  = extract(dummy);
    Xobj.VnominalDisplacement = Tout.displacements;
% NOTE: for ANSYS & ABAQUS, there is no possibility to just output 
%       displacements in a file. Hence, instead of parsing through the results
%       file, we solve it here 
elseif  strcmpi(Xobj.Sanalysis,'Static') && strcmpi(Sfesolver,'ansys')  
    Xobj.VnominalDisplacement = Xobj.MnominalStiffness \ Xobj.VnominalForce;
% NOTE: for ABAQUS, it is also necessary to remove the constrained DOFs
%       before performing the solution
elseif  strcmpi(Xobj.Sanalysis,'Static') && strcmpi(Sfesolver,'abaqus')  
    Xobj.VnominalForce        = Xobj.VnominalForce(VunconstrainedEntries);
    Xobj.VnominalDisplacement = Xobj.MnominalStiffness \ Xobj.VnominalForce;
end

% Read NOMINAL MASS & EIGENVALUES & EIGENVECTORS
if strcmpi(Xobj.Sanalysis,'Modal') && strcmpi(Sfesolver(1:5),'nastr')
    % Read the nominal mass matrix
    dummy = Op4Extractor('Sworkingdirectory',OpenCossan.getCossanWorkingPath,'Sfile',[Xobj.Sjobname '_M_NOMINAL.OP4'],'Soutputname','mass');
    Tout  = extract(dummy);
    Xobj.MnominalMass = Tout.mass;
    % Read the nominal eigenvalues
    dummy = Op4Extractor('Sworkingdirectory',OpenCossan.getCossanWorkingPath,'Sfile',[Xobj.Sjobname '_LAMDA_NOMINAL.OP4'],'Soutputname','evalues');
    Tout  = extract(dummy);
    Xobj.MnominalEigenvalues = Tout.evalues;
    % Read the nominal eigenvectors
    dummy = Op4Extractor('Sworkingdirectory',OpenCossan.getCossanWorkingPath,'Sfile',[Xobj.Sjobname '_PHI_NOMINAL.OP4'],'Soutputname','evectors');
    Tout  = extract(dummy);
    Xobj.MnominalEigenvectors = Tout.evectors;    
elseif strcmpi(Xobj.Sanalysis,'Modal') && strcmpi(Sfesolver,'ansys')
    % Read the nominal mass matrix
    dummy = HBExtractor('Sworkingdirectory',OpenCossan.getCossanWorkingPath,'Sfile',[Xobj.Sjobname '_M_NOMINAL'],'Soutputname','mass');
    Tout  = extract(dummy);
    Xobj.MnominalMass = Tout.mass;
    [Xobj.MnominalEigenvectors,Xobj.MnominalEigenvalues] = eigs(Xobj.MnominalStiffness,Xobj.MnominalMass,Xobj.Nmodes,'sm');
elseif strcmpi(Xobj.Sanalysis,'Modal') && strcmpi(Sfesolver,'abaqus')
    % Read the nominal mass matrix
    dummy = MTXExtractor('Sworkingdirectory',OpenCossan.getCossanWorkingPath,'Sfile',[Xobj.Sjobname '_M_NOMINAL.mtx'],'Soutputname','mass');
    Tout  = extract(dummy);
    Xobj.MnominalMass = Tout.mass;
    Xobj.MnominalMass = Xobj.MnominalMass(VunconstrainedEntries,VunconstrainedEntries);
    [Xobj.MnominalEigenvectors,Xobj.MnominalEigenvalues] = eigs(Xobj.MnominalStiffness,Xobj.MnominalMass,Xobj.Nmodes,'sm');
end

%% Read the perturbed system matrices

for irvno=1:Nrvs  
    % Read perturbed STIFFNESS
    if ~isempty(intersect(Crvnames{irvno},Xobj.CyoungsModulusRVs)) || ...
       ~isempty(intersect(Crvnames{irvno},Xobj.CthicknessRVs)) || ...
       ~isempty(intersect(Crvnames{irvno},Xobj.CcrossSectionRVs))
        % If NASTRAN is used, read from OP4 format
        if strcmpi(Sfesolver(1:5),'nastr')
            dummy = Op4Extractor('Sworkingdirectory',OpenCossan.getCossanWorkingPath,'Sfile',[Xobj.Sjobname '_K_POS_PER_'...
                    upper(Crvnames{irvno}) '.OP4'],'Soutputname','stiffness');
        % If ANSYS is used, read from HB format
        elseif strcmpi(Sfesolver,'ansys')
            dummy = HBExtractor('Sworkingdirectory',OpenCossan.getCossanWorkingPath,'Sfile',[Xobj.Sjobname '_K_POS_PER_'...
                    Crvnames{irvno}],'Soutputname','stiffness');
        % If ABAQUS is used, read from MTX format    
        elseif strcmpi(Sfesolver,'abaqus')
            dummy = MTXExtractor('Sworkingdirectory',OpenCossan.getCossanWorkingPath,'Sfile',[Xobj.Sjobname '_K_POS_PER_'...
                    upper(Crvnames{irvno}) '.mtx'],'Soutputname','stiffness');
        end
        Tout  = extract(dummy);
        Xobj.CMpositivePerturbedStiffness{irvno} = Tout.stiffness;  
        if Xobj.NinputApproximationOrder == 2
            % If NASTRAN is used, read from OP4 format
            if strcmpi(Sfesolver(1:5),'nastr')
               dummy = Op4Extractor('Sworkingdirectory',OpenCossan.getCossanWorkingPath,'Sfile',[Xobj.Sjobname '_K_NEG_PER_'...
               upper(Crvnames{irvno}) '.OP4'],'Soutputname','stiffness'); 
            % If ANSYS is used, read from HB format
            elseif strcmpi(Sfesolver,'ansys')
               dummy = HBExtractor('Sworkingdirectory',OpenCossan.getCossanWorkingPath,'Sfile',[Xobj.Sjobname '_K_NEG_PER_'...
               Crvnames{irvno}],'Soutputname','stiffness');     
            % If ABAQUS is used, read from MTX format    
            elseif strcmpi(Sfesolver,'abaqus')
            dummy = MTXExtractor('Sworkingdirectory',OpenCossan.getCossanWorkingPath,'Sfile',[Xobj.Sjobname '_K_NEG_PER_'...
                    upper(Crvnames{irvno}) '.mtx'],'Soutputname','stiffness');
            end
            Tout  = extract(dummy);
            Xobj.CMnegativePerturbedStiffness{irvno} = Tout.stiffness;              
        end
    % Read perturbed FORCE
    elseif ~isempty(intersect(Crvnames{irvno},Xobj.CdensityRVs)) && strcmpi(Xobj.Sanalysis,'Static')
        % If NASTRAN is used, read from OP4 format
        if strcmpi(Sfesolver(1:5),'nastr')
            dummy = Op4Extractor('Sworkingdirectory',OpenCossan.getCossanWorkingPath,'Sfile',[Xobj.Sjobname '_F_POS_PER_' ...
                              upper(Crvnames{irvno}) '.OP4'],'Soutputname','force');
        % If ANSYS is selected, the force vector is already included in the
        % matrix files, so forces are read from these                  
        elseif strcmpi(Sfesolver,'ansys')
            dummy = HBExtractor('Sworkingdirectory',OpenCossan.getCossanWorkingPath,'Sfile',[Xobj.Sjobname '_F_POS_PER_' ...
                              Crvnames{irvno}],'Soutputname','force');       
        end
        Tout  = extract(dummy);
        Xobj.CVpositivePerturbedForce{irvno} = Tout.force; 
        if Xobj.NinputApproximationOrder == 2
            % If NASTRAN is used, read from OP4 format
            if strcmpi(Sfesolver(1:5),'nastr')
                dummy = Op4Extractor('Sworkingdirectory',OpenCossan.getCossanWorkingPath,'Sfile',[Xobj.Sjobname '_F_NEG_PER_'...
                    upper(Crvnames{irvno}) '.OP4'],'Soutputname','force');
                % If ANSYS is used, read from HB format
            elseif strcmpi(Sfesolver,'ansys')
                dummy = HBExtractor('Sworkingdirectory',OpenCossan.getCossanWorkingPath,'Sfile',[Xobj.Sjobname '_F_NEG_PER_' ...
                    Crvnames{irvno}],'Soutputname','force');
            end
            Tout  = extract(dummy);
            Xobj.CVnegativePerturbedForce{irvno} = Tout.force;
        end
    % Read perturbed FORCE
    elseif ~isempty(intersect(Crvnames{irvno},Xobj.CforceRVs)) && strcmpi(Xobj.Sanalysis,'Static')
        % If NASTRAN is used, read from OP4 format
        if strcmpi(Sfesolver(1:5),'nastr')
            dummy = Op4Extractor('Sworkingdirectory',OpenCossan.getCossanWorkingPath,'Sfile',[Xobj.Sjobname '_F_POS_PER_' ...
                              upper(Crvnames{irvno}) '.OP4'],'Soutputname','force');
        % If ANSYS is selected, the force vector is already included in the
        % matrix files, so forces are read from these                  
        elseif strcmpi(Sfesolver,'ansys')
            dummy = HBExtractor('Sworkingdirectory',OpenCossan.getCossanWorkingPath,'Sfile',[Xobj.Sjobname '_F_POS_PER_' ...
                              Crvnames{irvno}],'Soutputname','force');       
        end
        Tout  = extract(dummy);
        Xobj.CVpositivePerturbedForce{irvno} = Tout.force; 
        if Xobj.NinputApproximationOrder == 2
            % If NASTRAN is used, read from OP4 format
            if strcmpi(Sfesolver(1:5),'nastr')
                dummy = Op4Extractor('Sworkingdirectory',OpenCossan.getCossanWorkingPath,'Sfile',[Xobj.Sjobname '_F_NEG_PER_'...
                    upper(Crvnames{irvno}) '.OP4'],'Soutputname','force');
                % If ANSYS is used, read from HB format
            elseif strcmpi(Sfesolver,'ansys')
                dummy = HBExtractor('Sworkingdirectory',OpenCossan.getCossanWorkingPath,'Sfile',[Xobj.Sjobname '_F_NEG_PER_' ...
                    Crvnames{irvno}],'Soutputname','force');
            end
            Tout  = extract(dummy);
            Xobj.CVnegativePerturbedForce{irvno} = Tout.force;
        end
    % Read perturbed MASS   
    elseif ~isempty(intersect(Crvnames{irvno},Xobj.CdensityRVs)) && strcmpi(Xobj.Sanalysis,'Modal')
        if strcmpi(Sfesolver(1:5),'nastr')
            dummy = Op4Extractor('Sworkingdirectory',OpenCossan.getCossanWorkingPath,'Sfile',[Xobj.Sjobname '_M_POS_PER_' ...
                    upper(Crvnames{irvno}) '.OP4'],'Soutputname','mass');
        elseif strcmpi(Sfesolver,'ansys')
            dummy = HBExtractor('Sworkingdirectory',OpenCossan.getCossanWorkingPath,'Sfile',[Xobj.Sjobname '_M_POS_PER_' ...
                    Crvnames{irvno}],'Soutputname','mass');
        elseif strcmpi(Sfesolver,'abaqus')
            dummy = HBExtractor('Sworkingdirectory',OpenCossan.getCossanWorkingPath,'Sfile',[Xobj.Sjobname '_M_POS_PER_' ...
                    Crvnames{irvno} '.mtx'],'Soutputname','mass');
        end
        Tout  = extract(dummy);
        Xobj.CMpositivePerturbedMass{irvno} = Tout.mass;   
    end
end

    
%% Assemble the global system matrices - applies only for COMPONENTWISE IMPLEMENTATION

if strcmpi(Xobj.Simplementation,'Componentwise')
    for irvno=1:Nrvs
        if ~isempty(intersect(Crvnames{irvno},Xobj.CyoungsModulusRVs)) || ...
           ~isempty(intersect(Crvnames{irvno},Xobj.CthicknessRVs))|| ...
           ~isempty(intersect(Crvnames{irvno},Xobj.CcrossSectionRVs))
            % Read DOFs of COMPONENT
            dummy = PunchExtractor('Sworkingdirectory',OpenCossan.getCossanWorkingPath,'Sfile',[Xobj.Sjobname '_KDOFS_'...
                    upper(Crvnames{irvno}) '.PCH'],'Soutputname','dofs');
            Tout  = extract(dummy);
            Xobj.CMcomponentDOFs{irvno} = Tout.dofs;
            % Read NOMINAL COMPONENT STIFFNESS MATRIX
            dummy = Op4Extractor('Sworkingdirectory',OpenCossan.getCossanWorkingPath,'Sfile',[Xobj.Sjobname...
            '_K_NOM_' upper(Crvnames{irvno}) '.OP4'],'Soutputname','stiffness');
            Tout  = extract(dummy);
            Xobj.CMnominalComponentStiffness{irvno} = Tout.stiffness; 
            % ASSEMBLE GLOBAL STIFFNESS MATRIX 
            MK1        = sparse(length(Xobj.MmodelDOFs),length(Xobj.MmodelDOFs));
            [~,i2,i3]  = intersect(Xobj.CMcomponentDOFs{irvno},Xobj.MmodelDOFs,'rows');
            MK1(i3,i3) = Xobj.CMpositivePerturbedStiffness{irvno}(i2,i2) - Xobj.CMnominalComponentStiffness{irvno};          %#ok<*SPRIX>
            Xobj.CMpositivePerturbedStiffness{irvno} = MK1 + Xobj.MnominalStiffness;
            if Xobj.NinputApproximationOrder == 2
                MK2 = sparse(length(Xobj.MmodelDOFs),length(Xobj.MmodelDOFs));
                MK2(i3,i3) = Xobj.CMnegativePerturbedStiffness{irvno}(i2,i2) - Xobj.CMnominalComponentStiffness{irvno}; 
                Xobj.CMnegativePerturbedStiffness{irvno} = MK2 + Xobj.MnominalStiffness;
            end
        elseif ~isempty(intersect(Crvnames{irvno},Xobj.CdensityRVs)) && strcmpi(Xobj.Sanalysis,'Modal')
             % Read DOFs of COMPONENT
            dummy = PunchExtractor('Sworkingdirectory',OpenCossan.getCossanWorkingPath,'Sfile',[Xobj.Sjobname '_MDOFS_'...
                    upper(Crvnames{irvno}) '.PCH'],'Soutputname','dofs');
            Tout  = extract(dummy);
            Xobj.CMcomponentDOFs{irvno} = Tout.dofs;
            % Read NOMINAL COMPONENT MASS MATRIX
            dummy = Op4Extractor('Sworkingdirectory',OpenCossan.getCossanWorkingPath,'Sfile',[Xobj.Sjobname...
            '_M_NOM_' upper(Crvnames{irvno}) '.OP4'],'Soutputname','mass');
            Tout  = extract(dummy);
            Xobj.CMnominalComponentMass{irvno} = Tout.mass; 
            % ASSEMBLE GLOBAL STIFFNESS MATRIX 
            MK1        = sparse(length(Xobj.MmodelDOFs),length(Xobj.MmodelDOFs));
            [~,i2,i3]  = intersect(Xobj.CMcomponentDOFs{irvno},Xobj.MmodelDOFs,'rows');
            MK1(i3,i3) = Xobj.CMpositivePerturbedMass{irvno}(i2,i2) - Xobj.CMnominalComponentMass{irvno}; %#ok<*SPRIX>
            Xobj.CMpositivePerturbedMass{irvno} = MK1 + Xobj.MnominalMass;
            if Xobj.NinputApproximationOrder == 2
                MK2 = sparse(length(Xobj.MmodelDOFs),length(Xobj.MmodelDOFs));
                MK2(i3,i3) = Xobj.CMnegativePerturbedMass{irvno}(i2,i2) - Xobj.CMnominalComponentMass{irvno}; 
                Xobj.CMnegativePerturbedMass{irvno} = MK2 + Xobj.MnominalMass;
            end          
        end
    end
end

%% Read the additional perturbed RHS (Right Hand Side) for GUYAN P-C

if strcmpi(Xobj.Smethod,'Guyan')
    for irvno=1:Nrvs
        % Read POSITIVE Perturbed
        dummy = Op4Extractor('Sworkingdirectory',OpenCossan.getCossanWorkingPath,'Sfile',[Xobj.Sjobname '_PA_POS_PER_'...
        upper(Crvnames{irvno}) '.OP4'],'Soutputname','rhs');
        Tout  = extract(dummy);
        Xobj.CVpositivePerturbedRHS{irvno} = Tout.rhs; 
        % Read NEGATIVE Perturbed
        dummy = Op4Extractor('Sworkingdirectory',OpenCossan.getCossanWorkingPath,'Sfile',[Xobj.Sjobname '_PA_NEG_PER_'...
        upper(Crvnames{irvno}) '.OP4'],'Soutputname','rhs');
        Tout  = extract(dummy);
        Xobj.CVnegativePerturbedRHS{irvno} = Tout.rhs; 
    end
end

%% if ABAQUS used, remove the constrained DOFs 

if strcmpi(Sfesolver,'abaqus')
    for irvno=1:Nrvs
        Xobj.CMpositivePerturbedStiffness{irvno} = ...
            Xobj.CMpositivePerturbedStiffness{irvno}(VunconstrainedEntries,VunconstrainedEntries);
    end
end

%% store the input data if requested

if Xobj.Lstoreinput
   save SFEM Xobj
end

%% Clean the files if requested

if Xobj.Lcleanfiles
    if strcmpi(Sfesolver(1:5),'nastr')
        delete(fullfile(OpenCossan.getCossanWorkingPath, '*.OP4'));
        delete(fullfile(OpenCossan.getCossanWorkingPath, '*.PCH'));
    elseif strcmpi(Sfesolver,'ansys')
        delete(fullfile(OpenCossan.getCossanWorkingPath,[Xobj.Sjobname '_K_*']));
        if strcmp(Xobj.Sanalysis,'Modal')
            delete(fullfile(OpenCossan.getCossanWorkingPath,[Xobj.Sjobname '_M_*']));
        end
    elseif strcmpi(Sfesolver,'abaqus')
        delete(fullfile(OpenCossan.getCossanWorkingPath,'*.mtx'));
    end
end

%% Stop the clock

stopTime = OPENCOSSAN.Xtimer.currentTime;
Xobj.Ccputimes{4} = stopTime - startTime;

OpenCossan.cossanDisp(['[SFEM.transferSystemQuantities] Transfer of System matrices/vectors completed in ' num2str(Xobj.Ccputimes{4}) ' sec'],1);

end

