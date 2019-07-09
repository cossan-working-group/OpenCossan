function putFile(Xobj,varargin)
%PUTFILE copy a file from the local machine to a directory in the remote
% host 
%
% See also: http://cossan.co.uk/wiki/index.php/GetFile@SSHConnection
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

% import necessary classes
% import ch.ethz.ssh2.SFTPv3Client;
% import ch.ethz.ssh2.Connection;
% import ch.ethz.ssh2.Session;
% import ch.ethz.ssh2.SFTPv3FileHandle;

import ch.ethz.ssh2.*;
%% input check
SlocalFileName='';
SremoteDestinationFolder='';

OpenCossan.validateCossanInputs(varargin{:})

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case 'slocalfilename'
            SlocalFileName = varargin{k+1};
        case 'sremotedestinationfolder'
            SremoteDestinationFolder = varargin{k+1};
        otherwise
            error('openCOSSAN:SSHConnection:putfile',...
                ['PropertyName name (' varargin{k} ') not allowed'])
    end
end

assert(~isempty(SlocalFileName),'openCOSSAN:SSHConnection:putFile',...
    'Mandatory input SlocalFileName missing.')

% default remote destination folder is the remote working dir
if isempty(SremoteDestinationFolder)
    SremoteDestinationFolder = Xobj.SremoteWorkFolder;
end

% check that the client is connected
if isempty(Xobj.JsshConnection) || ~Xobj.JsshConnection.isAuthenticationComplete
    Xobj.openSSHconnection;
end
%% check that only absolute paths are used
assert(strcmp(SremoteDestinationFolder(1),'/'),...
    'openCOSSAN:SSHConnection:putFile',...
    'Remote destination folder must be an absolute path!')

if isunix
    assert(strcmp(SlocalFileName(1),'/'),...
        'openCOSSAN:SSHConnection:putFile',...
        'Local file name must be an absolute path!')
elseif ispc
    assert(strcmp(SlocalFileName(2),':'),...
        'openCOSSAN:SSHConnection:putFile',...
        'Local file name must be an absolute path!')
end

%% check that the local file exists
if ~exist(SlocalFileName,'file')
    error('openCOSSAN:SSHConnection:putFile',...
        'Local file %s does not exist', SlocalFileName)
end
% retrieve the file name from the string SlocalFileName
[~, Sname, Sext] = fileparts(SlocalFileName);

%% check that the remote destination folder exists and that the user can
% write in it
status=Xobj.issueCommand(['[ -d ' SremoteDestinationFolder ' ]']);
assert(status==0,'openCOSSAN:SSHConnection:putFile',...
    'Remote destination folder %s does not exist', SremoteDestinationFolder)
status=Xobj.issueCommand(['[ -w ' SremoteDestinationFolder ' ]']);
assert(status==0,'openCOSSAN:SSHConnection:putFile',...
    'User does not have write permission on the destination folder')

% send a overwrite warning if the destination file already exist
% TODO should it give error instead???
SremoteDestinationFile = [SremoteDestinationFolder,'/',Sname,Sext]; % the remote machine is *nix!
status=Xobj.issueCommand(['[ -f ' SremoteDestinationFile ' ]']);
if status==0
    warning('openCOSSAN:SSHConnection:putFile',...
        ['A file named %s already exist in the destination folder %s.\n',...
        'This file will be overwritten.'],[Sname,Sext],SremoteDestinationFolder)
end

%% transfer file via SFTP
% initialize the sftp connection
JsftpConn = SFTPv3Client(Xobj.JsshConnection);

% create and open the destination file into the destination folder with
% read/write permission
JremoteFileId = JsftpConn.createFile(SremoteDestinationFile);
OpenCossan.cossanDisp(['[openCOSSAN.SSHConnection.putFile] Destination file ' SremoteDestinationFile...
    ' created and opened with write permissions'],4)

% retrieve local file size
Tfile = dir(SlocalFileName);
filesize = Tfile.bytes;
if filesize~=0
    count=0; 
    NlocalFileId = fopen(SlocalFileName,'r');
    [Vbuffer, bufsize] = fread(NlocalFileId, Xobj.maxbuffer);
    while(bufsize~=0)
        JsftpConn.write(JremoteFileId,count,Vbuffer,0,bufsize)
        count_old = count;
        count=count+bufsize;
        if floor(count/filesize*100)~=floor(count_old/filesize*100)
            OpenCossan.cossanDisp(['[openCOSSAN.SSHConnection.putFile] File transfer '...
                sprintf('%3d',floor(count/filesize*100)) '% completed.'],4);
        end
        [Vbuffer, bufsize] = fread(NlocalFileId, Xobj.maxbuffer);
    end    
    OpenCossan.cossanDisp(['[openCOSSAN.SSHConnection.putFile] Transfer of file ' SlocalFileName ' to '...
    SremoteDestinationFolder ' completed'],3)
    % close local file
    fclose(NlocalFileId);
else
    warning('openCOSSAN:SSHConnection:putFile',...
        'Local file %s is empty',SlocalFileName)
end;

% close SFTP connection
JsftpConn.closeFile(JremoteFileId);
JsftpConn.close();

end

