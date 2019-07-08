function Xobj = prepareInputFilesNASTRANComponentwise(Xobj)
%PREPARE NASTRAN INPUTFILES prepares necessary input files for perturbation
%                           according to the chosen probabilistic model
%
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/prepareInputFilesNASTRANComponentwise@Nastsem
%
% =======================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% =======================================================================

global OPENCOSSAN

OpenCossan.cossanDisp('[SFEM.prepareInputFilesNASTRANComponentwise] Preparation of the input files started',1);

startTime = OPENCOSSAN.Xtimer.currentTime;

%% Getting the required data 

Xinp            = Xobj.Xmodel.Xinput;                                 % Obtain Input
assert(length(Xinp.CnamesRandomVariableSet)==1,'openCOSSAN:SFEM:checkInput',...
    'Only 1 Random Variable Set is allowed in Nastsem.')

Xrvs            = Xinp.Xrvset.(Xinp.CnamesRandomVariableSet{1});    % Obtain RVSET
Crvnames        = Xinp.CnamesRandomVariable;                  % Obtain RV names
Nrvs            = Xinp.NrandomVariables;                      % Obtain No of RVs
Vmeanvalues     = get(Xrvs,'members','mean');                         % Obtain mean values of each RV
Vstdvalues      = get(Xrvs,'members','std');                          % Obtain std dev values of each RV
Smaininputpath  = Xobj.Xmodel.Xevaluator.CXsolvers{1}.Smaininputpath; 

%% Generate the DMAP code

for i=1:length(Xobj.CdmapFileNames)
    [status, ~] = copyfile(fullfile(OPENCOSSAN.SmatlabDatabasePath, 'DMAP', ...
        Xobj.CdmapFileNames{i}),OpenCossan.getCossanWorkingPath);
    if status == 0
        error('openCOSSAN:SFEM:prepareInputFilesNastranRegular','DMAP code could not be copied from the database');
    elseif status == 1
        OpenCossan.cossanDisp(['[SFEM.prepareInputFilesNastranRegular] ' Xobj.CdmapFileNames{i} ' copied from database'],3);
    end
end

%% Prepare input file for nominal analysis

% open masterfile (the main deterministic FE file with identifiers)
[fid,~] = fopen(fullfile(Smaininputpath,Xobj.Sinputfile),'r+');
if fid == -1
    error('openCOSSAN:SFEM:prepareInputFilesNastranRegular',...
        [ Xobj.Sinputfile ' could not be opened ']);
else
    OpenCossan.cossanDisp(['[SFEM.prepareInputFilesNASTRANComponentwise] ' Xobj.Sinputfile ' opened successfully'],3);
end   

% First masterfile is copied with a dummy name
[fid2,~] = fopen(fullfile(OpenCossan.getCossanWorkingPath,'nominal0.dat'),'w+');
if fid2 == -1
    error('openCOSSAN:SFEM:prepareInputFilesNastranRegular',...
        'nominal0.dat could not be opened ');
else
    OpenCossan.cossanDisp('[SFEM.prepareInputFilesNASTRANComponentwise] nominal0.dat opened successfully',3);
end  

% constant.dat file is created in order to speed-up the preparation of the 
% input files. It stores all the part of BULK DATA without the lines with
% identifiers
[fid3,~] =  fopen(fullfile(OpenCossan.getCossanWorkingPath,'constant.dat'),'w+');
if fid3 == -1
    error('openCOSSAN:SFEM:prepareInputFilesNastranRegular',...
        'constant.dat could not be opened ');
else
    OpenCossan.cossanDisp('[SFEM.prepareInputFilesNASTRANComponentwise] constant.dat opened successfully',3);
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

% this part prepares the Tinputnominal structure. This structure contain the
% values to be inserted into the nominal file

for krvno=1:Nrvs
    for jrvno=1:Nrvs
        eval([ 'Tinputnominal(jrvno).'         Crvnames{krvno} ' = Vmeanvalues(krvno) ;' ]);
        eval([ 'TinputPerturbPositive(jrvno).' Crvnames{krvno} ' = Vmeanvalues(krvno) ;' ]);
        eval([ 'TinputPerturbNegative(jrvno).' Crvnames{krvno} ' = Vmeanvalues(krvno) ;' ]);
    end
