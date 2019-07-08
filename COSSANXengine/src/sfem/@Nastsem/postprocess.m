function Xoutput = postprocess(Xobj)
%POSTPROCESS  obtains the statistical moments of the response
%
% See Also:
% http://cossan.cfd.liv.ac.uk/wiki/index.php/postprocess@Nastsem
%
% =========================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% =========================================================================

global OPENCOSSAN

startTime = OPENCOSSAN.Xtimer.currentTime;

OpenCossan.cossanDisp('[Nastsem.postprocess] Calculating the statistics of the response started',1);
OpenCossan.cossanDisp(' ',1);

%% Get necessary data from SFEM object

Xinp            = Xobj.Xmodel.Xinput;           % Obtain Input
assert(length(Xinp.CnamesRandomVariableSet)==1,'openCOSSAN:SFEM:checkInput',...
    'Only 1 Random Variable Set is allowed in SFEM.')
Xrvs            = Xinp.Xrvset.(Xinp.CnamesRandomVariableSet{1});    % Obtain RVSET
Crvnames        = Xinp.CnamesRandomVariable;                  % Obtain RV names
Nrvs            = Xinp.NrandomVariables;                      % Obtain No of RVs
Mcorr           = get(Xrvs, 'Mcorrelation');    % Obtain the Correlations of RVs
Vstdvalues      = get(Xrvs, 'members','std');   % Obtain the standard deviations of RVs
Xobj.Sjobname   = upper(Xobj.Sjobname);

%% Read The DOFs information
% this is necessary in order to extract the requested response properly
dummy           = PunchExtractor('Sworkingdirectory',OPENCOSSAN.SworkingPath,'Sfile',[Xobj.Sjobname '_DOFS.PCH'],'Soutputname','dofs');
Tout            = extract(dummy);
Xobj.MmodelDOFs = Tout.dofs;
delete([OPENCOSSAN.SworkingPath filesep '*.PCH']);

%% Create SFEM Output Object

Xoutput = SfemOutput('Sdescription','SFEM Output Object','XSfemObject',Xobj,'MmodelDOFs',double(Xobj.MmodelDOFs));

%% Calculate the statistisc 

if strcmpi(Xobj.Smethod,'Perturbation')
    fprintf('Reading derivatives of to MATLAB \n');
    display(' ');
    dummy     = Op4Extractor('Sworkingdirectory',OPENCOSSAN.SworkingPath,'Sfile','U_primes.op4','Soutputname','uprimes');
    Tout      = extract(dummy);
    Muprimes  = Tout.uprimes;
    % Stop measuring time for matrix transfer
    stopTime = OPENCOSSAN.Xtimer.currentTime;
    Xobj.Ccputimes{4} = stopTime - startTime;
    fprintf('Transfer of System matrices to MATLAB completed in  completed in %1.0f sec \n', Xobj.Ccputimes{4});
    display(' ');
    startTime = OPENCOSSAN.Xtimer.currentTime;
    Muprimes = Muprimes';
    % Getting nominal response
    Xoutput.Vmean = Muprimes(1,:);
    Vvariance_u = sparse(1,length(Muprimes));
    % Calculating the std dev of response according to 1. order perturbation formulation 
    %
    % NOTE: the variation of the RVs are taken into account in this stage
    %       => the derivatives calculated previously are independent of
    %       the variation of RVs (K' = deltaK/deltaX, where X is the RV)
    %
    for i=1:Nrvs
        for j=1:Nrvs
            Vvariance_u = Vvariance_u + Muprimes(i+1,:).*Muprimes(j+1,:) * ...
            Mcorr(i,j) * (Vstdvalues(i)*Vstdvalues(j));                   
        end
    end
    % Calculating the std dev of response
    Xoutput.Vstd  = sqrt(Vvariance_u); 
    Xoutput.Vcov  = abs(Xoutput.Vstd./Xoutput.Vmean);
elseif strcmpi (Xobj.Smethod,'Neumann')
    fprintf('Reading responses to MATLAB \n');
    dummy      = Op4Extractor('Sworkingdirectory',OPENCOSSAN.SworkingPath,'Sfile','U_samples.op4','Soutputname','Musamples');
    Tout       = extract(dummy);
    Mresponses = Tout.Musamples;
    % Stop measuring time for matrix transfer
    stopTime = OPENCOSSAN.Xtimer.currentTime;
    Xobj.Ccputimes{4} = stopTime - startTime;
    fprintf('Transfer of System matrices to MATLAB completed in  completed in %1.0f sec \n', Xobj.Ccputimes{4});
    display(' ');
    startTime = OPENCOSSAN.Xtimer.currentTime;
    Xoutput.Vmean = mean(Mresponses,2);
    Xoutput.Vstd  = std(Mresponses,[],2);
    Xoutput.Vcov  = abs(Xoutput.Vstd./Xoutput.Vmean);
end

%% Clean files

if Xobj.Lcleanfiles
    delete([OPENCOSSAN.SworkingPath filesep '*.op4']);
    delete([OPENCOSSAN.SworkingPath filesep 'se*.*']);
    delete([OPENCOSSAN.SworkingPath filesep 'residual*.*']);
    delete([OPENCOSSAN.SworkingPath filesep 'dmap*.*']);
    delete([OPENCOSSAN.SworkingPath filesep 'maininput.*']);
end

%% stop the time

stopTime = OPENCOSSAN.Xtimer.currentTime;
Xobj.Ccputimes{5} = stopTime - startTime;

OpenCossan.cossanDisp(' ',1);
OpenCossan.cossanDisp(['[Nastsem.postprocess] Calculating the statistics of the response completed in ' num2str(Xobj.Ccputimes{5}) ' sec'],1);
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
