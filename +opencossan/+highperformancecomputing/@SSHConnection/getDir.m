function getDir(Xobj,varargin)
%GETDIR copy a directory from the remote machine to a directory in the 
% local computer
%
% See also: http://cossan.co.uk/wiki/index.php/GetDir@SSHConnection
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
SremoteDirName='';
SlocalDestinationDir='';
Loverwrite = false;

OpenCossan.validateCossanInputs(varargin{:})

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case 'sremotedirname'
            SremoteDirName = varargin{k+1};
        case 'slocaldestinationdir'
            SlocalDestinationDir = varargin{k+1};
        case 'loverwrite'   
            Loverwrite = varargin{k+1};
        otherwise
            error('openCOSSAN:SSHConnection:getDir',...
                ['PropertyName name (' varargin{k} ') not allowed'])
    end
end

assert(~isempty(SremoteDirName),'openCOSSAN:SSHConnection:getDir',...
    'Mandatory input SlocalDirName missing.')

% default local destination directory is the COSSAN working path
if isempty(SlocalDestinationDir)
    SlocalDestinationDir = OpenCossan.getCossanWorkingPath;
end

% check that the client is connected
if isempty(Xobj.JsshConnection) || ~Xobj.JsshConnection.isAuthenticationComplete
    Xobj.openSSHconnection;
end
%% check that only absolute paths are used
assert(strcmp(SremoteDirName(1),'/'),...
    'openCOSSAN:SSHConnection:getDir',...
    'Remote source directory must be an absolute path!')

if isunix
    assert(strcmp(SlocalDestinationDir(1),'/'),...
        'openCOSSAN:SSHConnection:getDir',...
        'Local destination directory name must be an absolute path!')
elseif ispc
    assert(strcmp(SlocalDestinationDir(2),':'),...
        'openCOSSAN:SSHConnection:getDir',...
        'Local destination directory name must be an absolute path!')
end

% remove the final filesep if present
if strcmpi(SremoteDirName(end),'/')
    SremoteDirName(end)='';
end
if strcmpi(SlocalDestinationDir(end),filesep)
    SlocalDestinationDir(end)='';
end

% check that the remote directory exists
status=Xobj.issueCommand(['[ -d ' SremoteDirName ' ]']);
assert(status==0,'openCOSSAN:SSHConnection:getDir',...
        'remote directory %s does not exist', SremoteDirName)

% send a overwrite warning if the destination directory already exist
CpathParts = regexp(SremoteDirName,'/','split');
SlocalDirName = fullfile(SlocalDestinationDir,CpathParts{end});
if exist(SlocalDirName,'dir') && ~Loverwrite
    error('openCOSSAN:SSHConnection:getDir',...
        ['A directory named %s already exist in the destination folder %s\n',...
        'and Loverwite is not set to true.'],CpathParts{end},SlocalDestinationDir)
end

%% Compress the directory, transfer it to the remote host and decompress it
% Compress the remote directory. The compressed file is stored in the
% remote working path.
ScompressFileName = fullfileunix(Xobj.SremoteWorkFolder,[CpathParts{end} '.tar.gz']);
SlocalFileName =  fullfile(SlocalDestinationDir,[CpathParts{end} '.tar.gz']);
OpenCossan.cossanDisp('[openCOSSAN.SSHConnection.getDir] Compressing remote directory',4)
ScompressCommand = ['tar -czvf ' ScompressFileName ...
    ' -C ' fullfileunix('/',CpathParts{1:end-1}) ' ' CpathParts{end}];
OpenCossan.cossanDisp(['[openCOSSAN.SSHConnection.getDir] Compress directory command: ' ScompressCommand],4)
[status, result] = Xobj.issueCommand(ScompressCommand);

assert(status==0,'openCOSSAN:SSHConnection:getDir',...
    'Failed to compress folder on remote machine')
OpenCossan.cossanDisp('[openCOSSAN.SSHConnection.getDir] Compress command output',4)
OpenCossan.cossanDisp(result,4)

% get the compressed folder from the remote host
Xobj.getFile('SremoteFileName',ScompressFileName,...
    'SlocalDestinationFolder',SlocalDestinationDir);

% decompress the compressed folder in the local machine
CSfilenames = untar(SlocalFileName,SlocalDestinationDir);

OpenCossan.cossanDisp('[openCOSSAN.SSHConnection.getDir] Output from decompression:',4)
OpenCossan.cossanDisp(CSfilenames,4)

% delete compressed file on the remote machine
OpenCossan.cossanDisp(['[openCOSSAN.SSHConnection.getDir] Removing remote '...
    'compressed file' ScompressFileName],4)
Xobj.issueCommand(['rm ' ScompressFileName]);
% delete compressed file on the local machine
OpenCossan.cossanDisp(['[openCOSSAN.SSHConnection.getDir] Removing local '...
    'compressed file' SlocalFileName],4)
delete(SlocalFileName);

end