function Xoutput = postprocess(Xobj)
%POSTPROCESS  obtains the statistical moments of the response
%
% See Also:
% http://cossan.cfd.liv.ac.uk/wiki/index.php/postprocess@Perturbation
%
% =======================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% =======================================================================

% Start Measuring the time
global OPENCOSSAN
startTime = OPENCOSSAN.Xtimer.currentTime;

OpenCossan.cossanDisp('[Perturbation.postprocess] Calculating the statistics of the response started',1);

%% Get necessary data from SFEM object

Ndofs           = length(Xobj.MnominalStiffness);   % Obtain the no of DOFs
Xinp            = Xobj.Xmodel.Xinput;               % Obtain Input
assert(length(Xinp.CnamesRandomVariableSet)==1,'openCOSSAN:SFEM:checkInput',...
    'Only 1 Random Variable Set is allowed in SFEM.')
Xrvs            = Xinp.Xrvset.(Xinp.CnamesRandomVariableSet{1});    % Obtain RVSET
Crvnames        = Xinp.CnamesRandomVariable;                  % Obtain RV names
Nrvs            = Xinp.NrandomVariables;                      % Obtain No of RVs
Vstdvalues      = get(Xrvs,'members','std');        % Obtain std dev values of each RV
Nmodes          = length(Xobj.MnominalEigenvalues); % No of the mode for which the statistics are to be calculated
Mcorr           = get(Xrvs, 'Mcorrelation');        % Obtain the Correlations of RVs
Sfesolver       = Xobj.Xmodel.Xevaluator.CXsolvers{1}.Stype;    % Obtain FE solver type

%% Create SFEM Output Object

Xoutput = SfemOutput('Sdescription','SFEM Output Object','XSfemObject',Xobj,'MmodelDOFs',double(Xobj.MmodelDOFs));

%% Estimate the response statistics using SFEM-PERTURBATION