end

%% Insert the nominal values of RVs into nominal.dat file

inj1=Injector('Stype','scan','Sscanfilename','nominal0.dat','Sworkingdirectory',[OpenCossan.getCossanWorkingPath ],...
              'Sscanfilepath',OpenCossan.getCossanWorkingPath,'Sfile','tmpfile.dat'); 
inject(inj1,Tinputnominal(1));
[status, ~] = copyfile(fullfile(OpenCossan.getCossanWorkingPath,'tmpfile.dat'),fullfile(OpenCossan.getCossanWorkingPath,'nominal.dat'));
if status == 0
    error('openCOSSAN:SFEM:prepareInputFilesNastranRegular',...,
        'tmpfile.dat could not be copied');
elseif status == 1
    OpenCossan.cossanDisp('[SFEM.prepareInputFilesNASTRANComponentwise] tmpfile.dat copied successfully',3);
end    

%% The following part prepares Tinput structure for the perturbed files
% For each file, only the considered RV is perturbed, 
% (the remaining RVs have the mean values which are already inserted above)
%
% NOTE : Perturbation amount is fixed : 1 std deviation
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

%% Prepare the POSITIVE PERTURBED (COMPONENTWISE) input files

% Applies ONLY for the RVs within STIFFNESS & MASS

for irvno=1:Nrvs
    if ~isempty(intersect(Crvnames{irvno},Xobj.CyoungsModulusRVs)) || ...
    ~isempty(intersect(Crvnames{irvno},Xobj.CthicknessRVs)) || ...
     ~isempty(intersect(Crvnames{irvno},Xobj.CcrossSectionRVs)) || ...
    (~isempty(intersect(Crvnames{irvno},Xobj.CdensityRVs)) && strcmpi(Xobj.Sanalysis,'Modal'))  
        Sfilename = [ Crvnames{irvno} '.dat'];
        [fid, ~]  = fopen(fullfile(Smaininputpath,Sfilename),'r+');
        Sperturbedfilename=['positive_perturbed_' Crvnames{irvno} '.dat'];
        [~, ~] = copyfile(fullfile(OpenCossan.getCossanWorkingPath,Sfilename),fullfile(OpenCossan.getCossanWorkingPath,Sperturbedfilename));
        [fid2, ~] = fopen(fullfile(OpenCossan.getCossanWorkingPath,Sperturbedfilename),'w+');
        if fid2 == -1
            error('openCOSSAN:SFEM:prepareInputFilesNastranRegular',...,
                [Sperturbedfilename ' could not be opened ']);
        else
            OpenCossan.cossanDisp(['[SFEM.prepareInputFilesNASTRANComponentwise] ' Sperturbedfilename ' opened successfully'],3);
        end
        while 1
            Sline = fgetl(fid);
            if ~ischar(Sline),   break,   end
            fwrite(fid2,Sline);
            fprintf(fid2,'\n');
            if (length(Sline)>2 && strcmp(Sline(1:3),'SOL'))
                % getting the position of the 'SOL 101' string
                position = ftell(fid);
                % going back to before that position in the text file
                position = position - 8;
                % setting the position for further writing
                fseek(fid2, position,'bof');
                fprintf(fid2,'\n');
                % OUTPUT COMPONENT STIFFNESS MATRIX
                if ~isempty(intersect(Crvnames{irvno},Xobj.CyoungsModulusRVs)) || ...
                ~isempty(intersect(Crvnames{irvno},Xobj.CthicknessRVs)) || ...
                ~isempty(intersect(Crvnames{irvno},Xobj.CcrossSectionRVs)) 
                    fprintf(fid2,'assign output4=%s_K_pos_per_%s.op4,unit=13,formatted,delete\n',...
                    Xobj.Sjobname,Crvnames{irvno});
                    fprintf(fid2,'assign PUNCH=%s_KDOFs_%s.pch,unit=52,formatted,delete\n',...
                    Xobj.Sjobname,Crvnames{irvno});
                    fprintf(fid2,Sline);
                    fprintf(fid2,'\n');
                    fprintf(fid2,'INCLUDE dmapoutputstiffnesscomponentwise.dat \n');
                % OUTPUT COMPONENT MASS MATRIX
                elseif ~isempty(intersect(Crvnames{irvno},Xobj.CdensityRVs)) && ...
                strcmpi(Xobj.Sanalysis,'Modal') 
                    fprintf(fid2,'assign output4=%s_M_pos_per_%s.op4,unit=13,formatted,delete\n',...
                       Xobj.Sjobname,Crvnames{irvno});
                    fprintf(fid2,'assign PUNCH=%s_MDOFs_%s.pch,unit=52,formatted,delete\n',...
                        Xobj.Sjobname,Crvnames{irvno});
                    % insert the SOL command back to the file
                    fprintf(fid2,Sline);
                    fprintf(fid2,'\n');
                    fprintf(fid2,'INCLUDE dmapoutputmasscomponentwise.dat \n'); 
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
            error('openCOSSAN:SFEM:prepareInputFilesNastranRegular',...,
                [ Sperturbedfilename ' code could not be copied']);
        elseif status == 1
            OpenCossan.cossanDisp(['[SFEM.prepareInputFilesNASTRANComponentwise] ' Sperturbedfilename ' copied successfully'],3);
        end
    end
