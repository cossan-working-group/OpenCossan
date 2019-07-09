function putDir(Xobj,varargin)
%PUTDIR copy a directory from the local machine to a directory in the 
% remote host 
%
% See also: http://cossan.co.uk/wiki/index.php/PutDir@SSHConnection
%
% Author: Matteo Broggi
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

%% input check
SlocalDirName='';
SremoteDestinationDir='';
Loverwrite = false;

OpenCossan.validateCossanInputs(varargin{:})

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case 'slocaldirname'
            SlocalDirName = varargin{k+1};
        case 'sremotedestinationdir'
            SremoteDestinationDir = varargin{k+1};
        case 'loverwrite'   
            Loverwrite = varargin{k+1};
        otherwise
            error('openCOSSAN:SSHConnection:putDir',...
                ['PropertyName name (' varargin{k} ') not allowed'])
    end
end

assert(~isempty(SlocalDirName),'openCOSSAN:SSHConnection:putDir',...
    'Mandatory input SlocalDirName missing.')

% default remote destination directory is the remote working dir
if isempty(SremoteDestinationDir)
    SremoteDestinationDir = Xobj.SremoteWorkFolder;
end

% check that the client is connected
if isempty(Xobj.JsshConnection) || ~Xobj.JsshConnection.isAuthenticationComplete
    Xobj.openSSHconnection;
end
%% check that only absolute paths are used
assert(strcmp(SremoteDestinationDir(1),'/'),...
    'openCOSSAN:SSHConnection:putDir',...
    'Remote destination folder must be an absolute path!')

if isunix
    assert(strcmp(SlocalDirName(1),'/'),...
        'openCOSSAN:SSHConnection:putDir',...
        'Local source directory name must be an absolute path!')
elseif ispc
    assert(strcmp(SlocalDirName(2),':'),...
        'openCOSSAN:SSHConnection:putDir',...
        'Local source directory name must be an absolute path!')
end

% remove the final filesep if present
if strcmpi(SlocalDirName(end),filesep)
    SlocalDirName(end)='';
end
if strcmpi(SremoteDestinationDir(end),'/')
    SremoteDestinationDir(end)='';
end

% check that the local directory exists
if ~exist(SlocalDirName,'dir')
    error('openCOSSAN:SSHConnection:putDir',...
        'Local directory %s does not exist', SlocalDirName)
end

% send a overwrite warning if the destination directory already exist
CpathParts = regexp(SlocalDirName,filesep,'split');
SremoteDirName = [SremoteDestinationDir,'/',CpathParts{end}]; % destination system is *nix, don't use fullfile
status=Xobj.issueCommand(['[ -d ' SremoteDirName ' ]']);
if status==0 && ~Loverwrite
    error('openCOSSAN:SSHConnection:putDir',...
        ['A directory named %s already exist in the destination folder %s\n',...
        'and Loverwite is not set to true.'],CpathParts{end},SremoteDestinationDir)
end

%% Compress the directory, transfer it to the remote host and decompress it
% Compress the local directory. The compressed file is stored in the COSSAN
% working path.
ScompressFileName = fullfile(OpenCossan.getCossanWorkingPath,[CpathParts{end} '.tar.gz']);
SremoteFileName = [SremoteDestinationDir,'/',CpathParts{end} '.tar.gz']; % destnation system is *nix
OpenCossan.cossanDisp('[openCOSSAN.SSHConnection.putDir] Compressing local directory',4)
CSfilenames = tar(ScompressFileName,SlocalDirName);
OpenCossan.cossanDisp('[openCOSSAN.SSHConnection.putDir] Compressed file content',4)
OpenCossan.cossanDisp(CSfilenames,4)

% send the compressed folder to the remote host
Xobj.putFile('SlocalFileName',ScompressFileName,...
    'SremoteDestinationFolder',SremoteDestinationDir);

% decompress the compressed folder in the remote machine
SdecompressCommand = ['tar -xzvf ' SremoteFileName ' -C ' SremoteDestinationDir];
OpenCossan.cossanDisp(['[openCOSSAN.SSHConnection.putFile] Decompress file command' SdecompressCommand],4)
[status, result] = Xobj.issueCommand(SdecompressCommand);

assert(status==0,'openCOSSAN:SSHConnection:putDir',...
    'Failed to decompress folder in remote machine')
OpenCossan.cossanDisp('[openCOSSAN.SSHConnection.putDir] Output from decompression:',4)
OpenCossan.cossanDisp(result,4)

% delete compressed file on the local machine
OpenCossan.cossanDisp(['[openCOSSAN.SSHConnection.putDir] Removing local '...
    'compressed file' ScompressFileName],4)
delete(ScompressFileName);
% delete compressed file on the remote machine
OpenCossan.cossanDisp(['[openCOSSAN.SSHConnection.putDir] Removing remote '...
    'compressed file' SremoteFileName],4)
Xobj.issueCommand(['rm ' SremoteFileName]);

end