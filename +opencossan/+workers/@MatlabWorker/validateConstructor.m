function obj=validateConstructor(obj)
% VALIDATECONSTRUCTOR this private method check if the object is
% constructed correctly.
% See also: Mio
%
% Author: Edoardo Patelli and Matteo Broggi
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
import opencossan.OpenCossan;

OpenCossan.cossanDisp('[MatlabWorker:validateConstructor] Validate Constructor',4)

assert(~isempty(obj.OutputNames),'OpenCossan:MatlabWorker:EmptyOutputNames',...
    'The names of the Output variables must be defined in the field OutputNames');
if size(obj.OutputNames,1)>1
    obj.OutputNames=obj.OutputNames';
end

assert(~isempty(obj.InputNames),'OpenCossan:MatlabWorker:EmptyInputNames',...
    'The names of the Input variables should be defined in the field InputNames');
if size(obj.InputNames,1)>1
    obj.InputNames=obj.InputNames';
end


% Existance of m-file in directory Path is checked
if isempty(obj.Script) && isempty(obj.FunctionHandle)
    % check that an absolute path is given
    assert(~isempty(obj.FullFileName),'OpenCossan:MatlabWorker:NoFileName',...
        'A filename must be supplied if script of a function handle are not provided.')
    
    if ~isdeployed % if not deployed
        % Check if the file provided is a function or a script
        
        [Nfid,Smessage]=fopen(obj.FullFileName);
        
        assert(isempty(Smessage),'OpenCossan:MatlabWorker:ErrorOpeningFile',...
            ['The file specified in the field ''FullFileName'' (%s) ',...
            'can not be open\nError message: %s'],...
            obj.FullFileName,Smessage);
        
        % Read the file and check if it is a function or a script
        Sline=fgetl(Nfid);
        while isempty(regexp(Sline, '^%','once')) && ~isempty(Sline)
            Sline=fgetl(Nfid);
            
        end
        
        % No comment identified, check for function
        if isempty(regexp(Sline, '^function','once'))
            obj.IsFunction=false;
        else
            obj.IsFunction=true;
        end
        
        fclose(Nfid);
        
        opencossan.OpenCossan.cossanDisp(['[MatlabWorker:validateConstructor] convert : ' ...
            obj.FullFileName ' to Handle function'] ,4)
        [Spath,Sfile,Sext] = fileparts(obj.FullFileName);
        if isempty(which([Sfile,Sext]))
            addpath(Spath);
            obj.FunctionHandle=str2func(Sfile);
            rmpath(Spath);
        else
            obj.FunctionHandle=str2func(Sfile);
        end
        
        
        % nothing to do if is a script
        
        
    else %if is deployed version
        %% If is a Script, put the content of the script file in Sscript
        if ~obj.IsFunction
            OpenCossan.cossanDisp(['[Mio:validateConstructor] convert : ' ...
                obj.FullFileName ' script to a single string'] ,4)
            Nfid = fopen(obj.FullFileName);
            Vbytes = fread(Nfid);
            fclose(Nfid);
            % remove carriage return
            Vbytes(Vbytes==13)=[];
            % substitute line feeds (newlines) with commas
            Vbytes(Vbytes==10)=44;
            obj.Script=char(Vbytes');
        end % nothing to do if is a function
    end
end

if ~isdeployed
    assert((~isempty(obj.Script) || ~isempty(obj.FunctionHandle) || exist(obj.FullFileName,'file')), ...
        'OpenCossan:MatlabWorker:MissingMatlabFile',...
        strcat('A function or a script is required by the MatlabWorker object\n',...
        'Please use the PropertyName File, Script or FunctionHandle or check that the file exists. \nFile: %s'),obj.FullFileName);
else
    assert((~isempty(obj.Script) || exist(obj.FullFileName,'file')), ...
        'OpenCossan:MatlabWorker:NoScript',...
        strcat('A function or a script is required by the MatlabWorker object\n',...
        'Please use the propertyName Sfile or Sscript'));
end