end

%% Prepare the NEGATIVE PERTURBED (COMPONENTWISE) input files

% Applies ONLY for the RVs within STIFFNESS & MASS
% AND IF 2. order approximation is selected
    
if Xobj.NinputApproximationOrder == 2
    for irvno=1:Nrvs       
        if  ~isempty(intersect(Crvnames{irvno},Xobj.CyoungsModulusRVs)) || ...
        ~isempty(intersect(Crvnames{irvno},Xobj.CthicknessRVs)) || ...
        ~isempty(intersect(Crvnames{irvno},Xobj.CcrossSectionRVs)) || ...
        (~isempty(intersect(Crvnames{irvno},Xobj.CdensityRVs)) && strcmpi(Xobj.Sanalysis,'Modal'))  
            Sfilename = [ Crvnames{irvno} '.dat'];
            [fid, ~]  = fopen(fullfile(Smaininputpath,Sfilename),'r+');
            Sperturbedfilename=['negative_perturbed_' Crvnames{irvno} '.dat'];
            [~, ~] = copyfile(fullfile(OpenCossan.getCossanWorkingPath,Sfilename),fullfile(OpenCossan.getCossanWorkingPath,Sperturbedfilename));
            [fid2, ~] = fopen(fullfile(OpenCossan.getCossanWorkingPath ,Sperturbedfilename),'w+');
            if fid2 == -1
                error('openCOSSAN:SFEM:prepareInputFilesNastranRegular',...,
                    [ Sperturbedfilename ' could not be opened ']);
            else
                OpenCossan.cossanDisp(['[SFEM.prepareInputFilesNASTRANComponentwise] ' Sperturbedfilename ' opened successfully'],3);
            end
            while 1
                Sline = fgetl(fid);
                if ~ischar(Sline),   break,   end
                fwrite(fid2,Sline);
                fprintf(fid2,'\n');
                if (length(Sline)>2 && strcmp(Sline(1:3),'SOL'))
                    % getting the position of the 'SOL 101' string
                    position = ftell(fid);
                    % going back to before that position in the text file
                    position = position - 8;
                    % setting the position for further writing
                    fseek(fid2, position,'bof');
                    fprintf(fid2,'\n');
                    % OUTPUT COMPONENT STIFFNESS MATRIX
                    if ~isempty(intersect(Crvnames{irvno},Xobj.CyoungsModulusRVs)) || ...
                   ~isempty(intersect(Crvnames{irvno},Xobj.CthicknessRVs)) || ...
                   ~isempty(intersect(Crvnames{irvno},Xobj.CcrossSectionRVs))
                        fprintf(fid2,'assign output4=%s_K_neg_per_%s.op4,unit=13,formatted,delete\n',...
                        Xobj.Sjobname,Crvnames{irvno});
                        fprintf(fid2,'assign PUNCH=%s_KDOFs_%s.pch,unit=52,formatted,delete\n',...
                        Xobj.Sjobname,Crvnames{irvno});
                        fprintf(fid2,Sline);
                        fprintf(fid2,'\n');
                        fprintf(fid2,'INCLUDE dmapoutputstiffnesscomponentwise.dat \n');
                    % OUTPUT COMPONENT MASS MATRIX
                    elseif ~isempty(intersect(Crvnames{irvno},Xobj.CdensityRVs)) && ...
                    strcmpi(Xobj.Sanalysis,'Modal')   
                        fprintf(fid2,'assign output4=%s_M_neg_per_%s.op4,unit=13,formatted,delete\n',...
                           Xobj.Sjobname,Crvnames{irvno});
                        fprintf(fid2,'assign PUNCH=%s_MDOFs_%s.pch,unit=52,formatted,delete\n',...
                            Xobj.Sjobname,Crvnames{irvno});
                        % insert the SOL command back to the file
                        fprintf(fid2,Sline);
                        fprintf(fid2,'\n');
                        fprintf(fid2,'INCLUDE dmapoutputmasscomponentwise.dat \n'); 
                    end
                end
            end
            fclose(fid2);
            fclose(fid);
            inj1=Injector('Stype','scan','Sscanfilename',Sperturbedfilename,...
                  'Sworkingdirectory',[OpenCossan.getCossanWorkingPath ],...
                  'Sscanfilepath',[OpenCossan.getCossanWorkingPath ],'Sfile','tmpfile.dat'); 
            inject(inj1,TinputPerturbNegative(irvno));
            [status, ~] = copyfile(fullfile(OpenCossan.getCossanWorkingPath  ,'tmpfile.dat'),fullfile(OpenCossan.getCossanWorkingPath,Sperturbedfilename));
            if status == 0
                error('openCOSSAN:SFEM:prepareInputFilesNastranRegular',...,
                    [ Sperturbedfilename ' code could not be copied']);
            elseif status == 1
                OpenCossan.cossanDisp(['[SFEM.prepareInputFilesNASTRANComponentwise] ' Sperturbedfilename ' copied successfully'],3);
            end
        end
    end   
