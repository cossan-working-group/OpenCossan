function Xobj = prepareInputFilesNASTRANRegular(Xobj)
%PREPARE INPUTFILES REGULAR 
%
%
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/prepareInputFilesNASTRANRegular@Nastsem
%
% =======================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% =======================================================================

global OPENCOSSAN

OpenCossan.cossanDisp('[SFEM.prepareInputFilesNastranRegular] Preparation of the input files started',1);

startTime = OPENCOSSAN.Xtimer.currentTime;

%% Getting the required data 

Xinp            = Xobj.Xmodel.Xinput;                                 % Obtain Input
assert(length(Xinp.CnamesRandomVariableSet)==1,'openCOSSAN:SFEM:prepareInputFilesNASTRANRegular',...
    'Only 1 Random Variable Set is allowed in SFEM.')

assert(length(Xinp.CnamesRandomVariableSet)==1,'openCOSSAN:SFEM:checkInput',...
    'Only 1 Random Variable Set is allowed in SFEM.')
Xrvs            = Xinp.Xrvset.(Xinp.CnamesRandomVariableSet{1});    % Obtain RVSET
Crvnames        = Xinp.CnamesRandomVariable;                  % Obtain RV names
Nrvs            = Xinp.NrandomVariables;                      % Obtain No of RVs
Vmeanvalues     = get(Xrvs,'members','mean');                         % Obtain mean values of each RV
Vstdvalues      = get(Xrvs,'members','std');                          % Obtain std dev values of each RV
Smaininputpath  = Xobj.Xmodel.Xevaluator.CXsolvers{1}.Smaininputpath; 

%% Copy the DMAP code from database

for i=1:length(Xobj.CdmapFileNames)
    [status, Smessage] = copyfile(fullfile(OPENCOSSAN.SmatlabDatabasePath,...
                'DMAP',Xobj.CdmapFileNames{i}),OpenCossan.getCossanWorkingPath);
    if status == 0
         assert(isempty(Smessage),...
           'openCOSSAN:SFEM:prepareInputFilesNastranRegular', ...
       '[SFEM.prepareInputFilesNastranRegular] DMAP code could not be copied from the database/n%s',Smessage)
    elseif status == 1
        OpenCossan.cossanDisp(['[SFEM.prepareInputFilesNastranRegular] ' Xobj.CdmapFileNames{i} ' copied from database'],3);
    end
end

%% Prepare input file for nominal analysis

% open masterfile (the main deterministic FE file with identifiers)
[fid,~] = fopen(fullfile(Smaininputpath,Xobj.Sinputfile),'r+');
if fid == -1
    error('openCOSSAN:SFEM:prepareInputFilesNastranRegular',['[SFEM.prepareInputFilesNastranRegular] ' Xobj.Sinputfile ' could not be opened ']);
else
    OpenCossan.cossanDisp(['[SFEM.prepareInputFilesNastranRegular] ' Xobj.Sinputfile ' opened successfully'],4);
end   

% First masterfile is copied with a dummy name
[fid2,~] = fopen(fullfile(OpenCossan.getCossanWorkingPath,'nominal0.dat'),'w+');
if fid2 == -1
    error('openCOSSAN:SFEM:prepareInputFilesNastranRegular','[SFEM.prepareInputFilesNastranRegular] nominal0.dat could not be opened ');
else
    OpenCossan.cossanDisp('[SFEM.prepareInputFilesNastranRegular] nominal0.dat opened successfully',4);
end 

% constant.dat file is created in order to speed-up the preparation of the 
% input files. It stores all the part of BULK DATA without the lines with
% identifiers
fid3 = fopen(fullfile(OpenCossan.getCossanWorkingPath,'constant.dat'),'w+');
if fid3 == -1
    error('openCOSSAN:SFEM:prepareInputFilesNastranRegular','[SFEM.prepareInputFilesNastranRegular] constant.dat could not be opened ');
