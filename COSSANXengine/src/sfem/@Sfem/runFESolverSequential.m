function Xobj = runFESolverSequential(Xobj)
%runFESolverSequential  Calls FE solver to perform the analysis for the prepared SFEM problem
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/runFESolverSequential@SFEM
%
% =======================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% =======================================================================

global OPENCOSSAN

startTime = OPENCOSSAN.Xtimer.currentTime;

%% Retrieve input data

Xinp            = Xobj.Xmodel.Xinput;                                 % Obtain Input
assert(length(Xinp.CnamesRandomVariableSet)==1,'openCOSSAN:SFEM:checkInput',...
    'Only 1 Random Variable Set is allowed in SFEM.')
Xrvs            = Xinp.Xrvset.(Xinp.CnamesRandomVariableSet{1});    % Obtain RVSET
Crvnames        = Xinp.CnamesRandomVariable;                  % Obtain RV names
Nrvs            = Xinp.NrandomVariables;                      % Obtain No of RVs
% CHE MERDA DI CODICE!!
Xconnector      = Xobj.Xmodel.Xevaluator.CXsolvers{1};                % Obtain Connector object
Xconnector.Smaininputpath=OpenCossan.getCossanWorkingPath;
% Because of the great quality of this code, the simulation MUST be
% executed in the cossan working directory :S
Xconnector.Sworkingdirectory=OpenCossan.getCossanWorkingPath;
Xconnector.Ltimestamp=false; % Force the connector to not create a time-stamped folder!!!! DEPRECATED!!!!


Sfesolver       = Xconnector.Stype;                                   % Obtain FE solver type

%% Obtain nominal response

if strcmpi(Sfesolver,'abaqus')
    Xconnector.Smaininputfile='nominal.inp';
else
    Xconnector.Smaininputfile='nominal.dat';
end

OpenCossan.cossanDisp('[SFEM.runFESolverSequential] Running the 3rd party FE Solver started ',1);
OpenCossan.cossanDisp(' ',2);
OpenCossan.cossanDisp('[SFEM.runFESolverSequential] Analysis for the file Nominal model started ',2);
% perform analysis for the nominal model
[~,~,LerrorFound]=Xconnector.deterministicAnalysis;
assert(~LerrorFound,'CossanX:SFEM:runFESolverSequential','Failed to execute Nominal model FE solver.')
OpenCossan.cossanDisp('[SFEM.runFESolverSequential] Analysis for the file Nominal model completed ',2);
OpenCossan.cossanDisp(' ',2);

%% following part is necessary only for Guyan P-C

if strcmpi(Xobj.Smethod,'Guyan')
    Xconnector.Smaininputfile = 'nominal2.dat';
    [~,~,LerrorFound]=Xconnector.deterministicAnalysis;
    assert(~LerrorFound,'CossanX:SFEM:runFESolverSequential','Failed to execute FE solver.')
end

%% Obtain K_i's
%
OpenCossan.cossanDisp('[SFEM.runFESolverSequential] No JobManager defined - Runs will be performed sequentially',2);
OpenCossan.cossanDisp(' ',2);
if Xobj.NinputApproximationOrder == 1
    for irvno=1:Nrvs
        % positive
        if strcmpi(Sfesolver,'abaqus')
            Xconnector.Smaininputfile = ['positive_perturbed_' Crvnames{irvno} '.inp'];
        else
            Xconnector.Smaininputfile = ['positive_perturbed_' Crvnames{irvno} '.dat'];
        end
        OpenCossan.cossanDisp(['[SFEM.runFESolverSequential] Analysis for the file ' Xconnector.Smaininputfile ' started'],2);
        [~,~,LerrorFound]=Xconnector.deterministicAnalysis;
        assert(~LerrorFound,'CossanX:SFEM',['Failed to execute perturbed ' Crvnames{irvno} ' FE solver.'])
        OpenCossan.cossanDisp(['[SFEM.runFESolverSequential] Analysis for the file ' Xconnector.Smaininputfile ' completed'],2);
        if strcmpi(Xobj.Simplementation,'Componentwise')
            %nominal
            Xconnector.Smaininputfile = ['nominal_' Crvnames{irvno} '.dat'];
            OpenCossan.cossanDisp(['[SFEM.runFESolverSequential] Analysis for the file ' Xconnector.Smaininputfile ' started'],2);
            [~,~,LerrorFound]=Xconnector.deterministicAnalysis;
            assert(~LerrorFound,'CossanX:SFEM','Failed to execute FE solver.')
            OpenCossan.cossanDisp(['[SFEM.runFESolverSequential] Analysis for the file ' Xconnector.Smaininputfile ' completed'],2);
        end
    end
