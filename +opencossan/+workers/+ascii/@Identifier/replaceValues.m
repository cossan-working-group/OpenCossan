function replaceValues(obj,varargin)
%REPLACEVALUES This method replace values in the open file
%
%


%{
This file is part of OpenCossan <https://cossan.co.uk>.
Copyright (C) 2006-2020 COSSAN WORKING GROUP

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

import opencossan.common.utilities.*

%% Process Inputs
required = opencossan.common.utilities.parseRequiredNameValuePairs(...
    ["FileID", "TableInput"], varargin{:});
optional = opencossan.common.utilities.parseOptionalNameValuePairs(...
    ["UseOriginalValues"],{[],[]}, varargin{:});

FileID = required.fileid;
TableInput = required.tableinput;

if ~isempty(optional.useoriginalvalues)
    UseOriginalValues = optional.useoriginalvalues;
else
    UseOriginalValues = false;
end

[filename, permission, machineformat, encoding] = fopen(FileID);
%[Sfolder,~,~] = fileparts(filename);
opencossan.OpenCossan.cossanDisp('[COSSAN-X.Identifier.replaceValues] Open file:',4);
opencossan.OpenCossan.cossanDisp(['[COSSAN-X.Identifier.replaceValues] Filename:' filename ...
    ' permission: ' permission ' machineformat: ' ...
    machineformat ' encoding: ' encoding],4);

opencossan.OpenCossan.cossanDisp('[COSSAN-X.Identifier.replaceValues] Inputs name:',4);
opencossan.OpenCossan.cossanDisp(TableInput.Properties.VariableNames,4);

Svalue=[];
for ivar=1:length(obj)
    % Check inputs
    if ~(ismember(obj(ivar).Name,TableInput.Properties.VariableNames)) && ~UseOriginalValues
        % close file before to die
        fclose(FileID);
        %Show the error
        error('openCOSSAN:Identifier:replaceValues:MissingInput', ...
            ['The variables %s present in the Injector \n', ...
            'is not present in the input sample.'], obj(ivar).Name);
    else
        opencossan.OpenCossan.cossanDisp(['[COSSAN-X.Identifier.replaceValues] Injector ' ...
            obj(ivar).Name ' FileID= ' num2str(FileID)],4)
    end
    
    
    if ivar==1
        Ndigits=0;
    else
        Ndigits=Ndigits0+Ndigits;
    end
    
    switch lower(obj(ivar).FieldFormat)
        case {'nastran8'}
            Ndigits0 = 8;
        case {'nastran16'}
            Ndigits0 = 16;
        otherwise
            % extract the number of characters from the format
            s1=regexp(obj(ivar).FieldFormat,'\%','split');
            SstringFormat1=s1(2);
            s2=regexp(SstringFormat1{1},'\.','split');
            SstringFormat2=s2(1);
            Ndigits0=str2double(SstringFormat2{1});
    end
    
    % Update the Nposition based on the actual values of variables
    if ~isempty(Svalue)
        obj(ivar).Position=obj(ivar).Position+Ndigits;%-ivar+1;
    end
    
    status = fseek(FileID,obj(ivar).Position, 'bof');
    if ~isempty(status)
        opencossan.OpenCossan.cossanDisp(['[COSSAN-X.Identifier.replaceValues] Return to the beginning of file. status: ' num2str(status)],4)
    end
    
    %count=[];
    % get the value to be injected
    if ~UseOriginalValues
        switch class(TableInput.(obj(ivar).Name))
            case 'opencossan.common.Dataseries'
                % if an index is specified, assign to value the content of
                % the property Mdata of the Dataseries object at the
                % specified index
                if ~isempty(obj(ivar).Nindex)
                    Vdata = TableInput.(obj(ivar).Sname).Vdata;
                    value = Vdata(obj(ivar).Index);
                end
            case {'double','single','logical'}
                value=TableInput.(obj(ivar).Name)(obj(ivar).Index);
            otherwise
                error('openCOSSAN:Identifier:replaceValues',['It is not possible '...
                    'to inject values from object of class %s '], ...
                    class(TableInput.(obj(ivar).Name)))
        end
    else
        value = obj(ivar).OriginalValue;
    end
    
    % write the value in the file with the specified format
    switch lower(obj(ivar).FieldFormat)
        case {'nastran8'}
            Svalue = num2nastran8(value);
            count=fprintf(FileID,'%8s',Svalue);
        case {'nastran16'}
            Svalue = num2nastran16(value);
            count=fprintf(FileID,'%16s',Svalue);
        otherwise
            Svalue = sprintf(obj(ivar).FieldFormat,value);
            count=fprintf(FileID,obj(ivar).FieldFormat,value);
            if count > Ndigits0
                Ndigits0 = count;
            end
    end
    
    %% Used for debugging
    opencossan.OpenCossan.cossanDisp(['[COSSAN-X.Identifier.replaceValues] Writing ' ...
        obj(ivar).Name '(' num2str(obj(ivar).Index) ...
        ') with the format: ' obj(ivar).FieldFormat],4)
    
    opencossan.OpenCossan.cossanDisp(['[COSSAN-X.Identifier.replaceValues] Field Format:' obj(ivar).FieldFormat ],4);
    opencossan.OpenCossan.cossanDisp(['[COSSAN-X.Identifier.replaceValues] Value:' Svalue ' bytes written: ' num2str(count)],4);
    
    Smessage = ferror(FileID);
    if ~isempty(Smessage)
        opencossan.OpenCossan.cossanDisp(['[COSSAN-X.Identifier.replaceValues] Error writing value: ' Smessage],4);
    end
    
end
