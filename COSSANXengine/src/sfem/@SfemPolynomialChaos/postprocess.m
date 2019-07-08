function Xoutput = postprocess(Xobj)
%POSTPROCESS  obtains the statistical moments of the response
%
% See Also:
% http://cossan.cfd.liv.ac.uk/wiki/index.php/postprocess@SfemPolynomialChaos
%
% =======================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% =======================================================================

global OPENCOSSAN
% Start Measuring the time
startTime = OPENCOSSAN.Xtimer.currentTime;
OpenCossan.cossanDisp('[SfemPolynomialChaos.postprocess] Calculating the statistics of the response started',1);
OpenCossan.cossanDisp(' ',1);

%% Calculate the PC coefficients

Xpc = PolynomialChaos('Xsfem',Xobj,'Sbasis',Xobj.Sbasis);
Xpc = calibrate(Xpc); % WHY all the computations are executed in the method POSTPROCESS???

%% Get data

Mpccoefficients  = Xpc.Mpccoefficients;          % Obtain the calculated P-C coefficients
Npccoefficients  = Xpc.Npccoefficients;          % Obtain no of P-C coefficients
Norder           = Xobj.Norder;                  % Obtain the order of P-C
Xinp             = Xobj.Xmodel.Xinput;           % Obtain Input
assert(length(Xinp.CnamesRandomVariableSet)==1,'openCOSSAN:SFEM:checkInput',...
    'Only 1 Random Variable Set is allowed in SFEM.')
Xrvs            = Xinp.Xrvset.(Xinp.CnamesRandomVariableSet{1});    % Obtain RVSET
Crvnames        = Xinp.CnamesRandomVariable;                  % Obtain RV names
Nrvs            = Xinp.NrandomVariables;                      % Obtain No of RVs
%% Create SFEM Output Object

Xoutput = SfemOutput('Sdescription','SFEM Output Object',...
                     'XSfemObject',Xobj,'MmodelDOFs',double(Xobj.MmodelDOFs),'Xpc',Xpc);

%% Retrieve CPU times for Preconditioner & Iterative Solver

if ~strcmpi(Xobj.Smethod,'Collocation')
    Xobj.preconditionertime = Xpc.Ccputimes{1}; 
    Xobj.solvertime         = Xpc.Ccputimes{2};
end

%% load the Vpsii2 coefficients 

load(fullfile(OPENCOSSAN.SmatlabDatabasePath,'PCterms','vpsii2_coefficients',...
    ['vpsii2_coeffs_', num2str(Nrvs), '_', num2str(Norder), '.mat']));

%% Estimate the response statistics using SFEM-PC

if strcmpi(Xobj.Smethod,'Collocation')
    % Calculating mean,std and cov of response
    % the first coefficients determine the mean for each DOF
    Xoutput.Vmean = Mpccoefficients(:,1);
    % Calculate Variance of response
    variance = 0;
    % the indexing is done such that the first coefficients are ignored
    % since they are used only for the mean calculation
    for i=2:Npccoefficients
        variance = variance+ Vpsii2(i).*Mpccoefficients(:,i).^2;
    end
    % If the method is chosen as collocation, only one response can be
    % propagated. Therefore this part treated separately here. The function
    % quits after following is done
    Xoutput.Vstd = sqrt(variance);
    Xoutput.Vcov = abs(Xoutput.Vstd./Xoutput.Vmean);    
else
    % Calculating mean,std and cov of response
    % the first coefficients determine the mean for each DOF
    Xoutput.Vmean = Mpccoefficients(:,1);
    % Calculate Variance of response
    variance = 0;
    % the indexing is done such that the first coefficients are ignored
    % since they are used only for the mean calculation
    for i=2:Npccoefficients
        variance = variance+ Vpsii2(i).*Mpccoefficients(:,i).^2;
    end
    Xoutput.Vstd = sqrt(variance);
    Xoutput.Vcov = abs(Xoutput.Vstd./Xoutput.Vmean);
    % This following re-assignment is made in order to fix the
    % visualization problem within the GUI (because for Guyan-PC there is 
    % no correspondence between ModelDOFs and the calculated Vmean, Vstd, etc.
    % they are only calculated for the master DOFs)
    if strcmpi(Xobj.Smethod,'Guyan')
        Xoutput.MmodelDOFs = Xobj.MmasterDOFs;
    end
end

%% stop the time

stopTime = OPENCOSSAN.Xtimer.currentTime;
Xobj.Ccputimes{5} = stopTime - startTime;

OpenCossan.cossanDisp(' ',1);
OpenCossan.cossanDisp(['[SfemPolynomialChaos.postprocess] Calculating the statistics of the response completed in ' num2str(Xobj.Ccputimes{5}) ' sec'],1);
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
OpenCossan.cossanDisp(' ',2);
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
OpenCossan.cossanDisp(' ',2);

return
