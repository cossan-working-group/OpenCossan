classdef CodeInfoProvider
    %CODEINFOPROVIDER Provides convenience methods do gather info about
    %code from files.
    
    methods
        function [ code ] = readCode(~,fileName)
            %READCODE Return lines of code of a file as a cell array.
            %   CODE = readCode(FILENAME) returns the lines of the file FILENAME as
            %   a cell array.
            %
            %   See also REGEXP, FILEREAD
            code = regexp(fileread(fileName), '(\r\n|\n|\r)', 'split');
        end
        
        function runnable = getRunnableLines(~,fileName)
            %GETRUNNABLELINES Return executable lines in a file.
            %   RUNNABLE = getRunnableLines(FILENAME)
            runnable = unique(callstats('file_lines', fileName));
        end
        
        function fileName = getFunctionFile(~, packageName, functionName)
            %GETFUNCTIONFILE Return the file containing the function.
            %   FILENAME = getFunctionFile(PACKAGENAME,FUNCTIONNAME)
            fileName = which([packageName '.' functionName]);
        end
        
        function file = getClassFile(~, fileName)
            %GETCLASSFILE Return the full file name.
            %   FILENAME = getClassFile(FILENAME)
            file = which(fileName);
        end
        
        function callInfo = getCallInfo(~,fileName)
            %GETCALLINFO Return callinfo for file.
            %   CALLINFO = getCallInfo(FILENAME)
            callInfo = getcallinfo(fileName);
        end
        
        function exists = exists(~, fileName)
            %EXISTS Checks if a file exists
            % EXISTS = exists(FILENAME)
            exists = isfile(fileName);
        end
    end
end