else
    OpenCossan.cossanDisp('[SFEM.prepareInputFilesNastranRegular] constant.dat opened successfully',4);
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
        if  strcmpi(Xobj.Sanalysis,'Modal')
            fprintf(fid2,'assign output4=%s_K_NOMINAL.op4,unit=13,formatted,delete\n',Xobj.Sjobname);
            fprintf(fid2,'assign output4=%s_M_NOMINAL.op4,unit=85,formatted,delete\n',Xobj.Sjobname);                 
            fprintf(fid2,'assign output4=%s_LAMDA_NOMINAL.op4,unit=86,formatted,delete\n',Xobj.Sjobname);
            fprintf(fid2,'assign output4=%s_PHI_NOMINAL.op4,unit=87,formatted,delete\n',Xobj.Sjobname);
            fprintf(fid2,'assign PUNCH=%s_DOFS.pch,unit=52,formatted,delete\n',Xobj.Sjobname);
            % insert the SOL command back to the file
            fprintf(fid2,Sline);
            fprintf(fid2,'\n');
            fprintf(fid2,'INCLUDE dmapoutputnominalmodal.dat \n');             
        else
            % Include the DMAP file to output nominal K and u & file statements
            fprintf(fid2,'assign output4=%s_K_NOMINAL.op4,unit=13,formatted,delete\n',Xobj.Sjobname);
            fprintf(fid2,'assign output4=%s_u_NOMINAL.op4,unit=23,formatted,delete\n',Xobj.Sjobname);
            fprintf(fid2,'assign output4=%s_F_NOMINAL.op4,unit=61,formatted,delete\n',Xobj.Sjobname);            
            fprintf(fid2,'assign PUNCH=%s_DOFS.pch,unit=52,formatted,delete\n',Xobj.Sjobname);
            % insert the SOL command back to the file
            fprintf(fid2,Sline);
            fprintf(fid2,'\n');
            fprintf(fid2,'INCLUDE dmapoutputnominalstatic.dat \n');
        end
    end
    if length(Sline)>9 && strcmp(Sline(1:10),'BEGIN BULK')
        fprintf(fid2,'\n');
        fprintf(fid2,'include constant.dat \n');
        fprintf(fid2,'\n');
        while 1
            Sline = fgetl(fid);
            if ~ischar(Sline), 
                fprintf(fid2,'ENDDATA\n'); 
                break,   
            end
            Lfindidentifierlines = strfind(Sline, 'cossan');
            if ~isempty(Lfindidentifierlines)
                fwrite(fid2,Sline);
                fprintf(fid2,'\n');
            end
        end
        % here you say that the you have handled the part for the BULKDATA
        % properly and you can quit the loop
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
            if (length(Sline)>6 && strcmp(Sline(1:7),'ENDDATA')), break,   end
                Lfindidentifierlines = strfind(Sline, 'cossan');
                if isempty(Lfindidentifierlines)
                    fwrite(fid3,Sline);
                    fprintf(fid3,'\n');
                end
            if ~ischar(Sline),   break,   end
        end
    end    
end

%% close the files

fclose(fid);
fclose(fid2);
fclose(fid3);

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

[status, ~] = copyfile(fullfile(OpenCossan.getCossanWorkingPath,'tmpfile.dat'),fullfile(OpenCossan.getCossanWorkingPath,'nominal.dat'));
if status == 0
    error('openCOSSAN:SFEM:prepareInputFilesNastranRegular','tmpfile.dat could not be copied');
elseif status == 1
    OpenCossan.cossanDisp('[SFEM.prepareInputFilesNastranRegular] tmpfile.dat copied successfully',4);
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
       
