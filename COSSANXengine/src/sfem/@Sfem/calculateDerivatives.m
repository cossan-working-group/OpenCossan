function Xobj = calculateDerivatives(Xobj)
%CALCULATE_DERIVATIVES  it calculates the derivatives of system matrices
%
% See Also:
% http://cossan.cfd.liv.ac.uk/wiki/index.php/calculateDerivatives@SFEM
%
% =======================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% =======================================================================

OpenCossan.cossanDisp('[SFEM.calculateDerivatives] Calculating derivatives of System matrices/vectors started',2);

%% Retrieve necessary data

Xinp            = Xobj.Xmodel.Xinput;               % Obtain Input
assert(length(Xinp.CnamesRandomVariableSet)==1,'openCOSSAN:SFEM:checkInput',...
    'Only 1 Random Variable Set is allowed in SFEM.')
Xrvs            = Xinp.Xrvset.(Xinp.CnamesRandomVariableSet{1});    % Obtain RVSET
Crvnames        = Xinp.CnamesRandomVariable;                  % Obtain RV names
Nrvs            = Xinp.NrandomVariables;                      % Obtain No of RVs
NDOFs           = length(Xobj.MnominalStiffness);
Vstdvalues      = get(Xrvs,'members','std');        % Obtain std dev values of each RV

%% Calculate the K_i & K_ii terms

if isa(Xobj,'SfemPolynomialChaos') && strcmpi(Xobj.Smethod,'Guyan')
    Xobj.CMKi{Nrvs}  = [];
    Xobj.CMKii{Nrvs} = [];
    for irvno=1:Nrvs
        Xobj.CMKi{irvno}  = (Xobj.CMpositivePerturbedStiffness{irvno} - Xobj.CMnegativePerturbedStiffness{irvno})/2;
        Xobj.CMKii{irvno} = (Xobj.CMpositivePerturbedStiffness{irvno} ...
            - 2*Xobj.MnominalStiffness + Xobj.CMnegativePerturbedStiffness{irvno});
    end
    Xobj.CVfi{Nrvs}  = [];
    Xobj.CVfii{Nrvs} = [];
    % f_i will be calculated as:
    %
    % => PA  = fm - K_B
    % => f_i = fm - PA
    % where PA is what you output from NASTRAN
    % fm is the force you have on the m-DOF
    [~,i2,~]  = intersect(Xobj.MmodelDOFs,Xobj.MmasterDOFs,'rows');
    fm        = Xobj.VnominalForce(i2);
    for irvno=1:Nrvs
        Xobj.CVfi{irvno}  = ((fm - Xobj.CVpositivePerturbedRHS{irvno}) - (fm - Xobj.CVnegativePerturbedRHS{irvno}))/2;
        Xobj.CVfii{irvno} = ((fm - Xobj.CVpositivePerturbedRHS{irvno}) ...
            - 2*(fm - Xobj.VnominalRHS) + (fm - Xobj.CVnegativePerturbedRHS{irvno}));
    end
    OpenCossan.cossanDisp('[SFEM.calculateDerivatives] Calculating derivatives of System matrices/vectors completed',2);
    OpenCossan.cossanDisp(' ',2);
    return
end

%%  Calculate derivatives of system matrices for P-C

% NOTE: in P-C formulations, the derivatives have to be with respect to
% std.norm. RV's, (hence division to std. dev. is not necessary), while for
% other methods division to std. dev. is required.

