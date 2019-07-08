function Xobj = checkInput(Xobj)
%CHECK INPUT
%
%   MANDATORY ARGUMENTS: 
%
%   OPTIONAL ARGUMENTS: -
%
%   EXAMPLES:
%                                

global OPENCOSSAN

%% Check provided input

assert(~isempty(Xobj.Xmodel), ...
     'openCOSSAN:SFEM:checkInput','A physical model must be defined');
     
assert(isa(Xobj.Xmodel,'Model'), ...
         'openCOSSAN:SFEM:checkInput', ...
         'An object of type Model is required!\nObject of type %s is not valid',...
         class(Xobj.Xmodel));
     
assert(isa(Xobj.Xmodel,'Model'), ...
         'openCOSSAN:SFEM:checkInput', ...
         'An object of type Model is required!\nObject of type %s is not valid',...
         class(Xobj.Xmodel));
   
     
if isempty(Xobj.Xmodel.Xevaluator)  
    error('openCOSSAN:SFEM:checkInput','Evaluator object not defined');
elseif isempty(Xobj.Xmodel.Xinput)  
    error('openCOSSAN:SFEM:checkInput','Input object not defined');
elseif isempty(Xobj.Xmodel.Xinput.Xrvset)  
    error('openCOSSAN:SFEM:checkInput','RandomVariableSet not defined');
end

     
assert(isa(Xobj.Xmodel.Xevaluator.CXsolvers{1},'Connector'), ...
         'openCOSSAN:SFEM:checkInput', ...
         'The Physical model must contains 1 a connector!\nThe model is using a %s object', ...
         class(Xobj.Xmodel.Xevaluator.CXsolvers{1}));
     
   


%% Getting the required data 
Xinp            = Xobj.Xmodel.Xinput;                         % Obtain Input
assert(length(Xinp.CnamesRandomVariableSet)==1,'openCOSSAN:SFEM:checkInput',...
    'Only 1 Random Variable Set is allowed in SFEM.')

Xrvs            = Xinp.Xrvset.(Xinp.CnamesRandomVariableSet{1});    % Obtain RVSET
Crvnames        = Xinp.CnamesRandomVariable;                  % Obtain RV names
Nrvs            = Xinp.NrandomVariables;                      % Obtain No of RVs
Smaininputpath  = Xobj.Xmodel.Xevaluator.CXsolvers{1}.Smaininputpath; % Obtain the maininputpath



%% Check EXISTENCE OF REQUIRED FILES 

%check if the masterfile is specified
if isempty(Xobj.Xmodel.Xevaluator.CXsolvers{1}.CXmembers{1}.Sscanfilename)
   error('COSSAN:sfem: Please define the input file within an injector');
else
   Xobj.Sinputfile = Xobj.Xmodel.Xevaluator.CXsolvers{1}.CXmembers{1}.Sscanfilename;
   [~,Xobj.Sjobname,~] = fileparts(Xobj.Sinputfile);
end

%check if the masterfile exist
if exist([Smaininputpath Xobj.Sinputfile],'file') ~= 2
   error(['COSSAN:sfem: Please make sure that the input file ' Xobj.Sinputfile ' exists']);
end

%check if the componentwise files exist (applies only if componentwise is used)
if strcmpi(Xobj.Simplementation,'Componentwise')
    for irvno=1:length(Xobj.CyoungsModulusRVs)
        if exist([Smaininputpath Xobj.CyoungsModulusRVs{irvno} '.dat' ],'file') ~= 2
            error(['COSSAN:sfem: Please make sure that the componentwise input file '...
                    Xobj.CyoungsModulusRVs{irvno} '.dat exists']);
        end
    end
    for irvno=1:length(Xobj.CdensityRVs)
        if exist([Smaininputpath Xobj.CdensityRVs{irvno} '.dat' ],'file') ~= 2
            error(['COSSAN:sfem: Please make sure that the componentwise input file '...
                    Xobj.CdensityRVs{irvno} '.dat exists']);
        end
    end
end

%% Check GENERAL ISSUES

% check the analysis type
if ~strcmpi(Xobj.Sanalysis,'Static') && ~strcmpi(Xobj.Sanalysis,'Modal')
    error('COSSAN:sfem: Please enter a valid analysis type');