% Prepare the perturbed files for the RVs
for irvno=1:Nrvs
    [fid, ~]  = fopen(fullfile(OpenCossan.getCossanWorkingPath,'nominal0.dat'),'r+');
    if fid == -1
        error('openCOSSAN:SFEM:prepareInputFilesNastranRegular','nominal0.dat could not be opened ');
    else
        OpenCossan.cossanDisp('[SFEM.prepareInputFilesNastranRegular] nominal0.dat opened successfully',4);
    end 
    Sperturbedfilename = ['positive_perturbed_' Crvnames{irvno} '.dat'];
    [fid2, ~] = fopen(fullfile(OpenCossan.getCossanWorkingPath,Sperturbedfilename),'w+');
    if fid2 == -1
        error('openCOSSAN:SFEM:prepareInputFilesNastranRegular',[Sperturbedfilename ' could not be opened ']);
    else
        OpenCossan.cossanDisp(['[SFEM.prepareInputFilesNastranRegular] ' Sperturbedfilename ' opened successfully'],4);
    end 
    while 1
        Sline = fgetl(fid);
        if ~ischar(Sline),   break,   end
        Lfindidentifierlines1 = strfind(Sline, 'assign');
        Lfindidentifierlines2 = strfind(Sline, 'INCLUDE');
        if isempty(Lfindidentifierlines1) && isempty(Lfindidentifierlines2)
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
            % Include the DMAP file to output the required quantity & file
            % statements according to the type of RV
            % For STIFFNESS MATRIX
            if ~isempty(intersect(Crvnames{irvno},Xobj.CyoungsModulusRVs)) || ...
                    ~isempty(intersect(Crvnames{irvno},Xobj.CthicknessRVs)) || ...
                   ~isempty(intersect(Crvnames{irvno},Xobj.CcrossSectionRVs))
                fprintf(fid2,'assign output4=%s_K_pos_per_%s.op4,unit=13,formatted,delete\n',...
                    Xobj.Sjobname,Crvnames{irvno});
                % insert the SOL command back to the file
                fprintf(fid2,Sline);
                fprintf(fid2,'\n');
                fprintf(fid2,'INCLUDE dmapoutputstiffness.dat \n');
            % For FORCE VECTOR
            elseif ~isempty(intersect(Crvnames{irvno},Xobj.CdensityRVs)) && strcmpi(Xobj.Sanalysis,'Static')
                fprintf(fid2,'assign output4=%s_F_pos_per_%s.op4,unit=13,formatted,delete\n',...
                    Xobj.Sjobname,Crvnames{irvno});
                % insert the SOL command back to the file
                fprintf(fid2,Sline);
                fprintf(fid2,'\n');
                fprintf(fid2,'INCLUDE dmapoutputforce.dat \n');
            % For FORCE VECTOR
            elseif ~isempty(intersect(Crvnames{irvno},Xobj.CforceRVs)) && strcmpi(Xobj.Sanalysis,'Static')
                fprintf(fid2,'assign output4=%s_F_pos_per_%s.op4,unit=13,formatted,delete\n',...
                    Xobj.Sjobname,Crvnames{irvno});
                % insert the SOL command back to the file
                fprintf(fid2,Sline);
                fprintf(fid2,'\n');
                fprintf(fid2,'INCLUDE dmapoutputforce.dat \n');
            % For MASS MATRIX
            elseif ~isempty(intersect(Crvnames{irvno},Xobj.CdensityRVs)) && strcmpi(Xobj.Sanalysis,'Modal')
                fprintf(fid2,'assign output4=%s_M_pos_per_%s.op4,unit=13,formatted,delete\n',...
                    Xobj.Sjobname,Crvnames{irvno});
                % insert the SOL command back to the file
                fprintf(fid2,Sline);
                fprintf(fid2,'\n');
                fprintf(fid2,'INCLUDE dmapoutputmass.dat \n');
            end
        end
    end
    fclose(fid2);
    fclose(fid);
    inj1=Injector('Stype','scan','Sscanfilename',Sperturbedfilename,...
                  'Sworkingdirectory',[OpenCossan.getCossanWorkingPath ],...
                  'Sscanfilepath',[OpenCossan.getCossanWorkingPath ],'Sfile','tmpfile.dat'); 
    inject(inj1,TinputPerturbPositive(irvno));
    [status, ~] = copyfile(fullfile(OpenCossan.getCossanWorkingPath,'tmpfile.dat'),fullfile(OpenCossan.getCossanWorkingPath,Sperturbedfilename));
    if status == 0
        error('openCOSSAN:SFEM:prepareInputFilesNastranRegular',[ Sperturbedfilename ' code could not be copied']);
    elseif status == 1
        OpenCossan.cossanDisp(['[SFEM.prepareInputFilesNastranRegular] ' Sperturbedfilename ' copied successfully'],4);
    end
end


%% Prepare the NEGATIVE perturbed input files    
    
% NOTE: negative perturbed files are only needed if 2. order approximation
% is to be used

