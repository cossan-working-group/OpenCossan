function prepareReport(Xobj,varargin)
%PREPAREREPORT
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/prepareReport@SfemOutput
%
% Copyright 1983-2011 COSSAN Working Group, University of Innsbruck, Austria
% Author: Edoardo Patelli
% Author: Murat Panayirci 


%% Get the varargin

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'sresponse'}
            Xobj.Sresponse=varargin{k+1};
        case {'mresponsedofs'}
            Xobj.MresponseDOFs=varargin{k+1};
        case {'nmode'}
            Xobj.Nmode=varargin{k+1};
        otherwise
            error('openCOSSAN:sfemoutput','Field name not allowed');
    end
end

%% Retrieve Input data

Xsfem           = Xobj.XSfemObject;                                    % Obtain SFEM object
Xinp            = Xsfem.Xmodel.Xinput;                                % Obtain Input
Xrvs            = Xinp.Xrvset.(Xinp.CnamesRandomVariableSet{1});    % Obtain RVSET
Crvnames        = Xinp.CnamesRandomVariable;                  % Obtain RV names
Nrvs            = Xinp.NrandomVariables;                      % Obtain No of RVs
Vmeanvalues     = get(Xrvs,'members','mean');                         % Obtain mean values of each RV
Vstdvalues      = get(Xrvs,'members','std');                          % Obtain std dev values of each RV
Vcovvalues      = Vstdvalues./Vmeanvalues;                            % Obtain COVs
Cdistributions  = get(Xrvs,'Cmembers','Sdistribution');               % Obtain Distribution Types
if ~isempty(Xsfem.Xmodel.Xevaluator.CXsolvers)
    Sfesolver       = Xsfem.Xmodel.Xevaluator.CXsolvers{1}.Stype;         % Obtain FE solver type
else
    Sfesolver       = 'Not defined';
end

%% Retrieve the required response

Xobj = getResponse(Xobj,'Sresponse',Xobj.Sresponse,'MresponseDOFs',Xobj.MresponseDOFs);

%% OPen the Result file

Mdateandtime  = clock;
analysis_date = date;

Sfilename = [ 'Results_' num2str(Mdateandtime(1,2)) '_' num2str(Mdateandtime(1,3))...
    '_' num2str(Mdateandtime(1,4)) '_' num2str(Mdateandtime(1,5)) '_' num2str(Mdateandtime(1,6)) '.txt'];

fid = fopen(fullfile(OpenCossan.getCossanWorkingPath,Sfilename),'w+');

%% Summary of the Problem

fprintf(fid,'====================================== \n');
fprintf(fid,' Summary of the Problem                \n');
fprintf(fid,'====================================== \n');
fprintf(fid,' \n');
fprintf(fid,' Analysis Date            : %s \n', analysis_date);
if isa(Xsfem,'Nastsem')
    fprintf(fid,' FE Solver                : NASTRAN \n');
else
    fprintf(fid,' FE Solver                : %s \n', Sfesolver);
end
fprintf(fid,' Input file               : %s \n', Xsfem.Sjobname);
fprintf(fid,' Analysis Type            : %s \n', Xsfem.Sanalysis);
if isa(Xsfem,'Perturbation')
    fprintf(fid,' Applied Method           : Perturbation \n');
elseif isa(Xsfem,'Neumann')
    fprintf(fid,' Applied Method           : Neumann \n');
elseif isa(Xsfem,'SfemPolynomialChaos')
    fprintf(fid,' Applied Method           : P-C \n');
elseif isa(Xsfem,'Nastsem') && strcmp(Xsfem.Smethod,'Perturbation')
    fprintf(fid,' Applied Method           : Solver-based Perturbation \n');
elseif isa(Xsfem,'Nastsem') && strcmp(Xsfem.Smethod,'Neumann')
    fprintf(fid,' Applied Method           : Solver-based Neumann \n');
end
fprintf(fid,' Implementation Type      : %s \n', Xsfem.Simplementation);
fprintf(fid,' Applied Order (Input)    : %d \n', Xsfem.NinputApproximationOrder);
fprintf(fid,' Applied Order (Response) : %d \n', Xsfem.Norder);
if isa(Xsfem,'Neumann')
    fprintf(fid,' No of Simulations        : %d \n', Xsfem.Nsimulations);
end
fprintf(fid,' \n');
fprintf(fid,' \n');

%% Details on the calculation of P-C coefficients