end

% check the implementation type
if ~strcmpi(Xobj.Simplementation,'Regular') && ~strcmpi(Xobj.Simplementation,'Componentwise')
    error('COSSAN:sfem: Please enter a valid implementation type');
end

% check the order of the method
if Xobj.Norder < 0 || Xobj.NinputApproximationOrder < 0  
    error('COSSAN:sfem: Order of the method has to be defined as a positive integer')   
end

% check the input approximation order
if ~isempty(Xobj.CthicknessRVs) && Xobj.NinputApproximationOrder == 1
    OpenCossan.cossanDisp('[COSSAN.Sfem.checkInput] 2. order approximation is necessary for the input if thickness is assigned as random ',0);
    OpenCossan.cossanDisp('[COSSAN.Sfem.checkInput] order approximation will be therefore changed to 2 ',0);
    OpenCossan.cossanDisp(' ',0);
    Xobj.NinputApproximationOrder = 2;
end

% Check whether or not all RVs in the RVSET are assigned to a property or
% all RVs assigned to properties are defined in the RVSET
Ntotalrvs = length(Xobj.CyoungsModulusRVs) + length(Xobj.CthicknessRVs) +...
            length(Xobj.CdensityRVs) + length(Xobj.CforceRVs) + ...
            length(Xobj.CcrossSectionRVs);
        
if Ntotalrvs == 0
    error('COSSAN:sfem: Define the corresponding structural properties of RVs');
elseif Ntotalrvs ~= Nrvs     
    error('COSSAN:sfem: RVs which are assigned to properties are not consistent with the one defined in the RVSET');
end

% Check whether or not any RV is assigned to more than one property
Ctotalnames = [Xobj.CyoungsModulusRVs Xobj.CthicknessRVs...
              Xobj.CdensityRVs Xobj.CforceRVs Xobj.CcrossSectionRVs];
if length(unique(Ctotalnames)) ~= Ntotalrvs     
    error('COSSAN:sfem: Please make sure that each RV is assigned only to a single property type');
end

% Check if the assigned RV exists in the RVSET
if ~isempty(setdiff(Ctotalnames,Crvnames))
    error('COSSAN:sfem: Please make sure that assigned RVs exist in the RVSET');
end

%% Check options related to P-C

