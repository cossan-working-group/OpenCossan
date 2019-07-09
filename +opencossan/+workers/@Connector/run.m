function [Xout,varargout]= run(Xc,Pinput)
% RUN method is used to execute (i.e. run) 3rd party solvers
%
%   USAGE:  Xout=run(Xc,Pinput)
%
%   The run method runs a 3rd party software.
%   The method takes a structure array with sampled quantities or
%   an Input, Samples or SimulationData object (output from a previous
%   simulation).  It returns a SimulationOuput object.
%
% See Also: http://cossan.co.uk/wiki/index.php/run@Connector
%
% $Copyright~1993-2014,~COSSAN~Working~Group,~University~of~Liverpool,~UK$
% $Author: Matteo Broggi and Edoardo Patelli$

% =====================================================================
% This file is part of openCOSSAN.  The open general purpose matlab
% toolbox for numerical analysis, risk and uncertainty quantification.
%
% openCOSSAN is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License.
%
% openCOSSAN is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
% =====================================================================

import opencossan.common.outputs.SimulationData

% IMPORTANT:
% Sworkingdirectory: main working directory
% SfolderTimeStamp: specify the subfolders


% Use the verbosity level predifined in OpenCossan but when the connector
% is executed remotely used the local verbosity level
if ~Xc.Lremote
    NverboseLevel=OpenCossan.getVerbosityLevel;
else
    NverboseLevel=Xc.NverboseLevel;
end

if NverboseLevel>2
    disp(['[COSSAN-X.Connector.run] COSSAN-X:Connector:run  - START -' datestr(clock)])
    disp(['[COSSAN-X.Connector.run] Matlab current directory: ' pwd ])
end

%% check inputs

if isempty(Pinput)
    LuseOriginalValues=true;
    Nsimulations=1;
else
    switch class(Pinput)
        case 'opencossan.common.inputs.Input'
            if Pinput.Nsamples==0 % Use the default values (mean) of the RV if no sample are present in the Xinput
                Tinput=get(Pinput,'defaultvalues');
            else
                Tinput=getStructure(Pinput);
            end
            assert(~isempty(Tinput),'openCOSSAN:Connector:run:emptyInput',...
                'The Input object does NOT contain any samples and no parameters');
        case 'opencossan.common.Samples'
            Tinput=Pinput.Tsamples;
        case 'opencossan.common.outputs.SimulationData'
            Tinput = Pinput.Tvalues;
        case 'struct'
            Tinput=Pinput;
        otherwise
            error('openCOSSAN:connector:run:wrongInput',...
                'The input provided is of type %s and it is NOT supported.',class(Pinput));
    end
    LuseOriginalValues=false;
    Nsimulations=length(Tinput);
end

%% Check the initialization of the simulation Database
% if a connection to the simulation database is available, enables the
% property LkeepSimulationFiles, because it is necessary to populate the database

% This should be done by the constructor!

% if ~isempty(OPENCOSSAN.XdatabaseDriver)
%     OpenCossan.cossanDisp('[COSSAN-X.Connector.run] No database driver used (Flag LkeepSimulationFiles set true',2)
%     Xc.LkeepSimulationFiles = true;
% end

%% Start Simulation
% If the Sfoldername has not defined use the timestamp.

% TODO: It should use only Xc.Sworkingdirectory, or not?
%SworkingdirectoryOriginal = Xc.Sworkingdirectory;


