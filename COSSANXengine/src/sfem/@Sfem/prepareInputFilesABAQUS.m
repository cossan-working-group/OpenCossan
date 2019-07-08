function Xobj = prepareInputFilesABAQUS(Xobj)
%PREPARE NASTRAN INPUTFILES prepares necessary input files for perturbation
%                           according to the chosen probabilistic model
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/prepareInputFilesABAQUS@Nastsem
%
% =======================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% =======================================================================

global OPENCOSSAN

OpenCossan.cossanDisp('[SFEM.prepareInputFilesABAQUS] Preparation of the input files started',1);

startTime = OPENCOSSAN.Xtimer.currentTime;

%% Getting the required data 

Xinp            = Xobj.Xmodel.Xinput;  % Obtain Input

assert(length(Xinp.CnamesRandomVariableSet)==1,'openCOSSAN:SFEM:checkInput',...
    'Only 1 Random Variable Set is allowed in Nastsem.')
Xrvs            = Xinp.Xrvset.(Xinp.CnamesRandomVariableSet{1});    % Obtain RVSET
Crvnames        = Xinp.CnamesRandomVariable;                  % Obtain RV names
Nrvs            = Xinp.NrandomVariables;                      % Obtain No of RVs
Vmeanvalues     = get(Xrvs,'members','mean');                         % Obtain mean values of each RV
Vstdvalues      = get(Xrvs,'members','std');                          % Obtain std dev values of each RV
Smaininputpath  = Xobj.Xmodel.Xevaluator.CXsolvers{1}.Smaininputpath; 

%% Prepare input file for nominal analysis

% First copy the masterfile
[status, ~] = copyfile(fullfile(Smaininputpath,Xobj.Sinputfile),fullfile(OpenCossan.getCossanWorkingPath,'nominal0.dat'));
if status == 0
    error('openCOSSAN:SFEM:prepareInputFilesABAQUS',[Xobj.Sinputfile ' could not be copied from the database']);
elseif status == 1
    OpenCossan.cossanDisp(['[SFEM.prepareInputFilesABAQUS] ' Xobj.Sinputfile ' copied from database'],4);
end

% open the file (following file is used to obtain nominal K and f)
[fid,~] = fopen(fullfile(OpenCossan.getCossanWorkingPath,'nominal0.dat'),'a+');
% in case modal analysis is to be performed, a second file is needed,
% it is not possible to output K and f and M all at once
% Therefore, an additional nominal file is created to output M
if  strcmpi(Xobj.Sanalysis,'Modal')
    pause
    [~, ~] = copyfile(fullfile(Smaininputpath,Xobj.Sinputfile),fullfile(OpenCossan.getCossanWorkingPath,'nominal00.dat'));
    [fid2,~] = fopen(fullfile(OpenCossan.getCossanWorkingPath,'nominal00.dat'),'a+');
end
if fid == -1
    error('openCOSSAN:SFEM:prepareInputFilesABAQUS','nominal0.dat could not be opened ');
else
    OpenCossan.cossanDisp('[SFEM.prepareInputFilesABAQUS] nominal0.dat opened successfully',4);
end   

% Insert the commands to output the stiffness matrix & force vector
fprintf(fid,'*STEP \n'); 
fprintf(fid,'*MATRIX GENERATE, STIFFNESS, LOAD  \n');  
for ilines = 1:length(Xobj.CstepDefinition)
  fprintf(fid,'%s \n',Xobj.CstepDefinition{ilines}); 
end
fprintf(fid,'*END STEP \n'); 

% Insert the commands to output the mass matrix into second file
if  strcmpi(Xobj.Sanalysis,'Modal')
    fprintf(fid2,'*STEP \n');
    fprintf(fid2,'*MATRIX GENERATE, MASS  \n');
    for ilines = 1:length(Xobj.CstepDefinition)
        fprintf(fid2,'%s \n',Xobj.CstepDefinition{ilines});
    end
    fprintf(fid2,'*END STEP \n');
    fclose(fid2);
end

% close the file
fclose(fid);

%% Prepare the Tinput structure to be used to prepare input files

% this part prepares the Tinput structure. This structure contain the
% values to be inserted into the nominal and perturbation files
%
% Note: both positive & negative perturbation values are prepared by
% default, however, the negative ones are used only if second order input
% approximation is selected

for krvno=1:Nrvs
    for jrvno=1:Nrvs
        eval([ 'Tinputnominal(jrvno).'         Crvnames{krvno} ' = Vmeanvalues(krvno) ;' ]);
        eval([ 'TinputPerturbPositive(jrvno).' Crvnames{krvno} ' = Vmeanvalues(krvno) ;' ]);
        eval([ 'TinputPerturbNegative(jrvno).' Crvnames{krvno} ' = Vmeanvalues(krvno) ;' ]);
    end
end

%% Insert the nominal values of RVs into nominal.dat file

inj1=Injector('Stype','scan','Sscanfilename','nominal0.dat','Sworkingdirectory',[OpenCossan.getCossanWorkingPath ],...
              'Sscanfilepath',[OpenCossan.getCossanWorkingPath ],'Sfile','tmpfile.dat'); 
inject(inj1,Tinputnominal(1));
[status, ~] = copyfile(fullfile(OpenCossan.getCossanWorkingPath,'tmpfile.dat'),fullfile(OpenCossan.getCossanWorkingPath,'nominal.inp'));
if status == 0
    error('openCOSSAN:SFEM:prepareInputFilesABAQUS','tmpfile.dat could not be copied');
