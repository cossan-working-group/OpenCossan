function Xobj = prepareInputFilesANSYS(Xobj)
%PREPARE NASTRAN INPUTFILES prepares necessary input files for perturbation
%                           according to the chosen probabilistic model
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/prepareInputFilesANSYS@Nastsem
%
% =======================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% =======================================================================

global OPENCOSSAN

OpenCossan.cossanDisp('[SFEM.prepareInputFilesANSYS] Preparation of the input files started',1);

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

%% Prepare input file for nominal analysis

% open masterfile (the main deterministic FE file with identifiers)
[fid,~] = fopen(fullfile(Smaininputpath,Xobj.Sinputfile),'r+');
if fid == -1
    error('openCOSSAN:SFEM:prepareInputFilesANSYS',[Xobj.Sinputfile ' could not be opened ']);
else
    OpenCossan.cossanDisp(['[SFEM.prepareInputFilesANSYS] ' Xobj.Sinputfile ' opened successfully'],4);
end   

% First masterfile is copied with a dummy name
fid2 = fopen(fullfile(OpenCossan.getCossanWorkingPath,'nominal0.dat'),'w+');
if fid2 == -1
    error('openCOSSAN:SFEM:prepareInputFilesANSYS','nominal0.dat could not be opened ');
else
    OpenCossan.cossanDisp('[SFEM.prepareInputFilesANSYS] nominal0.dat opened successfully',4);
end  


% following part inserts necessary commands to regular ansys file
while 1
    Sline = fgetl(fid);
    fwrite(fid2,Sline);
    fprintf(fid2,'\n');
    if ~ischar(Sline),   break,   end
    if (length(Sline)>4 && strcmp(Sline(1:5),'SOLVE'))
        % getting the position of the 'SOL 101' string
        position = ftell(fid);
        % going back to before that position in the text file
        position = position - 8;
        % setting the position for further writing
        fseek(fid2, position,'bof');
        fprintf(fid2,'\n');
        % Include the statements in ANSYS file to stop the solution
        % and output K matrices
        fprintf(fid2,'WRFULL, 1  \n');
        fprintf(fid2,'SOLVE \n');
        fprintf(fid2,'/AUX2 \n');
        fprintf(fid2,'FILE,''file'',''full'','' '' \n');
        fprintf(fid2,'HBMAT,''%s_K_NOMINAL'','' '','' '',ASCII,STIFF,YES,YES  \n',Xobj.Sjobname);
        if  strcmpi(Xobj.Sanalysis,'Modal')
            fprintf(fid2,'FILE,''file'',''full'','' '' \n');
            fprintf(fid2,'HBMAT,''%s_M_NOMINAL'','' '','' '',ASCII,MASS,NO,NO  \n',Xobj.Sjobname);
        end
    end
end        
        
% close the files
fclose(fid);
fclose(fid2);

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
    error('openCOSSAN:SFEM:prepareInputFilesANSYS', ...
        'tmpfile.dat could not be copied');
elseif status == 1
    OpenCossan.cossanDisp('[SFEM.prepareInputFilesANSYS] tmpfile.dat copied successfully',4);
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
    [fid, ~]  = fopen(fullfile(OpenCossan.getCossanWorkingPath,'nominal0.dat'),'r+');
    if fid == -1
        error('openCOSSAN:SFEM:prepareInputFilesANSYS', ...
            'nominal0.dat could not be opened ');
    else
        OpenCossan.cossanDisp('[SFEM.prepareInputFilesANSYS] nominal0.dat opened successfully',4);
    end
    Sperturbedfilename = ['positive_perturbed_' Crvnames{irvno} '.dat'];
    [fid2, ~] = fopen(fullfile(OpenCossan.getCossanWorkingPath,Sperturbedfilename),'w+');
    if fid2 == -1
        error('openCOSSAN:SFEM:prepareInputFilesANSYS', ...
            [Sperturbedfilename ' could not be opened ']);
    else
        OpenCossan.cossanDisp(['[SFEM.prepareInputFilesANSYS] ' Sperturbedfilename ' opened successfully'],4);
    end
    while 1
        Sline = fgetl(fid);
        fwrite(fid2,Sline);
        fprintf(fid2,'\n');
        if ~ischar(Sline),   break,   end
        if (length(Sline)>4 && strcmp(Sline(1:5),'SOLVE'))
            % getting the position of the 'SOL 101' string
            position = ftell(fid);
            % going back to before that position in the text file
            position = position - 8;
            % setting the position for further writing
            fseek(fid2, position,'bof');
            fprintf(fid2,'\n');
            fprintf(fid2,'\n');
            % Include the statements in ANSYS file to stop the solution
            % and output K matrices
            fprintf(fid2,'WRFULL, 1  \n');
            fprintf(fid2,'SOLVE \n');
            % For STIFFNESS MATRIX
            if ~isempty(intersect(Crvnames{irvno},Xobj.CyoungsModulusRVs)) || ...
                    ~isempty(intersect(Crvnames{irvno},Xobj.CthicknessRVs)) || ...
                    ~isempty(intersect(Crvnames{irvno},Xobj.CcrossSectionRVs))
                fprintf(fid2,'/AUX2 \n');
                fprintf(fid2,'FILE,''file'',''full'','' '' \n');
                fprintf(fid2,'HBMAT,''%s_K_POS_PER_%s'','' '','' '',ASCII,STIFF,NO,NO  \n',Xobj.Sjobname,Crvnames{irvno});
                fprintf(fid2,'FINISH \n');
            % For FORCE VECTOR
            elseif ~isempty(intersect(Crvnames{irvno},Xobj.CforceRVs))
                fprintf(fid2,'/AUX2 \n');
                fprintf(fid2,'FILE,''file'',''full'','' '' \n');
                fprintf(fid2,'HBMAT,''%s_F_POS_PER_%s'','' '','' '',ASCII,STIFF,YES,NO  \n',Xobj.Sjobname,Crvnames{irvno});
                fprintf(fid2,'FINISH \n');
            % For MASS MATRIX
            elseif ~isempty(intersect(Crvnames{irvno},Xobj.CdensityRVs)) && strcmpi(Xobj.Sanalysis,'Modal')
                fprintf(fid2,'/AUX2 \n');
                fprintf(fid2,'FILE,''file'',''full'','' '' \n');
                fprintf(fid2,'HBMAT,''%s_M_POS_PER_%s'','' '','' '',ASCII,MASS,NO,NO  \n',Xobj.Sjobname,Crvnames{irvno});
                fprintf(fid2,'FINISH \n');
            end
            break
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
        error('openCOSSAN:SFEM:prepareInputFilesANSYS', ...
            [Sperturbedfilename ' code could not be copied']);
    elseif status == 1
        OpenCossan.cossanDisp(['[SFEM.prepareInputFilesANSYS] ' Sperturbedfilename ' copied successfully'],4);
    end
