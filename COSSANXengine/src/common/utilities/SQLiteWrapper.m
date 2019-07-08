% Class for querying a SQLite database. This is a Java ODBC wrapper.
% Based on MySQLDatabase, by Jonathan Karr
%
%   Provides methods:
%   - SQLiteDatabase:   Create a database thisect
%   - prepareStatement: Create an SQL statement
%   - query:            Query the database
%   - lastInsertID:     Optionally return the last generated primary key
%   - close:            Close the connection to the database when done.
%
%   prepareStatement syntax is the same as mym, that is the placeholders "{S}", "{Si}",
%   "{Sn}", "{F}", and "{uF}" are replaced by the contents of varargin, eg.
%     sql='SELECT * FROM table where id="{Si}" and type="{S}"'
%     varargin{1}=1;
%     varargin{2}='text';
%   will be evaluated as 
%     SELECT * FROM table where id=1 && type='text'
%  
%   "{S}"  placeholder is for strings
%   "{Si}" placeholder is for integers
%   "{Sn}" placeholder is for floats
%   "{F}", "{uF}" are synonymous placeholders for binary files, that is
%     the varargin element should be a filename and the placeholder will be
%     replaced with the contents of the file of the name equal to the
%     corresponding varargin element
%
%   query returns data as struct with field names equal to the mysql result
%   set column names. The fields of the struct will be MATLAB (cell)arrays
%   with length the number of returned records.
%
% Requires SQLite JDBC connector:
% - http://www.xerial.org/trac/Xerial/wiki/SQLiteJDBC
%
% Author: Matteo Broggi, mbroggi@liverpool.ac.uk
% Affilitation: Virtual Engineering Centre, School of Engineering, University of Liverpool
% Last updated: 12/06/2012
classdef SQLiteWrapper < JDBCWrapper
    properties
        dbConn                 %The Java database connection
    end
    
    properties (SetAccess = protected)
        hostName               %The database host
        schema                 %The schema to use (test7, ims, etc....)
        userName               %The userName for the database
        password               %The database password
        sqlStatement           %Holds the current sql statement
        sqlStatementStreams    %Holds streams for the current sql statement
        data                   %Holds the returned result, -1 for error message update
        dataColumnNames        %Holds the real column names of the returned result, -1 for error message update
        errorMsg               %This holds the last generated error message
        nullValue              %null value
    end
    
    methods
        % Constructor
        function this = SQLiteWrapper(varargin)
            this = this@JDBCWrapper(varargin{:});
            this.nullValue = 0;
            this.open();
            this.close();
        end
        
        function prepareStatement(this, sql, varargin)
            %format query according to mym syntax, see mym for details
            [startIndex, tokenStr] = regexp(sql, '"{(S|Sn|Si|M|B|F|uF)}"', 'start', 'tokens');
            sql = regexprep(sql, '"{(S|Sn|Si|M|B|F|uF)}"', '?');
            
            this.closeStreams();
            % check if the connection is closed
            if this.dbConn.isClosed
                this.reopen();
            end
            this.sqlStatement = this.dbConn.prepareStatement(sql);
            this.sqlStatementStreams = cell(length(startIndex), 1);
            
            for i = 1:length(startIndex)
                switch tokenStr{i}{1}
                    case 'S',     this.sqlStatement.setString(i, java.lang.String(varargin{i}));
                    case 'Sn',    this.sqlStatement.setDouble(i, varargin{i});
                    case 'Si',    this.sqlStatement.setLong(i, varargin{i});
                    case 'M',     throw(MException('Database:unsupportedType', tokenStr{i}{1}));
                    case 'B',     throw(MException('Database:unsupportedType', tokenStr{i}{1}));
                    case {'F', 'uF'},
                        % this read a file binary content into a binary
                        % stream. We do it with matlab IO instead of java
                        % IO (as done in the original MySQLDatabase),
                        % because java needs an array of byte written by
                        % reference (not supported in matlab!)
                        fid = fopen(varargin{i});
                        assert(fid~=-1,'SQLiteWrapper:unexistingfile',...
                            ['File ' varargin{i} ' does not exist.']);                            
                        bytes = fread(fid,inf,'uint8=>uint8');
                        this.sqlStatement.setBytes(i, bytes);
                        fclose(fid);
                end
            end
        end
                
        function [out, columnNames] = query(this)
            % return 0 for 'ok', a positive number for an
            % 'auto_insert_id()', or a -1 to indicate an error and that the
            % user should check the error message for details.
            
            % check if the connection is closed
            if this.dbConn.isClosed
                this.reopen();
            end
            try
                this.sqlStatement.execute();
                
            catch exception
                tmperrormsg = char(exception.message);
                % If it's a recognised error:
                if ~isempty(strfind(tmperrormsg, 'Duplicate entry'))
                    this.errorMsg = tmperrormsg;
                    this.data = -1;                    
                    this.dataColumnNames = -1;
                    out = this.data;
                    columnNames = this.dataColumnNames;
                    return;
                end
                % if it's an unrecognised error then:
                throw(MException('SQLiteDatabase:sqliteError', ...
                    sprintf('%s\n%s', char(this.sqlStatement.toString()), char(exception.message))));
            end
            
            %close streams
            this.closeStreams();
            
            try
                resultSet = this.sqlStatement.getResultSet();
            catch ME
                % with SQLite, when query returns no stream, an error is
                % given instead of an empty stream. Here, the error is
                % parsed to see if no result are returned.
                if ~isempty(regexpi(ME.message,' no ResultSet available'))
                    % If no result is returned, set the data to empty
                    this.data = [];
                    this.dataColumnNames = {};
                    out = this.data;
                    columnNames = this.dataColumnNames;
                    return;
                else
                    rethrow(ME)
                end
            end
            
            columnTypes = cell(resultSet.getColumnCount(), 1); 
            for i = 1:resultSet.getColumnCount()   
                columnTypes{i} = char(resultSet.getColumnTypeName(i));
            end
            this.data = struct;
            this.dataColumnNames = cell(resultSet.getColumnCount(), 1);            
            
            for i = 1:resultSet.getColumnCount()                
                this.dataColumnNames{i} = char(resultSet.getColumnLabel(i));
                fieldName = this.getValidFieldName(char(resultSet.getColumnLabel(i)));                
                switch upper(columnTypes{i})
                    case 'NULL'        
                        this.data.(fieldName) = cell(0, 1);
                    case 'INTEGER'
                        this.data.(fieldName) = zeros(0, 1, 'double');
                    case 'REAL'
                        this.data.(fieldName) = zeros(0, 1, 'double');
                    case 'DATE',
                        % what about dates? SQLite saves them as string,
                        % real or integer (see
                        % http://www.sqlite.org/datatype3.html)
                        this.data.(fieldName) = cell(0, 1);
                    case 'BLOB',
                        this.data.(fieldName) = cell(0, 1);
                    case 'TEXT',
                        this.data.(fieldName) = cell(0, 1);
                    otherwise,
                        this.data.(fieldName) = zeros(0, 1, 'double');
                end
            end
            
            j = 0;
            while resultSet.next()
                j = j + 1;
                for i = 1:resultSet.getColumnCount()
                    fieldName = this.getValidFieldName(char(resultSet.getColumnLabel(i)));
                    
                    switch upper(columnTypes{i})
                        case 'NULL',
                            this.data.(fieldName){j, 1} = [];
                        case 'INTEGER',
                            this.data.(fieldName)(j, 1) = double(resultSet.getInt(i));
                            if resultSet.wasNull()
                                this.data.(fieldName)(j, 1) = double(this.nullValue);
                            elseif isempty(this.data.(fieldName)(j, 1))
                                throw(MException('SQLiteDatabase:earlyNullTermination', columnTypes{i}{1}))
                            end
                        case 'REAL',
                            this.data.(fieldName)(j, 1) = double(resultSet.getInt(i));
                            if resultSet.wasNull()
                                this.data.(fieldName)(j, 1) = double(this.nullValue);
                            elseif isempty(this.data.(fieldName)(j, 1))
                                throw(MException('SQLiteDatabase:earlyNullTermination', columnTypes{i}{1}))
                            end
                        case 'DATE',
                            if resultSet.getInt(i)
                                this.data.(fieldName){j, 1} = char(resultSet.getDate(i));
                            else
                                this.data.(fieldName){j, 1} = '0000-00-00';
                            end
                            if resultSet.wasNull()
                                this.data.(fieldName){j, 1} = '';
                            elseif isempty(this.data.(fieldName){j, 1})
                                throw(MException('SQLiteDatabase:earlyNullTermination', columnTypes{i}{1}))
                            end
                        case 'BLOB'
                            this.data.(fieldName){j, 1} = this.castBytes(resultSet.getBytes(i));
                        case 'TEXT'
                            this.data.(fieldName){j, 1} = char(resultSet.getString(i));
                            if resultSet.wasNull()
                                this.data.(fieldName){j, 1} = '';
                            elseif isempty(this.data.(fieldName){j, 1})
                                this.data.(fieldName){j, 1} = char(this.castBytes(resultSet.getBytes(i)));
                            end
                        otherwise
                            this.data.(fieldName)(j, 1) = double(resultSet.getDouble(i));
                            if resultSet.wasNull()
                                this.data.(fieldName)(j, 1) = double(this.nullValue);
                            elseif isempty(this.data.(fieldName)(j, 1))
                                throw(MException('SQLiteDatabase:earlyNullTermination', columnTypes{i}{1}))
                            end
                    end
                    
                    if      iscell(this.data.(fieldName)) && ...
                            isempty(this.data.(fieldName){j, 1}) && ...
                            any(size(this.data.(fieldName){j, 1}))
                        this.data.(fieldName){j, 1} = '';
                    end
                end
                
            end
            
            resultSet.close();
            out = this.data;
            columnNames = this.dataColumnNames;
            this.close();
        end

        function open(this)
            try
                % no need to use an additional wrapper with these commands
                properties = java.util.Properties();
                driver = javaObjectEDT('org.sqlite.JDBC');
                urlString = fullfile(this.hostName,this.schema);
                if ~isempty(urlString)
                    if ~exist(urlString,'file')
                        warning('SQLiteDatabase:FileNotExist',...
                            'SQLite Database file %s does not exist. It will be created.',urlString)
                    end
                    % check for absolute path usage and construct url
                    if ispc
                        assert(strcmp(this.hostName(2),':') || ...
                            strcmp(this.hostName(1:2),'\\'),...
                            'SQLiteDatabase:RelativePath',...
                            'SQLite Database file is not in an absolute path')
                        % find the \ and substitute with /
                        urlString = strrep(urlString,'\','/');
                    elseif isunix
                        assert(strcmp(this.hostName(1),'/'),...
                            'SQLiteDatabase:RelativePath',...
                            'SQLite Database file is not in an absolute path')
                        % add a / to make the url
                        urlString = ['/' urlString];
                    end
                else
                    warning('SQLiteDatabase:MemoryBatabase',...
                            'SQLite is using memory Database. All the DB entries will be lost when you close COSSAN. \nUse this only for testing!')
                end
                url = ['jdbc:sqlite:' urlString];
                this.dbConn = driver.connect(url,properties);
            catch exception
                throw(MException('SQLiteDatabase:sqliteError', char(exception.message)));
            end
        end

    end
end