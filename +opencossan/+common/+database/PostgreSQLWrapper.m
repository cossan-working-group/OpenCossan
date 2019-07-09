% Class for querying a PostgreSQL database. This is a Java ODBC wrapper.
%
%   Provides methods:
%   - PostgreSQLWrapper:    Create a database thisect
%   - prepareStatement: Create an SQL statement
%   - query:            Query the database
%   - lastInsertID:     Optionally return the last generated primary key
%   - close:            Close the connection to the database when done.
% 
%   Example usage
%   > db = PostgreSQLWrapper(hostName, schema, userName, password);
%   > db.setNullValue(nullValue);
%   > db.prepareStatement(sql);
%   > data = db.query();
%   > db.close();
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
% Requires mysql connector J:
% - http://www.etf-central.com/using-matlab%2526%2523039%3Bs-database-toolbox-mysql-connector/j-214
% - http://www.mysql.com/products/connector/
% - http://neumann.bsn.com/doc/mysql-connector-java/javadoc/com/mysql/jdbc/package-summary.html
%
% Author: Jonathan Karr, jkarr@stanford.edu
% Author: Alex Harper, aharper@guralp.com
% Affilitation: Covert Lab, Department of Bioengineering, Stanford University
%
% Modified (heavily, to adapt to openCOSSAN) by: Matteo Broggi, mbroggi@liverpool.ac.uk
% Affiliation: University of Liverpool
% Last updated: 6/13/2012
classdef PostgreSQLWrapper < opencossan.common.database.JDBCWrapper
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
        function this = PostgreSQLWrapper(varargin)
            this = this@opencossan.common.database.JDBCWrapper(varargin{:});
            this.nullValue = 0;
            this.open();   
        end
        
        function prepareStatement(this, sql, varargin)
            %format query according to mym syntax, see mym for details
            [startIndex, tokenStr] = regexp(sql, '"{(S|Sn|Si|M|B|F|uF)}"', 'start', 'tokens');
            sql = regexprep(sql, '"{(S|Sn|Si|M|B|F|uF)}"', '?');
            
            this.closeStreams();
            this.sqlStatement = this.dbConn.prepareStatement(sql);
            this.sqlStatementStreams = cell(length(startIndex), 1);
            
            for i = 1:length(startIndex)
                switch tokenStr{i}{1}
                    case 'S',     this.sqlStatement.setString(i, java.lang.String(varargin{i}));
                    case 'Sn',    this.sqlStatement.setDouble(i, varargin{i});
                    case 'Si',    this.sqlStatement.setLong(i, varargin{i});
                    case 'M',     throw(MException('PostgreSQLDatabase:unsupportedType', tokenStr{i}{1}));
                    case 'B',     throw(MException('PostgreSQLDatabase:unsupportedType', tokenStr{i}{1}));
                    case {'F', 'uF'},
                        this.sqlStatementStreams{i} = java.io.FileInputStream(varargin{i});
                        this.sqlStatement.setBinaryStream(i, this.sqlStatementStreams{i});
                end
            end
        end
        
        function [out, columnNames] = query(this)
            % return 0 for 'ok', a positive number for an
            % 'auto_insert_id()', or a -1 to indicate an error and that the
            % user should check the error message for details.
            
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
                throw(MException('PostgreSQLDatabase:mysqlError', ...
                    sprintf('%s\n%s', char(this.sqlStatement.toString()), char(exception.message))));
            end
            
            %close streams
            this.closeStreams();
            
            resultSet = this.sqlStatement.getResultSet();
            % If the result set is empty, return an empty set.
            if isempty(resultSet)
                this.data = [];
                this.dataColumnNames = {};
                out = this.data;
                columnNames = this.dataColumnNames;
                return;
            end
            
            metaData = resultSet.getMetaData();
            columnTypes=cell(metaData.getColumnCount(), 1);
            for i=1:metaData.getColumnCount()
                columnTypes{i}=char(metaData.getColumnTypeName(i));
            end            
            this.data = struct;
            this.dataColumnNames = cell(metaData.getColumnCount(), 1);            
            
            for i = 1:metaData.getColumnCount()                
                this.dataColumnNames{i} = char(metaData.getColumnLabel(i));
                fieldName = this.getValidFieldName(char(metaData.getColumnLabel(i)));                
                switch columnTypes{i}
                    
                    case 'FIELD_TYPE_NULL',        this.data.(fieldName) = cell(0, 1);
                    case 'FIELD_TYPE_TINY',        this.data.(fieldName) = zeros(0, 1, 'double');
                    case 'FIELD_TYPE_SHORT',       this.data.(fieldName) = zeros(0, 1, 'double');
                    case 'FIELD_TYPE_INT24',       this.data.(fieldName) = zeros(0, 1, 'double');
                    case 'FIELD_TYPE_LONG',        this.data.(fieldName) = zeros(0, 1, 'double');
                    case 'FIELD_TYPE_LONGLONG',    this.data.(fieldName) = zeros(0, 1, 'double');
                    case 'FIELD_TYPE_DECIMAL',     this.data.(fieldName) = zeros(0, 1, 'double');
                    case 'FIELD_TYPE_FLOAT',       this.data.(fieldName) = zeros(0, 1, 'double');
                    case 'FIELD_TYPE_DOUBLE',      this.data.(fieldName) = zeros(0, 1, 'double');
                    case 'FIELD_TYPE_YEAR',        this.data.(fieldName) = zeros(0, 1, 'double');
                    case 'FIELD_TYPE_TIMESTAMP',   this.data.(fieldName) = cell(0, 1);
                    case 'FIELD_TYPE_DATE',        this.data.(fieldName) = cell(0, 1);
                    case 'FIELD_TYPE_TIME',        this.data.(fieldName) = cell(0, 1);
                    case 'FIELD_TYPE_DATETIME',    this.data.(fieldName) = cell(0, 1);
                    case 'FIELD_TYPE_NEWDATE',     throw(MException('PostgreSQLDatabase:unsupportedType', columnTypes{i}{1}))
                    case 'FIELD_TYPE_ENUM',        this.data.(fieldName) = char(resultSet.getString(i));
                    case 'FIELD_TYPE_SET',         this.data.(fieldName) = cell(0, 1);
                    case 'FIELD_TYPE_TINY_BLOB',   this.data.(fieldName) = cell(0, 1);
                    case 'FIELD_TYPE_MEDIUM_BLOB', this.data.(fieldName) = cell(0, 1);
                    case 'FIELD_TYPE_LONG_BLOB',   this.data.(fieldName) = cell(0, 1);
                    case 'FIELD_TYPE_BLOB',        this.data.(fieldName) = cell(0, 1);
                    case 'FIELD_TYPE_VAR_STRING',  this.data.(fieldName) = cell(0, 1);
                    case 'varchar',      this.data.(fieldName) = cell(0, 1);
                    case 'FIELD_TYPE_GEOMETRY',    throw(MException('PostgreSQLDatabase:unsupportedType', columnTypes{i}{1}))
                    otherwise,                     this.data.(fieldName) = zeros(0, 1, 'double');
                end
            end
            
            j = 0;
            while resultSet.next()
                j = j + 1;
                for i = 1:metaData.getColumnCount()
                    fieldName = this.getValidFieldName(char(metaData.getColumnLabel(i)));
                    
                    switch columnTypes{i}
                        case 'FIELD_TYPE_NULL',
                            this.data.(fieldName){j, 1} = [];
                        case 'FIELD_TYPE_TINY',
                            this.data.(fieldName)(j, 1) = double(resultSet.getInt(i));
                            if resultSet.wasNull()
                                this.data.(fieldName)(j, 1) = double(this.nullValue);
                            elseif isempty(this.data.(fieldName)(j, 1))
                                throw(MException('PostgreSQLDatabase:earlyNullTermination', columnTypes{i}{1}))
                            end
                        case 'FIELD_TYPE_SHORT',
                            this.data.(fieldName)(j, 1) = double(resultSet.getShort(i));
                            if resultSet.wasNull()
                                this.data.(fieldName)(j, 1) = double(this.nullValue);
                            elseif isempty(this.data.(fieldName)(j, 1))
                                throw(MException('PostgreSQLDatabase:earlyNullTermination', columnTypes{i}{1}))
                            end
                        case 'FIELD_TYPE_INT24',
                            this.data.(fieldName)(j, 1) = double(resultSet.getInt(i));
                            if resultSet.wasNull()
                                this.data.(fieldName)(j, 1) = double(this.nullValue);
                            elseif isempty(this.data.(fieldName)(j, 1))
                                throw(MException('PostgreSQLDatabase:earlyNullTermination', columnTypes{i}{1}))
                            end
                        case 'FIELD_TYPE_LONG',
                            this.data.(fieldName)(j, 1) = double(resultSet.getInt(i));
                            if resultSet.wasNull()
                                this.data.(fieldName)(j, 1) = double(this.nullValue);
                            elseif isempty(this.data.(fieldName)(j, 1))
                                throw(MException('PostgreSQLDatabase:earlyNullTermination', columnTypes{i}{1}))
                            end
                        case 'FIELD_TYPE_LONGLONG',
                            this.data.(fieldName)(j, 1) = double(resultSet.getLong(i));
                            if resultSet.wasNull()
                                this.data.(fieldName)(j, 1) = double(this.nullValue);
                            elseif isempty(this.data.(fieldName)(j, 1))
                                throw(MException('PostgreSQLDatabase:earlyNullTermination', columnTypes{i}{1}))
                            end
                        case 'FIELD_TYPE_DECIMAL',
                            this.data.(fieldName)(j, 1) = double(resultSet.getFloat(i));
                            if resultSet.wasNull()
                                this.data.(fieldName)(j, 1) = double(this.nullValue);
                            elseif isempty(this.data.(fieldName)(j, 1))
                                throw(MException('PostgreSQLDatabase:earlyNullTermination', columnTypes{i}{1}))
                            end
                        case 'FIELD_TYPE_FLOAT',
                            this.data.(fieldName)(j, 1) = double(resultSet.getFloat(i));
                            if resultSet.wasNull()
                                this.data.(fieldName)(j, 1) = double(this.nullValue);
                            elseif isempty(this.data.(fieldName)(j, 1))
                                throw(MException('PostgreSQLDatabase:earlyNullTermination', columnTypes{i}{1}))
                            end
                        case 'FIELD_TYPE_DOUBLE',
                            this.data.(fieldName)(j, 1) = double(resultSet.getDouble(i));
                            if resultSet.wasNull()
                                this.data.(fieldName)(j, 1) = double(this.nullValue);
                            elseif isempty(this.data.(fieldName)(j, 1))
                                throw(MException('PostgreSQLDatabase:earlyNullTermination', columnTypes{i}{1}))
                            end
                        case 'FIELD_TYPE_YEAR',
                            this.data.(fieldName)(j, 1) = double(resultSet.getShort(i));
                            if resultSet.wasNull()
                                this.data.(fieldName)(j, 1) = double(this.nullValue);
                            elseif isempty(this.data.(fieldName)(j, 1))
                                throw(MException('PostgreSQLDatabase:earlyNullTermination', columnTypes{i}{1}))
                            end
                        case 'FIELD_TYPE_TIMESTAMP',
                            this.data.(fieldName){j, 1} = char(resultSet.getString(i));
                            if resultSet.wasNull()
                                this.data.(fieldName){j, 1} = '';
                            elseif isempty(this.data.(fieldName){j, 1})
                                throw(MException('PostgreSQLDatabase:earlyNullTermination', columnTypes{i}{1}))
                            end
                        case 'FIELD_TYPE_DATE',
                            if resultSet.getInt(i)
                                this.data.(fieldName){j, 1} = char(resultSet.getDate(i));
                            else
                                this.data.(fieldName){j, 1} = '0000-00-00';
                            end
                            if resultSet.wasNull()
                                this.data.(fieldName){j, 1} = '';
                            elseif isempty(this.data.(fieldName){j, 1})
                                throw(MException('PostgreSQLDatabase:earlyNullTermination', columnTypes{i}{1}))
                            end
                        case 'FIELD_TYPE_TIME',
                            this.data.(fieldName){j, 1} = char(resultSet.getTime(i));
                            if resultSet.wasNull()
                                this.data.(fieldName){j, 1} = '';
                            elseif isempty(this.data.(fieldName){j, 1})
                                throw(MException('PostgreSQLDatabase:earlyNullTermination', columnTypes{i}{1}))
                            end
                        case 'FIELD_TYPE_DATETIME',
                            if resultSet.getInt(i)
                                this.data.(fieldName){j, 1} = [char(resultSet.getDate(i)) ' ' char(resultSet.getTime(i))];
                            else
                                this.data.(fieldName){j, 1} = '0000-00-00 00:00:00';
                            end                            
                            if resultSet.wasNull()
                                this.data.(fieldName){j, 1} = '';
                            elseif isempty(this.data.(fieldName){j, 1})
                                throw(MException('PostgreSQLDatabase:earlyNullTermination', columnTypes{i}{1}))
                            end
                        case 'FIELD_TYPE_ENUM',
                            this.data.(fieldName){j, 1} = char(resultSet.getString(i));
                            if resultSet.wasNull()
                                this.data.(fieldName){j, 1} = '';
                            elseif isempty(this.data.(fieldName){j, 1})
                                throw(MException('PostgreSQLDatabase:earlyNullTermination', columnTypes{i}{1}))
                            end
                        case 'FIELD_TYPE_SET',
                            this.data.(fieldName){j, 1} = char(resultSet.getString(i));
                            if resultSet.wasNull()
                                this.data.(fieldName){j, 1} = '';
                            elseif isempty(this.data.(fieldName){j, 1})
                                throw(MException('PostgreSQLDatabase:earlyNullTermination', columnTypes{i}{1}))
                            end
                        case {'FIELD_TYPE_TINY_BLOB', 'FIELD_TYPE_MEDIUM_BLOB', 'FIELD_TYPE_LONG_BLOB', 'FIELD_TYPE_BLOB'}
                            this.data.(fieldName){j, 1} = this.castBytes(resultSet.getBytes(i));
                        case {'FIELD_TYPE_VAR_STRING','FIELD_TYPE_STRING','varchar'}
                            this.data.(fieldName){j, 1} = char(resultSet.getString(i));
                            if resultSet.wasNull()
                                this.data.(fieldName){j, 1} = '';
                            elseif isempty(this.data.(fieldName){j, 1})
                                this.data.(fieldName){j, 1} = char(this.castBytes(resultSet.getBytes(i)));
                            end
                        case {'FIELD_TYPE_GEOMETRY', 'FIELD_TYPE_NEWDATE'}
                            throw(MException('PostgreSQLDatabase:unsupportedType', columnTypes{i}{1}))
                        otherwise
                            this.data.(fieldName)(j, 1) = double(resultSet.getDouble(i));
                            if resultSet.wasNull()
                                this.data.(fieldName)(j, 1) = double(this.nullValue);
                            elseif isempty(this.data.(fieldName)(j, 1))
                                throw(MException('PostgreSQLDatabase:earlyNullTermination', columnTypes{i}{1}))
                            end
                    end
                    
                    if      iscell(this.data.(fieldName)) && ...
                            isempty(this.data.(fieldName){j, 1}) && ...
                            any(size(this.data.(fieldName){j, 1}))
                        this.data.(fieldName){j, 1} = '';
                    end
                end
                
                if ~resultSet.next()
                    break;
                end
            end
            
            resultSet.close();
            out = this.data;
            columnNames = this.dataColumnNames;
        end

        function open(this)
            try
                % modified by Matteo Broggi
                % No need to use an additional java wrapper with these
                % commands
                properties = java.util.Properties();
                properties.setProperty('user',this.userName);
                properties.setProperty('password',this.password);
                driver = javaObjectEDT('org.postgresql.Driver');
                url = ['jdbc:postgresql://' this.hostName '/' this.schema];
                this.dbConn = driver.connect(url,properties);
            catch exception
                throw(MException('PostgreSQLDatabase:postgresqlError', char(exception.message)));
            end
        end
        
    end

end
