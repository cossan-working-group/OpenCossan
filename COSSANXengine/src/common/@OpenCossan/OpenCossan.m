classdef OpenCossan < handle
    % OpenCossan This class defines the settings and the preferences
    % required by the COSSANengine
    %
    % See also: https://cossan.co.uk/wiki/index.php/@OpenCossan
    %
    % Author: Edoardo Patelli
    % Institute for Risk and Uncertainty, University of Liverpool, UK
    % email address: openengine@cossan.co.uk
    % Website: http://www.cossan.co.uk
    
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
        ScossanRoot            % Installation root of COSSANengine
        SexternalPath          % Path of 3rd party tools/software
        SexternalDistributionPath % Path of 3rd party tools/software distribution folder (machine dependent)
        SmatlabDatabasePath    % Path of the Engine Database
        SmcrPath               % Define the path of the Matlab Compiler Runtime
        SmatlabPath            % Define the path of the Matlab installation
        NverboseLevel=3        % Verbosity level
        Lchecks=true           % if false no checks are performed during analysis
        SdiaryFileName = 'CossanLog.txt' % Filename of the log file
        Xanalysis              % Analysis object
        XdatabaseDriver        % DataBaseDriver
        XjobInterface          % JobInterface
        XsshConnection         % SSHConnection Object for SSH connection and operations
    end
    
    properties (Dependent)
        SbinPath
        SlibPath
        SincludePath
    end
    
    properties (Hidden, SetAccess=protected)
        LisCossanX=false
    end
    
    properties (Constant,Hidden)
        % Predefined path for openCOSSAN
        CsrcPathFolders={['src' filesep 'common'] ...
            ['src' filesep 'common' filesep 'utilities'] ...
            ['src' filesep 'common' filesep 'utilities' filesep 'ASCII'] ...
            ['src' filesep 'common' filesep 'utilities' filesep 'PC_exp_functions'] ...
            ['src' filesep 'connectors'] ...
            ['src' filesep 'connectors' filesep 'matlab'] ...
            ['src' filesep 'connectors' filesep 'ascii'] ...
            ['src' filesep 'highperformancecomputing'] ...
            ['src' filesep 'inference'] ...
            ['src' filesep 'Inputs'] ...
            ['src' filesep 'metamodel'] ...
            ['src' filesep 'optimization']  ...
            ['src' filesep 'outputs'] ...
            ['src' filesep 'reliability'] ...
            ['src' filesep 'sensitivity'] ...
            ['src' filesep 'sfem'] ...
            ['src' filesep 'simulations'] ...
            }
        % Predefined path for mex files
        CmexPathFolders={fullfile('mex','bin')}
        
        % Predefined path for tutorials
        CtutorialsPathFolders={...
            fullfile('examples','Tutorials','2DOFmodelupdating'), ...
            fullfile('examples','Tutorials','6StoreyBuilding'), ...
            fullfile('examples','Tutorials','AntennaTower'), ...
            fullfile('examples','Tutorials','Beam3PointBending'), ...
            fullfile('examples','Tutorials','BikeFrame'), ...
            fullfile('examples','Tutorials','BridgeModel'), ...
            fullfile('examples','Tutorials','BuildingFrameWithDampers'), ...
            fullfile('examples','Tutorials','CantileverBeam'), ...
            fullfile('examples','Tutorials','CargoCrane'), ...
            fullfile('examples','Tutorials','CossanObjects'), ...
            fullfile('examples','Tutorials','CrackGrowth'), ...
            fullfile('examples','Tutorials','CylindricalShell'), ...
            fullfile('examples','Tutorials','GOCEsatellite'), ...
            fullfile('examples','Tutorials','InfectionDynamicModel'), ...
            fullfile('examples','Tutorials','IshigamiFunction'), ...
            fullfile('examples','Tutorials','ParallelSystem'), ...
            fullfile('examples','Tutorials','SmallSatellite'), ...
            fullfile('examples','Tutorials','TrussBridgeStructure'),...
            fullfile('examples','Tutorials','TurbineBlade')};
        
        % List of jar files to be included in the path
        CjarFileName={'mysql-connector-java-5.1.18-bin.jar',... % MySQL JDBC
            'sqlite-jdbc-3.7.2.jar',...                         % SQLite JDBC
            'postgresql-9.1-902.jdbc4.jar',...                  % PostgreSQL JDBC
            'ganymed-ssh2-261.jar'};                            % SSHconnector
        
        % Predefined path for documentation files
        CdocsPathFolders={fullfile('doc'),fullfile('doc','html')}
        
        SrequiredMatlabVersion='8.1'; % Minimum required Matlab version
        
        Skillfilename='KILL';
    end
    
    methods
        function Xobj=OpenCossan(varargin)
            % OpenCossan. This constructor initialize the object OpenCossan
            % that contains all the setting of the COSSANengine
            %
            % See Also https://cossan.co.uk/wiki/index.php/@OpenCossan
            %
            % Author: Edoardo Patelli
            % Institute for Risk and Uncertainty,
            % University of Liverpool, UK
            % email address: openengine@cossan.co.uk
            % Website: http://www.cossan.co.uk
            
            clear global OPENCOSSAN
            global OPENCOSSAN
            
            CdbArguments={};
            CsshArguments={};
            CanalysisArguments={};
            
            %% Process inputs
            OpenCossan.validateCossanInputs(varargin{:})
            
            %% Check Matlab version
            if verLessThan('matlab', Xobj.SrequiredMatlabVersion)
                warning('OpenCOSSAN:OpenCOSSAN:checkMatlabversion', ...
                    ['A Matlab version %s or higher is required!!!!' ...
                    '\nCurrent Matlab release is R%s\n\n',...
                    'Please be aware that some features of OpenCossan may not function properly or this Matlab version!!!!\n'],...
                    Xobj.SrequiredMatlabVersion,version)
            else
                disp(['Detected Matlab release R' version('-release')])
            end
            
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case {'scossanroot','scossanpath'}
                        assert (isdir(varargin{k+1}), ...
                            'OpenCossan:wrongPath',...
                            'please provide a valid directory name after Scossanpath')
                        Sroot=varargin{k+1};
                        if strcmpi(Sroot(end),filesep)
                            % remove the separator if it is the last character
                            Sroot = Sroot(1:end-1);
                        end
                    case {'nverboselevel'} %DONE
                        %Set verbose level
                        Xobj.NverboseLevel=varargin{k+1};
                        if Xobj.NverboseLevel > 4 || Xobj.NverboseLevel < 0
                            warning('OpenCossan:wrongVerboseLevel',...
                                'Nverboselevel should be an integer between 0-4, therefore it will be set to its default value 4 ')
                            Xobj.NverboseLevel=4;
                        end
                    case {'sdiaryfilename'} % DONE
                        Xobj.SdiaryFileName=varargin{k+1};
                    case {'sexternalpath'} %  DONE
                        assert(isdir(varargin{k+1}), ...
                            'OpenCossan:wrongExternalPath',...
                            'please provide a valid directory name for the externalpath')
                        Xobj.SexternalPath=varargin{k+1};
                    case {'smcrpath'} %DONE
                        assert(isdir(varargin{k+1}), ...
                            'OpenCossan:wrongMCR',...
                            'please provide a valid directory name for the MatlabCompilerRuntime')
                        Xobj.SmcrPath=varargin{k+1};
                    case {'smatlabpath'}  %  DONE
                        assert(isdir(varargin{k+1}), ...
                            'OpenCossan:wrongMatlabPath',...
                            'please provide a valid directory name for the Matlab installation')
                        Xobj.SmatlabPath=varargin{k+1};
                    case {'smatlabdatabasepath'} %  DONE
                        assert(isdir(varargin{k+1}), ...
                            'openCOSSAN:OpenCossan',...
                            'please provide a valid directory name for the Engine Database Path')
                        Xobj.SmatlabDatabasePath = varargin{k+1};
                    case {'xdatabasedriver'}
                        assert(isa(varargin{k+1},'DatabaseDriver'),...
                            'openCOSSAN:OpenCossan',...
                            'please provide an object of DatabaseDriver after the property name %s',varargin{k})
                        Xobj.XdatabaseDriver = varargin{k+1};
                    case {'cxdatabasedriver'}
                        assert(isa(varargin{k+1}{1},'DatabaseDriver'),...
                            'openCOSSAN:OpenCossan',...
                            'please provide an object of DatabaseDriver after the property name %s',varargin{k})
                        Xobj.XdatabaseDriver = varargin{k+1}{1};
                    case {'sdatabasename','susername','spassword',...
                            'sjdbcdriver','sdatabaseurl'}
                        CdbArguments{end+1}=varargin{k};
                        CdbArguments{end+1}=varargin{k+1};
                        % ssh connection
                    case {'cxsshsonnection'}
                        assert(isa(varargin{k+1}{1},'SSHConnection'),...
                            'openCOSSAN:OpenCossan',...
                            'please provide an object of SSHConnection after the property name %s',varargin{k})
                        Xobj.XdatabaseDriver = varargin{k+1}{1};
                    case {'xsshconnection'}
                        assert(isa(varargin{k+1},'SSHConnection'),...
                            'openCOSSAN:OpenCossan',...
                            'please provide an object of SSHConnection after the property name %s',varargin{k})
                        Xobj.XdatabaseDriver = varargin{k+1};
                    case {'ssshuser','ssshhost','ssshprivatekey',...
                            'skeypassword',...
                            'ssshpassword','sremoteworkingpath',...
                            'sremoteworkfolder','sremotemcrpath',...
                            'sremotecossanroot','sremoteexternalpath'}
                        CsshArguments{end+1} = varargin{k}; %#ok<*AGROW>
                        CsshArguments{end+1} = varargin{k+1};
                        % ANALYSIS OBJECT
                    case {'sprojectname','sanalysisname','sdescription',...
                            'xtimer','nseed','srandomnumberalgorithm',...
                            'sworkingpath','smainpath'}
                        CanalysisArguments{end+1} = varargin{k};
                        CanalysisArguments{end+1} = varargin{k+1};
                    case {'xanalysis'}
                        assert(isa(varargin{k+1},'Analysis'),...
                            'OpenCossan:OpenCossan',...
                            'please provide an object of Type Analysis after the property name %s',varargin{k})
                        Xobj.Xanalysis = varargin{k+1};
                    case {'cxanalysis'}
                        assert(isa(varargin{k+1}{1},'Timer'),...
                            'OpenCossan:OpenCossan',...
                            'please provide an object of Type Analysis after the property name %s',varargin{k})
                        Xobj.Xanalysis = varargin{k+1}{1};
                    case {'liscossanx'}
                        Xobj.LisCossanX=varargin{k+1};
                    otherwise
                        error('OpenCossan:OpenCossan',...
                            'The property name %s is not valid',varargin{k})
                end
                
            end
            
            if isdeployed
                Status='deployed';
                disp(['Engine type: ',Status])
            else
                [Spath, Status]=OpenCossan.getCossanRoot;
            end
            
                     
            %% Set path
            if ~isdeployed %&& isempty(OpenCossan.getCossanRoot)
                
                % Check if the toolbox is OpenCossan is installed as a
                % Matlab Toolbox 
                if verLessThan('matlab', '9.4') || exist('Sroot','var')
                    LsetPath=1;
                else
                    if (usejava('desktop'))
                        toolboxes=matlab.addons.toolbox.installedToolboxes;

                        if  any(arrayfun(@(x)strcmp(x.Name,'OpenCossan'),toolboxes))
                            LsetPath=0;
                            disp(['Using OpenCossan toolbox version: ',toolboxes.Version])
                        else
                            LsetPath=1;
                        end
                    else
                        LsetPath = 1;
                    end
                end
                
                if ~exist('Sroot','var')
                    % Define the path of OpenCossan for pcode of OpenCossan
                    Sroot=Spath;
                end
                
                assert(logical(exist('Sroot','var')),...
                    'openCOSSAN:OpenCossan', ...
                    strcat('Please define the installation path of ',...
                    'OpenCossan.\nPlease use the PropertyName: ScossanPath'))
                
                if LsetPath
                    if strcmp(Status,'.m')
                        OpenCossan.setPath('ScossanRoot',Sroot, ...
                            'CsrcCossanPaths',Xobj.CsrcPathFolders, ...
                            'CtutorialCossanPaths',Xobj.CtutorialsPathFolders, ...
                            'CmexCossanPaths',Xobj.CmexPathFolders, ...
                            'CdocsCossanPaths',Xobj.CdocsPathFolders);
                    else
                        OpenCossan.setPath('ScossanRoot',Sroot, ...
                            'CmexCossanPaths',Xobj.CmexPathFolders,...
                            'CtutorialCossanPaths',Xobj.CtutorialsPathFolders, ...
                            'CdocsCossanPaths',Xobj.CdocsPathFolders);
                    end
                end
            else
                
            end
            
            if ~isdeployed && isempty(Xobj.SmatlabPath)
                Xobj.SmatlabPath=matlabroot; %#ok<MCMLR>
            end
            
            % Store the COSSAN path
            Xobj.ScossanRoot=OpenCossan.getCossanRoot;
            
            if isempty(Xobj.SexternalPath) && ~isdeployed
                Xobj.SexternalPath=fullfile(Xobj.ScossanRoot,'..','OpenSourceSoftware');
            end
            
            %% Initilize enviroments for non-matlab code
            
            % SET ENVIROMENT FOR UNIX MACHINE
            if isunix&&~ismac
                % Retrive Discribution Reliase and architecture
                [status, Sdistribution]=system('lsb_release -i | awk ''{print $3}''');
                if status
                    warning('openCOSSAN:OpenCossan', ...
                        'Linux distribution not detected')
                else
                    % Remove newline character
                    Sdistribution=Sdistribution(1:end-1);
                end
                
                [status, Srelease]=system('lsb_release -r | awk ''{print $2}''');
                
                if status
                    warning('openCOSSAN:OpenCossan', ...
                        'Linux release not detected')
                else
                    % Remove newline character
                    Srelease=Srelease(1:end-1);
                end
            elseif ismac
                Sdistribution='Mac_OS_X';
                [status, Srelease]=system('sw_vers -productVersion');
                if status
                    warning('openCOSSAN:OpenCossan', ...
                        'Mac_OS_X release not detected')
                else
                    % Remove newline character
                    Srelease=Srelease(1:end-1);
                end
            else
                %% SET ENVIROMENT FOR WINDOWS MACHINES
                Sdistribution='Windows';
                [~,Srelease]=system('ver');
                [Vs]=regexp(Srelease,'\d');
                Srelease=Srelease(Vs(1):Vs(end));
            end
            % for all  the machines
            Sarch = computer('arch');
            
            % set the distribution folder
            Xobj.SexternalDistributionPath = fullfile(Xobj.SexternalPath,'dist',Sdistribution,Srelease,Sarch);
            
            if isunix
                COSSANbinPath=fullfile(Xobj.SexternalDistributionPath,'bin');
                COSSANlibPath=fullfile(Xobj.SexternalDistributionPath,'lib');
            elseif ispc
                % there is no difference between path and runtime library
                % path in windows!
                COSSANbinPath=Xobj.SexternalDistributionPath;
                COSSANlibPath=Xobj.SexternalDistributionPath;
            end
            COSSANincludePath=fullfile(Xobj.SexternalDistributionPath,'include');
            
            Slookoutfor='OpenSourceSoftware';
            
            if isunix
                %% SET ENVIROMENT FOR LINUX/MAC MACHINES
                SpathEnv=Xobj.SbinPath;
                
                if isempty(SpathEnv)
                    setenv('PATH', COSSANbinPath );
                elseif isempty(regexpi(SpathEnv,[filesep Slookoutfor]))
                    setenv('PATH', [SpathEnv ':' COSSANbinPath ]);
                else
                    Xobj.showDisp('Enviroments variables PATH already defined',2);
                end
                
                SpathEnv=Xobj.SlibPath;
                if ismac
                    % library path var name in mac
                    SLibraryVarName = 'DYLD_LIBRARY_PATH';
                else
                    % library path var name in linux
                    SLibraryVarName = 'LD_LIBRARY_PATH';
                end
                
                if isempty(SpathEnv)
                    setenv(SLibraryVarName, COSSANlibPath );
                elseif isempty(regexpi(SpathEnv,[filesep Slookoutfor]))
                    setenv(SLibraryVarName, [SpathEnv ':' COSSANlibPath ]);
                else
                    Xobj.showDisp(['Enviroments variables ' SLibraryVarName ' already defined'],2);
                end
                
                SpathEnv=Xobj.SincludePath;
                
                if isempty(SpathEnv)
                    setenv('C_INCLUDE_PATH', COSSANincludePath );
                elseif isempty(regexpi(SpathEnv,[filesep Slookoutfor]))
                    setenv('C_INCLUDE_PATH', [SpathEnv ':' COSSANincludePath ]);
                else
                    Xobj.showDisp('Enviroments variables C_INCLUDE_PATH already defined',2);
                end
                
            elseif ispc
                %% SET ENVIROMENT FOR WINDOWS
                % Note: windows uses ";" instead of ":" to separate
                % elements in the path
                SpathEnv=Xobj.SbinPath;
                
                if isempty(SpathEnv)
                    setenv('PATH', COSSANbinPath );
                elseif isempty(regexpi(SpathEnv,[filesep Slookoutfor]))
                    setenv('PATH', [SpathEnv ';' COSSANbinPath ]);
                else
                    Xobj.showDisp('Enviroments variables PATH already defined',2);
                end
                
                SpathEnv=Xobj.SlibPath;
                
                if isempty(SpathEnv) % note this is a compilation path only, not a runtime path
                    setenv('LIB', COSSANlibPath );
                elseif isempty(regexpi(SpathEnv,[filesep Slookoutfor]))
                    setenv('LIB', [SpathEnv ';' COSSANlibPath ]);
                else
                    Xobj.showDisp('Enviroments variables LIB already defined',2);
                end
                
                SpathEnv=Xobj.SincludePath;
                
                if isempty(SpathEnv) % inlude is used only for compilation in windows
                    setenv('INCLUDE', COSSANincludePath );
                elseif isempty(regexpi(SpathEnv,[filesep Slookoutfor]))
                    setenv('INCLUDE', [SpathEnv ';' COSSANincludePath ]);
                else
                    Xobj.showDisp('Enviroments variables INCLUDE already defined',2);
                end
            end
            
            
            %% Initialize external toolboxes
            
            if ~isdeployed
                SpathToolbox=fullfile(Xobj.SexternalPath,'src','spinterp_v5.1.1','spinit.m');
                
                if exist(SpathToolbox,'file')
                    run(SpathToolbox);
                else
                    warning('openCOSSAN:OpenCossan', ...
                        'Sparse Grid Toolbox has not been initialized')
                end
            else
                % Check Sparse grid toolbox
                try
                    spinit
                catch ME %#ok<NASGU>
                    warning('openCOSSAN:OpenCossan', ...
                        'Sparse Grid Toolbox has not been included in deployed engine')
                    %rethrow(ME)
                end
            end
            
            %% Check if MEX files exists
            
            if ~isdir(fullfile(Xobj.ScossanRoot,Xobj.CmexPathFolders{:}))
                warning('openCOSSAN:OpenCossan:noMEX', ...
                        ['MEX folder not available. \n',...
                        '1. download the source file from cossan.co.uk\n',...
                        '2. Compile the mex files\n',...
                        '3. Copy the mex files into the folder: ',...
                        fullfile(Xobj.ScossanRoot,'mex','src')])
            end
            
            %% Assign Object to global variable
            OPENCOSSAN=Xobj;
            
            if isempty(OPENCOSSAN.Xanalysis)
                % Initialize Analysis object
                if isempty(CanalysisArguments)
                    OPENCOSSAN.Xanalysis=Analysis;
                else
                    OPENCOSSAN.Xanalysis=Analysis(CanalysisArguments{:});
                end
            end
            
            if isempty(OPENCOSSAN.XdatabaseDriver) &&  exist('DatabaseDriver','class')
                if isempty(CdbArguments)
                    OPENCOSSAN.XdatabaseDriver=DatabaseDriver;
                else
                    try
                        OPENCOSSAN.XdatabaseDriver=DatabaseDriver(CdbArguments{:});
                    catch ME
                        warning('OpenCossan:OpenCossan',...
                            'Failed to initialize Database connection')
                        display(ME.message)
                    end
                end
            end
            
            if isempty(OPENCOSSAN.XsshConnection) && exist('SSHConnection','class')
                if isempty(CsshArguments)
                    OPENCOSSAN.XsshConnection = SSHConnection;
                else
                    try
                        OPENCOSSAN.XsshConnection = SSHConnection(CsshArguments{:});
                    catch ME
                        warning('OpenCossan:OpenCossan',...
                            'Failed to initialize SSHConnection connection')
                        display(ME.message)
                    end
                end
            end
            
            
            %% Initialize logfile (diary)
            if ~isempty(Xobj.SdiaryFileName)
                [Sdir, Sfilename, Sext]=fileparts(Xobj.SdiaryFileName);
                if isempty(Sdir)
                    Sdir=Xobj.Xanalysis.SworkingPath;
                end
                Xobj.SdiaryFileName=fullfile(Sdir,[Sfilename Sext]);
                % Initialize diary
                if exist(Xobj.SdiaryFileName,'file')
                    disp('Removing old log file')
                    delete(Xobj.SdiaryFileName);
                end
                try
                    diary(Xobj.SdiaryFileName)
                catch ME
                    disp('Not able to create diary file')
                    disp(ME.message)
                end
            end
            
            
        end % of constructor method
        
        showDisp(Xobj,Smessage,Nlevel);
        
        function SbinPath=get.SbinPath(Xobj) %#ok<MANU>
            SbinPath=getenv('PATH');
        end
        
        function SlibPath=get.SlibPath(Xobj) %#ok<MANU>
            if isunix
                SlibPath=getenv('LD_LIBRARY_PATH');
            elseif ispc
                SlibPath=getenv('LIB'); % in windows this is a COMPILATION library path, not a runtime path
            end
        end
        
        function SincludePath=get.SincludePath(Xobj) %#ok<MANU>
            if isunix
                SincludePath=getenv('C_INCLUDE_PATH');
            elseif ispc
                SincludePath=getenv('INCLUDE');
            end
        end
        
    end
    
    %% Static Methods
    methods (Static)
        createStartupFile;                  % Create a startup file for OpenCossan
        cossanDisp(Smessage,Nlevel);        % Controll cossan output
        removePath;                         % Remove OpenCossan from the Matlab path
        reset;                              % clear workspace, close files and figures
        resetRandomNumberGenerator(Nseed)   % This method reset the seed and the algotithm of the random number generator
        validateCossanInputs(varargin);     % method used to enforce the name convenction in the arguments
        printLogo;                          % Print OpenCossan logo
        
        % Get Methods
        SanalysisName=getAnalysisName;      % Get the Analysis Name
        NanalysisID=getAnalysisID;          % Get the Analysis ID
        SprojectName=getProjectName;
        Sdescription=getDescription;
        deltaTime=getDeltaTime(varargin);   % get the time enlapsed between two laptime
        SexternalPath=getCossanExternalPath;
        SdistPath=getCossanDistributionPath;
        [ScossanRoot, Stype]=getCossanRoot;
        SworkingPath=getCossanWorkingPath;
        Xobj=getDatabaseDriver;
        Xobj=getAnalysis;
        getInfo;
        Sname=getKillFilename;     % Return the name of the kill file
        XrandomStream=getRandomStream; % Return the random stream stored in the Analysis
        Xobj=getSSHConnection;
        Nlevel=getVerbosityLevel;
        
        % Set methods
        setAnalysisName(SanalysisName); % Define Analysis Name
        setAnalysisID(NanalysisID);     % Set the Analysis ID
        setProjectName(SprojectName);   % set the name of Project (current open project)
        setDescription(Sdescription);   % set the description of the analysis (current open project)
        varargout=setLaptime(varargin); % set the description of the analysis (current open project)
        setPath(varargin)               % Method to set the COSSANengine path
        setVerbosityLevel(Nlevel)       % Method to set the verbosity Level
        setWorkingPath(SworkingPath);   % Set the working path
        
        function Xtimer=getTimer
            global OPENCOSSAN
            Xtimer=OPENCOSSAN.Xanalysis.Xtimer;
        end
        
        function SuserName=getUserName
            if isunix
                % get the user name from the unix command line
                [~, SuserName] = system('whoami');
                SuserName = SuserName(1:end-1); % remove the last character (it's a new line)
            elseif ismac
                [~, SuserName] = system('whoami');
                SuserName = SuserName(1:end-1); % remove the last character (it's a new line)
            else
                % get the user name from the windows command line
                SuserName = getenv('USERNAME');
            end
        end
        
        function SmatlabPath=getMatlabPath
            global OPENCOSSAN
            SmatlabPath = OPENCOSSAN.SmatlabPath;
        end
        
        function SmcrPath=getMCRPath
            global OPENCOSSAN
            SmcrPath = OPENCOSSAN.SmcrPath;
        end
        
        function CcossanObjects=getCossanObjectNames
            global OPENCOSSAN
            CcossanFiles = dirrec(fullfile(OPENCOSSAN.getCossanRoot,'src'));
            CclassDirs = regexp(CcossanFiles,'@[a-zA-Z]*','match');
            CcossanObjects = cat(1,CclassDirs{:});
            CcossanObjects = unique(CcossanObjects);
        end
        
        %% SSH connection static methods
        % return properties from the SSH connection
        function Sout = getRemoteWorkingPath
            % return the remote working directory
            global OPENCOSSAN
            assert(~isempty(OPENCOSSAN),'openCOSSAN:OpenCossan',...
                'OpenCossan has not been initialize. \n Please run OpenCossan! ')
            assert(~isempty(OPENCOSSAN.XsshConnection),'openCOSSAN:OpenCossan',...
                'SSH connection is not available ')
            
            Sout=OPENCOSSAN.XsshConnection.SremoteWorkFolder;
        end
        
        function LhasSSHConnection = hasSSHConnection
            % return true if COSSAN includes an SSH connection
            global OPENCOSSAN
            LhasSSHConnection = false;
            if ~isempty(OPENCOSSAN.XsshConnection)
                LhasSSHConnection = true;
            end
        end
        
        function LisAuthenticated = isAuthenticated
            % return true if the SSH connection is authenticated
            global OPENCOSSAN
            LisAuthenticated = false;
            if ~isempty(OPENCOSSAN.XsshConnection) && ...
                    ~isempty(OPENCOSSAN.XsshConnection.JsshConnection)
                LisAuthenticated = ...
                    OPENCOSSAN.XsshConnection.JsshConnection.isAuthenticationComplete;
            end
        end
        
        function [status, result] = issueSSHcommand(Scommand)
            % issueSSHcommand
            % issue a command to a remote host via SSH.
            % INPUTS
            % Scommand: string containing the remote command
            %
            % OUTPUTS
            % status: integer with the command returned status
            % results: stdout of the command
            
            global OPENCOSSAN
            
            assert(OpenCossan.hasSSHConnection,'OpenCossan:issueSSHcommand',...
                'Cannot issue a command via SSH. SSH connection is not available')
            
            % check that user is authenticated before issuing a command
            if ~OpenCossan.isAuthenticated
                OPENCOSSAN.XsshConnection.openSSHconnection
            end
            
            [status, result]  =  OPENCOSSAN.XsshConnection.issueCommand(Scommand);
        end
        
        function Lstatus=isKilled
            Lstatus= exist(fullfile(OpenCossan.getCossanWorkingPath,OpenCossan.getKillFilename),'file');
        end
        
        function Lchecks=getChecks
            global OPENCOSSAN
            Lchecks= OPENCOSSAN.Lchecks;
        end
        
        function setChecks(Lchecks)
            global OPENCOSSAN
            OPENCOSSAN.Lchecks=Lchecks;
        end
    end
    
end