if isa(Xobj,'SfemPolynomialChaos')
    if strcmpi(Xobj.Smethod,'Guyan') && strcmpi(Xobj.Simplementation,'Componentwise')
        error('openCOSSAN:SFEM:PolynomialChaos','Guyan P-C is not available for componentwise implementation');
    elseif strcmpi(Xobj.Smethod,'Collocation') && strcmpi(Xobj.Simplementation,'Componentwise')
        error('openCOSSAN:SFEM:PolynomialChaos','Collocation P-C is not available for componentwise implementation');
    elseif strcmpi(Xobj.Sanalysis,'Modal')
        error('COSSAN:sfem: P-C method is not implemented for the modal analysis')
    elseif strcmpi(Xobj.Smethod,'Guyan') && ~isempty(Xobj.CdensityRVs)
        error('openCOSSAN:SFEM:PolynomialChaos','Density cannot be assigned as random within Guyan P-C (not implemented yet)');
    elseif strcmpi(Xobj.Smethod,'Guyan') && ~isempty(Xobj.CforceRVs)
        error('openCOSSAN:SFEM:PolynomialChaos','Force cannot be assigned as random within Guyan P-C (not implemented yet)');
    elseif strcmpi(Xobj.Smethod,'Collocation') && ~isempty(Xobj.CdensityRVs)
        error('openCOSSAN:SFEM:PolynomialChaos','Density cannot be assigned as random within Collocation P-C (not implemented yet)');
    elseif strcmpi(Xobj.Smethod,'Collocation') && ~isempty(Xobj.CforceRVs)
        error('openCOSSAN:SFEM:PolynomialChaos','Force cannot be assigned as random within Collocation P-C (not implemented yet)');
    elseif strcmpi(Xobj.Smethod,'Guyan') && isempty(Xobj.MmasterDOFs)
        error('openCOSSAN:SFEM:PolynomialChaos','Please define the master DOFs');
    end
   
    if strcmpi(Xobj.Smethod,'Guyan') && Xobj.NinputApproximationOrder == 1
        OpenCossan.cossanDisp('[COSSAN.Sfem.checkInput] 2. order approximation is necessary for Guyan P-C ',0);
        OpenCossan.cossanDisp('[COSSAN.Sfem.checkInput] order approximation will be therefore changed to 2 ',0);
        OpenCossan.cossanDisp(' ',0);
        Xobj.NinputApproximationOrder=2;
    end
    if length(Xobj.Vdroptolerancerange) ~= 2
        OpenCossan.cossanDisp('[COSSAN.Sfem.checkInput] Vdroptolerancerange parameter should be defined as a 2x1 vector',0);
        OpenCossan.cossanDisp('[COSSAN.Sfem.checkInput] Vdroptolerancerange parameter will be set to its defualt value [1e-1,1e-6]',0);
        Xobj.Vdroptolerancerange=[1e-1,1e-6];
    end
    if Xobj.droptolerance < 0
        OpenCossan.cossanDisp('[COSSAN.Sfem.checkInput] droptolerance parameter should be defined as a positive value',0);
        OpenCossan.cossanDisp('[COSSAN.Sfem.checkInput] droptolerance parameter will be set to its defualt value 1e-4',0);
        Xobj.droptolerance=1e-4;
    end
    if Xobj.convergenceparameter < 0
        OpenCossan.cossanDisp('[COSSAN.Sfem.checkInput] convergenceparameter parameter should be defined as a positive value',0);
        OpenCossan.cossanDisp('[COSSAN.Sfem.checkInput] convergenceparameter parameter will be set to its defualt value 5%',0);
        Xobj.droptolerance=5;
    end
    if Xobj.convergencetolerance < 0
        OpenCossan.cossanDisp('[COSSAN.Sfem.checkInput] convergencetolerance parameter should be defined as a positive value',0);
        OpenCossan.cossanDisp('[COSSAN.Sfem.checkInput] convergencetolerance parameter will be set to its defualt value 5%',0);
        Xobj.convergencetolerance=1e-2;
    end
    if  ~strcmpi(Xobj.Sbasis,'Hermite') && ~strcmpi(Xobj.Sbasis,'Legendre')
        OpenCossan.cossanDisp('[COSSAN.Sfem.checkInput] please select the basis either as Hermite or as Legendre',0);
        OpenCossan.cossanDisp('[COSSAN.Sfem.checkInput] the basis will be set to its defualt value Hermite',0);
        Xobj.Sbasis='Hermite'; 
    end
    if  ~strcmpi(Xobj.Sgridtype,'Clenshaw-Curtis') && ~strcmpi(Xobj.Sgridtype,'Noboundary')...
        ~strcmpi(Xobj.Sgridtype,'Chebyshev') && ~strcmpi(Xobj.Sgridtype,'Maximum') && ~strcmpi(Xobj.Sgridtype,'Gauss-Patterson');
        OpenCossan.cossanDisp('[COSSAN.Sfem.checkInput] please select one of the following gridtypes: Clenshaw-Curtis,Noboundary,Chebyshev,Gauss-Patterson,Maximum',0);
        OpenCossan.cossanDisp('[COSSAN.Sfem.checkInput] the basis will be set to its defualt value Clenshaw-Curtis',0);
        Xobj.Sgridtype='Clenshaw-Curtis'; 
    end
    if Xobj.Nmaxdepth < 0 || Xobj.Nmaxdepth > 8
        OpenCossan.cossanDisp('[COSSAN.Sfem.checkInput] Nmaxdepth parameter should be defined as a positive integer between 1 and 8',0);
        OpenCossan.cossanDisp('[COSSAN.Sfem.checkInput] Nmaxdepth parameter will be set to its defualt value 8',0);
        Xobj.Nmaxdepth;
    end
end

%% Check options related to Neumann

if isa(Xobj,'Neumann')
    if strcmpi(Xobj.Sanalysis,'Modal')
        error('COSSAN:sfem: Neumann method is not implemented for the modal analysis')
    elseif Xobj.Nsimulations < 0
        error('COSSAN:sfem: No of simulations has to be defined as a positive integer')
    end
