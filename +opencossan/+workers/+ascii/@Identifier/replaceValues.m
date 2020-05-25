function replaceValues(Xidentifier,varargin)
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
% OpenCossan.validateCossanInputs(varargin{:});
LuseOriginal = false;
for k = 1:2:length(varargin)
    switch(lower(varargin{k}))
        case 'nfid'
            Nfid=varargin{k+1};
        case 'tinput'
            Tinput=varargin{k+1};
        otherwise
            error('openCOSSAN:identifier:replaceValues',...
                'Property Name not allowed')
    end
end

[filename, permission, machineformat, encoding] = fopen(Nfid);
%[Sfolder,~,~] = fileparts(filename);
OpenCossan.cossanDisp('[COSSAN-X.Identifier.replaceValues] Open file:',4);
OpenCossan.cossanDisp(['[COSSAN-X.Identifier.replaceValues] Filename:' filename ...
    ' permission: ' permission ' machineformat: ' ...
    machineformat ' encoding: ' encoding],4);

OpenCossan.cossanDisp('[COSSAN-X.Identifier.replaceValues] Inputs name:',4);
OpenCossan.cossanDisp(fieldnames(Tinput),4);

Svalue=[];
for ivar=1:length(Xidentifier)
    % Check inputs
    if ~(isfield(Tinput,Xidentifier(ivar).Sname)) && ~LuseOriginal
        % close file before to die
        fclose(Nfid);
        %Show the error
        error('openCOSSAN:Identifier:replaceValues', ...
            ['The variables ' Xidentifier(ivar).Sname ' present in the Injector \n' ...
            'is not present in the input object ' ]);
    else
        OpenCossan.cossanDisp(['[COSSAN-X.Identifier.replaceValues] Injector ' ...
            Xidentifier(ivar).Sname ' Nfid= ' num2str(Nfid)],4)
    end
    
    
    if ivar==1
        Ndigits=0;
    else
        Ndigits=Ndigits0+Ndigits;
    end
    
    switch lower(Xidentifier(ivar).Sfieldformat)
        case {'nastran8'}
            Ndigits0 = 8;
        case {'nastran16'}
            Ndigits0 = 16;
        otherwise
            % extract the format of the current value
            s1=regexp(Xidentifier(ivar).Sfieldformat,'\%','split');
            SstringFormat1=s1(2);
            s2=regexp(SstringFormat1{1},'\.','split');
            SstringFormat2=s2(1);
            Ndigits0=str2double(SstringFormat2{1});
    end
    
    % Update the Nposition based on the actual values of variables
    if ~isempty(Svalue)
        Xidentifier(ivar).Nposition=Xidentifier(ivar).Nposition+Ndigits;%-ivar+1;
    end
    
    status = fseek(Nfid,Xidentifier(ivar).Nposition, 'bof');
    if ~isempty(status)
        OpenCossan.cossanDisp(['[COSSAN-X.Identifier.replaceValues] Return to the beginning of file. status: ' num2str(status)],4)
    end
    
    %count=[];
    % get the value to be injected
    if ~LuseOriginal
        switch class(Tinput.(Xidentifier(ivar).Sname))
            case 'opencossan.common.Dataseries'
                % if an index is specified, assign to value the content of
                % the property Mdata of the Dataseries object at the
                % specified index
                if ~isempty(Xidentifier(ivar).Nindex)
                    Vdata = Tinput.(Xidentifier(ivar).Sname).Vdata;
                    value = Vdata(Xidentifier(ivar).Nindex);
                end
            case {'double','single','logical'}
                value=Tinput.(Xidentifier(ivar).Sname)(Xidentifier(ivar).Nindex);
            otherwise
                error('openCOSSAN:Identifier:replaceValues',['It is not possible '...
                    'to inject values from object of class %s '], ...
                    class(Tinput.(Xidentifier(ivar).Sname)))
        end
    else
        value = str2double(Xidentifier(ivar).Soriginal);
    end
    
    % write the value in the file with the specified format
    switch lower(Xidentifier(ivar).Sfieldformat)
        case {'nastran8'}
            Svalue = num2nastran8(value);
            count=fprintf(Nfid,'%8s',Svalue);
        case {'nastran16'}
            Svalue = num2nastran16(value);
            count=fprintf(Nfid,'%16s',Svalue);
        otherwise
            Svalue = num2str(value,Xidentifier(ivar).Sfieldformat);
            count=fprintf(Nfid,Xidentifier(ivar).Sfieldformat,value);
    end
    
    %% Used for debugging
    OpenCossan.cossanDisp(['[COSSAN-X.Identifier.replaceValues] Writing ' ...
        Xidentifier(ivar).Sname '(' num2str(Xidentifier(ivar).Nindex) ...
        ') with the format: ' Xidentifier(ivar).Sfieldformat],4)
    
    OpenCossan.cossanDisp(['[COSSAN-X.Identifier.replaceValues] Field Format:' Xidentifier(ivar).Sfieldformat ],4);
    OpenCossan.cossanDisp(['[COSSAN-X.Identifier.replaceValues] Value:' Svalue ' bytes written: ' num2str(count)],4);
    
    Smessage = ferror(Nfid);
    if ~isempty(Smessage)
        OpenCossan.cossanDisp(['[COSSAN-X.Identifier.replaceValues] Error writing value: ' Smessage],4);
    end
    
end
