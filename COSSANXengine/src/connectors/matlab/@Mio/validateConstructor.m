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

OpenCossan.cossanDisp('[Mio:validateConstructor] Validate Constructor',4)

assert(~isempty(Xobj.Coutputnames),'openCOSSAN:Mio',...
    'The names of the Output variables must be defined in the field Coutputnames');
if size(Xobj.Coutputnames,1)>1
    Xobj.Coutputnames=Xobj.Coutputnames';
end

assert(~isempty(Xobj.Cinputnames),'openCOSSAN:Mio',...
    'The names of the Input variables should be defined in the field Cinputnames');
if size(Xobj.Cinputnames,1)>1
    Xobj.Cinputnames=Xobj.Cinputnames';
end


% Existance of m-file in directory Spath is checked
if isempty(Xobj.Sscript) && isempty(Xobj.FunctionHandle)
    % check that an absolute path is given
    assert(~isempty(Xobj.Sfile),'openCOSSAN:Mio',...
        'A file name must be supplied.')
    assert(~(isempty(Xobj.Spath)||strcmp(Xobj.Spath(1),'.')),'openCOSSAN:Mio',...
        'A full file path must be supplied.')
    
    if ~isdeployed % if not deployed
        %% If is a Mio function, check if the file in already in the path
        if Xobj.Lfunction
            [~, Xobj.Sfile] =fileparts(Xobj.Sfile);
            SfullfileMio=fullfile(Xobj.Spath,[Xobj.Sfile '.m']);
            % Check if the provided files is really a function
            
            [Nfid,Smessage]=fopen(SfullfileMio);
            
            assert(isempty(Smessage),'openCOSSAN:Mio',...
                  'The Script or Function specified in the field ''Spath/Sname'' (%s) can not be open\nError message: %s',...
                  SfullfileMio,Smessage);
                    
            
            Sline=fgetl(Nfid);
            while 1              
                if isempty(regexp(Sline, '^%','once')) && ~isempty(Sline)
                    % No comment identified, check for function
                    
                    assert(~isempty(regexp(Sline, '^function','once')),'openCOSSAN:Mio',...
                        'The provided file (%s) does not seem to be a function!!\nPlease check the Lfunction flag and your file',SfullfileMio);
                    break
                else
                    % Process next line
                    Sline=fgetl(Nfid);
                end
            end
            fclose(Nfid);
            
            OpenCossan.cossanDisp(['[Mio:validateConstructor] convert : ' ...
                fullfile(Xobj.Spath,[Xobj.Sfile '.m']) ' to Handle function'] ,4)
            if isempty(which(Xobj.Sfile))
                    addpath(Xobj.Spath);
                    Xobj.FunctionHandle=str2func(Xobj.Sfile);
                    rmpath(Xobj.Spath);
            else
                Xobj.FunctionHandle=str2func(Xobj.Sfile);
            end
            
            
        end % nothing to do if is a script
        
        if Xobj.Lfunction
            % TODO: Include check of the file. It should at least contain
            % the word function. 
            
        else
            % TODO: Include check of the file. 
        end

    else %if is deployed version
        %% If is a Script, put the content of the script file in Sscript
        if ~Xobj.Lfunction
            OpenCossan.cossanDisp(['[Mio:validateConstructor] convert : ' ...
                fullfile(Xobj.Spath,Xobj.Sfile) ' script to a single string'] ,4)
            Nfid = fopen(fullfile(Xobj.Spath,Xobj.Sfile));
            Vbytes = fread(Nfid);
            fclose(Nfid);
            % remove carriage return
            Vbytes(Vbytes==13)=[];
            % substitute line feeds (newlines) with commas
            Vbytes(Vbytes==10)=44;
            Xobj.Sscript=char(Vbytes');
        end % nothing to do if is a function
    end
end

if ~isdeployed
    assert((~isempty(Xobj.Sscript) || ~isempty(Xobj.FunctionHandle) || exist(fullfile(Xobj.Spath,Xobj.Sfile),'file')), ...
        'openCOSSAN:Mio',strcat('A function or a script is required by the Mio object\n',...
        'Please use the propertyName Sfile, Sscript or AfunctionHandle or check that the files exists. \nFile: %s'),fullfile(Xobj.Spath,Xobj.Sfile));
else
    assert((~isempty(Xobj.Sscript) || exist(fullfile(Xobj.Spath,Xobj.Sfile),'file')), ...
        'openCOSSAN:Mio',strcat('A function or a script is required by the Mio object\n',...
        'Please use the propertyName Sfile or Sscript'));
end

%% Check flags
% the input cannot be both matrix and structure
assert(~(Xobj.Liomatrix && Xobj.Liostructure), ...
    'openCOSSAN:Mio',...
    'The flags Liomatrix and Liostructure can not be set both to true');
% assure that if the input is neither matrix nor structure, then it is a
% function
if ~Xobj.Liomatrix && ~Xobj.Liostructure
    assert(Xobj.Lfunction,'openCOSSAN:Mio',...
        'Only functions can be used with multiple inputs and outputs');
end


