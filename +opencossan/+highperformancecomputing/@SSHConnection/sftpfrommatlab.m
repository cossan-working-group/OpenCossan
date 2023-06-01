function sftpfrommatlab(userName,hostName,password,localfilename,remotefilename)
%sftpfrommatlab connects Matlab to a remote computer and uploads
%a file using the SFTP protocol
%
% STATUS  =  SFTPROMMATLAB(USERNAME,HOSTNAME,PASSWORD,LOCALFILENAME,REMOTEFILENAME)
%
% Inputs:
%   USERNAME is the user name required for the remote machine
%   HOSTNAME is the name of the remote machine
%   PASSWORD is the password for the account USERNAME@HOSTNAME
%   LOCALFILENAME is the fully qualified path of the filename to be uploaded
%   REMOTEFILENAME is the fully qualified path where the file will be
%   stored at the remote computer
%
% See also SSHFROMMATLAB, SSHFROMMATLABCLOSE, SSHFROMMATLABINSTALL, SSHFROMMATLABISSUE
%
% (c)2008 Athens Information Technology
%    Kostas Katrinis (kostas.katrinis@gmail.com)
%    Version 1.0
%     2010 Boston University - ECE
%    David Scott Freedman (dfreedma@bu.edu)
%    Version 1.3
%
import ch.ethz.ssh2.*
% import ch.ethz.ssh2.SFTPv3Client;
% import ch.ethz.ssh2.Connection;
% import ch.ethz.ssh2.Session;
% import ch.ethz.ssh2.SFTPv3FileHandle;
%
%  Invocation checks
%
  if(nargin  ~=  5)
    error('Error: SFTPFROMMATLAB requires 5 input arguments...');
  end
  if(~ischar(userName)  || ~ischar(hostName)  ||  ~ischar(password) || ~ischar(localfilename) || ~ischar(remotefilename))
    error...
      (['Error: SFTPFROMMATLAB requires all input ',...
      'arguments to be strings...']);
  end


%Set up the connection with the remote server

try
    channel  =  Connection(hostName);
    channel.connect();
catch
    error(['Error: SFTPFROMMATLAB could not connect to the'...
    ' remote machine %s ...'],hostName);
end 

%
%  Check the authentication for login...
%
  
isAuthenticated = channel.authenticateWithPassword(userName,password);
if(~isAuthenticated)
    error...
        (['Error: SFTPFROMMATLAB could not authenticate the',...
        ' SSH connection...']);  
end

%Open session
sftpcl = SFTPv3Client(channel);

%create files
localf=sftpcl.createFile(remotefilename);
remotef=sftpcl.openFileRW(remotefilename);

%transfer file byte by byte

count=0; 
buf = zeros(1,1024);
fileid = fopen(localfilename,'r');
[buf, bufsize] = fread(fileid, 1024);
try
    while(bufsize~=0)
        sftpcl.write(remotef,count,buf,0,bufsize);
        count=count+bufsize;
        [buf, bufsize] = fread(fileid, 1024);
    end   
catch
    error(['Error: SFTPFROMMATLAB could not write to the'...
        ' remote machine %s ...'],...
        hostName);
end
fclose(fileid);
% byte count
%count
sftpcl.close();
channel.close();  

