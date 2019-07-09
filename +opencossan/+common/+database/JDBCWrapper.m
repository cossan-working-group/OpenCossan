% Interface for connecting a database
%
% Author: Jonathan Karr
% Affilitation: Covert Lab, Department of Bioengineering, Stanford University
% Last updated: 1/21/2011
classdef JDBCWrapper < handle
    
    properties (Abstract = true, SetAccess = protected)
        hostName
        schema
        userName
        password    
        sqlStatement
        sqlStatementStreams
        data
        dataColumnNames
        errorMsg
    end

    methods
        function this = JDBCWrapper(varargin)
            switch nargin 
                case 1
                    this.hostName = varargin{1}.hostName;
                    this.schema = varargin{1}.schema;
                    this.userName = varargin{1}.userName;
                    this.password = varargin{1}.password;
                case 4
                    this.hostName = varargin{1};
                    this.schema = varargin{2};
                    this.userName = varargin{3};
                    this.password = varargin{4};
                otherwise
                    throw(MException('Database:error', 'invalid options'));
            end                    
        end
                
        function close(this)
            if ~isempty(this.sqlStatement)
                this.sqlStatement.close();
            end
            this.dbConn.close();
        end
        
        function delete(this)
            this.close();
        end
        
        function reopen(this)
            this.close();
            this.open();
        end
        
        function out = lastInsertID(this)
            stmt = this.dbConn.createStatement();
            rs = stmt.executeQuery('SELECT LAST_INSERT_ID()');
            if rs.next()
                this.data = double(rs.getInt(1));
                out = this.data;
            end
            rs.close();
        end
        
        function setNullValue(this, value)
            this.nullValue = value;
        end
        
        function varargout = exec(this,Squery)
            this.prepareStatement(Squery);
            results = this.query();
            if isempty(results)
                return
            else
                varargout{1} = results;
            end
        end
    end

    methods (Abstract = true)
        prepareStatement(this, sql, varargin)
        result = query(this)
    end    
    
    methods (Access = protected)           
        function closeStreams(this)
            for i = 1:numel(this.sqlStatementStreams)
                if ~isempty(this.sqlStatementStreams{i})
                    stream = this.sqlStatementStreams{i};
                    stream.close;
                end
            end
            this.sqlStatementStreams = {};
        end
        
        function dataOut = castBytes(~, dataIn)
            dataIn = int16(dataIn');
            dataOut = repmat(uint8(1), 1, length(dataIn));
            for v = 1:length(dataIn)
                if dataIn(v)<0
                    dataOut(v) = uint8(dataIn(v) + 256);
                else
                    dataOut(v) = uint8(dataIn(v));
                end
            end
        end
        
        function fieldName = getValidFieldName(~, fieldName)
            upperFieldName = upper(fieldName);
            if upperFieldName(1) >= 'A' && upperFieldName(1) <= 'Z' && all(ismembc(upperFieldName, char([48:57 65:90 95])))
                return;
            end
            fieldName = regexprep(fieldName, '[^a-zA-Z0-9_]', '_');
            upperFieldName = upper(fieldName);
            if upperFieldName(1) < 'A' || upperFieldName(1) > 'Z'
                fieldName = ['col_' fieldName];
            end
        end
     end
end