if isa(Xobj,'SfemPolynomialChaos') && strcmpi(Xobj.Smethod,'Galerkin')
    for irvno=1:Nrvs
        % DERIVATIVES OF STIFFNESS
        if ~isempty(intersect(Crvnames{irvno},Xobj.CyoungsModulusRVs)) || ...
                ~isempty(intersect(Crvnames{irvno},Xobj.CthicknessRVs)) || ...
                ~isempty(intersect(Crvnames{irvno},Xobj.CcrossSectionRVs))
            if Xobj.NinputApproximationOrder == 1
                Xobj.CMKi{irvno}  = (Xobj.CMpositivePerturbedStiffness{irvno} - Xobj.MnominalStiffness);
                if Xobj.LrandomForce
                    Xobj.CVfi{irvno}  = sparse(NDOFs,1);
                end
            elseif Xobj.NinputApproximationOrder == 2
                Xobj.CMKi{irvno}  = (Xobj.CMpositivePerturbedStiffness{irvno}...
                    - Xobj.CMnegativePerturbedStiffness{irvno})/2;
                Xobj.CMKii{irvno} = (Xobj.CMpositivePerturbedStiffness{irvno} ...
                    - 2*Xobj.MnominalStiffness + Xobj.CMnegativePerturbedStiffness{irvno});
                if Xobj.LrandomForce
                    Xobj.CVfi{irvno}  = sparse(NDOFs,1);
                    Xobj.CVfii{irvno}  = sparse(NDOFs,1);
                end
            end
            % DERIVATIVES OF FORCE
        elseif ~isempty(intersect(Crvnames{irvno},Xobj.CdensityRVs)) && strcmpi(Xobj.Sanalysis,'Static')
            if Xobj.NinputApproximationOrder == 1
                Xobj.CVfi{irvno}  = (Xobj.CVpositivePerturbedForce{irvno} - Xobj.VnominalForce);
                Xobj.CMKi{irvno}  = sparse(NDOFs,NDOFs);
            elseif Xobj.NinputApproximationOrder == 2
                Xobj.CVfi{irvno}  = (Xobj.CVpositivePerturbedForce{irvno}...
                    - Xobj.CVnegativePerturbedForce{irvno})/2;
                Xobj.CVfii{irvno} = (Xobj.CVpositivePerturbedForce{irvno} ...
                    - 2*Xobj.VnominalForce + Xobj.CVnegativePerturbedForce{irvno});
                Xobj.CMKi{irvno}  = sparse(NDOFs,NDOFs);
                Xobj.CMKii{irvno} = sparse(NDOFs,NDOFs);
            end
            % DERIVATIVES OF FORCE
        elseif ~isempty(intersect(Crvnames{irvno},Xobj.CforceRVs)) && strcmpi(Xobj.Sanalysis,'Static')
            if Xobj.NinputApproximationOrder == 1
                Xobj.CVfi{irvno}  = (Xobj.CVpositivePerturbedForce{irvno} - Xobj.VnominalForce);
                if LrandomStiffness
                    Xobj.CMKi{irvno}  = sparse(NDOFs,NDOFs);
                end
            elseif Xobj.NinputApproximationOrder == 2
                Xobj.CVfi{irvno}  = (Xobj.CVpositivePerturbedForce{irvno}...
                    - Xobj.CVnegativePerturbedForce{irvno})/2;
                Xobj.CVfii{irvno} = (Xobj.CVpositivePerturbedForce{irvno} ...
                    - 2*Xobj.VnominalForce + Xobj.CVnegativePerturbedForce{irvno});
                if Xobj.LrandomStiffness
                    Xobj.CMKi{irvno}  = sparse(NDOFs,NDOFs);
                    Xobj.CMKii{irvno} = sparse(NDOFs,NDOFs);
                end
            end
        end
    end
    OpenCossan.cossanDisp('[SFEM.calculateDerivatives] Calculating derivatives of System matrices/vectors completed',2);
    OpenCossan.cossanDisp(' ',2);
    return
end

%% Calculate derivatives of system matrices (for all other cases)