end

%% Check options related to Perturbation

if isa(Xobj,'Perturbation')
    if ~isempty(Xobj.CthicknessRVs)
        error('COSSAN:sfem: Perturbation method is not applicable for the case where thickness is assigned as random');
    elseif ~isempty(Xobj.CcrossSectionRVs)
        error('COSSAN:sfem: Perturbation method is not applicable for the case where cross sectional dimensions are assigned as random');
    elseif Xobj.NinputApproximationOrder == 2
        error('COSSAN:sfem: 2. order input approximation is not available for the Perturbation method');
    elseif Xobj.Norder == 2
        OpenCossan.cossanDisp('[COSSAN.Sfem.checkInput] 2. order Perturbation method is not implemented ',0);
        OpenCossan.cossanDisp('[COSSAN.Sfem.checkInput] Therefore order of the method will be changed to 1 ',0);
        OpenCossan.cossanDisp(' ',0);
        Xobj.Norder = 1;
    end
end

%% Check options for NASTSEM

if isa(Xobj,'Nastsem')
    
    % Check if a Grid is defined
    XsfemGrid = Xobj.Xmodel.Xevaluator.getJobManager(...            
                'SsolverName',Xobj.Xmodel.Xevaluator.CSnames{1});   
    if ~isempty(Xobj.CthicknessRVs) || ~isempty(Xobj.CcrossSectionRVs) || ~isempty(Xobj.CforceRVs)
        error('COSSAN:sfem: NASTSEM is implemented for the case, where ONLY Youngs modulud is modeled as random');
    elseif strcmpi(Xobj.Sanalysis,'Modal')
        error('COSSAN:sfem: NASTSEM is not implemented for the modal analysis');
    elseif ~strcmpi(Xobj.Smethod,'Neumann') && ~strcmpi(Xobj.Smethod,'Perturbation')
        error('COSSAN:sfem: Please select either the Neumann or Perturbation methods');
    elseif isempty(Xobj.Vfixednodes)
        error('COSSAN:sfem: Please define the constrained nodes in the FE model');      
    end
    
    if Xobj.NinputApproximationOrder == 2
        OpenCossan.cossanDisp('[COSSAN.Sfem.checkInput] 2. order input approximation is not available for NASTSEM ',0);
        OpenCossan.cossanDisp('[COSSAN.Sfem.checkInput] Therefore the order of the input approximation will be changed to 1 ',0);
        OpenCossan.cossanDisp(' ',0);
        Xobj.NinputApproximationOrder = 1;
    end
    
    if Xobj.Norder == 2  && strcmpi(Xobj.Smethod,'Perturbation')
        OpenCossan.cossanDisp('[COSSAN.Sfem.checkInput] 2. order Perturbation method is not implemented ',0);
        OpenCossan.cossanDisp('[COSSAN.Sfem.checkInput] Therefore order of the method will be changed to 1 ',0);
        OpenCossan.cossanDisp(' ',0);
        Xobj.Norder = 1;
    end
        
    if Xobj.Norder == 1  && strcmpi(Xobj.Smethod,'Neumann')
        OpenCossan.cossanDisp('[COSSAN.Sfem.checkInput] Neumann exp. should be used at least with Norder=3 (for accuracy reasons) ',0);
        OpenCossan.cossanDisp('[COSSAN.Sfem.checkInput] Therefore order of the method will be changed to 3. ',0);
        OpenCossan.cossanDisp(' ',0);
        Xobj.Norder = 3;
    end
end

%% Check options related to NASTRAN

if strcmpi(Xobj.Xmodel.Xevaluator.CXsolvers{1}.Stype,'nastran_x86_64')  
    for krvno=1:Nrvs
        % It is necessary to check the length of the Rvname+Filenam, because it
        % causes problems with DMAP when it is longer than 16 characters
        if length([Xobj.Sjobname Crvnames{krvno}])>16
            error('COSSAN:sfem: Filename + RVname is too long, please use shorter names');
        end
    end
    if ~isempty(Xobj.CstepDefinition) || ~isempty(Xobj.MconstrainedDOFs)
        error('COSSAN:sfem: CstepDefinition or MconstrainedDofs are only needed for ABAQUS, please make sure that you selected the right FE solver');
    end
    