elseif status == 1
    OpenCossan.cossanDisp('[SFEM.prepareInputFilesABAQUS] tmpfile.dat copied successfully',4);
end    

if strcmpi(Xobj.Sanalysis,'Modal')
    inj1=Injector('Stype','scan','Sscanfilename','nominal00.dat','Sworkingdirectory',[OpenCossan.getCossanWorkingPath ],...
        'Sscanfilepath',[OpenCossan.getCossanWorkingPath ],'Sfile','tmpfile.dat');
    inject(inj1,Tinputnominal(1));
    [~, ~] = copyfile(fullfile(OpenCossan.getCossanWorkingPath,'tmpfile.dat'),fullfile(OpenCossan.getCossanWorkingPath,'nominal2.inp'));
end

%% The following part prepares Tinput structure for the perturbed files
% For each file, only the considered RV is perturbed, 
% (the remaining RVs have the mean values which are already inserted above)
%
% NOTE : Perturbation amount is fixed : 1 std dev
Vperturbpositive = zeros(Nrvs,1);
Vperturbnegative = zeros(Nrvs,1);
for irvno=1:Nrvs
    % All RVs are perturbed by the amount of their std deviation 
    Vperturbpositive(irvno) = Vmeanvalues(irvno) + Vstdvalues(irvno);
    Vperturbnegative(irvno) = Vmeanvalues(irvno) - Vstdvalues(irvno);
    for jrvno=1:Nrvs
        if jrvno==irvno
            eval([ 'TinputPerturbPositive(jrvno).' Crvnames{jrvno} ' = Vperturbpositive(jrvno) ;' ]);
            eval([ 'TinputPerturbNegative(jrvno).' Crvnames{jrvno} ' = Vperturbnegative(jrvno) ;' ]);
        end
    end
end

%% Prepare the POSITIVE perturbed input files

for irvno=1:Nrvs
    Sperturbedfilename = ['positive_perturbed_' Crvnames{irvno} '.inp'];
    [status, ~] = copyfile(fullfile(OpenCossan.getCossanWorkingPath,'nominal0.dat'),fullfile(OpenCossan.getCossanWorkingPath,Sperturbedfilename));
    if status == 0
        error('openCOSSAN:SFEM:prepareInputFilesABAQUS',[Sperturbedfilename ' code could not be copied']);
    elseif status == 1
        OpenCossan.cossanDisp(['[SFEM.prepareInputFilesABAQUS ' Sperturbedfilename ' copied successfully'],4);
    end
    inj1=Injector('Stype','scan','Sscanfilename',Sperturbedfilename,...
        'Sworkingdirectory',[OpenCossan.getCossanWorkingPath ],...
        'Sscanfilepath',[OpenCossan.getCossanWorkingPath ],'Sfile','tmpfile.dat');
    inject(inj1,TinputPerturbPositive(irvno));
    [status, ~] = copyfile(fullfile(OpenCossan.getCossanWorkingPath,'tmpfile.dat'),fullfile(OpenCossan.getCossanWorkingPath,Sperturbedfilename));
    if status == 0
        error('openCOSSAN:SFEM:prepareInputFilesABAQUS',[Sperturbedfilename ' code could not be copied']);
    elseif status == 1
        OpenCossan.cossanDisp(['[SFEM.prepareInputFilesABAQUS ' Sperturbedfilename ' copied successfully'],4);
    end
end
    
%% Prepare the NEGATIVE perturbed input files

% NOTE: negative perturbed files are only needed if 2. order approximation
% is to be used

if Xobj.NinputApproximationOrder == 2
    for irvno=1:Nrvs
        Sperturbedfilename = ['negative_perturbed_' Crvnames{irvno} '.inp'];
        [status, ~] = copyfile(fullfile(OpenCossan.getCossanWorkingPath,'nominal0.dat'),fullfile(OpenCossan.getCossanWorkingPath,Sperturbedfilename));
        if status == 0
            error('openCOSSAN:SFEM:prepareInputFilesABAQUS',[Sperturbedfilename ' code could not be copied']);
        elseif status == 1
            OpenCossan.cossanDisp(['[SFEM.prepareInputFilesABAQUS ' Sperturbedfilename ' copied successfully'],4);
        end
        inj1=Injector('Stype','scan','Sscanfilename',Sperturbedfilename,...
            'Sworkingdirectory',[OpenCossan.getCossanWorkingPath ],...
            'Sscanfilepath',[CossOPENCOSSANanX.SworkingPath ],'Sfile','tmpfile.dat');
        inject(inj1,TinputPerturbNegative(irvno));
        [status, ~] = copyfile(fullfile(OpenCossan.getCossanWorkingPath,'tmpfile.dat'),fullfile(OpenCossan.getCossanWorkingPath,Sperturbedfilename));
        if status == 0
            error('openCOSSAN:SFEM:prepareInputFilesABAQUS',[Sperturbedfilename ' code could not be copied']);
        elseif status == 1
            OpenCossan.cossanDisp(['[SFEM.prepareInputFilesABAQUS ' Sperturbedfilename ' copied successfully'],4);
        end
    end
end

delete(fullfile(OpenCossan.getCossanWorkingPath,'tmpfile.dat')) 

%% Record the CPU time

stopTime          = OPENCOSSAN.Xtimer.currentTime;
Xobj.Ccputimes{2} = stopTime - startTime;

OpenCossan.cossanDisp(['[SFEM.prepareInputFilesABAQUS] Preparation of the input files completed in ' num2str(Xobj.Ccputimes{2}) ' sec'],1);

return

