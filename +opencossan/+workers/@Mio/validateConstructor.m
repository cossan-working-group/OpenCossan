function Xobj=validateConstructor(Xobj)
% VALIDATECONSTRUCTOR this private method check if the object is
% constructed correctly.
% See also: https://cossan.co.uk/wiki/index.php/@Mio
%
% Author: Edoardo Patelli and Matteo Broggi
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
import opencossan.OpenCossan;

OpenCossan.cossanDisp('[Mio:validateConstructor] Validate Constructor',4)

assert(~isempty(Xobj.OutputNames),'openCOSSAN:Mio',...
    'The names of the Output variables must be defined in the field OutputNames');
if size(Xobj.OutputNames,1)>1
    Xobj.OutputNames=Xobj.OutputNames';
end

assert(~isempty(Xobj.InputNames),'openCOSSAN:Mio',...
    'The names of the Input variables should be defined in the field InputNames');
if size(Xobj.InputNames,1)>1
    Xobj.InputNames=Xobj.InputNames';
end


% Existance of m-file in directory Spath is checked
if isempty(Xobj.Script) && isempty(Xobj.FunctionHandle)
    % check that an absolute path is given
    assert(~isempty(Xobj.FullFileName),'openCOSSAN:Mio',...
        'A file name must be supplied.')
    
    if ~isdeployed % if not deployed
        %% If is a Mio function, check if the file in already in the path
        if Xobj.IsFunction
            % Check if the provided files is really a function
            
            [Nfid,Smessage]=fopen(Xobj.FullFileName);
            
            assert(isempty(Smessage),'openCOSSAN:Mio',...
                  'The Script or Function specified in the field ''Spath/Sname'' (%s) can not be open\nError message: %s',...
                  Xobj.FullFileName,Smessage);
                    
            
            Sline=fgetl(Nfid);
            while 1              
                if isempty(regexp(Sline, '^%','once')) && ~isempty(Sline)
                    % No comment identified, check for function
                    
                    assert(~isempty(regexp(Sline, '^function','once')),'openCOSSAN:Mio',...
                        'The provided file (%s) does not seem to be a function!!\nPlease check the Lfunction flag and your file',Xobj.FullFileName);
                    break
                else
                    % Process next line
                    Sline=fgetl(Nfid);
                end
            end
            fclose(Nfid);
            
            opencossan.OpenCossan.cossanDisp(['[Mio:validateConstructor] convert : ' ...
                Xobj.FullFileName ' to Handle function'] ,4)
            [Spath,Sfile,Sext] = fileparts(Xobj.FullFileName);
            if isempty(which([Sfile,Sext]))
                    addpath(Spath);
                    Xobj.FunctionHandle=str2func(Sfile);
                    rmpath(Spath);
            else
                Xobj.FunctionHandle=str2func(Sfile);
            end
            
            
        end % nothing to do if is a script
        
        if Xobj.IsFunction
            % TODO: Include check of the file. It should at least contain
            % the word function. 
            
        else
            % TODO: Include check of the file. 
        end

    else %if is deployed version
        %% If is a Script, put the content of the script file in Sscript
        if ~Xobj.IsFunction
            OpenCossan.cossanDisp(['[Mio:validateConstructor] convert : ' ...
                Xobj.FullFileName ' script to a single string'] ,4)
            Nfid = fopen(Xobj.FullFileName);
            Vbytes = fread(Nfid);
            fclose(Nfid);
            % remove carriage return
            Vbytes(Vbytes==13)=[];
            % substitute line feeds (newlines) with commas
            Vbytes(Vbytes==10)=44;
            Xobj.Script=char(Vbytes');
        end % nothing to do if is a function
    end
end

if ~isdeployed
    assert((~isempty(Xobj.Script) || ~isempty(Xobj.FunctionHandle) || exist(Xobj.FullFileName,'file')), ...
        'openCOSSAN:Mio',strcat('A function or a script is required by the Mio object\n',...
        'Please use the propertyName Sfile, Sscript or AfunctionHandle or check that the files exists. \nFile: %s'),Xobj.FullFileName);
else
    assert((~isempty(Xobj.Script) || exist(Xobj.FullFileName,'file')), ...
        'openCOSSAN:Mio',strcat('A function or a script is required by the Mio object\n',...
        'Please use the propertyName Sfile or Sscript'));
end