for irvno=1:Nrvs
    % Calculate derivatives of STIFFNESS
    if ~isempty(intersect(Crvnames{irvno},Xobj.CyoungsModulusRVs)) || ...
       ~isempty(intersect(Crvnames{irvno},Xobj.CthicknessRVs)) || ...
       ~isempty(intersect(Crvnames{irvno},Xobj.CcrossSectionRVs))
        if Xobj.NinputApproximationOrder == 1
            Xobj.CMKi{irvno} = ...
             (Xobj.CMpositivePerturbedStiffness{irvno} - Xobj.MnominalStiffness)/(Vstdvalues(irvno));
        elseif Xobj.NinputApproximationOrder == 2
            Xobj.CMKi{irvno} = ...
             (Xobj.CMpositivePerturbedStiffness{irvno} - Xobj.CMnegativePerturbedStiffness{irvno})/(2*Vstdvalues(irvno));
            Xobj.CMKii{irvno} = ...
                (Xobj.CMpositivePerturbedStiffness{irvno} - 2*Xobj.MnominalStiffness + Xobj.CMnegativePerturbedStiffness{irvno})...
                /(Vstdvalues(irvno)^2);
        end
    % Calculate derivatives of FORCE
    elseif ~isempty(intersect(Crvnames{irvno},Xobj.CdensityRVs)) && strcmpi(Xobj.Sanalysis,'Static')
        if Xobj.NinputApproximationOrder == 1
            Xobj.CVfi{irvno} = ...
             (Xobj.CVpositivePerturbedForce{irvno} - Xobj.VnominalForce)/(Vstdvalues(irvno));
        elseif Xobj.NinputApproximationOrder == 2
            Xobj.CVfi{irvno} = ...
             (Xobj.CVpositivePerturbedForce{irvno} - Xobj.CVnegativePerturbedForce{irvno})/(2*Vstdvalues(irvno));
            Xobj.CVfii{irvno} = ...
                (Xobj.CVpositivePerturbedForce{irvno} - 2*Xobj.VnominalForce + Xobj.CVnegativePerturbedForce{irvno})...
                /(Vstdvalues(irvno)^2);
        end
    % Calculate derivatives of FORCE
    elseif ~isempty(intersect(Crvnames{irvno},Xobj.CforceRVs)) && strcmpi(Xobj.Sanalysis,'Static')
        if Xobj.NinputApproximationOrder == 1
            Xobj.CVfi{irvno} = ...
             (Xobj.CVpositivePerturbedForce{irvno} - Xobj.VnominalForce)/(Vstdvalues(irvno));
        elseif Xobj.NinputApproximationOrder == 2
            Xobj.CVfi{irvno} = ...
             (Xobj.CVpositivePerturbedForce{irvno} - Xobj.CVnegativePerturbedForce{irvno})/(2*Vstdvalues(irvno));
            Xobj.CVfii{irvno} = ...
                (Xobj.CVpositivePerturbedForce{irvno} - 2*Xobj.VnominalForce + Xobj.CVnegativePerturbedForce{irvno})...
                /(Vstdvalues(irvno)^2);
        end
    % Calculate derivatives of MASS   
    elseif ~isempty(intersect(Crvnames{irvno},Xobj.CdensityRVs)) && strcmpi(Xobj.Sanalysis,'Modal')
        if Xobj.NinputApproximationOrder == 1
        Xobj.CMMi{irvno} = ...
             (Xobj.CMpositivePerturbedMass{irvno} - Xobj.MnominalMass)/(Vstdvalues(irvno));
        elseif Xobj.NinputApproximationOrder == 2
            Xobj.CMMi{irvno} = ...
             (Xobj.CMpositivePerturbedMass{irvno} - Xobj.CMnegativePerturbedMass{irvno})/(2*Vstdvalues(irvno));
            Xobj.CMMii{irvno} = ...
                (Xobj.CMpositivePerturbedMass{irvno} - 2*Xobj.MnominalMass + Xobj.CMnegativePerturbedMass{irvno})...
                /(Vstdvalues(irvno)^2);
        end
    end

end

OpenCossan.cossanDisp('[SFEM.calculateDerivatives] Calculating derivatives of System matrices/vectors completed',2);

return

