function Xobj = prepareInputFilesForGuyan(Xobj)
%PREPARE NASTRAN INPUTFILES prepares necessary input files for perturbation
%                           according to the chosen probabilistic model
%
% See Also:
% http://cossan.cfd.liv.ac.uk/wiki/index.php/prepareInputFilesForGuyan@SfemPolynomialChaos
%
% =======================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% =======================================================================

global OPENCOSSAN

OpenCossan.cossanDisp('[SFEM.prepareInputFilesForGuyan] Preparation of the input files started',1);

startTime = OPENCOSSAN.Xtimer.currentTime;

%% Getting the required data

Xinp            = Xobj.Xmodel.Xinput;                                 % Obtain Input
assert(length(Xinp.CnamesRandomVariableSet)==1,'openCOSSAN:SFEM:checkInput',...
    'Only 1 Random Variable Set is allowed in SFEM.')
Xrvs            = Xinp.Xrvset.(Xinp.CnamesRandomVariableSet{1});    % Obtain RVSET
Crvnames        = Xinp.CnamesRandomVariable;                  % Obtain RV names
Nrvs            = Xinp.NrandomVariables;                      % Obtain No of RVs

Vmeanvalues     = get(Xrvs,'members','mean');                         % Obtain mean values of each RV
Vstdvalues      = get(Xrvs,'members','std');                          % Obtain std dev values of each RV
Smaininputpath  = Xobj.Xmodel.Xevaluator.CXsolvers{1}.Smaininputpath;

%% Copy the required DMAP code from database to the current working directory

for i=1:length(Xobj.CdmapFileNames)
    [status, ~] = copyfile(fullfile(OPENCOSSAN.SmatlabDatabasePath,'DMAP',...
        Xobj.CdmapFileNames{i}),OpenCossan.getCossanWorkingPath);
    if status == 0
        error('openCOSSAN:SFEM:prepareInputFilesForGuyan','DMAP code could not be copied from the database');
    elseif status == 1
        OpenCossan.cossanDisp(['[SFEM.prepareInputFilesForGuyan] ' Xobj.CdmapFileNames{i} ' copied from database'],3);
    end
end

%% Prepare input file for nominal analysis

% open masterfile (the main deterministic FE file with identifiers)
[fid,~] = fopen(fullfile(Smaininputpath,Xobj.Sinputfile),'r+');
if fid == -1
    error('openCOSSAN:SFEM:error',[Xobj.Sinputfile ' could not be opened ']);
else
    OpenCossan.cossanDisp(['[SFEM.prepareInputFilesForGuyan] ' Xobj.Sinputfile ' opened successfully'],3);
end

% First create a file with the
[fid2,~] = fopen(fullfile(OpenCossan.getCossanWorkingPath,'nominal0.dat'),'w+');
if fid == -1
    error('openCOSSAN:SFEM:prepareInputFilesForGuyan','nominal0.dat could not be opened ');
else
    OpenCossan.cossanDisp('[SFEM.prepareInputFilesForGuyan] nominal0.dat opened successfully',3);
end

% following file is created in order to obtain the full size, i.e. without
% Guyan reduction, force vector. This is needed then to obtain f_B (see notation
% in the notes), as f_B = PA - fm, PA is what NASTRAN outputs, and fm is
% focre on the master-DOFs (= response DOFs), so using the full size vector
% and the requested response DOFs, I obtain fm
[fid4,~] = fopen(fullfile(OpenCossan.getCossanWorkingPath,'nominal00.dat'),'w+');
if fid == -1
    error('openCOSSAN:SFEM:prepareInputFilesForGuyan','nominal00.dat could not be opened ');
else
    OpenCossan.cossanDisp('[SFEM.prepareInputFilesForGuyan] nominal00.dat opened successfully',3);
end

% constant.dat file is created in order to speed-up the preparation of the
% input files. It stores all the part of BULK DATA without the lines with
% identifiers
[fid3,~] =  fopen(fullfile(OpenCossan.getCossanWorkingPath,'constant.dat'),'w+');
if fid == -1
    error('openCOSSAN:SFEM:prepareInputFilesForGuyan','constant.dat could not be opened ');
else
    OpenCossan.cossanDisp('[SFEM.prepareInputFilesForGuyan] constant.dat opened successfully',3);
end

