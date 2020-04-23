classdef (Sealed) OpenCossan < handle
    %OPENCOSSAN This singleton class exposes settings and global objects
    %used by OpenCossan. The first time the object is accessed, the toolbox
    %is automatically initialized.
    %
    % COSSAN = opencossan.OpenCossan.getInstance()
    %
    % See also SINGLETON
    
    %{
    This file is part of OpenCossan <https://cossan.co.uk>.
    Copyright (C) 2006-2018 COSSAN WORKING GROUP

    OpenCossan is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License or,
    (at your option) any later version.

    OpenCossan is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with OpenCossan. If not, see <http://www.gnu.org/licenses/>.
    %}
    
    properties
        % Path of the Engine Database
        MatlabDatabasePath(1,:) char  {shouldBeDirectory(MatlabDatabasePath)}
        % Define the path of the Matlab Compiler Runtime
        McrPath(1,:) char {shouldBeDirectory(McrPath)}
        % Verbosity level
        VerboseLevel(1,1) uint8 {mustBeNonnegative,...
            mustBeLessThan(VerboseLevel,5)} = 3
        % Filename of the log file
        DiaryFileName(1,:) char = 'OpenCossanLog.txt'
        % Name of the wrapper used to run Cossan jobs
        WrapperName(1,1) char
        % Analysis object
        Analysis(1,1) opencossan.common.Analysis = opencossan.common.Analysis();
        % DataBaseDriver
        DatabaseDriver(1,1) opencossan.common.database.DatabaseDriver
        % JobInterface
        JobInterface(1,1)
        % SSHConnection Object for SSH connection and operations
        SSHConnection(1,1) opencossan.highperformancecomputing.SSHConnection
    end
    
    properties (Dependent)
        Root                        % Installation root of OpenCossan
    end
    
    properties (Dependent, Hidden)
        PathToMex                   % Path to the lib\mex folder
        PathToDocs                  % Path to the docs\ folder
        PathToExternalDistribution  % Path to the machine dependant dist\ folder
        PathToJar                   % Path to the lib\jar folder
        
        BinPath                     % environment variable
        LibPath                     % environment variable
        IncludePath                 % environment variable
    end
    
    properties (Constant,Hidden)
        % Define external tooolboxes. The first column defines the name of the
        % script required to initilise the toolbox. The second column
        % contains the name of the toolboxes.
        % The following paths are relative to the cossan root
        Toolboxes = "lib/bnt";
        
        RequiredMatlabVersion='9.5'; % Minimum required Matlab version
        KillFileName='KILL';
    end
    
    methods (Access=private)
        function obj = OpenCossan(varargin)
            % This constructor initializes the handle object OpenCossan.
            % The object contains the settings and configurations for the
            % OpenCossan toolbox.
            %
            % COSSAN = opencossan.OpenCossan.getInstance()
            %
            % See also SINGLETON
            
            %% Update the paths
            obj.setPath();
            
            %% Setup environment variables
            obj.setEnvironmentVariables();
            
            %% Initialize diary
            if exist(fullfile(userpath,obj.DiaryFileName),'file')
                disp('Removing old log file')
                diary off;
                delete(fullfile(userpath,obj.DiaryFileName));
            end
            
            try
                diary(fullfile(userpath,obj.DiaryFileName))
            catch ME
                disp('Not able to create diary file')
                disp(ME.message)
            end
            
            
            %% Check Matlab version
            if verLessThan('matlab', obj.RequiredMatlabVersion)
                warning('OpenCOSSAN:OpenCOSSAN:UnsupportedMatlabVersion', ...
                    'Matlab version %s or higher is required but version is %s.',...
                    obj.RequiredMatlabVersion,version)
            end
            
            opencossan.OpenCossan.printLogo();
        end
        
        setEnvironmentVariables(obj);
        setPath(obj, varargin);
    end
    
    methods
        function root = get.Root(~)
            root = strsplit(which('opencossan.OpenCossan'),filesep);
            root = strjoin(root(1:end-3),filesep);
        end
        
        function path = get.PathToDocs(obj)
            path = fullfile(obj.Root,'docs');
        end
        
        function path = get.PathToMex(obj)
            path = fullfile(obj.Root,'lib','mex','bin');
        end
        
        function path = get.PathToJar(obj)
            path = fullfile(obj.Root,'lib','jar');
        end
        
        function path = get.PathToExternalDistribution(obj)
            if isunix && ~ismac
                % Retrieve distribution release and architecture
                [status, distribution] = system('lsb_release -i | awk ''{print $3}''');
                if status
                    warning('OpenCossan:EnviromentError', ...
                        'Linux distribution not detected')
                else
                    % Remove newline character
                    distribution = distribution(1:end-1);
                end
                
                [status, release] = system('lsb_release -r | awk ''{print $2}''');
                
                if status
                    warning('OpenCossan:EnviromentError', ...
                        'Linux release not detected')
                else
                    % Remove newline character
                    release = release(1:end-6);
                end
            elseif ismac
                distribution = 'Mac_OS_X';
                [status, release] = system('sw_vers -productVersion');
                if status
                    warning('OpenCossan:EnviromentError', ...
                        'Mac_OS_X release not detected')
                else
                    % Remove newline character
                    release = release(1:end-1);
                end
            else
                distribution='Windows';
                [~,release] = system('ver');
                Vs = regexp(release,'\d');
                release = release(Vs(1):Vs(2)); % get only major and first minor release number 
            end
            % for all  the machines
            arch = computer('arch');
            
            % set the distribution folder
            path = fullfile(obj.Root,'lib','dist',distribution,release,arch);
        end
        
        function path = get.BinPath(~)
            path = getenv('PATH');
        end
        
        function path = get.LibPath(~)
            if isunix
                path = getenv('LD_LIBRARY_PATH');
            elseif ispc
                path = getenv('LIB'); % in windows this is a COMPILATION library path, not a runtime path
            end
        end
        
        function path = get.IncludePath(~)
            if isunix
                path = getenv('C_INCLUDE_PATH');
            elseif ispc
                path = getenv('INCLUDE');
            end
        end
        
    end
    
    %% Static Methods
    methods (Static)
        
        function obj = getInstance()
            persistent localObj;
            if isempty(localObj) || ~isvalid(localObj)
                localObj = opencossan.OpenCossan();
            end
            obj = localObj;
        end
        
        %% Static methods to interface with the Analysis object
        function analysis = getAnalysis()
            analysis = opencossan.OpenCossan.getInstance().Analysis;
        end
        
        function id = getAnalysisId()
            id = opencossan.OpenCossan.getInstance().Analysis.AnalysisID;
        end
        
        function name = getAnalysisName()
            name = opencossan.OpenCossan.getInstance().Analysis.AnalysisName;
        end
        
        function name = getProjectName()
            name = opencossan.OpenCossan.getInstance().Analysis.ProjectName;
        end
        
        function desc = getDescription()
            desc = opencossan.OpenCossan.getInstance().Analysis.Description;
        end
        
        function stream = getRandomStream()
            stream = opencossan.OpenCossan.getInstance().Analysis.RandomStream;
        end
        
        function setAnalysis(varargin)
            cossan = opencossan.OpenCossan.getInstance();
            cossan.Analysis = opencossan.common.Analysis(varargin{:});
        end
        
        function setAnalysisId(id)
            cossan = opencossan.OpenCossan.getInstance();
            cossan.Analysis.AnalysisID = id;
        end
        
        function setAnalysisName(name)
            cossan = opencossan.OpenCossan.getInstance();
            cossan.Analysis.AnalysisName = name;
        end
        
        function setProjectName(name)
            cossan = opencossan.OpenCossan.getInstance();
            cossan.Analysis.ProjectName = name;
        end
        
        function setDescription(desc)
            cossan = opencossan.OpenCossan.getInstance();
            cossan.Analysis.Description = desc;
        end
        
        function ssh = getSSHConnection()
            cossan = opencossan.OpenCossan.getInstance();
            ssh = cossan.SSHConnection;
            if ~isempty(ssh) && ~isvalid(ssh)
                ssh = opencossan.highperformancecomputing.SSHConnection();
                cossan.SSHConnection = ssh;
            end
        end
        
        function driver = getDatabaseDriver()
            driver = opencossan.OpenCossan.getInstance().DatabaseDriver;
        end
        
        function setSSHConnection(ssh)
            cossan = opencossan.OpenCossan.getInstance();
            cossan.SSHConnection = ssh;
        end
        
        function path = getWorkingPath()
            path = opencossan.OpenCossan.getInstance().Analysis.WorkingPath;
        end
        
        function setWorkingPath(path)
            cossan = opencossan.OpenCossan.getInstance();
            cossan.Analysis.WorkingPath = path;
        end
        
        function setDatabaseDriver(driver)
            cossan = opencossan.OpenCossan.getInstance();
            cossan.DatabaseDriver = driver;
        end
        
        function timer = getTimer()
            timer = opencossan.OpenCossan.getInstance().Analysis.Timer;
        end
        
        function root = getRoot()
            %GETCOSSANROOT Return the path of the OpenCossan
            %installation
            
            root = opencossan.OpenCossan.getInstance().Root;
        end
        
        function level = getVerbosityLevel()
            level = opencossan.OpenCossan.getInstance().VerboseLevel;
        end
        
        function setVerbosityLevel(level)
            cossan = opencossan.OpenCossan.getInstance();
            cossan.VerboseLevel = level;
        end
        
        
        createStartupFile();                % Create startup file
        cossanDisp(Smessage,Nlevel);        % Control cossan output
        
        reset;                              % clear workspace, close files and figures and reset Timer
        resetRandomNumberGenerator(Nseed)   % This method reset the seed and the algotithm of the random number generator
        validateCossanInputs(varargin);     % method used to enforce the name convenction in the arguments
        printLogo;                          % Print OpenCossan logo
        
        function user = getUserName()
            if isunix || ismac
                % get the user name from the unix command line
                [~, user] = system('whoami');
                user = user(1:end-1); % remove the last character (it's a new line)
            else
                % get the user name from the windows command line
                user = getenv('USERNAME');
            end
        end
        
        function status = isKilled()
            cossan = opencossan.OpenCossan.getInstance();
            status = isfile(fullfile(cossan.getWorkingPath,...
                cossan.KillFileName));
        end
    end
    
end

function shouldBeDirectory(CdirPath)
warning('off','backtrace')
if isempty(CdirPath), return, end

if iscell(CdirPath)
    for n=1:length(CdirPath)
        if ~isdir(CdirPath{n})
            warning('OpenCossan:pathNotValid',...
                ['The provided path (%s) is not valid.\n' ...
                'Some of the methods and tools of OpenCossan might not be available.\n'], ...
                CdirPath{n});
        end
    end
else
    if ~isdir(CdirPath)
        warning('OpenCossan:pathNotValid',...
            ['The provided path (%s) is not valid.\n' ...
            'Some of the methods and tools of OpenCossan might not be available.\n'], ...
            CdirPath);
    end
end
warning('on','backtrace')
end