if isa(Xsfem,'SfemPolynomialChaos')
    fprintf(fid,'================================================ \n');
    fprintf(fid,' Details on the calculation of P-C Coefficients  \n');
    fprintf(fid,'================================================ \n');
    fprintf(fid,' Method                  : %s \n', Xsfem.Smethod);
    if strcmp(Xsfem.Smethod,'Collocation')
        fprintf(fid,' Grid Type               : %s \n',    Xsfem.Sgridtype);
        fprintf(fid,' Max depth               : %1.1d \n', Xsfem.Nmaxdepth);
        fprintf(fid,' Relative Tolerance      : %1.1d \n', Xsfem.relativetolerance);
        fprintf(fid,' Range                   : [%1.1d,%1.1d] \n', Xsfem.Vrange(1),Xsfem.Vrange(2));
        fprintf(fid,' Total No of Simulations : %1.1d \n', Xsfem.Ntotalsimulations);
    elseif strcmp(Xsfem.Smethod,'Galerkin')
        fprintf(fid,' Preconditioner          : Incomplete Cholesky Factorization \n');
        if Xsfem.Lautofactorization
            fprintf(fid,' Drop tolerance          : Determined automatically \n');
            fprintf(fid,' Lower Limit             : %1.1d  \n', Xsfem.Vdroptolerancerange(1));
            fprintf(fid,' Upper Limit             : %1.1d  \n', Xsfem.Vdroptolerancerange(2));
        else
            fprintf(fid,' Drop tolerance          : %1.1d (User Defined) \n', Xsfem.droptolerance);
        end
        fprintf(fid,' Iterative Solver        : Preconditioned Conjugate Gradient \n');
        if Xsfem.Lautoconvergence
            fprintf(fid,' Convergence of Solver   : Determined automatically using convergence parameter as %d (in percent) \n',Xsfem.convergenceparameter);
        else
            fprintf(fid,' Convergence tolerance for solver : %1.1d (User Defined) \n',Xsfem.convergencetolerance);
        end
        fprintf(fid,' Preconditioner time     : %3.0f \n', Xsfem.preconditionertime);
        fprintf(fid,' PCG Solver time         : %3.0f \n', Xsfem.solvertime);
    end
    fprintf(fid,' \n');
    fprintf(fid,' \n');
end

%% Summary of the Probabilistic Model

fprintf(fid,'====================================== \n');
fprintf(fid,' Summary of the Probabilistic Model    \n');
fprintf(fid,'====================================== \n');
fprintf(fid,' \n');
fprintf(fid,' Total No of RVs: %d \n', Nrvs);
for i=1:Nrvs
    fprintf(fid,' RV No #%d : %s, %s, %d, %2.4f \n', i, ...
        Crvnames{i}, Cdistributions{i}, Vmeanvalues(i), Vcovvalues(i));
end
fprintf(fid,' \n');
fprintf(fid,' \n');

%% Summary of the statistics of the Responses

fprintf(fid,'====================================================== \n');
fprintf(fid,' Summary of the statistics of the selected Responses \n');
fprintf(fid,'====================================================== \n');
fprintf(fid,' \n');
if strcmp(Xsfem.Sanalysis,'Static')
    if strcmp(Xobj.Sresponse,'max')
        fprintf(fid,' Quantity of Interest                  : Maximum Displacement \n');
        fprintf(fid,' Entry no of the max displacement      : %d \n',    Xobj.maxresponseDOF);
        fprintf(fid,' Corresponding Node no                 : %d \n',    Xsfem.MmodelDOFs(Xobj.maxresponseDOF,1));
        fprintf(fid,' Corresponding DOF no                  : %d \n',    Xsfem.MmodelDOFs(Xobj.maxresponseDOF,2));
        fprintf(fid,' Mean of Response                      : %3.4f \n', Xobj.Vresponsemean);
        fprintf(fid,' Standard Deviation of Response        : %3.4f \n', Xobj.Vresponsestd);
        fprintf(fid,' Coefficient of Variation of Response  : %2.4f \n', Xobj.Vresponsecov);
    elseif strcmp(Xobj.Sresponse,'specific')
        for i=1:size(Xobj.MresponseDOFs,1)
            fprintf(fid,' Quantity of Interest                  : Displacement at NODE no %d - DOF no %d \n',...
                Xobj.MresponseDOFs(i,1),Xobj.MresponseDOFs(i,2));
            fprintf(fid,' Mean of Response                      : %3.4f \n', Xobj.Vresponsemean(i));
            fprintf(fid,' Standard Deviation of Response        : %3.4f \n', Xobj.Vresponsestd(i));
            fprintf(fid,' Coefficient of Variation of Response  : %2.4f \n', Xobj.Vresponsecov(i));
        end
    end
