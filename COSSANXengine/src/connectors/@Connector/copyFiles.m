function copyFiles(Xc,varargin)
%
% See Also: http://cossan.co.uk/wiki/index.php/copyFiles@Connector
%
% $Copyright~1993-2014,~COSSAN~Working~Group,~University~of~Liverpool,~UK$
% $Author: Matteo Broggi and Edoardo Patelli$

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

% Validate inputs
OpenCossan.validateCossanInputs(varargin{:});

% process optional inputs
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'ssourcedir'}
            Ssourcedir=varargin{k+1};
        case {'sdestdir'}
            Sdestdir=varargin{k+1};
        otherwise
            error('OpenCossan:Connector:copyFiles:wrongArgument', ...
            'The argument %s is not valid',varargin{k})
    end
end

if ~exist('Ssourcedir','var')
    Ssourcedir = Xc.Smaininputpath;
end
if ~exist('Sdestdir','var')
    Sdestdir = Xc.Sworkingdirectory;
end

%% copy main input file
[Lstatus,Smess]=copyfile(fullfile(Ssourcedir,Xc.Smaininputfile),Sdestdir,'f');

OpenCossan.cossanDisp(['[OpenCossan:Connector:copyFiles] Copy main input file from: ' ...
    fullfile(Ssourcedir,Xc.Smaininputfile) ' to: ' fullfile(Sdestdir,Xc.Smaininputfile)],3)
if ~Lstatus
    OpenCossan.cossanDisp(['[OpenCossan:Connector:copyFiles] message: ' Smess],1)
end

%% copy additional files into the new folder
if ~isempty(Xc.Caddfiles)
    for iaddfile=1:length(Xc.Caddfiles)
        [Saddfilepath, Saddfilename, Saddfileext] = fileparts(Xc.Caddfiles{iaddfile});
        if ~isempty(Saddfilepath)
            if ~exist(fullfile(Sdestdir,Saddfilepath),'dir')

                    OpenCossan.cossanDisp(['[OpenCossan:Connector:copyFiles] Creating folder: ' ...
                        fullfile(Sdestdir,Saddfilepath) ],3)

                [Lstatus,mess]=mkdir(Sdestdir,Saddfilepath);
                if ~Lstatus
                    OpenCossan.cossanDisp(['[OpenCossan:Connector:copyFiles] Error Creating folder: ' ...
                        fullfile(Sdestdir,Saddfilepath) ' mess: ' mess],3)
                end
            end
            [Lstatus,Smess]=copyfile(fullfile(Ssourcedir,Xc.Caddfiles{iaddfile}),...
                fullfile(Sdestdir,Saddfilepath));

                OpenCossan.cossanDisp(['[OpenCossan:Connector:copyFiles] Copy additional file from: ' ...
                    fullfile(Ssourcedir,Xc.Caddfiles{iaddfile}) ' to: ' ...
                    fullfile(Sdestdir,Saddfilepath,[Saddfilename Saddfileext])],3)
                if ~Lstatus
                    OpenCossan.cossanDisp(['[OpenCossan:Connector:copyFiles] message: ' Smess],3)
                end

        else
            [Lstatus,Smess]=copyfile(fullfile(Ssourcedir,Saddfilepath,[Saddfilename Saddfileext]),Sdestdir);
            

                OpenCossan.cossanDisp(['[OpenCossan:Connector:copyFiles] Copy additional file from: ' ...
                    fullfile(Ssourcedir,Saddfilepath,[Saddfilename Saddfileext]) ' to: ' fullfile(Sdestdir,Saddfilepath, [Saddfilename Saddfileext])],3)
                if ~Lstatus
                    OpenCossan.cossanDisp(['[OpenCossan:Connector:copyFiles] message: ' Smess],3)
                end

        end
    end
end


%% copy injector files
OpenCossan.cossanDisp('[OpenCossan:Connector:copyFiles] Copy files of the injectors',3)
% Vinjector=fieldnames(Xc.Xinjector);
if any(Xc.Linjectors)
    for iinj=find(Xc.Linjectors)
        Sfilename = Xc.CXmembers{iinj}.Sfile;
        Spath = Xc.CXmembers{iinj}.Srelativepath;
        if strcmp(Spath,'./')
            % Do not copy again the mainInputFile
            if strcmp([Ssourcedir Xc.Smaininputfile],[Ssourcedir Sfilename])
                OpenCossan.cossanDisp('[OpenCossan:Connector:copyFiles] main Input file already copied',2)
                OpenCossan.cossanDisp(['[OpenCossan:Connector:copyFiles] MainInputFile: ' Ssourcedir Xc.Smaininputfile],2)
                OpenCossan.cossanDisp(['[OpenCossan:Connector:copyFiles] Injector File: ' Ssourcedir Sfilename],2)
            else
            [Lstatus,Smess]=copyfile(fullfile(Ssourcedir,Sfilename),Sdestdir);
            
            if ~Lstatus
                OpenCossan.cossanDisp(['[OpenCossan:Connector:copyFiles] message: ' Smess],1)
            end
            end
        else
            if ~exist(fullfile(Sdestdir,Spath),'dir')
                
                [Lstatus,Smess]=mkdir(Sdestdir, Spath);
                

                OpenCossan.cossanDisp(['[OpenCossan:Connector:copyFiles] Create folder: ' fullfile(Sdestdir,Spath)],3)

                if ~Lstatus
                    OpenCossan.cossanDisp(['[OpenCossan:Connector:copyFiles] message: ' Smess],1)
                end
                
            end
            [Lstatus,Smess]=copyfile(fullfile(Ssourcedir,Spath,Sfilename),fullfile(Sdestdir,Spath));
        end
        
        OpenCossan.cossanDisp(['[OpenCossan:Connector:copyFiles] Copy file from: ' ...
            Ssourcedir Spath Sfilename ' to: ' Sdestdir Spath Sfilename],3)
        
        
        if ~Lstatus
            OpenCossan.cossanDisp(['[OpenCossan:Connector:copyFiles] message: ' Smess],1)
        end
    end
end

end