end


%% Prepare the NOMINAL COMPONENTWISE input files
   
% NOTE: According to the latest formulation, for each perturbed componentwise
% matrix, one needs also the nominal componentwise matrix. this is
% beacuse after the introduction of thickness as RV, it was not
% possible just to insert the perturbation amount (for very small thickness 
% values it caused problems with NASTRAN)

for irvno=1:Nrvs
    if ~isempty(intersect(Crvnames{irvno},Xobj.CyoungsModulusRVs)) || ...
       ~isempty(intersect(Crvnames{irvno},Xobj.CthicknessRVs)) || ...
       ~isempty(intersect(Crvnames{irvno},Xobj.CcrossSectionRVs)) || ...
       (~isempty(intersect(Crvnames{irvno},Xobj.CdensityRVs)) && strcmpi(Xobj.Sanalysis,'Modal'))       
         Sfilename = [ Crvnames{irvno} '.dat'];
         [fid, ~]  = fopen(fullfile(Smaininputpath,Sfilename),'r+');
         Sperturbedfilename=['nominal_' Crvnames{irvno} '.dat'];
         [~, ~]    = copyfile(fullfile(OpenCossan.getCossanWorkingPath,Sfilename),fullfile(OpenCossan.getCossanWorkingPath,Sperturbedfilename));
         [fid2, ~] = fopen(fullfile(OpenCossan.getCossanWorkingPath,Sperturbedfilename),'w+');
         if fid2 == -1
             error('openCOSSAN:SFEM:prepareInputFilesNastranRegular',...,
                 [ Sperturbedfilename ' could not be opened ']);
         else
             OpenCossan.cossanDisp(['[sfem.prepareinputfilesnastrancomponentwise] ' Sperturbedfilename ' opened successfully'],3);
         end
         while 1
            Sline = fgetl(fid);
            if ~ischar(Sline),   break,   end
            fwrite(fid2,Sline);
            fprintf(fid2,'\n');
            if (length(Sline)>2 && strcmp(Sline(1:3),'SOL'))
                % getting the position of the 'SOL 101' string
                position = ftell(fid);
                % going back to before that position in the text file
                position = position - 8;
                % setting the position for further writing
                fseek(fid2, position,'bof');
                fprintf(fid2,'\n');
                % OUTPUT COMPONENT STIFFNESS MATRIX                   
                if ~isempty(intersect(Crvnames{irvno},Xobj.CyoungsModulusRVs)) || ...
                   ~isempty(intersect(Crvnames{irvno},Xobj.CthicknessRVs)) || ...
                   ~isempty(intersect(Crvnames{irvno},Xobj.CcrossSectionRVs))
                    fprintf(fid2,'assign output4=%s_K_nom_%s.op4,unit=13,formatted,delete\n',...
                        Xobj.Sjobname,Crvnames{irvno});
                    fprintf(fid2,'assign PUNCH=%s_KDOFs_%s.pch,unit=52,formatted,delete\n',...
                        Xobj.Sjobname,Crvnames{irvno});
                    fprintf(fid2,Sline);
                    fprintf(fid2,'\n');
                    fprintf(fid2,'INCLUDE dmapoutputstiffnesscomponentwise.dat \n');
                % OUTPUT COMPONENT MASS MATRIX
                elseif ~isempty(intersect(Crvnames{irvno},Xobj.CdensityRVs)) && ...
                 strcmpi(Xobj.Sanalysis,'Modal')   
                    fprintf(fid2,'assign output4=%s_M_nom_%s.op4,unit=13,formatted,delete\n',...
                           Xobj.Sjobname,Crvnames{irvno});
                    fprintf(fid2,'assign PUNCH=%s_MDOFs_%s.pch,unit=52,formatted,delete\n',...
                            Xobj.Sjobname,Crvnames{irvno});
                    % insert the SOL command back to the file
                    fprintf(fid2,Sline);
                    fprintf(fid2,'\n');
                    fprintf(fid2,'INCLUDE dmapoutputmasscomponentwise.dat \n'); 
                end
            end
        end
        fclose(fid2);
        fclose(fid);
        inj1=Injector('Stype','scan','Sscanfilename',Sperturbedfilename,...
                  'Sworkingdirectory',[OpenCossan.getCossanWorkingPath],...
                  'Sscanfilepath',[OpenCossan.getCossanWorkingPath],'Sfile','tmpfile.dat'); 
        eval(['Tinput(1).' Crvnames{irvno} ' = Vmeanvalues(irvno);']);
        inject(inj1,Tinput(1));
        [status, ~] = copyfile(fullfile(OpenCossan.getCossanWorkingPath,'tmpfile.dat'),fullfile(OpenCossan.getCossanWorkingPath,Sperturbedfilename));
        if status == 0
            error('openCOSSAN:SFEM:prepareInputFilesNastranRegular',...,
                [Sperturbedfilename ' code could not be copied']);
        elseif status == 1
            OpenCossan.cossanDisp(['[SFEM.prepareInputFilesNASTRANComponentwise] ' Sperturbedfilename ' copied successfully'],3);
        end
    end
