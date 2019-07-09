function getFile(Xobj,varargin)
%GETFILE copy a file from the local machine to a directory in the remote
% host 
%
% See also: http://cossan.co.uk/wiki/index.php/PutFile@SSHConnection
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

import ch.ethz.ssh2.*;
%% input check
SremoteFileName='';
SlocalDestinationFolder='';

OpenCossan.validateCossanInputs(varargin{:})

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case 'sremotefilename'
            SremoteFileName = varargin{k+1};
        case 'slocaldestinationfolder'
            SlocalDestinationFolder = varargin{k+1};
        otherwise
            error('openCOSSAN:SSHConnection:getfile',...
                ['PropertyName name (' varargin{k} ') not allowed'])
    end
end

assert(~isempty(SremoteFileName),'openCOSSAN:SSHConnection:getFile',...
    'Mandatory input SremoteFileName missing.')

% default local destination folder is the cossan working path
if isempty(SlocalDestinationFolder)
    SlocalDestinationFolder = OpenCossan.getCossanWorkingPath;
end

% check that the client is connected
if isempty(Xobj.JsshConnection) || ~Xobj.JsshConnection.isAuthenticationComplete
    Xobj.openSSHconnection;
end
%% check that only absolute paths are used
assert(strcmp(SremoteFileName(1),'/'),...
    'openCOSSAN:SSHConnection:getFile',...
    'Remote file name must be an absolute path!')

if isunix
    assert(strcmp(SlocalDestinationFolder(1),'/'),...
        'openCOSSAN:SSHConnection:getFile',...
        'Local destination folder must be an absolute path!')
elseif ispc
    assert(strcmp(SlocalDestinationFolder(2),':'),...
        'openCOSSAN:SSHConnection:getFile',...
        'Localdestination folder must be an absolute path!')
end

%% check that the remote file exists
status=Xobj.issueCommand(['[ -f ' SremoteFileName ' ]']);
assert(status==0,'openCOSSAN:SSHConnection:getFile',...
    'Remote file %s does not exist', SremoteFileName)
% retrieve the file name from the string SlocalFileName
[~, Sname, Sext] = fileparts(SremoteFileName);

%% check that the local destination folder exists and that the user can
% write in it
if ~exist(SlocalDestinationFolder,'dir')
    error('openCOSSAN:SSHConnection:getFile',...
        'Local destination directory %s does not exist', SlocalDestinationFolder)
else
    [~, Tattrib] = fileattrib(SlocalDestinationFolder);
    assert(Tattrib.UserWrite==1,'openCOSSAN:SSHConnection:getFile',...
        'User does not have write permission on the destination folder')
end

% send a overwrite warning if the destination file already exist
% TODO should it give error instead???
SlocalDestinationFile = fullfile(SlocalDestinationFolder,[Sname,Sext]);
if exist(SlocalDestinationFile,'file')
     warning('openCOSSAN:SSHConnection:getFile',...
        ['A file named %s already exist in the destination folder %s.\n',...
        'This file will be overwritten.'],[Sname,Sext],SlocalDestinationFolder)
end

% %% transfer the file via SCP
% % retrieve local file size
% [~, Sout] = Xobj.issueCommand(['stat -c %s ' SremoteFileName]);
% filesize = str2double(Sout); % no check is necessary on the status because we already checked that file exists
% 
% if filesize~=0
%     % initialize the scp client
%     JscpClient = SCPClient(Xobj.JsshConnection);
%     
%     % get the remote file
%     OpenCossan.cossanDisp('[openCOSSAN.SSHConnection.getFile] File transfer via SCP started',3)
%     JscpClient.get(SremoteFileName,SlocalDestinationFolder);
%     OpenCossan.cossanDisp('[openCOSSAN.SSHConnection.getFile] File transfer via SCP completed',3)
% else
%     warning('openCOSSAN:SSHConnection:getFile',...
%         'Remote file %s is empty',SremoteFileName)
% end
%% transfer file via SFTP
% initialize the sftp connection
JsftpConn = SFTPv3Client(Xobj.JsshConnection);

try 
    % you need to have the wrapper in the classpath 
    reader = RemoteFileIDStreamByteWrapper(JsftpConn, Xobj.maxbuffer);
catch me
    error('openCOSSAN:SSHConnection:getFile','Cannot find the buffer wrapping class')
end

% open the remote file from the source folder with read permission
JremoteFileId = JsftpConn.openFileRO(SremoteFileName);

% retrieve remote file size
JfileAttributes = JsftpConn.fstat(JremoteFileId);
filesize = JfileAttributes.size;
filesize = filesize.doubleValue;

if filesize~=0
    % Open the local destination file in write mode
    NlocalFileId = fopen(SlocalDestinationFile,'w');

    count=0;
    bufsize = reader.readBuffer(JremoteFileId, count, Xobj.maxbuffer);
    while(bufsize~=-1)
        Vbuffer = double(reader.bfr(1:bufsize));
        Vbuffer(Vbuffer<0) = Vbuffer(Vbuffer<0) + 256; % necessary conversion for matlab compatibility
        fwrite(NlocalFileId,Vbuffer);
        count = count+bufsize;
        OpenCossan.cossanDisp(['[openCOSSAN.SSHConnection.getFile] File transfer '...
            sprintf('%3d',floor(count/filesize*100)) '% completed.'],4);
        bufsize = reader.readBuffer(JremoteFileId, count, Xobj.maxbuffer);
    end
    OpenCossan.cossanDisp(['[openCOSSAN.SSHConnection.getFile] Transfer of file ' SremoteFileName ' to '...
        SlocalDestinationFile ' completed'],3)
    % close local file
    fclose(NlocalFileId);
    
else
    warning('openCOSSAN:SSHConnection:getFile',...
        'Remote file %s is empty',SlocalFileName)
end

% close SFTP connection
JsftpConn.closeFile(JremoteFileId);
JsftpConn.close();


end