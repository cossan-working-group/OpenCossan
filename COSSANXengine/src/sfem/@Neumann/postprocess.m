function Xoutput = postprocess(Xobj)
%POSTPROCESS  obtains the statistical moments of the response
%
% See Also:
% http://cossan.cfd.liv.ac.uk/wiki/index.php/postprocess@Neumann
%
% =======================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% =======================================================================

% Start Measuring the time
global OPENCOSSAN
startTime = OPENCOSSAN.Xtimer.currentTime;

OpenCossan.cossanDisp('[Neumann.postprocess] Calculating the statistics of the response started',1);
OpenCossan.cossanDisp(' ',2);

%% Get necessary data from SFEM object

Ndofs           = length(Xobj.MnominalStiffness); % Obtain the no of DOFs
Xinp            = Xobj.Xmodel.Xinput;             % Obtain Input
assert(length(Xinp.CnamesRandomVariableSet)==1,'openCOSSAN:SFEM:checkInput',...
    'Only 1 Random Variable Set is allowed in SFEM.')
Xrvs            = Xinp.Xrvset.(Xinp.CnamesRandomVariableSet{1});    % Obtain RVSET
Crvnames        = Xinp.CnamesRandomVariable;                  % Obtain RV names
Nrvs            = Xinp.NrandomVariables;                      % Obtain No of RVs
Vmeanvalues     = get(Xrvs,'members','mean');     % Obtain the standard deviations of RVs

%% Create SFEM Output Object

Xoutput = SfemOutput('Sdescription','SFEM Output Object','XSfemObject',Xobj,'MmodelDOFs',double(Xobj.MmodelDOFs));

%% Estimate the response statistics using NEUMANN EXPANSION METHOD

% NOTE: I removed the code where u is approximated using the incomplete 
% cholesky factorization of K. This approach worked more efficiently than
% the current one for some problems but for some other problems the current
% one worked better. Hence, it is still an open issue. Moreover, one has to
% define the drop tolerance for the approach with CHOLIN function. 
% => look at the previous versions in order to recover that part

if strcmpi(Xobj.Sanalysis,'Static') 
    % Generate samples for the simulations
    Xsamples = sample(Xrvs,Xobj.Nsimulations);
    Msamples = Xsamples.MsamplesPhysicalSpace;
    % initialize matrix to store responses 
    Mresponses = zeros(Ndofs,Xobj.Nsimulations);
    % Loop over the no of simulations
    for isim = 1:Xobj.Nsimulations
        % Store the responses column-wise (each column - one simulation)
        % Initialize the DeltaK and DeltaF
        MKDelta = sparse(Ndofs,Ndofs);
        VfDelta = sparse(Ndofs,1);      
        % Note that both DeltaK and DeltaF are expressed using Taylor series expansions 
        % (DeltaK = K1'*deltax(1) +  K2'*deltax(2) + ... + KN'*deltax(N) (N = Nrvs) 
        % (DeltaF = f1'*deltax(1) +  f2'*deltax(2) + ... + fN'*deltax(N) (N = Nrvs) 
        for jrvno=1:Nrvs
           if ~isempty(intersect(Crvnames{jrvno},Xobj.CyoungsModulusRVs)) || ...
           ~isempty(intersect(Crvnames{jrvno},Xobj.CthicknessRVs)) || ...
           ~isempty(intersect(Crvnames{jrvno},Xobj.CcrossSectionRVs))
                MKDelta = MKDelta + ...
                          Xobj.CMKi{jrvno}.*(Msamples(isim,jrvno) - Vmeanvalues(jrvno)); 
                if Xobj.NinputApproximationOrder == 2
                    MKDelta = MKDelta + ...
                          (1/2).*Xobj.CMKii{jrvno}.*((Msamples(isim,jrvno) - Vmeanvalues(jrvno))^2); 
                end
           elseif ~isempty(intersect(Crvnames{jrvno},Xobj.CdensityRVs)) ||...
           ~isempty(intersect(Crvnames{jrvno},Xobj.CforceRVs))     
                VfDelta = VfDelta + ...
                          Xobj.CVfi{jrvno}.*(Msamples(isim,jrvno) - Vmeanvalues(jrvno));
                if Xobj.NinputApproximationOrder == 2   
                   VfDelta = VfDelta + ...
                         (1/2).*Xobj.CVfii{jrvno}.*((Msamples(isim,jrvno) - Vmeanvalues(jrvno))^2);
                end
           end
        end    
        % Calculate the P vector (MP) according to Neumann Exp. Notation
        % MP2 is an additional term which has to be taken into account if
        % also the force vector is assumed to be uncertain (see Chakraborty 
        % & Dey, 1995 publication)
        % Approximate response with Neumann Expansion
        % If only K is random
        if Xobj.LrandomStiffness && Xobj.LrandomForce == 0
           MP                 = Xobj.MnominalStiffness\(MKDelta*Xobj.VnominalDisplacement);
           Mresponses(:,isim) = Xobj.VnominalDisplacement;
           for j=1:Xobj.Norder  
                Mresponses(:,isim) = Mresponses(:,isim) + ((-1)^j)*MP;
                MP                 = Xobj.MnominalStiffness\(MKDelta*MP);
           end
        % If both K & f are random
        elseif  Xobj.LrandomStiffness && Xobj.LrandomForce
            Mresponses(:,isim) = Xobj.VnominalDisplacement + Xobj.MnominalStiffness\VfDelta;
            MP              = Xobj.MnominalStiffness\(MKDelta*Mresponses(:,isim));
            for j=1:Xobj.Norder 
                Mresponses(:,isim) = Mresponses(:,isim) + ((-1)^j)*MP;
                MP              = Xobj.MnominalStiffness\(MKDelta*MP);
            end
        % If only F is random, just solve for u for the various force
        % vectors (No need to appr. K, since it is constant)
        elseif Xobj.LrandomForce && Xobj.LrandomStiffness == 0
            Mresponses(:,isim) = Xobj.MnominalStiffness\(Xobj.VnominalForce+VfDelta);
        end
        OpenCossan.cossanDisp(['[Neumann.postprocess] Simulation no ' num2str(isim) ' completed'],2);
    end                  
end

%% Store the responses

Xoutput.Mresponses = Mresponses;

%% Calculating mean,std and cov of displacements

Xoutput.Vmean = mean(Mresponses');  %#ok<*UDIM>
Xoutput.Vstd  = std(Mresponses');
Xoutput.Vcov  = abs(Xoutput.Vstd./Xoutput.Vmean);    

%% stop the time

stopTime = OPENCOSSAN.Xtimer.currentTime;
Xobj.Ccputimes{5} = stopTime - startTime;

OpenCossan.cossanDisp(['[Neumann.postprocess] Calculating the statistics of the response completed in ' num2str(Xobj.Ccputimes{5}) ' sec'],1);

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
OpenCossan.cossanDisp('Total time                                : < 1 sec  ',2);
else
OpenCossan.cossanDisp(['Total time                               : ' num2str(Xobj.Ccputimes{1}) ' sec  '],2);
end
end

if isempty(Xobj.Ccputimes{2})
OpenCossan.cossanDisp('Time for generating the input files       : Not performed ',2);
elseif Xobj.Ccputimes{2} < 1
OpenCossan.cossanDisp('Time for generating the input files       : < 1 sec  ',2);
else
OpenCossan.cossanDisp(['Time for generating the input files      : ' num2str(Xobj.Ccputimes{2}) ' sec  '],2);  
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