end


%% Prepare POSITIVE PERTURBED files (REGULAR) for RVs related to FORCE

% RVs related to FORCE are excluded since they are treated as done in the
% REGULAR implementation

for irvno=1:Nrvs
    if strcmpi(Xobj.Sanalysis,'Static')
        if ~isempty(intersect(Crvnames{irvno},Xobj.CdensityRVs)) ||...
                ~isempty(intersect(Crvnames{irvno},Xobj.CforceRVs))
            [fid, ~]  = fopen(fullfile(OpenCossan.getCossanWorkingPath,'nominal0.dat'),'r+');
            Sperturbedfilename = ['positive_perturbed_' Crvnames{irvno} '.dat'];
            [fid2, ~] = fopen(fullfile(OpenCossan.getCossanWorkingPath,Sperturbedfilename),'w+');
            if fid2 == -1
                error('openCOSSAN:SFEM:prepareInputFilesNastranRegular',...,
                    [Sperturbedfilename ' could not be opened ']);
            else
                OpenCossan.cossanDisp(['[SFEM.prepareInputFilesNASTRANComponentwise] ' Sperturbedfilename ' opened successfully'],3);
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
                    % For FORCE VECTOR
                    if ~isempty(intersect(Crvnames{irvno},Xobj.CdensityRVs)) && strcmpi(Xobj.Sanalysis,'Static')
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
                error('openCOSSAN:SFEM:prepareInputFilesNastranRegular',...,
                    [Sperturbedfilename ' code could not be copied']);
            elseif status == 1
                OpenCossan.cossanDisp(['[SFEM.prepareInputFilesNASTRANComponentwise] ' Sperturbedfilename ' copied successfully'],3);
            end
        end
    end
