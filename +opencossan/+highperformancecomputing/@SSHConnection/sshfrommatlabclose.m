function channel  =  sshfrommatlabclose(channel)
%SSHFROMMATLABCLOSE disconnects Matlab from a remote machine
%
%  CHANNEL  =  SSHFROMMATLABCLOSE(CHANNEL)
%
%   where CHANNEL is the Java ChannelShell object to disconnect
%
% See also SSHFROMMATLAB, SSHFROMMATLABINSTALL, SSHFROMMATLABISSUE
%
% (c) 2008 British Oceanographic Data Centre
%    Adam Leadbetter (alead@bodc.ac.uk)
%     2010 Boston University - ECE
%    David Scott Freedman (dfreedma@bu.edu)
%    Version 1.3
%
  if(nargin  ~=  1)
    error('Error: SSHFROMMATLABCLOSE requires one input argument...');
  end
%
%  Disconnect the Java object using the java method if it is of the correct
%  class, if not quit with an error
%
  if(isa(channel,'ch.ethz.ssh2.Connection'))
    channel.close();
  else
    error(['Error: SSHFROMMATLABCLOSE input argument CHANNEL is'...
      ' not a Java Connection object...']);
  end