elseif Xobj.NinputApproximationOrder == 2
    for irvno=1:Nrvs
        % POSITIVE PERTURBED
        Xconnector.Smaininputfile = ['positive_perturbed_' Crvnames{irvno} '.dat'];
        OpenCossan.cossanDisp(['[SFEM.runFESolverSequential] Analysis for the file ' Xconnector.Smaininputfile ' started'],2);
        [~,~,LerrorFound]=Xconnector.deterministicAnalysis;
        assert(~LerrorFound,'CossanX:SFEM','Failed to execute FE solver.')
        OpenCossan.cossanDisp(['[SFEM.runFESolverSequential] Analysis for the file ' Xconnector.Smaininputfile ' completed'],2);
        % NEGATIVE PERTURBED
        Xconnector.Smaininputfile = ['negative_perturbed_' Crvnames{irvno} '.dat'];
        OpenCossan.cossanDisp(['[SFEM.runFESolverSequential] Analysis for the file ' Xconnector.Smaininputfile ' started'],2);
        [~,~,LerrorFound]=Xconnector.deterministicAnalysis;
        assert(~LerrorFound,'CossanX:SFEM','Failed to execute FE solver.')
        OpenCossan.cossanDisp(['[SFEM.runFESolver] Analysis for the file ' Xconnector.Smaininputfile ' completed'],2);
        if strcmpi(Xobj.Simplementation,'Componentwise')
            % NOMINAL COMPONENTWISE
            Xconnector.Smaininputfile = ['nominal_' Crvnames{irvno} '.dat'];
            OpenCossan.cossanDisp(['[SFEM.runFESolverSequential] Analysis for the file ' Xconnector.Smaininputfile ' started'],2);
            [~,~,LerrorFound]=Xconnector.deterministicAnalysis;
            assert(~LerrorFound,'CossanX:SFEM','Failed to execute FE solver.')
            OpenCossan.cossanDisp(['[SFEM.runFESolverSequential] Analysis for the file ' Xconnector.Smaininputfile ' completed'],2);
        end
    end
end


%% If ABAQUS is selected as FE solver

% NOTE: it was necessary for ABAQUS to copy the generated matrix files
% under another name, since it is not possible to assign the names of the
% output files in the ABAQUS input file
if strcmpi(Sfesolver,'abaqus')
    [status, ~] = copyfile(fullfile(OpenCossan.getCossanWorkingPath,'nominal_STIF2.mtx'),...
        fullfile(OpenCossan.getCossanWorkingPath,[ Xobj.Sjobname '_K_NOMINAL.mtx']));
    if status == 0
        error('openCOSSAN:SFEM','[SFEM.runFESolverSequential] nominal_STIF2.mtx file could not be copied');
    elseif status == 1
        OpenCossan.cossanDisp('[SFEM.runFESolverSequential] nominal_STIF2.mtx copied successfully',3);
    end
    for irvno=1:Nrvs
        [status, ~] = copyfile(fullfile(OpenCossan.getCossanWorkingPath,['positive_perturbed_'  Crvnames{irvno} '_STIF2.mtx']),...
            fullfile(OpenCossan.getCossanWorkingPath,[Xobj.Sjobname '_K_POS_PER_' upper(Crvnames{irvno}) '.mtx']));
        if status == 0
            error('openCOSSAN:SFEM','[SFEM.runFESolverSequential] mtx file could not be copied');
        elseif status == 1
            OpenCossan.cossanDisp(['[SFEM.runFESolverSequential] ' Xobj.Sjobname '_K_POS_PER_' upper(Crvnames{irvno}) '.mtx copied successfully'],3);
        end
    end
    % following part is necessary only if Modal analysis is selected
    if strcmpi(Xobj.Sanalysis,'Modal')
        Xconnector.Smaininputfile = 'nominal2.inp';
        [~,~,LerrorFound]=Xconnector.deterministicAnalysis;
        assert(~LerrorFound,'CossanX:SFEM','Failed to execute FE solver.')
        [~, ~] = copyfile(fullfile(OpenCossan.getCossanWorkingPath,'nominal2_MASS2.mtx'),...
            fullfile(OpenCossan.getCossanWorkingPath,[Xobj.Sjobname '_M_NOMINAL.mtx']));
    end