end  

%% Prepare NEGATIVE PERTURBED files (REGULAR) for RVs related to FORCE

% RVs related to FORCE are excluded since they are treated as done in the
% REGULAR implementation
    
if Xobj.NinputApproximationOrder == 2
    for irvno=1:Nrvs
        if ~isempty(intersect(Crvnames{irvno},Xobj.CdensityRVs)) ||...
        ~isempty(intersect(Crvnames{irvno},Xobj.CforceRVs))
            [fid, ~]  =  fopen(fullfile(OpenCossan.getCossanWorkingPath,'nominal0.dat'),'r+');
            Sperturbedfilename = ['negative_perturbed_' Crvnames{irvno} '.dat'];
            [fid2, ~] = fopen(fullfile(OpenCossan.getCossanWorkingPath,Sperturbedfilename),'w+');
            if fid2 == -1
                error('openCOSSAN:SFEM:prepareInputFilesNastranRegular',...,
                    [Sperturbedfilename ' could not be opened ']);
            else
                OpenCossan.cossanDisp(['[SFEM.prepareInputFilesNASTRANComponentwise] ' Sperturbedfilename ' opened successfully'],3);
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
                    % FORCE VECTOR
                    if ~isempty(intersect(Crvnames{irvno},Xobj.CdensityRVs)) && ...
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
                    end
                end
            end
            fclose(fid2);
            fclose(fid);
            inj1=Injector('Stype','scan','Sscanfilename',Sperturbedfilename,...
                  'Sworkingdirectory',[OpenCossan.getCossanWorkingPath ],...
                  'Sscanfilepath',[OpenCossan.getCossanWorkingPath ],'Sfile','tmpfile.dat'); 
            inject(inj1,TinputPerturbNegative(irvno));
            [status, ~] = copyfile(fullfile(OpenCossan.getCossanWorkingPath,'tmpfile.dat'),fullfile(OpenCossan.getCossanWorkingPath,Sperturbedfilename));    
            if status == 0
                error('openCOSSAN:SFEM:prepareInputFilesNastranRegular',...,
                    [ Sperturbedfilename ' code could not be copied']);
            elseif status == 1
                OpenCossan.cossanDisp(['[SFEM.prepareInputFilesNASTRANComponentwise] ' Sperturbedfilename ' copied successfully'],3);
            end
        end    
    end
end

delete(fullfile(OpenCossan.getCossanWorkingPath,'tmpfile.dat'))  

%% Record the CPU time

stopTime          = OPENCOSSAN.Xtimer.currentTime;
Xobj.Ccputimes{2} = stopTime - startTime;

OpenCossan.cossanDisp(['[SFEM.prepareInputFilesNASTRANComponentwise] Preparation of the input files completed in ' num2str(Xobj.Ccputimes{2}) ' sec'],1);
OpenCossan.cossanDisp(' ',1);

return

