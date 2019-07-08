function prepareSEfiles(Xobj)
%GENSEFILES Generates the SE files 
%   GENSEFILES prepares the superelement (SE) files. These superelements serve
%   different purposes according to the chosen SFE method. For example, for
%   the perturbation, SE = 1 is used to to obtain the nominal system
%   matrices (K0) and the nominal solution (u0), whereas SE = 2 is used to obtain the
%   system matrix with perturbed with respect to the first RV (K1). As a
%   reult, there will be N+1 SE's created (N = No of RVs).
%   For the Neumann Exp. method, SE = 1 is used again for nominal
%   quantities whereas all other SE's are for the simulations. Therefore
%   there will be N+1 SE's generated (N = No of Simulations).
%
% See Also:
% http://cossan.cfd.liv.ac.uk/wiki/index.php/prepareSEfiles@Nastsem
%
% =========================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% =========================================================================

OpenCossan.cossanDisp('[Nastsem.prepareSEfiles] Preparation of the Superelement files started ',2);

%% Get initial information

Xinp         = Xobj.Xmodel.Xinput;      % Obtain Input
assert(length(Xinp.CnamesRandomVariableSet)==1,'openCOSSAN:SFEM:checkInput',...
    'Only 1 Random Variable Set is allowed in SFEM.')
Xrvs            = Xinp.Xrvset.(Xinp.CnamesRandomVariableSet{1});    % Obtain RVSET
Crvnames        = Xinp.CnamesRandomVariable;                        % Obtain RV names
Nrvs            = Xinp.NrandomVariables;                            % Obtain No of RVs

%% Construct Injector

% Injector is created to obtain the tmpfile.dat which contains the numbers instead of identifiers
inj1=Injector('Stype','scan','Sscanfilename','residual_master.dat','Sworkingdirectory',OpenCossan.getCossanWorkingPath ,...
              'Sscanfilepath',OpenCossan.getCossanWorkingPath,'Sfile','tmpfile.dat'); 

%% Create the input file for SE=1 (Nominal Structure) 

% Obtain the nominal values for the RVs
Vmeanvalues = get(Xrvs,'members','mean'); 
Vstdvalues  = get(Xrvs,'members','std');

% First the whole structure is prepared such that in contains only the mean values
if strcmpi(Xobj.Smethod,'Perturbation')
    for krvno=1:Nrvs
        for jrvno=1:Nrvs
            eval([ 'Tinputnominal(jrvno).'         Crvnames{krvno} ' = Vmeanvalues(krvno) ;' ]);
            eval([ 'TinputPerturbPositive(jrvno).' Crvnames{krvno} ' = Vmeanvalues(krvno) ;' ]);
        end
    end
elseif strcmpi(Xobj.Smethod,'Neumann')
    for krvno=1:Nrvs
        for jrvno=1:Xobj.Nsimulations
            eval([ 'Tinputnominal(jrvno).' Crvnames{krvno} ' = Vmeanvalues(krvno) ;' ]);
        end
    end
end

% Insert the nominal values using injector
inject(inj1,Tinputnominal(1));
[status, ~] = copyfile(fullfile(OpenCossan.getCossanWorkingPath, 'tmpfile.dat'),fullfile(OpenCossan.getCossanWorkingPath,'se1.dat'));
if status == 0
    error('openCOSSAN:NASTSEM','[Nastsem.prepareSEfiles] tmpfile.dat could not be copied');
elseif status == 1
    OpenCossan.cossanDisp('[Nastsem.prepareSEfiles] tmpfile.dat  copied successfully',3);
end

%% Create residual.dat file

% Residual.dat is the copy of SE=1.
% NOTE:The residual structure is not used in the calculations
%      However it is needed for NASTRAN SE analysis  
[status, ~] = copyfile(fullfile(OpenCossan.getCossanWorkingPath,'se1.dat'),fullfile(OpenCossan.getCossanWorkingPath,'residual.dat'));
if status == 0
    error('openCOSSAN:NASTSEM','[Nastsem.prepareSEfiles] residual.dat could not be copied');
elseif status == 1
    OpenCossan.cossanDisp('[Nastsem.prepareSEfiles] residual.dat  copied successfully',3);
end

%% Preparing SE files for PERTURBATION method

if strcmpi(Xobj.Smethod,'Perturbation')
    
    Vperturbpositive = zeros(Nrvs,1);
    for irvno=1:Nrvs
        % All RVs are perturbed by the amount of their std deviation
        Vperturbpositive(irvno) = Vmeanvalues(irvno) + Vstdvalues(irvno);
        for jrvno=1:Nrvs
            if jrvno==irvno
                eval([ 'TinputPerturbPositive(jrvno).' Crvnames{jrvno} ' = Vperturbpositive(jrvno) ;' ]);
            end
        end
    end
    
    % Insert Tinput values using injector
    for jrvno=1:Nrvs
        inject(inj1,TinputPerturbPositive(jrvno));
        Sfilename=eval(['sprintf(''se%d'',',num2str(jrvno+1),')']);
        % before overwriting tmpdat.file it is copied with a different name
        [status, ~] = copyfile(fullfile(OpenCossan.getCossanWorkingPath,'tmpfile.dat'),fullfile(OpenCossan.getCossanWorkingPath,[Sfilename '.dat']));
        if status == 0
            error('openCOSSAN:NASTSEM',['[Nastsem.prepareSEfiles] ' Sfilename ' could not be copied']);
        elseif status == 1
            OpenCossan.cossanDisp(['[Nastsem.prepareSEfiles] ' Sfilename ' copied successfully'],3);
        end
    end
       
%% Preparing SE files for NEUMANN method

elseif strcmpi(Xobj.Smethod,'Neumann')
    % Generate samples for the simulations
    Xsamples = sample(Xrvs,Xobj.Nsimulations);
    Msamples = Xsamples.MsamplesPhysicalSpace; %#ok<*NASGU>
    % Prepare Tinput structure (to be used with injector)
    for i=1:Xobj.Nsimulations
        for k=1:Nrvs
            eval(['Tinput(i).' Crvnames{k} '  = Msamples(i,k) ;' ]);
        end
        % Insert Tinput values using injector
        inject(inj1,Tinput(i));
        Sfilename=eval(['sprintf(''se%0d'',',num2str(i+1),')']);
        % before overwriting tmpdat.file it is copied with a different name
        [status, ~] = copyfile(fullfile(OpenCossan.getCossanWorkingPath,'tmpfile.dat'),fullfile(OpenCossan.getCossanWorkingPath,[Sfilename '.dat']));
        if status == 0
            error('openCOSSAN:NASTSEM',['[Nastsem.prepareSEfiles] ' Sfilename ' could not be copied']);
        elseif status == 1
            OpenCossan.cossanDisp(['[Nastsem.prepareSEfiles] ' Sfilename ' copied successfully'],3);
        end
    end
end

% clean unnecessary files
delete(fullfile(OpenCossan.getCossanWorkingPath, 'tmpfile.dat'));

OpenCossan.cossanDisp('[Nastsem.prepareSEfiles] Preparation of the Superelement files completed ',2);

return