end
    
%% Prepare the NEGATIVE perturbed input files

% NOTE: negative perturbed files are only needed if 2. order approximation
% is to be used

if Xobj.NinputApproximationOrder == 2
    for irvno=1:Nrvs
        [fid, ~]  = fopen(fullfile(OpenCossan.getCossanWorkingPath,'nominal0.dat'),'r+');
        if fid == -1
            error('openCOSSAN:SFEM:prepareInputFilesANSYS', ...
                'nominal0.dat could not be opened ');
        else
            OpenCossan.cossanDisp('[SFEM.prepareInputFilesANSYS] nominal0.dat opened successfully',4);
        end
        Sperturbedfilename = ['negative_perturbed_' Crvnames{irvno} '.dat'];
        [fid2, ~] = fopen(fullfile(OpenCossan.getCossanWorkingPath,Sperturbedfilename),'w+');
        if fid2 == -1
            error('openCOSSAN:SFEM:prepareInputFilesANSYS', ...
                [Sperturbedfilename ' could not be opened ']);
        else
            OpenCossan.cossanDisp(['[SFEM.prepareInputFilesANSYS] ' Sperturbedfilename ' opened successfully'],4);
        end
        while 1
            Sline = fgetl(fid);
            fwrite(fid2,Sline);
            fprintf(fid2,'\n');
            if ~ischar(Sline),   break,   end
            if (length(Sline)>4 && strcmp(Sline(1:5),'SOLVE'))
                % getting the position of the 'SOL 101' string
                position = ftell(fid);
                % going back to before that position in the text file
                position = position - 8;
                % setting the position for further writing
                fseek(fid2, position,'bof');
                fprintf(fid2,'\n');
                fprintf(fid2,'\n');
                % Include the statements in ANSYS file to stop the solution
                % and output K matrices
                fprintf(fid2,'WRFULL, 1  \n');
                fprintf(fid2,'SOLVE \n');
                % For STIFFNESS MATRIX
                if ~isempty(intersect(Crvnames{irvno},Xobj.CyoungsModulusRVs)) || ...
                   ~isempty(intersect(Crvnames{irvno},Xobj.CthicknessRVs)) || ...
                   ~isempty(intersect(Crvnames{irvno},Xobj.CcrossSectionRVs))
                    fprintf(fid2,'/AUX2 \n');
                    fprintf(fid2,'FILE,''file'',''full'','' '' \n');
                    fprintf(fid2,'HBMAT,''%s_K_NEG_PER_%s'','' '','' '',ASCII,STIFF,NO,NO  \n',Xobj.Sjobname,Crvnames{irvno});
                    fprintf(fid2,'FINISH \n');
                % For FORCE VECTOR
                elseif ~isempty(intersect(Crvnames{irvno},Xobj.CforceRVs))
                    fprintf(fid2,'/AUX2 \n');
                    fprintf(fid2,'FILE,''file'',''full'','' '' \n');
                    fprintf(fid2,'HBMAT,''%s_F_NEG_PER_%s'','' '','' '',ASCII,STIFF,YES,NO  \n',Xobj.Sjobname,Crvnames{irvno});
                    fprintf(fid2,'FINISH \n');
                % For MASS MATRIX
                elseif ~isempty(intersect(Crvnames{irvno},Xobj.CdensityRVs)) && strcmpi(Xobj.Sanalysis,'Modal')
                    fprintf(fid2,'/AUX2 \n');
                    fprintf(fid2,'FILE,''file'',''full'','' '' \n');
                    fprintf(fid2,'HBMAT,''%s_K_NEG_PER_%s'','' '','' '',ASCII,MASS,NO,NO  \n',Xobj.Sjobname,Crvnames{irvno});
                    fprintf(fid2,'FINISH \n');
                end
                break
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
            error('openCOSSAN:SFEM:prepareInputFilesANSYS', ...
                [Sperturbedfilename ' code could not be copied']);
        elseif status == 1
            OpenCossan.cossanDisp(['[SFEM.prepareInputFilesANSYS] ' Sperturbedfilename ' copied successfully'],4);
        end
    end
end

delete(fullfile(OpenCossan.getCossanWorkingPath,'tmpfile.dat')) 

%% Record the CPU time

stopTime          = OPENCOSSAN.Xtimer.currentTime;
Xobj.Ccputimes{2} = stopTime - startTime;

OpenCossan.cossanDisp(['[SFEM.prepareInputFilesANSYS] Preparation of the input files completed in ' num2str(Xobj.Ccputimes{2}) ' sec'],1);

return