if strcmpi(Xobj.Sanalysis,'Static') 
    Mui  = zeros(Nrvs,Ndofs); 
    % Calculate derivatives of u
    for irvno=1:Nrvs
        if ~isempty(intersect(Crvnames{irvno},Xobj.CyoungsModulusRVs)) || ...
           ~isempty(intersect(Crvnames{irvno},Xobj.CthicknessRVs))
            Mui(irvno,:) = Xobj.MnominalStiffness \ ((-Xobj.CMKi{irvno})*Xobj.VnominalDisplacement); 
        elseif ~isempty(intersect(Crvnames{irvno},Xobj.CdensityRVs)) && ...
               strcmpi(Xobj.Sanalysis,'Static')
            Mui(irvno,:) = Xobj.MnominalStiffness \ ((Xobj.CVfi{irvno})); 
        elseif ~isempty(intersect(Crvnames{irvno},Xobj.CforceRVs)) && ...
               strcmpi(Xobj.Sanalysis,'Static')
            Mui(irvno,:) = Xobj.MnominalStiffness \ ((Xobj.CVfi{irvno})); 
        end
    end
    
    Vvariance = zeros(Ndofs,1);
    % Calculating the std dev of response according to 1. order perturbation formulation 
    %
    % NOTE: the variation of the RVs are taken into account in this stage
    %       => the derivatives calculated previously are independent ofSfesolver       = Xobj.Xmodel.Xevaluator.CXsolvers{1}.Stype;          % Obtain FE solver type
    %       the variation of RVs (K' = deltaK/deltaX, where X is the RV)
    %
    for i=1:Nrvs
        for j=1:Nrvs
            Vvariance = Vvariance + (Mui(i,:).*Mui(j,:)*Mcorr(i,j) * (Vstdvalues(i)*Vstdvalues(j)))';                   
        end
    end
    % Calculating mean,std and cov of response
    Xoutput.Vmean = Xobj.VnominalDisplacement;
    Xoutput.Vstd  = sqrt(Vvariance);
    Xoutput.Vcov  = abs(Xoutput.Vstd./Xoutput.Vmean);
elseif strcmpi(Xobj.Sanalysis,'Modal')
    if strcmpi(Sfesolver(1:5),'nastr')
        % Obtain the corresponding nominal eigenvalue
        Vlamda0 = Xobj.MnominalEigenvalues(:,1);
        % Obtain the corresponding nominal eigenvector
        VPhii  = Xobj.MnominalEigenvectors;
        % Calculate derivatives of eigenvalues
        Mlamdai = zeros(Nmodes,Nrvs); 
    elseif strcmpi(Sfesolver,'ansys')
        % Obtain the corresponding nominal eigenvalue
        % NOTE: here the vector is reversed in order to have the eigenvalues in 
        %       increasing order
        Vlamda0 = wrev(diag(Xobj.MnominalEigenvalues));
        % Obtain the corresponding nominal eigenvector
        % NOTE: similarly the eigenvectors are re-ordered (see the above note)
        VPhii  = fliplr(Xobj.MnominalEigenvectors);
        % Calculate derivatives of eigenvalues
        Mlamdai = zeros(Nmodes,Nrvs); 
    elseif strcmpi(Sfesolver,'abaqus')
        % Obtain the corresponding nominal eigenvalue
        % NOTE: here the vector is reversed in order to have the eigenvalues in 
        %       increasing order
        Vlamda0 = wrev(diag(Xobj.MnominalEigenvalues));
        % Obtain the corresponding nominal eigenvector
        % NOTE: similarly the eigenvectors are re-ordered (see the above note)
        VPhii  = fliplr(Xobj.MnominalEigenvectors);
        % Calculate derivatives of eigenvalues
        Mlamdai = zeros(Nmodes,Nrvs); 
    end
    for imode=1:Nmodes
        for irvno=1:Nrvs
            if ~isempty(intersect(Crvnames{irvno},Xobj.CyoungsModulusRVs))
                Mlamdai(imode,irvno) = VPhii(:,imode)'*(Xobj.CMKi{irvno}*Vstdvalues(irvno))*VPhii(:,imode);
            elseif ~isempty(intersect(Crvnames{irvno},Xobj.CdensityRVs))
                Mlamdai(imode,irvno) = VPhii(:,imode)'*(-Vlamda0(imode)*Xobj.CMMi{irvno}*Vstdvalues(irvno))*VPhii(:,imode);
            end
        end
    end
    Vlamdavar = zeros(Nmodes,1);
    for imode=1:Nmodes
        Vlamdaprimes = Mlamdai(imode,:).^2;
        if Nrvs==1
            Vlamdavar(imode) = Vlamdaprimes;
        else
            Vlamdavar(imode) = sum(Vlamdaprimes);
        end
    end
    % Calculating mean,std and cov of response
    Xoutput.Vmean = Vlamda0;
    Xoutput.Vstd  = sqrt(Vlamdavar);
    Xoutput.Vcov  = abs(Xoutput.Vstd./Xoutput.Vmean);
end

%% stop time

stopTime = OPENCOSSAN.Xtimer.currentTime;
Xobj.Ccputimes{5} = stopTime - startTime;

OpenCossan.cossanDisp(' ',1);
OpenCossan.cossanDisp(['[Perturbation.postprocess] Calculating the statistics of the response completed in ' num2str(Xobj.Ccputimes{5}) ' sec'],1);
OpenCossan.cossanDisp(' ',1);

%% Calculate the overall total time

Xobj.Ccputimes{1} = Xobj.Ccputimes{2} + Xobj.Ccputimes{3} + Xobj.Ccputimes{4} + Xobj.Ccputimes{5};
% store the times also in the output object (so that they can be reported)
Xoutput.XSfemObject.Ccputimes = Xobj.Ccputimes;

%% Finish Analysis

OpenCossan.cossanDisp('------------------------------- ',1);
OpenCossan.cossanDisp('COSSAN completed SFEM analysis ', 1);
OpenCossan.cossanDisp('------------------------------- ',1);

%% Display the Summary of CPU times

if ~isempty(Xobj.Ccputimes)
OpenCossan.cossanDisp('====================================== ',2);
OpenCossan.cossanDisp(' Summary of CPU times ',2);
OpenCossan.cossanDisp('====================================== ',2);
if Xobj.Ccputimes{1} < 1
OpenCossan.cossanDisp('Total time                               : < 1 sec  ',2);
else
OpenCossan.cossanDisp(['Total time                              : ' num2str(Xobj.Ccputimes{1}) ' sec  '],2);
end
end

if isempty(Xobj.Ccputimes{2})
OpenCossan.cossanDisp('Time for generating the input files      : Not performed ',2);
elseif Xobj.Ccputimes{2} < 1
OpenCossan.cossanDisp('Time for generating the input files      : < 1 sec  ',2);
else
OpenCossan.cossanDisp(['Time for generating the input files     : ' num2str(Xobj.Ccputimes{2}) ' sec  '],2);  
end

if isempty(Xobj.Ccputimes{3})
OpenCossan.cossanDisp('Time for running 3rd party FE solver     : Not performed ',2);
elseif isempty(Xobj.Ccputimes{3})==0 && Xobj.Ccputimes{3} < 1
OpenCossan.cossanDisp('Time for running 3rd party FE solver      : < 1 sec  ',2);
else
OpenCossan.cossanDisp(['Time for running 3rd party FE solver     : ' num2str(Xobj.Ccputimes{3}) ' sec  '],2);   
end

if isempty(Xobj.Ccputimes{4})
OpenCossan.cossanDisp('Time for transferring matrices to MATLAB  : Not performed ',2);
elseif isempty(Xobj.Ccputimes{3})==0 && Xobj.Ccputimes{4} < 1
OpenCossan.cossanDisp('Time for transferring matrices to MATLAB  : < 1 sec  ',2);
else
OpenCossan.cossanDisp(['Time for transferring matrices to MATLAB : ' num2str(Xobj.Ccputimes{4}) ' sec  '],2); 
end

if Xobj.Ccputimes{5} < 1
OpenCossan.cossanDisp('Time for calculating statistics           : < 1 sec  ',2);
else
OpenCossan.cossanDisp(['Time for calculating statistics          : ' num2str(Xobj.Ccputimes{5}) ' sec  '],2); 
end

return