% The following check is necessary in order to print only the lines without
% the identifiers to constant.dat and also to quit the following loop
% properly
check = 0;
while 1
    Sline = fgetl(fid);
    if ischar(Sline),
        fwrite(fid2,Sline);
        fprintf(fid2,'\n');
        fwrite(fid4,Sline);
        fprintf(fid4,'\n');
    end
    if check == 1,   break,   end
    % Searching for SOL string to find right place to insert DMAP commands
    if (length(Sline)>2 && strcmp(Sline(1:3),'SOL'))
        % getting the position of the 'SOL' string
        position = ftell(fid);
        % going back to before that position in the text file
        position = position - 8;
        % setting the position for further writing
        fseek(fid2, position,'bof');
        fprintf(fid2,'\n');
        fseek(fid4, position,'bof');
        fprintf(fid2,'\n');
        % only static analysis case is implemented for P-C currently
        fprintf(fid2,'assign output4=%s_K_NOMINAL.op4,unit=13,formatted,delete\n',Xobj.Sjobname);
        fprintf(fid2,'assign output4=%s_PA_NOMINAL.op4,unit=61,formatted,delete\n',Xobj.Sjobname);
        fprintf(fid2,'assign PUNCH=%s_DOFS.pch,unit=52,formatted,delete\n',Xobj.Sjobname);
        % insert the SOL command back to the file
        fprintf(fid2,Sline);
        fprintf(fid2,'\n');
        % following dmap is inserted to nominal0.dat (see explanation above)
        fprintf(fid2,'INCLUDE dmapoutputnominalguyan.dat \n');
        fprintf(fid4,'assign output4=%s_F_NOMINAL.op4,unit=13,formatted,delete\n',Xobj.Sjobname);
        % insert the SOL command back to the file
        fprintf(fid4,Sline);
        fprintf(fid4,'\n');
        % following dmap is inserted to nominal00.dat (see explanation above)
        fprintf(fid4,'INCLUDE dmapoutputforce.dat \n');
    end
    if length(Sline)>9 && strcmp(Sline(1:10),'BEGIN BULK')
        % following line assigns the requested response DOF to A-set in
        % NASTRAN, which means the master-DOFs
        for m=1:size(Xobj.MmasterDOFs,1)
            eval(['fprintf(fid2,''ASET,' num2str(Xobj.MmasterDOFs(m,1)) ','  num2str(Xobj.MmasterDOFs(m,2)) '\n'');']);
        end
        fprintf(fid2,'\n');
        fprintf(fid2,'include constant.dat \n');
        fprintf(fid2,'\n');
        fprintf(fid4,'\n');
        fprintf(fid4,'include constant.dat \n');
        fprintf(fid4,'\n');
        while 1
            Sline = fgetl(fid);
            if ~ischar(Sline), fprintf(fid2,'ENDDATA\n'); fprintf(fid4,'ENDDATA\n'); break,   end
            Lfindidentifierlines = strfind(Sline, 'cossan');
            if ~isempty(Lfindidentifierlines)
                fwrite(fid2,Sline);
                fprintf(fid2,'\n');
                fwrite(fid4,Sline);
                fprintf(fid4,'\n');
            end
        end
        check = 1;
    end
end

%% write the constant part of BULKDATA to constant.dat

frewind(fid);
while 1
    Sline = fgetl(fid);
    if ~ischar(Sline),   break,   end
    if (strcmp(Sline,'BEGIN BULK') )
        while 1
            Sline = fgetl(fid);
            if (length(Sline)>6 && strcmp(Sline(1:7),'ENDDATA'))
                break
            end
            Lfindidentifierlines = strfind(Sline, 'cossan');
            if isempty(Lfindidentifierlines)
                fwrite(fid3,Sline);
                fprintf(fid3,'\n');
            end
            if ~ischar(Sline)
                break
            end
        end
    end
end

%% close all the open files

fclose(fid);
fclose(fid2);
fclose(fid3);
fclose(fid4);

%% Prepare the Tinput structure to be used to prepare input files

% NOTE: this part prepares the Tinput structure. This structure contain the
% values to be inserted into the nominal and perturbation files

% First the whole structure is prepared such that in contains only the mean values
for krvno=1:Nrvs
    for jrvno=1:Nrvs
        eval([ 'Tinputnominal(jrvno).'         Crvnames{krvno} ' = Vmeanvalues(krvno) ;' ]);
        eval([ 'TinputPerturbPositive(jrvno).' Crvnames{krvno} ' = Vmeanvalues(krvno) ;' ]);
        eval([ 'TinputPerturbNegative(jrvno).' Crvnames{krvno} ' = Vmeanvalues(krvno) ;' ]);
    end
end

%% Insert the nominal values of RVs into nominal.dat file

inj1=Injector('Stype','scan','Sscanfilename','nominal0.dat','Sworkingdirectory',OpenCossan.getCossanWorkingPath,...
    'Sscanfilepath',OpenCossan.getCossanWorkingPath,'Sfile','tmpfile.dat');
inject(inj1,Tinputnominal(1));
[status, ~] = copyfile(fullfile(OpenCossan.getCossanWorkingPath,'tmpfile.dat'),fullfile(OpenCossan.getCossanWorkingPath,'nominal.dat'));
if status == 0
    error('openCOSSAN:SFEM:prepareInputFilesForGuyan','tmpfile.dat could not be copied');