%% Execute the simulations
for irun=1:Nsimulations
    disp(['Simulation #' num2str(irun) ' of ' num2str(Nsimulations) ]);
    
    if Xc.Lremote
        % This is a relative folder inside the job folder. We do not need
        % to recrate the timestamp
        Sfoldername=['simulation_' num2str(irun) '_of_' num2str(Nsimulations)];
        Xc.SfolderTimeStamp = fullfile(Xc.SremoteWorkingDirectory,Sfoldername);
    else
        Sfoldername=[datestr(now,30) '_sim_' num2str(irun)];
        Xc.SfolderTimeStamp = fullfile(OpenCossan.getCossanWorkingPath,Sfoldername);
    end
    
    [~,mess] = mkdir(Xc.SfolderTimeStamp);
    
    OpenCossan.cossanDisp(['Create folder: ' Xc.SfolderTimeStamp],3)
    
    if ~isempty(mess)
        disp(['Create folder: ' Xc.SfolderTimeStamp])
    end
    
    %% copy input files to the working directory
    % if the working directory and the main input path are different
    % It should be not necessary to recopy N times the additional files
    Xc.copyFiles('Sdestdir',Xc.SfolderTimeStamp);
    
    %% Inject paramaters
    % create the structure with the values to be injected (i.e., if there
    % is a parameter its values is stored in Tinput(1))
    
    if ~LuseOriginalValues
        Tinject = opencossan.workers.Connector.prepareInputStructure(Tinput,irun);
        Xc.inject(Tinject); % Start injecting values
    end
    
    %% Run pre execution command
    % The pre execution command is executed on the working folder
    if ~isempty(Xc.SpreExecutionCommand)
        [status,cmdout] = system(['cd ' Xc.SfolderTimeStamp ';' Xc.SpreExecutionCommand]);
        if status ~= 0
            warning('openCOSSAN:Connector:run','Non-zero exit status from pre-execution command.\n %s',cmdout);
        end
        if NverboseLevel>2
            disp(['[COSSAN-X.Connector.run] Run pre-execution command: ' Xc.SpreExecutionCommand ])
            disp(['[COSSAN-X.Connector.run] Folder: ' Xc.SfolderTimeStamp])
        end
        
        if NverboseLevel>3
            disp(['[COSSAN-X.Connector.run] Command output: ' cmdout])
        end
    end
    
    %% Run the external code (e.g. FE)
    
    string=Xc.Sexecmd;
    
    if ~isempty(string)
        [tok] = regexp(string, Xc.Sexp, 'tokens');
        
        for i=1:length(tok)
            switch (lower(tok{i}{1}))
                case {'solverbinary','ssolverbinary'}
                    % the solver binary needs some OS dependent processing to
                    % be correctly executed
                    if ispc % in windows
                        % duplicates the '\' to avoid that they are interpreted
                        % as regexp commands
                        Ssolverbinary = strrep(Xc.Ssolverbinary,'\','\\');
                        % If there are spaces in the path, the shell will
                        % interpret them as separator between command options.
                        % If everything is in "" the problem is fixed.
                        Ssolverbinary = ['"' Ssolverbinary '"']; %#ok<*AGROW>
                    else % in *nix
                        % If there are spaces in the path, the shell will
                        % interpret them as separator between command options.
                        % A "\\" must be inserted before the space (the first
                        % to say regexp to ignore the second, and the second to
                        % say the shell to ignore the space).
                        Ssolverbinary = strrep(Xc.Ssolverbinary,' ','\\ ');
                    end
                    string=regexprep(string, Xc.Sexp,  Ssolverbinary, 1);
                case {'executionflags','sexeflags'}
                    string=regexprep(string, Xc.Sexp, Xc.Sexeflags, 1);
                case {'executionpath','sexepath'}
                    string=regexprep(string, Xc.Sexp, Xc.SfolderTimeStamp, 1);
                case {'maininputfile','smaininputfile'}
                    string=regexprep(string, Xc.Sexp, Xc.Smaininputfile, 1);
                case {'soutputfile' 'outputfile'}
                    string=regexprep(string, Xc.Sexp, Xc.Soutputfile, 1);
                otherwise
                    error('openCOSSAN:Connector:run:unknownExecutionParameter', ...
                        ['Unknown parameter in execution string: ' tok{i}{1}])
            end
        end
        
        % The system command is not executed from the current matlab directory.
        % Therefore it is necessary to change directory in the shell command
        % before executing external code from the system shell
        if isunix
            string=['cd ' strrep(Xc.SfolderTimeStamp,' ','\\ ')... % solve the problem with spaces in path
                '; pwd;' string]; %#ok<*AGROW>
        else
            % On windows it is necessary to change the drive first and then the
            % directory. Since Sworkingdirectory is a full path, the first 2
            % characters of the string specify the disk.
            % It will NOT WORK with network drives, because the shell does not
            % allow the use of UNC directory!
            assert(~strcmp(Xc.SfolderTimeStamp(1:2),'\\'),...
                'OpenCossan:Connector:run',...
                ['Due to limitations of the windows shell, it is not possible to use a network '...
                'path as a working directory']);
            if strcmp(Xc.Stype,'opensees')
                string=[Xc.SfolderTimeStamp(1:2) ' & cd "' Xc.SfolderTimeStamp '" & cd & ' string,' ',Xc.Smaininputfile];
            else
                string=[Xc.SfolderTimeStamp(1:2) ' & cd "' Xc.SfolderTimeStamp '" & cd & ' string];
            end
        end
        
        disp(['[COSSAN-X.Connector.run]  Prepare execution command: ''' string ''])
        
        %% Execute 3rd party solver
        [status, cmdout]=system(string);
        % Report results
        if status ~= 0
            warning('openCOSSAN:Connector:run','Non-zero exit status from execution command.\n %s',cmdout);
        end
        
        if NverboseLevel>2
            disp(['[COSSAN-X.Connector.run] Run execution command: ' string ])
        end
        if NverboseLevel>3
            disp('[COSSAN-X.Connector.run]  console output from 3rd party code: \n')
            disp(cmdout)
            disp('[COSSAN-X.Connector.run]  Excecution of the solver completed')
            disp(['[COSSAN-X.Connector.run]  Matlab directory:' pwd])
        end
        
        %% check if the FE has been successfully executed
        LerrorFound(irun) = Xc.checkForErrors;
    else
        LerrorFound=false;
    end
    %% Run post execution command
    if ~isempty(Xc.SpostExecutionCommand)
        [status, cmdout] = system(['cd ' Xc.SfolderTimeStamp ';' Xc.SpostExecutionCommand]);
        
        % Report results
        if status ~= 0
            warning('openCOSSAN:Connector:run','Non-zero exit status from post-execution command.\n %s',cmdout);
        end
        
        if NverboseLevel>2
            disp(['[COSSAN-X.Connector.run] Run post-execution command: ' Xc.SpostExecutionCommand ])
            disp(['[COSSAN-X.Connector.run] Folder: ' Xc.SfolderTimeStamp])
        end
        if NverboseLevel>3
            disp(['[COSSAN-X.Connector.run] Command output: ' result])
        end
    end
    
    %% Extract paramaters
    if ~any(Xc.Lextractors)
        if NverboseLevel>2
            disp('[COSSAN-X.Connector.run] No Extractor defined in Connector. An output structure is created')
        end
        if ~exist('Tout','var')
            Tout=struct;
        end
        LsuccessfullExtract(irun)=true;
    else
        % extract parameter from the output files
        [Textracted,LsuccessfullExtract(irun)] = Xc.extract('Nsimulation',irun);
        
        %% Associate extracted values with COSSAN variables
        if ~isempty(Textracted)
            Sname=fieldnames(Textracted);
            for in=1:length(Sname)
                Tout(irun).(Sname{in})=Textracted.(Sname{in});
            end
        end
    end
    
    % restore original value of working directory
    %Xc.Sworkingdirectory = SworkingdirectoryOriginal;
    
    
    if ~Xc.LkeepSimulationFiles
        rmdir(Xc.SfolderTimeStamp,'s')
    end
    
    % TODO: TO BE CHECKED!
    if ~isempty(OpenCossan.getDatabaseDriver)   % Add record to the Database
        % Create a SimulationData object
        if LuseOriginalValues
            XSimData=SimulationData;
        else
            XSimData = SimulationData('Tvalues',Tinput(irun));
        end
        
        if ~isempty(fieldnames(Tout))
            % if no extractor is defined, Tout is an empty structure
            XSimData = XSimData.merge(SimulationData('Tvalues',Tout(irun)));
        end
        
        SsimulationFolder=fullfile(OpenCossan.getCossanWorkingPath,Sfoldername);
        
        %% Add record
        insertRecord(OpenCossan.getDatabaseDriver,'StableType','Solver',...
            'Nid',getNextPrimaryID(OpenCossan.getDatabaseDriver,'Solver'),...
            'XsimulationData',XSimData,...
            'LsuccessfullExtract',LsuccessfullExtract(irun), ...
            'SsimulationFolder', SsimulationFolder, 'Nsimulation',irun, ...
            'LsuccessfullExecution',~LerrorFound(irun));
        % % delete the folder after it is assured that the content has been corretly put in db
        % delete([SsimulationFolder '.tgz']);
    end
    
end


%% Export results
if NverboseLevel>2
    disp('[COSSAN-X.Connector.run]  Creating SimulationData object')
end

% create Xoutput object
if ~exist('Tout','var')
    % if no Extractor contained Reponses, the variable Tout has not yet
    % been created.
    warning('openCOSSAN:Connector:run',...
        'No outputs in Connector.\nAn empty output structure is created.');
    Tout = struct;
end
Xout=SimulationData('Tvalues',Tout);
if NverboseLevel>2
    disp(['[COSSAN-X.Connector.run]   - END -' datestr(clock)])
end
% Return optional output argument
varargout{1}=Tout;
varargout{2}=LerrorFound;
varargout{3}=LsuccessfullExtract;
end
