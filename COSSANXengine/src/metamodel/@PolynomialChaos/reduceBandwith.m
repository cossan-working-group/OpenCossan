function Xobj = reduceBandwith(Xobj)
%REDUCEBANDWITH
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/reduceBandwith@PolynomialChaos
%
% =======================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% =======================================================================

OpenCossan.cossanDisp('[PolynomialChaos.reduceBandwith] Reducing the bandwith of Nominal Stiffness matrix started',3);

%% Retrieve the data

Xsfem      = Xobj.Xsfem;
Xinp       = Xsfem.Xmodel.Xinput;             % Obtain Input
Crvnames   = Xinp.CnamesRandomVariable;       % Obtain RV names
Nrvs       = Xinp.NrandomVariables;           % Obtain No of RVs


%% Obtain the reordering index to reduce the bandwith of nominal K
% NOTE: Sparse reverse Cuthill-McKee ordering is used for this purpose

p = symrcm(Xsfem.MnominalStiffness);

%% Reorder all system quantities accordingly

Xsfem.MnominalStiffness     = Xsfem.MnominalStiffness(p,p);   % Reorder nominal K
Xsfem.VnominalForce         = Xsfem.VnominalForce(p);         % Reorder nominal f
Xsfem.VnominalDisplacement  = Xsfem.VnominalDisplacement(p);  % Reorder nominal u
Xsfem.MmodelDOFs(:,1)       = Xsfem.MmodelDOFs(p,1);          % Reorder DOFs
Xsfem.MmodelDOFs(:,2)       = Xsfem.MmodelDOFs(p,2);          % Reorder DOFs

% reorder stiffness
for irvno = 1:Nrvs
   if ~isempty(intersect(Crvnames{irvno},Xsfem.CyoungsModulusRVs)) || ...
   ~isempty(intersect(Crvnames{irvno},Xsfem.CthicknessRVs)) || ...
   ~isempty(intersect(Crvnames{irvno},Xsfem.CcrossSectionRVs))
       Xsfem.CMKi{irvno} = Xsfem.CMKi{irvno}(p,p);
       if Xsfem.NinputApproximationOrder == 2
            Xsfem.CMKii{irvno} = Xsfem.CMKii{irvno}(p,p);
       end
   elseif ~isempty(intersect(Crvnames{irvno},Xsfem.CdensityRVs)) && strcmp(Xsfem.Sanalysis,'Static')
       Xsfem.CVfi{irvno} = Xsfem.CVfi{irvno}(p);
       if Xsfem.NinputApproximationOrder == 2
            Xsfem.CVfii{irvno} = Xsfem.CVfii{irvno}(p);
       end    
   elseif ~isempty(intersect(Crvnames{irvno},Xsfem.CforceRVs)) && strcmp(Xsfem.Sanalysis,'Static')
       Xsfem.CVfi{1} = Xsfem.CVfi{1}(p);
       if Xsfem.NinputApproximationOrder == 2
            Xsfem.CVfii{1} = Xsfem.CVfii{1}(p);
       end        
   end
end

OpenCossan.cossanDisp('[PolynomialChaos.reduceBandwith] Reducing the bandwith of Nominal Stiffness matrix completed',3);

return
