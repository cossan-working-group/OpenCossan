classdef Connector < opencossan.workers.Worker
    %CONNECTOR  Class connector
    %
    %   CONSTRUCTOR:  Xobj = Connector('PropertyName', PropertyValue, ...)
    %SsimulationDirectory
    %   This class defines the constructors and methods used to connect
    %   OpenCOSSAN with 3rd-party software. 
    %
    % See Also: http://cossan.co.uk/wiki/index.php/@Connector
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
    
    properties
        Stype = ''              % Type of solver.
        Smaininputfile = ''     % name of the input file of the FE analysis
        Smaininputpath = ''     % path of the main input file
        Soutputfile = ''        % name of the output file
        SpreExecutionCommand    % name of the matlab script used for preprocessing
        SpostExecutionCommand   % name of the matlab script used for preprocessing
        Ssolverbinary           % full path of the FE solver binary
        Sexeflags = ''          % Termination criteria
        SerrorString = ''       % string identifying an error in a simulation
        SerrorFileExtension = ''% extension of the file with error information
        Caddfiles               % Cell array containing the name of additional input files
        LkeepSimulationFiles = true; % if true, keep the simulation files after the FE execution is finished
        CXmembers = {};         % Cell array containing the Injector Extractor objects included in the Connector
        CSmembersNames = {};    % Cell array containing the names of objects included in the Connector
        Lremoteprepost = false
        Sexecmd                 % string containing placeholder for execution command assembly
                                % Define input and output filename 
    end
    
   properties (Hidden=true)
        sleepTime = 5 % Waiting time for checking status of the jobs
        matlabInputName='ConnectorInput.mat'  % Name of the Matlab input file
        matlabOutputName='ConnectorOutput.mat' % Name of the Matlab output file
    end
    
    
    properties (SetAccess=private)
        NverboseLevel % Save the verbosity level 
        Lremote=false % flag the to indicate that the execution is on a remote machine
        SfolderTimeStamp   % Current folder name used to run the simulation
        SremoteWorkingDirectory = ''
    end
    
    properties (Hidden=true,Access=private)
        Sexp = '%(\w+)\>'; % regular expression used to find the identifiers in Sexecmd
        SconnectorScriptName = 'run_Connector.sh' % Name of the connector shell script
        SconnectorRelativePath= ['src' filesep 'ConnectorWrapper']
    end
    
    
    properties (Dependent=true)
        Linjectors    % logical that identifies which CXmembers are Injectors
        Lextractors   % logical that identifies which CXmembers are Extractors
        SexecutionCommand % get execution command of the connector
    end
    
    methods
        %% constructor
        function Xobj = Connector(varargin)
            %CONNECTOR constractor for the connector object
            %
            % See also: http://cossan.co.uk/wiki/index.php/@Connector
            %
            %  The run method runs a 3rd party software and returns a SimulationOuput object.
            %  The 3rd party software is executed on a remote machine, submitting
            %  the job using a job management program, defined in a JobManager object.
            %
            %  [Xout,Toutput]=runJob(Xc,'PropertyName', PropertyValue, ...) returns
            %  the SimulationOuput object Xout and the structure of extracted values
            %  (by means of the extractor object)
            %
            % $Copyright~1993-2015,~COSSAN~Working~Group,~University~of~Liverpool,~UK$
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

            
            %%  Argument Check            
            if nargin==0
                return
            end
            
            %% Processing Inputs
            % Process all the optional arguments and assign them the corresponding
            % default value if not passed as argument
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case ('spredefinedtype')
                        SpredefinedType = varargin{k+1};
                    case ('stype')
                        Xobj.Stype = varargin{k+1};
                    case ('sdescription')
                        Xobj.Description = varargin{k+1};
                    case ('smaininputfile')
                        Xobj.Smaininputfile = varargin{k+1};
                    case ('smaininputpath')
                        Xobj.Smaininputpath = varargin{k+1};
                        if not(strcmp(Xobj.Smaininputpath(end),filesep))
                            Xobj.Smaininputpath  = [Xobj.Smaininputpath filesep];
                        end
                    case ('soutputfile')
                        Xobj.Soutputfile = varargin{k+1};
                    case ('spreexecutioncommand')
                        Xobj.SpreExecutionCommand = varargin{k+1};
                    case ('spostexecutioncommand')
                        Xobj.SpostExecutionCommand = varargin{k+1};
                    case ('ssolverbinary')
                        Xobj.Ssolverbinary = varargin{k+1};
                    case ('sexeflags')
                        Xobj.Sexeflags = varargin{k+1};
                    case ('sexecmd')
                        Xobj.Sexecmd = varargin{k+1};
                    case ('serrorstring')
                        Xobj.SerrorString = varargin{k+1};
                    case ('serrorfileextension')
                        Xobj.SerrorFileExtension = varargin{k+1};
                    case {'caddfiles','csadditionalfiles'}
                        Xobj.Caddfiles = varargin{k+1};
                    case ('lkeepsimulationfiles')
                        Xobj.LkeepSimulationFiles = varargin{k+1};
                    case {'lremoteprepost'}
                        Xobj.Lremoteprepost = varargin{k+1};
                    case ({'xinjector';'xextractor'})
                        % For compatibility reason only
                        eval([inputname(k+1) '=varargin{k+1};' ])
                        eval(['Xobj = Xobj.add(' inputname(k+1) ');'])
                    case {'cxmembers'}
                        Xobj.CXmembers = varargin{k+1};
                        assert(all(xor(Xobj.Linjectors,Xobj.Lextractors)),...
                            'openCOSSAN:Connector:Connector',...
                            'An object that is not either of class Injector nor Extractor have been passed.')
                    case {'csmembersnames','csmembernames'}
                        Xobj.CSmembersNames = varargin{k+1};
                    case {'ccxmembers'}
                        for n= 1:length(varargin{k+1})
                            Xobj.CXmembers{n} = varargin{k+1}{n}{1};
                        end
                        assert(all(xor(Xobj.Linjectors,Xobj.Lextractors)),...
                            'openCOSSAN:Connector:Connector',...
                            'An object that is not either of class Injector nor Extractor have been passed.')
                    otherwise
                        error( 'openCOSSAN:Connector:Connector',...
                            'Property Name %s not valid',varargin{k})
                end
                
            end
            
            % if CSmembersNames is empty, gives "standard" names to
            % injectors and extractors
            if isempty(Xobj.CSmembersNames)
                iinjector = 0;
                iextractor = 0;
                for n=1:length(Xobj.CXmembers)
                    if Xobj.Linjectors(n)
                        iinjector = iinjector +1;
                        Xobj.CSmembersNames{n} = ['Injector' num2str(iinjector)];
                    end
                    if Xobj.Lextractors(n)
                        iextractor = iextractor +1;
                        Xobj.CSmembersNames{n} = ['Extractor' num2str(iextractor)];
                    end
                end
            end
            
            % set private properties Cinputnames and Coutputnames
            Xobj.InputNames = Xobj.getCinputnames();
            Xobj.OutputNames = Xobj.getCoutputnames();
            
            % check that the number of the members and number of names are
            % the same
            assert(length(Xobj.CXmembers)==length(Xobj.CSmembersNames),...
                'openCOSSAN:Connector:Connector',...
                ['The number of members - ' num2str(length(Xobj.CXmembers))...
                ' - is different from the number of names - '...
                num2str(length(Xobj.CSmembersNames))])
            
            %% be sure Smaininputfile contains only the file name
            [Spath, Sfile, Sext] = fileparts(Xobj.Smaininputfile);
            if ~isempty(Spath)
                % Check if Spath is a relative or an absolute path
                if isunix
                    if strcmp(Spath(1),filesep)
                        Labsolutepath=true;
                    else
                        Labsolutepath=false;
                    end
                else
                    if strcmp(Spath(2:3),':\')
                        Labsolutepath=true;
                    else
                        Labsolutepath=false;
                    end
                end
                
                if Labsolutepath
                    % if the main input file includes an absolute path,
                    % set the main input path to this value
                    if isempty(Xobj.Smaininputpath)
                        Xobj.Smaininputfile=[Sfile Sext];
                        Xobj.Smaininputpath=[Spath filesep];
                    else
                        error('openCOSSAN:Connector:Connector',...
                            ['SmainInputPath and Smaininputfile contains absolute paths. ' ...
                            '\n Smaininputfile (path) : ' Spath ...
                            '\n SmainInputPath: ' Xobj.Smaininputpath])
                    end
                else
                    Xobj.Smaininputfile=[Sfile Sext];
                    Xobj.Smaininputpath=[Xobj.Smaininputpath Spath filesep];
                    
                    warning('openCOSSAN:Connector:Connector',...
                        ['SmainInputPath reset to: ' Xobj.Smaininputpath ...
                        '\n Smaininputfile reset to: ' Xobj.SmaininpSworkingdirectoryutfile])
                end
            end
            
            %% Select SOLVER code
            if exist('SpredefinedType','var')
                % Assign default values to the private properties
                try
                    run(fullfile(OpenCossan.getCossanRoot,...
                        'src','+workers','@Connector','predefinedConnectors',...
                        SpredefinedType));
                catch me
                    error('openCOSSAN:Connector:Connector',...
                        'Unknown predefined type %s: ', SpredefinedType);
                end
            end

            %% connector validations assertions
            % a connector must run something...
            assert(~isempty(Xobj.Sexecmd),'openCOSSAN:Connector:Connector',...
                'The property Sexecmd cannot be empty');
                        
            % check that all the necessary files (main input, injector,
            % additional files) exist
            Xobj.checkFiles
        end % end constructor
        
        Xconnector = add(Xconnector,Xobject) % add an Injector or an Extractor to a Connector
        Xconnector = remove(Xconnector,Xobject) % remove an Injector or an Extractor from a Connector
        [varargout]=deterministicAnalysis(Xconnector,varargin) % execute a Deterministic Analysis
        TableOutput= evaluate(Xconnector,TableInput) % execute the Connector with a set of samples on the local machine
        [Xout,varargout]= run(Xconnector,Pinput) % execute the Connector with a set of samples on the local machine
        [Xout,varargout] = runJob(Xconnector,varargin) % execute the Connector with a set of samples using the Grid
        
        [vargout]=test(Xconnector) % check that all the componenent of the Connector are working
        [Tout, LsuccessfullExtract] = extract(Xc,varargin) % execute the extract methods of all the Extractor inside the Connector
        [varargout] = inject(Xc,varargin)  % execute the inject methods of all the Injector inside the Connector
        createWrapper(Xobj,Nfid) % This method prepares the wrapper for the Connector
        
        function Linjectors=get.Linjectors(Xobj)
            Linjectors = false(size(Xobj.CXmembers));
            for n=1:length(Xobj.CXmembers)
                Linjectors(n) = isa(Xobj.CXmembers{n},'opencossan.workers.ascii.Injector');
            end
        end
        
        function Lextractors=get.Lextractors(Xobj)
            Lextractors = false(size(Xobj.CXmembers));
            for n=1:length(Xobj.CXmembers)
                Lextractors(n) = isa(Xobj.CXmembers{n},'opencossan.workers.ascii.Extractor');
            end
        end
        
        function Sexecmd=get.SexecutionCommand(Xobj)
            % this method return the execution command to be run on a linux
            % machine for the runJob.
            Sexecmd=Xobj.Sexecmd;
            [tok] = regexp(Sexecmd, Xobj.Sexp, 'tokens');
            
            for i=1:length(tok)
                switch (lower(tok{i}{1}))
                    case {'solverbinary','ssolverbinary'}
                        % If there are spaces in the path, the shell will
                        % interpret them as separator between command options.
                        % A "\\" must be inserted before the space (the first
                        % to say regexp to ignore the second, and the second to
                        % say the shell to ignore the space).
                        Sexecmd=regexprep(Sexecmd, Xobj.Sexp, strrep(Xobj.Ssolverbinary,' ','\\ '), 1);
                    case {'executionflags','sexeflags'}
                        Sexecmd=regexprep(Sexecmd, Xobj.Sexp, Xobj.Sexeflags, 1);
                    case {'executionpath','sexepath'}
                        Sexecmd=regexprep(string, Xobj.Sexp, strrep(Xobj.Sworkingdirectory,' ','\\ '), 1);
                    case {'maininputfile','smaininputfile'}
                        Sexecmd=regexprep(Sexecmd, Xobj.Sexp, Xobj.Smaininputfile, 1);
                    case {'soutputfile'}
                        Sexecmd=regexprep(Sexecmd, Xobj.Sexp, Xobj.Soutputfile, 1);
                    otherwise
                        error('openCOSSAN:Connector:SexecutionCommand',...
                            ['Unknown parameter in execution string: ' tok{i}{1}])
                end
            end
            
        end
        
         
    end
    
    methods (Access=private)
        LerrorFound = checkForErrors(Xobj) % check if the 3rd party solver exited with an error
        copyFiles(Xc,varargin) % copy the additional files of the Connector to a defined folder
        
        % run the Connector on the Grid, with inject and extract executed locally
        [Xout,varargout] = runJobLocalInjectExtract(Xobj,varargin) 
        % run the Connector on the Grid, with inject and extract executed remotely
        [Xout,varargout] = runJobRemoteInjectExtract(Xobj,varargin) 
        % run the Connector via SSH connection, with inject and extract executed locally
        [Xout,varargout] = runJobLocalInjectExtractSSH(Xobj,varargin) 
        % run the Connector via SSH connection, with inject and extract executed remotely
        [Xout,varargout] = runJobRemoteInjectExtractSSH(Xobj,varargin) 
        
        function checkFiles(Xobj) 
            % check that user specified a main input path
            assert(~isempty(Xobj.Smaininputpath),'openCOSSAN:Connector:checkFiles:noMainInputPath',...
                'Please define the main input path of the solver.')
            % check that all the input files exist
            Cfiles = {fullfile(Xobj.Smaininputpath,Xobj.Smaininputfile)};
            if ~isempty(Xobj.CXmembers) && any(Xobj.Linjectors)
                for imember = 1:length(Xobj.CXmembers)
                    if Xobj.Linjectors(imember)
                        Cfiles = [Cfiles, {fullfile(Xobj.Smaininputpath,...
                            Xobj.CXmembers{imember}.Srelativepath,...
                            Xobj.CXmembers{imember}.Sfile)}]; %#ok<AGROW>
                    end
                end
            end
            for iaddfile = 1:length(Xobj.Caddfiles)
                Cfiles =  [Cfiles, {fullfile(Xobj.Smaininputpath,Xobj.Caddfiles{iaddfile})}]; %#ok<AGROW>
            end
            LfileFound = cellfun(@(x) logical(exist(x,'file')), Cfiles);
            assert(all(LfileFound),'openCOSSAN:Connector:checkFiles',...
                'Cannot find files:\n%s',strjoin(Cfiles(~LfileFound),'\n'))
        end
        
        function Xobj = injextonly(Xobj)
            Xobj.Stype = 'nosolver';
            Xobj.Ssolverbinary='echo Injector execution terminated; date';
            Xobj.Sexecmd='%Ssolverbinary ';
        end
               
        function Coutputnames=getCoutputnames(Xobj)
            if ~any(Xobj.Lextractors)
                Coutputnames={};
            else
                Coutputnames={};
                for n=find(Xobj.Lextractors)
                    Coutputnames=[Coutputnames; Xobj.CXmembers{n}.Coutputnames]; %#ok<AGROW>
                end
                Coutputnames = unique(Coutputnames);
            end
        end
        
        function Cinputnames=getCinputnames(Xobj)
            if ~any(Xobj.Linjectors)
                Cinputnames={};
            else
                Cinputnames={};
                for n=find(Xobj.Linjectors)
                    Cinputnames=[Cinputnames Xobj.CXmembers{n}.Cinputnames]; %#ok<AGROW>
                end
                Cinputnames = unique(Cinputnames);
            end
        end
    end
    
    methods (Static, Access=private)
%         function Tinject = prepareInputStructure(Tinput,irun)
%             create the structure with the values to be injected (i.e., if there
%             is a parameter its values is stored in Tinput(1))
%             Tinject = Tinput(irun);
%             Cnames = fieldnames(Tinject);
%             for iname = 1:length(Cnames)
%                 if isempty(Tinject.(Cnames{iname}))
%                     Tinject.(Cnames{iname}) = Tinput(1).(Cnames{iname});
%                 end
%             end
%         end
    end
    
    
end