end

%% clean files

if Xobj.Lcleanfiles
    if strcmpi(Sfesolver(1:5),'nastr')
        delete(fullfile(OpenCossan.getCossanWorkingPath, '*.f06'));
        delete(fullfile(OpenCossan.getCossanWorkingPath, '*.f04'));
        delete(fullfile(OpenCossan.getCossanWorkingPath, '*.log'));
        delete(fullfile(OpenCossan.getCossanWorkingPath, 'dmap*.dat'));
        delete(fullfile(OpenCossan.getCossanWorkingPath, 'pos*.*'));
        delete(fullfile(OpenCossan.getCossanWorkingPath, 'neg*.*'));
        delete(fullfile(OpenCossan.getCossanWorkingPath, 'nominal*.*'));
        delete(fullfile(OpenCossan.getCossanWorkingPath, 'constant*.*'));
        delete(fullfile(OpenCossan.getCossanWorkingPath, '*.inp'));
    elseif strcmpi(Sfesolver,'ansys')
        delete(fullfile(OpenCossan.getCossanWorkingPath, '*.db'));
        delete(fullfile(OpenCossan.getCossanWorkingPath, '*.err'));
        delete(fullfile(OpenCossan.getCossanWorkingPath, '*.mntr'));
        delete(fullfile(OpenCossan.getCossanWorkingPath, '*.log'));
        delete(fullfile(OpenCossan.getCossanWorkingPath, '*.esav'));
        delete(fullfile(OpenCossan.getCossanWorkingPath, '*.full'));
        delete(fullfile(OpenCossan.getCossanWorkingPath, 'pos*.*'));
        delete(fullfile(OpenCossan.getCossanWorkingPath, 'neg*.*'));
        delete(fullfile(OpenCossan.getCossanWorkingPath, 'nominal*.*'));
        delete(fullfile(OpenCossan.getCossanWorkingPath, '*.mlv'));
        delete(fullfile(OpenCossan.getCossanWorkingPath, '*.emat'));
        delete(fullfile(OpenCossan.getCossanWorkingPath, '*.inp'));
        delete(fullfile(OpenCossan.getCossanWorkingPath, '*.sh'));
        delete(fullfile(OpenCossan.getCossanWorkingPath, '*.err'));
        delete(fullfile(OpenCossan.getCossanWorkingPath, '*.out'));
    elseif strcmpi(Sfesolver,'abaqus')
        delete(fullfile(OpenCossan.getCossanWorkingPath, '*.odb'));
        delete(fullfile(OpenCossan.getCossanWorkingPath, '*.com'));
        delete(fullfile(OpenCossan.getCossanWorkingPath, '*.prt'));
        delete(fullfile(OpenCossan.getCossanWorkingPath, '*.sta'));
        delete(fullfile(OpenCossan.getCossanWorkingPath, '*.msg'));
        delete(fullfile(OpenCossan.getCossanWorkingPath, '*.dat'));
        delete(fullfile(OpenCossan.getCossanWorkingPath, '*.inp'));
    end
end

%% Stop clock

stopTime = OPENCOSSAN.Xtimer.currentTime;
Xobj.Ccputimes{3} = stopTime - startTime;

OpenCossan.cossanDisp(['[SFEM.runFESolverSequential] Running the 3rd party FE solver completed in ' num2str(Xobj.Ccputimes{3}) ' sec'],1);

return