elseif strcmp(Xsfem.Sanalysis,'Modal')
    fprintf(fid,' Quantity of Interest                  : %d. Natural Frequency \n',Xobj.Nmode);
    % NOTE: here the eigenvalue is converted to Hz for the mean value
    %       CoV is calculated for the eigenvalue
    fprintf(fid,' Mean of Response                      : %3.4f Hz \n', sqrt(Xobj.Vresponsemean)./(2*pi));
    fprintf(fid,' Standard Deviation of Response        : %3.4f \n',  Xobj.Vresponsestd);
    fprintf(fid,' Coefficient of Variation of Response  : %2.4f \n',  Xobj.Vresponsecov);
end

if strcmp(Xobj.Sresponse,'all')
    if strcmp(Xsfem.Smethod,'Collocation')
        for i=1:size(Xobj.Vresponsemean,1)
            fprintf(fid,' Mean of Response # %d                  : %3.4f \n', i,Xobj.Vresponsemean(i));
            fprintf(fid,' Standard Deviation of Response        : %3.4f \n', Xobj.Vresponsestd(i));
            fprintf(fid,' Coefficient of Variation of Response  : %2.4f \n', Xobj.Vresponsecov(i));
        end
    else
        fprintf(fid,' Quantity of Interest                  : All displacement values  \n');
        Sresponsefilename = [ 'Responses_' num2str(Mdateandtime(1,2)) '_' num2str(Mdateandtime(1,3))...
            '_' num2str(Mdateandtime(1,4)) '_' num2str(Mdateandtime(1,5)) '_' num2str(Mdateandtime(1,6)) '.txt'];
        fid2 = fopen([OpenCossan.getCossanWorkingPath filesep Sresponsefilename],'w+');
        fprintf(fid2,' Node No         DOF No         Mean Value        CoV Value  \n');
        fprintf(fid2,'---------      ------------    ------------      ----------- \n');
        for i = 1:length(Xobj.Vresponsemean)
            fprintf(fid2,' %0.6d           %0.6d         %2.4f             %2.4f      \n',...
                Xsfem.MmodelDOFs(i,1),Xsfem.MmodelDOFs(i,2),Xobj.Vresponsemean(i),Xobj.Vresponsecov(i));
        end
        fclose(fid2);
    end
end
fprintf(fid,' \n');
fprintf(fid,' \n');

%% Summary of the CPU times

if ~isempty(Xsfem.Ccputimes)
    fprintf(fid,'====================================== \n');
    fprintf(fid,' Summary of CPU times                  \n');
    fprintf(fid,'====================================== \n');
    fprintf(fid,' \n');
    if Xsfem.Ccputimes{1} < 1
        fprintf(fid,' Total time                               : < 1 sec \n');
    else
        fprintf(fid,' Total time                               : %3.0f sec \n', Xsfem.Ccputimes{1});
    end
    if isempty(Xsfem.Ccputimes{2})
        fprintf(fid,' Time for generating the input files      : Not performed \n');
    elseif Xsfem.Ccputimes{2} < 1
        fprintf(fid,' Time for generating the input files      : < 1 sec \n');
    else
        fprintf(fid,' Time for generating the input files      : %3.0f sec \n', Xsfem.Ccputimes{2});
    end
    if isempty(Xsfem.Ccputimes{3})
        fprintf(fid,' Time for running 3rd party FE solver     : Not performed \n');
    elseif isempty(Xsfem.Ccputimes{3})==0 && Xsfem.Ccputimes{3} < 1
        fprintf(fid,' Time for running 3rd party FE solver     : < 1 sec \n');
    else
        fprintf(fid,' Time for running 3rd party FE solver     : %3.0f sec \n', Xsfem.Ccputimes{3});
    end
    if isempty(Xsfem.Ccputimes{4})
        fprintf(fid,' Time for transferring matrices to MATLAB : Not performed \n');
    elseif isempty(Xsfem.Ccputimes{3})==0 && Xsfem.Ccputimes{4} < 1
        fprintf(fid,' Time for transferring matrices to MATLAB : < 1 sec \n');
    else
        fprintf(fid,' Time for transferring matrices to MATLAB : %3.0f sec \n', Xsfem.Ccputimes{4});
    end
    if Xsfem.Ccputimes{5} < 1
        fprintf(fid,' Time for calculating statistics          : < 1 sec \n');
    else
        fprintf(fid,' Time for calculating statistics          : %3.0f sec \n', Xsfem.Ccputimes{5});
    end
    fprintf(fid,' \n');
end

fclose(fid);

return