end

%% Check options related to ANSYS

if strcmpi(Xobj.Xmodel.Xevaluator.CXsolvers{1}.Stype,'ansys')  
    if strcmp(Xobj.Simplementation,'Componentwise')
        error('COSSAN:sfem: Componentwise implementation is not implemented yet for ANSYS')
    elseif strcmp(Xobj.Smethod,'Guyan')
        error('COSSAN:sfem: Guyan P-C is not available for ANSYS')
    end
end

%% Check options for ABAQUS

if strcmpi(Xobj.Xmodel.Xevaluator.CXsolvers{1}.Stype,'abaqus')  
    if strcmp(Xobj.Simplementation,'Componentwise')
        error('COSSAN:sfem: Componentwise implementation is not implemented yet for ABAQUS')
    elseif strcmp(Xobj.Smethod,'Guyan')
        error('COSSAN:sfem: Guyan P-C is not available for ABAQUS')
    end
end

%% Determine the random system quantities

% this information is then used throughout all the analysis in order to
% know which matrices/vectors should be accounted as random

if ~isempty(Xobj.CyoungsModulusRVs)
    Xobj.LrandomStiffness = true;
elseif ~isempty(Xobj.CthicknessRVs)
    Xobj.LrandomStiffness = true;
elseif ~isempty(Xobj.CcrossSectionRVs)
    Xobj.LrandomStiffness = true;
end

if ~isempty(Xobj.CdensityRVs) && strcmpi(Xobj.Sanalysis,'Static')
    Xobj.LrandomForce = true;
elseif ~isempty(Xobj.CforceRVs)
    Xobj.LrandomForce = true;
end

if ~isempty(Xobj.CdensityRVs) && strcmpi(Xobj.Sanalysis,'Modal')
    Xobj.LrandomMass = true;
end

%%  Start Analysis

OpenCossan.cossanDisp(' ',1);
OpenCossan.cossanDisp('-------------------------------------------------',1);
OpenCossan.cossanDisp('COSSAN starting SFEM analysis',1);
OpenCossan.cossanDisp('-------------------------------------------------',1);
OpenCossan.cossanDisp(' ',1);

OpenCossan.cossanDisp(' ',2);
OpenCossan.cossanDisp('-------------------------------------------------',2);
OpenCossan.cossanDisp('Summary of problem',2);
OpenCossan.cossanDisp('-------------------------------------------------',2);
OpenCossan.cossanDisp([' Input file               : ' Xobj.Sinputfile ],2);
OpenCossan.cossanDisp([' Working path             : ' OPENCOSSAN.SworkingPath],2);
OpenCossan.cossanDisp([' Analysis Type            : ' Xobj.Sanalysis],2);
if isa(Xobj,'Perturbation')
    OpenCossan.cossanDisp(' Applied Method           : Perturbation',2);
elseif isa(Xobj,'Neumann')
    OpenCossan.cossanDisp(' Applied Method           : Neumann',2);
elseif isa(Xobj,'SfemPolynomialChaos') && strcmp(Xobj.Smethod,'Galerkin')
    OpenCossan.cossanDisp(' Applied Method           : P-C (Galerkin)',2);
elseif isa(Xobj,'SfemPolynomialChaos') && strcmp(Xobj.Smethod,'Guyan')   
    OpenCossan.cossanDisp(' Applied Method           : P-C (Guyan)',2);
elseif isa(Xobj,'SfemPolynomialChaos') && strcmp(Xobj.Smethod,'Collocation')  
    OpenCossan.cossanDisp(' Applied Method           : P-C (Collocation)',2);
end
OpenCossan.cossanDisp([' Implementation Type      : ' Xobj.Simplementation],2);
OpenCossan.cossanDisp([' Applied Order (Input)    : ' num2str(Xobj.NinputApproximationOrder)],2);
OpenCossan.cossanDisp([' Applied Order (Response) : ' num2str(Xobj.Norder)],2);
OpenCossan.cossanDisp(' ',1);

return