if Xobj.NinputApproximationOrder == 2
   for irvno=1:Nrvs
        % NEGATIVE Perturbed files
        [fid, ~]  = fopen(fullfile(OpenCossan.getCossanWorkingPath,'nominal0.dat'),'r+');
        if fid == -1
            error('openCOSSAN:SFEM:prepareInputFilesNastranRegular','nominal0.dat could not be opened ');
        else
            OpenCossan.cossanDisp('[SFEM.prepareInputFilesNastranRegular] nominal0.dat opened successfully',4);
        end
        Sperturbedfilename = ['negative_perturbed_' Crvnames{irvno} '.dat'];
        [fid2, ~] = fopen(fullfile(OpenCossan.getCossanWorkingPath,Sperturbedfilename),'w+');
        if fid2 == -1
            error('openCOSSAN:SFEM:prepareInputFilesNastranRegular',[Sperturbedfilename ' could not be opened ']);
        else
            OpenCossan.cossanDisp(['[SFEM.prepareInputFilesNastranRegular] ' Sperturbedfilename ' opened successfully'],4);
        end
        while 1
             Sline = fgetl(fid);
             Lfindidentifierlines1 = strfind(Sline, 'assign');
             Lfindidentifierlines2 = strfind(Sline, 'INCLUDE');
             if isempty(Lfindidentifierlines1) && isempty(Lfindidentifierlines2)
                fwrite(fid2,Sline);
                fprintf(fid2,'\n');
             end
            if ~ischar(Sline),   break,   end
            if (length(Sline)>2 && strcmp(Sline(1:3),'SOL'))
                % getting the position of the 'SOL 101' string
                position = ftell(fid2);
                % going back to before that position in the text file
                position = position - 8;
                % setting the position for further writing
                fseek(fid2, position,'bof');
                fprintf(fid2,'\n');
                % Include the DMAP file to output the required quantity & file
                % statements according to the type of RV
                % STIFFNESS MATRIX
                if ~isempty(intersect(Crvnames{irvno},Xobj.CyoungsModulusRVs)) || ...
                   ~isempty(intersect(Crvnames{irvno},Xobj.CthicknessRVs)) || ...
                   ~isempty(intersect(Crvnames{irvno},Xobj.CcrossSectionRVs))
                    fprintf(fid2,'assign output4=%s_K_neg_per_%s.op4,unit=13,formatted,delete\n',...
                            Xobj.Sjobname,Crvnames{irvno});
                    % insert the SOL command back to the file
                    fprintf(fid2,Sline);
                    fprintf(fid2,'\n');
                    fprintf(fid2,'INCLUDE dmapoutputstiffness.dat \n');
                % FORCE VECTOR
                elseif ~isempty(intersect(Crvnames{irvno},Xobj.CdensityRVs)) && ...
                       strcmpi(Xobj.Sanalysis,'Static')
                    fprintf(fid2,'assign output4=%s_F_neg_per_%s.op4,unit=13,formatted,delete\n',...
                        Xobj.Sjobname,Crvnames{irvno});
                    % insert the SOL command back to the file
                    fprintf(fid2,Sline);
                    fprintf(fid2,'\n');
                    fprintf(fid2,'INCLUDE dmapoutputforce.dat \n');
                % FORCE VECTOR
                elseif ~isempty(intersect(Crvnames{irvno},Xobj.CforceRVs)) && ...
                       strcmpi(Xobj.Sanalysis,'Static')
                    fprintf(fid2,'assign output4=%s_F_neg_per_%s.op4,unit=13,formatted,delete\n',...
                        Xobj.Sjobname,Crvnames{irvno});
                    % insert the SOL command back to the file
                    fprintf(fid2,Sline);
                    fprintf(fid2,'\n');
                    fprintf(fid2,'INCLUDE dmapoutputforce.dat \n');
                % MASS MATRIX
                elseif ~isempty(intersect(Crvnames{irvno},Xobj.CdensityRVs)) && ...
                       strcmpi(Xobj.Sanalysis,'Modal')
                    fprintf(fid2,'assign output4=%s_M_neg_per_%s.op4,unit=13,formatted,delete\n',...
                        Xobj.Sjobname,Crvnames{irvno});
                    % insert the SOL command back to the file
                    fprintf(fid2,Sline);
                    fprintf(fid2,'\n');
                    fprintf(fid2,'INCLUDE dmapoutputmass.dat \n'); 
                end
            end
        end
        fclose(fid2);
        fclose(fid);
        inj1=Injector('Stype','scan','Sscanfilename',Sperturbedfilename,...
                  'Sworkingdirectory',OpenCossan.getCossanWorkingPath,...
                  'Sscanfilepath',OpenCossan.getCossanWorkingPath ,'Sfile','tmpfile.dat');
        inject(inj1,TinputPerturbNegative(irvno));
        [status, ~] = copyfile(fullfile(OpenCossan.getCossanWorkingPath,'tmpfile.dat'),fullfile(OpenCossan.getCossanWorkingPath,Sperturbedfilename));       
        if status == 0
            error('openCOSSAN:SFEM:prepareInputFilesNastranRegular',[ Sperturbedfilename ' code could not be copied']);
        elseif status == 1
            OpenCossan.cossanDisp(['[SFEM.prepareInputFilesNastranRegular] ' Sperturbedfilename ' copied successfully'],4);
        end
   end    
end
 
delete(fullfile(OpenCossan.getCossanWorkingPath,'tmpfile.dat')) 

%% Record the CPU time

stopTime          = OPENCOSSAN.Xtimer.currentTime;
Xobj.Ccputimes{2} = stopTime - startTime;

OpenCossan.cossanDisp(['[SFEM.prepareInputFilesNastranRegular] Preparation of the input files completed in ' num2str(Xobj.Ccputimes{2}) ' sec'],1);
OpenCossan.cossanDisp(' ',1);

return