elseif status == 1
    OpenCossan.cossanDisp('[SFEM.prepareInputFilesForGuyan] tmpfile.dat copied successfully',3);
end

inj1=Injector('Stype','scan','Sscanfilename','nominal00.dat','Sworkingdirectory',OpenCossan.getCossanWorkingPath,...
    'Sscanfilepath',OpenCossan.getCossanWorkingPath,'Sfile','tmpfile2.dat');
inject(inj1,Tinputnominal(1));
[status, ~] = copyfile(fullfile(OpenCossan.getCossanWorkingPath,'tmpfile2.dat'),fullfile(OpenCossan.getCossanWorkingPath,'nominal2.dat'));
if status == 0
    error('openCOSSAN:SFEM:prepareInputFilesForGuyan','tmpfile2.dat could not be copied');
elseif status == 1
    OpenCossan.cossanDisp('[SFEM.prepareInputFilesForGuyan] tmpfile2.dat copied successfully',3);
end

%% The following part prepares Tinput structure for the perturbed files
% For each file, only the considered RV is perturbed,
% (the remaining RVs have the mean values which are already inserted above)

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

%% Prepare the perturbed input files (as many as No of RVs)

for irvno=1:Nrvs
    % POSITIVE perturbed files
    [fid, ~]  = fopen(fullfile(OpenCossan.getCossanWorkingPath,'nominal0.dat'),'r+');
    if fid == -1
        error('openCOSSAN:SFEM:prepareInputFilesForGuyan','nominal0.dat could not be opened ');
    else
        OpenCossan.cossanDisp('[SFEM.prepareInputFilesForGuyan] nominal0.dat opened successfully',3);
    end
    Sperturbedfilename = ['positive_perturbed_' Crvnames{irvno} '.dat'];
    [fid2, ~]  = fopen(fullfile(OpenCossan.getCossanWorkingPath,Sperturbedfilename),'w+');
    if fid2 == -1
        error('openCOSSAN:SFEM:prepareInputFilesForGuyan',[ Sperturbedfilename ' could not be opened ']);
    else
        OpenCossan.cossanDisp(['[SFEM.prepareInputFilesForGuyan] ' Sperturbedfilename ' opened successfully'],3);
    end
    while 1
        Sline = fgetl(fid);
        Lfindidentifierlines1 = strfind(Sline, 'assign');
        Lfindidentifierlines2 = strfind(Sline, 'INCLUDE');
        Lfindidentifierlines3 = strfind(Sline, 'ASET');
        if ~ischar(Sline),   break,   end
        if isempty(Lfindidentifierlines1) && isempty(Lfindidentifierlines2) && isempty(Lfindidentifierlines3)
            fwrite(fid2,Sline);
            fprintf(fid2,'\n');
        end
        if (length(Sline)>2 && strcmp(Sline(1:3),'SOL'))
            % getting the position of the 'SOL 101' string
            position = ftell(fid2);
            % going back to before that position in the text file
            position = position - 8;
            % setting the position for further writing
            fseek(fid2, position,'bof');
            fprintf(fid2,'\n');
            % Include the DMAP file to output the required quantity & file statements
            % according to the name of the RV
            % NOTE: the name convention of RV's:
            % RVK = a random property related to K matrix
            fprintf(fid2,'assign output4=%s_K_pos_per_%s.op4,unit=13,formatted,delete\n',...
                Xobj.Sjobname,Crvnames{irvno});
            fprintf(fid2,'assign output4=%s_PA_pos_per_%s.op4,unit=61,formatted,delete\n',...
                Xobj.Sjobname,Crvnames{irvno});
            % insert the SOL command back to the file
            fprintf(fid2,Sline);
            fprintf(fid2,'\n');
            fprintf(fid2,'INCLUDE dmapoutputstiffnessandforceguyan.dat \n');
        end
        if (length(Sline)>9 && strcmp(Sline(1:10),'BEGIN BULK'))
            for m=1:size(Xobj.MmasterDOFs,1)
                eval(['fprintf(fid2,''ASET,' num2str(Xobj.MmasterDOFs(m,1)) ','  num2str(Xobj.MmasterDOFs(m,2)) '\n'');']);
            end
        end
    end
    fclose(fid2);
    fclose(fid);
    inj1=Injector('Stype','scan','Sscanfilename',Sperturbedfilename,...
        'Sworkingdirectory',OpenCossan.getCossanWorkingPath,...
        'Sscanfilepath',OpenCossan.getCossanWorkingPath,'Sfile','tmpfile.dat');
    inject(inj1,TinputPerturbPositive(irvno));
    [status, ~] = copyfile(fullfile(OpenCossan.getCossanWorkingPath,'tmpfile.dat'),fullfile(OpenCossan.getCossanWorkingPath,Sperturbedfilename));
    if status == 0
        error('openCOSSAN:SFEM:prepareInputFilesForGuyan',[Sperturbedfilename ' code could not be copied']);
    elseif status == 1
        OpenCossan.cossanDisp(['[SFEM.prepareInputFilesForGuyan] ' Sperturbedfilename ' copied successfully'],3);
    end
    
    % NEGATIVE Perturbed files
    [fid, ~]  = fopen(fullfile(OpenCossan.getCossanWorkingPath,'nominal0.dat'),'r+');
    if fid == -1
        error('openCOSSAN:SFEM:prepareInputFilesForGuyan','nominal0.dat could not be opened ');
    else
        OpenCossan.cossanDisp('[SFEM.prepareInputFilesForGuyan] nominal0.dat opened successfully',3);
    end
    Sperturbedfilename = ['negative_perturbed_' Crvnames{irvno} '.dat'];
    [fid2, ~]  = fopen(fullfile(OpenCossan.getCossanWorkingPath,Sperturbedfilename),'w+');
    if fid2 == -1
        error('openCOSSAN:SFEM:prepareInputFilesForGuyan',[Sperturbedfilename ' could not be opened ']);
    else
        OpenCossan.cossanDisp(['[SFEM.prepareInputFilesForGuyan] ' Sperturbedfilename ' opened successfully'],3);
    end
    while 1
        Sline = fgetl(fid);
        Lfindidentifierlines1 = strfind(Sline, 'assign');
        Lfindidentifierlines2 = strfind(Sline, 'INCLUDE');
        Lfindidentifierlines3 = strfind(Sline, 'ASET');
        if ~ischar(Sline),   break,   end
        if isempty(Lfindidentifierlines1) && isempty(Lfindidentifierlines2) && isempty(Lfindidentifierlines3)
            fwrite(fid2,Sline);
            fprintf(fid2,'\n');
        end
        if (length(Sline)>2 && strcmp(Sline(1:3),'SOL'))
            % getting the position of the 'SOL 101' string
            position = ftell(fid2);
            % going back to before that position in the text file
            position = position - 8;
            % setting the position for further writing
            fseek(fid2, position,'bof');
            fprintf(fid2,'\n');
            % Include the DMAP file to output the required quantity & file statements
            % according to the name of the RV
            % NOTE: the name convention of RV's:
            % RVK = a random property related to K matrix
            fprintf(fid2,'assign output4=%s_K_neg_per_%s.op4,unit=13,formatted,delete\n',...
                Xobj.Sjobname,Crvnames{irvno});
            fprintf(fid2,'assign output4=%s_PA_neg_per_%s.op4,unit=61,formatted,delete\n',...
                Xobj.Sjobname,Crvnames{irvno});
            % insert the SOL command back to the file
            fprintf(fid2,Sline);
            fprintf(fid2,'\n');
            fprintf(fid2,'INCLUDE dmapoutputstiffnessandforceguyan.dat \n');
        end
        if (length(Sline)>9 && strcmp(Sline(1:10),'BEGIN BULK'))
            for m=1:size(Xobj.MmasterDOFs,1)
                eval(['fprintf(fid2,''ASET,' num2str(Xobj.MmasterDOFs(m,1)) ','  num2str(Xobj.MmasterDOFs(m,2)) '\n'');']);
            end
        end
    end
    fclose(fid2);
    fclose(fid);
    inj1=Injector('Stype','scan','Sscanfilename',Sperturbedfilename,...
        'Sworkingdirectory',OpenCossan.getCossanWorkingPath,...
        'Sscanfilepath',OpenCossan.getCossanWorkingPath,'Sfile','tmpfile.dat');
    inject(inj1,TinputPerturbNegative(irvno));
    [status, ~] = copyfile(fullfile(OpenCossan.getCossanWorkingPath,'tmpfile.dat'),fullfile(OpenCossan.getCossanWorkingPath,Sperturbedfilename));
    if status == 0
        error('openCOSSAN:SFEM:prepareInputFilesForGuyan',[Sperturbedfilename ' code could not be copied']);
    elseif status == 1
        OpenCossan.cossanDisp(['[SFEM.prepareInputFilesForGuyan] ' Sperturbedfilename ' copied successfully'],3);
    end
end

delete(fullfile(OpenCossan.getCossanWorkingPath,'tmpfile.dat'))
delete(fullfile(OpenCossan.getCossanWorkingPath,'tmpfile2.dat'))

%% Record the CPU time

stopTime          = OPENCOSSAN.Xtimer.currentTime;
Xobj.Ccputimes{2} = stopTime - startTime;

OpenCossan.cossanDisp(['[SFEM.prepareInputFilesForGuyan] Preparation of the input files completed in ' num2str(Xobj.Ccputimes{2}) ' sec'],1);

return

