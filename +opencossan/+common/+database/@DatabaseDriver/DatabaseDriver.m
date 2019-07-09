classdef DatabaseDriver < handle
    % DATABASEDRIVER Definition of the class DatabaseDriver
    % The class DatabaseDriver is used to connect to a database and store
    % the input and the results of the simulation or of the execution of
    % third party solvers.
    %
    % See also: https://cossan.co.uk/wiki/index.php/@DatabaseDriver
    %
    % Author: Matteo Broggi and Edoardo Patelli
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
        Sdescription
        SdatabaseName % the name of the databse (SQLite: db file name)
        SdatabaseURL  % the JDBC URL pointing to the db, e.g. jdbc:mysql://devmetrics.mrkps.com/testing, jdbc:sqlite:C:/path/dbname
        SuserName     % the user name of the database user
        Spassword     % the password SAFETY PROBLEM: it must be clear!!!
        SjdbcDriver   % the java class for JDBC connection.
        XdatabaseConnection
    end
    
    properties (Constant)        
        CcolnamesAnalysis = {'Analysis_ID',... primary key of the table
            'Project_Name','Analysis_Name','Owner','Description',...
            'TimeStamp'};
        
        CcolnamesSolver={'Solver_ID',... primary key of the table
            'Analysis_ID',... foreign key to  table
            'Simulation_Number','SimulationData_object',...
            'Solver_Execution_Status','Output_Extraction_Status',...
            'Simulation_Folder',...
            'TimeStamp'};
        
        CcolnamesSimulation={'Simulation_ID',... primary key of the table
            'Analysis_ID',... foreign key to  table
            'Batch_Number','SimulationData_object','Cossan_objects',...
            'TimeStamp'};
        
        CcolnamesResult={'Result_ID',... primary key of the table
            'Analysis_ID',... foreign key to  table
            'Engine_outputs',...
            'TimeStamp'};
        
        CtableTypes={'Analysis','Solver','Simulation','Result'}
        SmatlabBinaryName = 'simData.mat';

    end
    
    properties (Dependent)
        CcoltypesAnalysis
        CcoltypesSolver
        CcoltypesSimulation
        CcoltypesResult
        ShostName     % hostname of the database server (SQLite: db directory)
    end
    
    methods
        function Xobj = DatabaseDriver(varargin)
            % See also: https://cossan.co.uk/wiki/index.php/@DatabaseDriver
            %
            % Author: Matteo Broggi and Edoardo Patelli
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

            %% Process inputs
            opencossan.OpenCossan.validateCossanInputs(varargin{:})
            
            if nargin==0
                return
            end
            
            %% Get DatabaseDriver from OpenCossan
            if isa(opencossan.OpenCossan.getDatabaseDriver,'DatabaseDriver')
                Xobj=opencossan.OpenCossan.getDatabaseDriver;
            end
            
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case {'sdescription'}
                        Xobj.Sdescription=varargin{k+1};
                    case {'sdatabaseurl'}
                        Xobj.SdatabaseURL=varargin{k+1};
                    case {'sdatabasename'}
                        Xobj.SdatabaseName=varargin{k+1};
                    case {'susername'}
                        Xobj.SuserName=varargin{k+1};
                    case {'spassword'}
                        Xobj.Spassword=varargin{k+1};
                    case {'sjdbcdriver'}
                        Xobj.SjdbcDriver=varargin{k+1};
                    otherwise
                        error('CossanX:DatabaseDriver',...
                            'PropertyName %s not valid',varargin{k})
                end
            end
            
            %% Connection to simulation database
            switch Xobj.SjdbcDriver
                case 'com.mysql.jdbc.Driver'
                    if isempty(Xobj.Sdescription)
                        Xobj.Sdescription = 'Connection to MySQL';
                    end
                    assert(~isempty(regexpi(Xobj.SdatabaseURL,'jdbc:mysql://')),...
                        'openCOSSAN:DatabaseDriver',...
                        'Wrong database URL! It should be in the form "jdbc:mysql://mysql.server.address:<portnumber>/".')
                    conn = MySQLWrapper(Xobj.ShostName,Xobj.SdatabaseName,...
                        Xobj.SuserName,Xobj.Spassword);
                case 'org.sqlite.JDBC'
                    if isempty(Xobj.Sdescription)
                        Xobj.Sdescription = 'Connection to SQLite';
                    end
                    assert(~isempty(regexpi(Xobj.SdatabaseURL,'jdbc:sqlite:')),...
                        'openCOSSAN:DatabaseDriver',...
                        'Wrong database URL! It should be in the form "jdbc:sqlite:/path/to/db/file".')
                    conn = SQLiteWrapper(Xobj.ShostName,Xobj.SdatabaseName,'','');
                case 'org.postgresql.Driver'
                    if isempty(Xobj.Sdescription)
                        Xobj.Sdescription = 'Connection to PostgreSQL';
                    end
                    conn = PostgreSQLWrapper(Xobj.ShostName,Xobj.SdatabaseName,...
                        Xobj.SuserName,Xobj.Spassword);
                otherwise
                    error('openCOSSAN:DatabaseDriver',...
                        'Unsupported database (%s).',Xobj.SjdbcDriver)
            end
            
            assert(~isempty(conn.dbConn), ...
                'openCOSSAN:DatabaseDriver',...
                'Failed to initialize the simulation database connection.\n')
            
            assert(~isempty(OpenCossan.getProjectName), ...
                'openCOSSAN:DatabaseDriver',['No project name defined in OPENCOSSAN preferences.\n'...
                'The database connection cannot be initialized'])
            
            Xobj.XdatabaseConnection = conn;
            
            
            %% check if the tables exist
            for n=1:length(Xobj.CtableTypes)
                
                if ~Xobj.tableExists(Xobj.CtableTypes{n})
                    OpenCossan.cossanDisp(['Creating Table ' Xobj.CtableTypes{n}],3)
                    Xobj.createTable(Xobj.CtableTypes{n});
                end
            end
                        
            % Add DatabaseDriver to CossanX
            % OpenCossan.setDatabaseDriver(Xobj);
        end
        
        function createTable(Xobj,Stabletype)
            %CREATETABLE create the table for the database of simulations
            % define table columns
            
            assert(~isempty(Stabletype),...
                'openCOSSAN:DatabaseDriver:createTable',...
                'Required input Stabletype missing.')
            
            switch Stabletype
                case 'Analysis'
                    Ccolnames=Xobj.CcolnamesAnalysis;
                    Ccoltypes=Xobj.CcoltypesAnalysis;
                case 'Solver'
                    Ccolnames=Xobj.CcolnamesSolver;
                    Ccoltypes=Xobj.CcoltypesSolver;
                case 'Simulation'
                    Ccolnames=Xobj.CcolnamesSimulation;
                    Ccoltypes=Xobj.CcoltypesSimulation;
                case 'Result'
                    Ccolnames=Xobj.CcolnamesResult;
                    Ccoltypes=Xobj.CcoltypesResult;
                otherwise
                    error('openCOSSAN:DatabaseDriver:createTable',...
                        'Table type %s not valid',Stabletype)
            end
            
            Squery = ['CREATE TABLE ' Stabletype ' ('];
            for i=1:length(Ccolnames)
                Squery = [Squery Ccolnames{i} ' ' Ccoltypes{i} ]; %#ok<*AGROW>
                if i~=length(Ccolnames)
                    Squery = [Squery ', '];
                end
            end
            
            % add the primary key. Given the way we coded cossan, it is 
            % always the first column of the table.
            Squery = [Squery ', PRIMARY KEY (' Ccolnames{1} ')'];
            
            % add the foreign key link if the table is not the main
            % analysis table. Given the way we coded cossan, it is 
            % always the second column of the table.
            if ~strcmpi(Stabletype,'Analysis')
                Squery = [Squery ', FOREIGN KEY (' Ccolnames{2} ') REFERENCES Analysis(Analysis_ID) ON DELETE CASCADE)'];
            else
                Squery = [Squery ')'];
            end
            
            % Run query
            try
                exec(Xobj.XdatabaseConnection, Squery);
                OpenCossan.cossanDisp(['Table ' Stabletype ' created'],3)
            catch ME
                rethrow(ME);
            end
            
        end
        
        function Lexists = tableExists(Xobj,StableName)
            switch Xobj.SjdbcDriver
                case 'com.mysql.jdbc.Driver'
                    SfieldTableName = 'table_name';
                    Squery = ['SELECT ' SfieldTableName ' FROM information_schema.tables '...
                        'WHERE table_schema = ''' Xobj.SdatabaseName ''' '...
                        'AND table_name = ''' StableName ''''];
                case 'org.sqlite.JDBC'
                    SfieldTableName = 'name';
                    Squery = ['SELECT ' SfieldTableName ' FROM sqlite_master '...
                        'WHERE type=''table'' AND name=''' StableName ''''];
                case 'org.postgresql.Driver'
                    SfieldTableName = 'table_name';
                    StableName = lower(StableName); % Postgresql is case-insensitive
                    Squery = ['SELECT ' SfieldTableName ' FROM information_schema.tables '...
                        'WHERE table_schema = ''public''' ...
                        'AND table_name = ''' StableName ''''];
                otherwise
                    error('openCOSSAN:DatabaseDriver','Unsupported database.')
            end
            Tdata = exec(Xobj.XdatabaseConnection,Squery);
            if ~isempty(Tdata.(SfieldTableName)) && ...
                    strcmp(Tdata.(SfieldTableName),StableName)
                Lexists = true;
            else
                Lexists = false;
            end
        end
        
        %% Other methods
        insertRecord(Xobj,varargin) % Method to add record to the DB
        Nid = getNextPrimaryID(Xobj,Stabletype)
        
        function Lempty = isempty(Xobj)
            % check if all the public, non-costant properties of the object
            % are empty
            Lempty = isempty(Xobj.Sdescription) && ...
                isempty(Xobj.SdatabaseName) && ...
                isempty(Xobj.SdatabaseURL) && ...
                isempty(Xobj.SuserName) && ...
                isempty(Xobj.Spassword) && ...
                isempty(Xobj.SjdbcDriver) && ...
                isempty(Xobj.XdatabaseConnection);        
        end
        
        %% Dependent properties get methods
        %% get the column type (dependent from the db used)         
        function CcoltypesAnalysis=get.CcoltypesAnalysis(Xobj)
            switch Xobj.SjdbcDriver
                case 'com.mysql.jdbc.Driver'
                    CcoltypesAnalysis={'int NOT NULL UNIQUE',...
                        'varchar(128)','varchar(128)','varchar(128)','varchar(2048)',...
                        'datetime'};
                case 'org.sqlite.JDBC'
                    CcoltypesAnalysis={'integer NOT NULL UNIQUE',...
                        'varchar(128)','varchar(128)','varchar(128)','varchar(2048)',...
                        'datetime'};
                case'org.postgresql.Driver'
                    CcoltypesAnalysis={'integer NOT NULL UNIQUE',...
                        'varchar(128)','varchar(128)','varchar(128)','varchar(2048)',...
                        'timestamp'};
                otherwise
                    error('openCOSSAN:DatabaseDriver','Unsupported database.')
            end
        end

        function CcoltypesSolver = get.CcoltypesSolver(Xobj)
            % this properties was constant before, however the type
            % definition depends from the database used!
            switch Xobj.SjdbcDriver
                case 'com.mysql.jdbc.Driver'
                    CcoltypesSolver={'int NOT NULL UNIQUE',...
                        'int NOT NULL',... foreign key to Analysis table
                        'int(15)','mediumblob',...
                        'bool','bool','longblob','datetime'};
                case 'org.sqlite.JDBC'
                    CcoltypesSolver={'integer NOT NULL UNIQUE',...
                        'integer NOT NULL',... foreign key to Analysis table
                        'integer','mediumblob',...
                        'bool','bool','longblob','datetime'};
                case 'org.postgresql.Driver'
                    CcoltypesSolver={'integer NOT NULL UNIQUE',...
                        'integer NOT NULL',... foreign key to Analysis table
                        'integer','bytea',...
                        'bool','bool','bytea','timestamp'};
                otherwise
                    error('openCOSSAN:DatabaseDriver','Unsupported database.')
            end
        end
        
        function CcoltypesSimulation = get.CcoltypesSimulation(Xobj)
            % this properties was constant before, however the type
            % definition depends from the database used!
            switch Xobj.SjdbcDriver
                case 'com.mysql.jdbc.Driver'
                    CcoltypesSimulation={'int NOT NULL UNIQUE',...
                        'int NOT NULL',... foreign key to Analysis table
                        'int(15)','mediumblob','mediumblob',...
                        'datetime'};
                case 'org.sqlite.JDBC'
                    CcoltypesSimulation={'integer NOT NULL UNIQUE',...
                        'integer NOT NULL',... foreign key to Analysis table
                        'integer','mediumblob','mediumblob',...
                        'datetime'};
                case'org.postgresql.Driver'
                    CcoltypesSimulation={'integer NOT NULL UNIQUE',...
                        'integer NOT NULL',... foreign key to Analysis table
                        'integer','bytea','bytea',...
                        'timestamp'};
                otherwise
                    error('openCOSSAN:DatabaseDriver','Unsupported database.')
            end
        end
              
        function CcoltypesResult=get.CcoltypesResult(Xobj)
            switch Xobj.SjdbcDriver
                case 'com.mysql.jdbc.Driver'
                    CcoltypesResult={'int NOT NULL UNIQUE',...
                        'int NOT NULL',... foreign key to Analysis table
                        'mediumblob',...
                        'datetime'};
                case 'org.sqlite.JDBC'
                    CcoltypesResult={'integer NOT NULL UNIQUE',...
                        'integer NOT NULL',... foreign key to Analysis table
                        'mediumblob',...
                        'datetime'};
                case'org.postgresql.Driver'
                    CcoltypesResult={'integer NOT NULL UNIQUE',...
                        'integer NOT NULL',... foreign key to Analysis table
                        'bytea',...
                        'timestamp'};
                otherwise
                    error('openCOSSAN:DatabaseDriver','Unsupported database.')
            end
        end
        
        %% get the host name for the connection to the DB server/file
        function ShostName = get.ShostName(Xobj)
            % Retrieve the hostname from the full JDBC URL
            switch Xobj.SjdbcDriver
                case {'com.mysql.jdbc.Driver','org.postgresql.Driver'}
                    % This regexp extract the hostname and the dbname
                    % from a string in the form of  jdbc:mysql://devmetrics.mrkps.com/testing
                    [~,~,~,~,~,~,Csplitstring]=regexpi(Xobj.SdatabaseURL,'/+');
                    ShostName=Csplitstring{2};
                case 'org.sqlite.JDBC'
                    % This regexp extract the file path  and the file name
                    % from a string in the form of
                    % jdbc:sqlite:/path/dbname or jdbc:sqlite:C:/path/dbname
                    [~,~,~,~,~,~,Csplitstring]=regexpi(Xobj.SdatabaseURL,'jdbc:sqlite:');
                    if ispc
                        ShostName = strrep(Csplitstring{2},'/','\');
                    else
                        ShostName = Csplitstring{2};
                    end
                otherwise
                    error('openCOSSAN:DatabaseDriver',...
                        'Unsupported database (%s).',Xobj.SjdbcDriver)
            end
            
        end
    end
    
end

