function channel  =  sshfrommatlab_publickey_file(userName,hostName,private_key, private_key_password)
%SSHFROMMATLAB_PUBLICKEY_FILE connects Matlab to a remote computer via a
%secure shell using a private key file
%
% CONN  =  SSHFROMMATLAB_PUBLICKEY_FILE(USERNAME,HOSTNAME,PRIVATE_KEY,PRIVATE_KEY_PASSWORD)
%
% Inputs:
%   USERNAME is the user name required for the remote machine
%   HOSTNAME is the name of the remote machine
%   PRIVATE_KEY is the Private Key file path
%   PRIVATE_KEY_PASSWORD is the password for the PRIVATE_KEY
%
% Outputs:
%   CONN is a Java ch.ethz.ssh2.Connection object
%
% See also SSHFROMMATLABCLOSE, SSHFROMMATLABINSTALL, SSHFROMMATLABISSUE
%
% (c) 2008 British Oceanographic Data Centre
%    Adam Leadbetter (alead@bodc.ac.uk)
%     2010 Boston University - ECE
%    David Scott Freedman (dfreedma@bu.edu)
%    Version 1.3
%

%
%  Invocation checks
%
  try 
      import java.io.File;
  catch
      error('Error: SSHFROMMATLAB_PUBLICKEY_FILE cannot load java.io.File...');
  end

  if(nargin  ~=  4)
    error('Error: SSHFROMMATLAB_PUBLICKEY_FILE requires 3 input arguments...');
  end
  if(~ischar(userName)  || ~ischar(hostName)  ||   ~ischar(private_key) ||  ~ischar(private_key_password) )
    error...
      (['Error: SSHFROMMATLAB_PUBLICKEY_FILE requires all input ',...
      'arguments to be strings...']);
  end
%
%  Build the connection using the JSch package
%
  try
    import ch.ethz.ssh2.*;
    try
      channel  =  Connection(hostName);
      channel.connect();
    catch
      error(['Error: SSHFROMMATLAB_PUBLICKEY_FILE could not connect to the'...
        ' remote machine %s ...'],...
        hostName);
    end
  catch
    error('Error: SSHFROMMATLAB_PUBLICKEY_FILE could not find the SSH2 java package');
  end
  
%
% Load Private Key File
%
 try
     private_key_file_handle = java.io.File(private_key);
 catch
     error(['Error: SSHFROMMATLAB_PUBLICKEY_FILE could not open private key file'...
        ' %s ...'],...
        private_key);
 end

%
%  Check the authentication for login...
%
  isAuthenticated = channel.authenticateWithPublicKey(userName,private_key_file_handle,private_key_password);
  if(~isAuthenticated)
    error...
      (['Error: SSHFROMMATLAB_PUBLICKEY_FILE could not authenticate the',...
        ' SSH connection...']);
  end
  
  