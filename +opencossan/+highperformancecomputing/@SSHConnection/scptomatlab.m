function scptomatlab(userName,hostName,password,localFolder,remotefilename)
%SCPTOMATLAB connects Matlab to a remote computer and uploads
%a file using the SFTP protocol
%
% STATUS  =  SCPTOMATLAB(USERNAME,HOSTNAME,PASSWORD,LOCALFILENAME,REMOTEFILENAME)
%
% Inputs:
%   USERNAME is the user name required for the remote machine
%   HOSTNAME is the name of the remote machine
%   PASSWORD is the password for the account USERNAME@HOSTNAME
%   LOCALFOLDER is the fully qualified path of the folder to copy the file
%   to
%   REMOTEFILENAME is the fully qualified path where the file will be
%   stored at the remote computer
%
% See also SCPTOMATLAB, SSHFROMMATLAB, SSHFROMMATLABCLOSE, SSHFROMMATLABINSTALL, SSHFROMMATLABISSUE
%
% (c) 2010 Boston University - ECE
%    David Scott Freedman (dfreedma@bu.edu)
%    Version 1.3
%

% import ch.ethz.ssh2.SCPClient;
% import ch.ethz.ssh2.Connection;
% import ch.ethz.ssh2.Session;
import ch.ethz.ssh2.*;
%
%  Invocation checks
%
  if(nargin  ~=  5)
    error('Error: SCPTOMATLAB requires 5 input arguments...');
  end
  if(~ischar(userName)  || ~ischar(hostName)  ||  ~ischar(password) || ~ischar(localFolder) || ~ischar(remotefilename))
    error...
      (['Error: SCPTOMATLAB requires all input ',...
      'arguments to be strings...']);
  end


%Set up the connection with the remote server

try
    channel  =  Connection(hostName);
    channel.connect();
catch
    error(['Error: SCPTOMATLAB could not connect to the'...
    ' remote machine %s ...'],hostName);
end 

%
%  Check the authentication for login...
%
  
isAuthenticated = channel.authenticateWithPassword(userName,password);
if(~isAuthenticated)
    error...
        (['Error: SCPTOMATLAB could not authenticate the',...
        ' SSH connection...']);  
end

%Open session
scp1 = SCPClient(channel);

scp1.get(remotefilename,localFolder);

channel.close();  

