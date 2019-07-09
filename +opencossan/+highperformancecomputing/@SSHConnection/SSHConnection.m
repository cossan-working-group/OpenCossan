classdef SSHConnection < handle
    % SSHConnection This class defines an SSH connection to an host and
    % allows for remote command execution and file/directory transfer
    % from/to a remote host
    %
    % See also: https://cossan.co.uk/wiki/index.php/@SSHConnection
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
    properties
        Sdescription    % Description of the object
        SsshUser        % Username to connect with SSH
        SsshHost        % Host to connect to with SSH (i.e., cluster head node)
        SsshPrivateKey  % Path to the SSH private key file
        SremoteWorkFolder % Working directory on the remote machine
        SremoteMCRPath  % Path to the MCR installed on the remote host
        SremoteCossanRoot % Path to the Cossan installed on the remote host
        SremoteExternalPath % Path to the OpenSourceSoftware installed on the remote host
        JsshConnection  % Java object storing the SSH channel
    end
    
    properties (Access=private)
        SsshPassword    % SSH Password - WARNING!!! it is saved in plain text!!!
        SkeyPassword = '';
    end
    
    properties (Transient=true)
        SremoteHome % home folder on the remote host
    end
    
    properties (Constant)
        maxbuffer = 32768; % maximum value of SFTP buffer for read as implemented
    end
    
    methods
        
        function Xobj = SSHConnection(varargin)
            % SSHConnection This class defines an SSH connection to an host and
            % allows for remote command execution and file/directory transfer
            % from/to a remote host
            %
            % See also: https://cossan.co.uk/wiki/index.php/@SSHConnection
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

            %% Process inputs
            opencossan.OpenCossan.validateCossanInputs(varargin{:})
            
            if nargin==0
                return
            end
            
            % Get SSHConnection from OpenCossan
            if isa(OpenCossan.getSSHConnection,'SSHConnection')
                Xobj=OpenCossan.getSSHConnection;
            end
            
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case 'sdescription'
                        Xobj.Sdescription = varargin{k+1};
                    case 'ssshuser'
                        Xobj.SsshUser = varargin{k+1};
                    case 'ssshhost'
                        Xobj.SsshHost = varargin{k+1};
                    case 'ssshprivatekey'
                        Xobj.SsshPrivateKey = varargin{k+1};
                    case 'ssshpassword'
                        Xobj.SsshPassword = varargin{k+1};
                    case 'skeypassword'
                        Xobj.SkeyPassword = varargin{k+1};
                    case 'sremoteworkfolder'
                        Xobj.SremoteWorkFolder = varargin{k+1};
                    case 'sremotemcrpath'
                        Xobj.SremoteMCRPath = varargin{k+1};
                    case 'sremotecossanroot'
                        Xobj.SremoteCossanRoot = varargin{k+1};
                    case 'sremoteexternalpath'
                        Xobj.SremoteExternalPath = varargin{k+1};
                    otherwise
                        error('openCOSSAN:SSHConnection',...
                             'PropertyName name (%s) not allowed',varargin{k});
                end
            end
            
            % check that mandatory input arguments have been passed
            if isempty(Xobj.SsshUser) || isempty(Xobj.SsshHost)
                error('openCOSSAN:SSHConnection',...
                    'User name and host name are necessary to initialize a SSH connection')
            end
            if ~xor(isempty(Xobj.SsshPrivateKey),isempty(Xobj.SsshPassword))
                error('openCOSSAN:SSHConnection',...
                    'Either the password or the private key file location must be passed')
            end
            
            % if the description is empty, set it to the default value
            if isempty(Xobj.Sdescription)
                Xobj.Sdescription = ['SSH connection to ' Xobj.SsshHost];
            end
            
            % check that the Jar for SSH connection is available in the
            % classpath
            jpath = javaclasspath('-all');
            assert(~isempty(cell2mat(regexpi(jpath,'ganymed-ssh2-261.jar'))),...
                'openCOSSAN:SSHConnection','ganymed ssh2 java class not available in class path')
            
            try
                % if no remote work directory is specified, set it to the
                % remote home
                if isempty(Xobj.SremoteWorkFolder)
                    Xobj.SremoteWorkFolder = Xobj.SremoteHome;
                end
            catch me
                % Something failed while creating/checking/connecting on
                % the remote host. In order to avoid problems with a
                % partially set SSHconnection object in the global
                % OPENCOSSAN, reset the global object property to an empty
                % object an then rethrow the last error
                Xobj = SSHConnection();
                rethrow(me);
            end
            
        end
        
        function Xobj = openSSHconnection(Xobj)
            
            %% Initialize SSH connection
            if ~isempty(Xobj.SsshUser) && ~isempty(Xobj.SsshHost)
                if ~isempty(Xobj.SsshPrivateKey) && exist(Xobj.SsshPrivateKey,'file')
                    % check that the path to the private key is an absolute path
                    assert(~strcmpi(Xobj.SsshPrivateKey(1),'.'),...
                        'The path to the private key must be an absolute path');
                    % check if the path to the key uses the ~
                    if strcmpi(Xobj.SsshPrivateKey(1),'~')
                        % remove the tilde and put the full home (the java
                        % class used does not find the file if ~ is used)
                        Xobj.SsshPrivateKey = [getenv('HOME') Xobj.SsshPrivateKey(2:end)];
                    end
                    Xobj.JsshConnection = opencossan.highperformancecomputing.SSHConnection.sshfrommatlab_publickey_file...
                        (Xobj.SsshUser,Xobj.SsshHost,Xobj.SsshPrivateKey,Xobj.SkeyPassword);
                elseif ~isempty(Xobj.SsshPassword)
                    warning('openCOSSAN:SSHConnection',...
                        'SECURITY WARNING: The password is viewable and saved in plain text!')
                    Xobj.JsshConnection = opencossan.highperformancecomputing.SSHConnection.sshfrommatlab(Xobj.SsshUser,...
                        Xobj.SsshHost,Xobj.SsshPassword);
                else
                    error('openCOSSAN:SSHConnection',...
                        ['Either the full path to the private key or '...
                        'the password are necessary to initialize an SSH connection']);
                end
            end
        end
        
        function checkWorkingFolder(Xobj)
            %% check that the remote working folder exists on the remote host
            % This work only if the remote machine is running linux, but do
            % we expect to connect to a Windows cluster? :)
            
            if isempty(Xobj.JsshConnection) || ~Xobj.JsshConnection.isAuthenticationComplete
                Xobj.openSSHconnection;
            end
            
            % bash command to check that directory exists
            % TODO: what if bash is not used???
            Nstatus = Xobj.issueCommand(['[ -d ' Xobj.SremoteWorkFolder ' ]']);
            if Nstatus==0
                OpenCossan.cossanDisp(['openCOSSAN:SSHConnection:checkWorkingFolder ' ...
                    ' Working directory ' Xobj.SremoteWorkFolder ' already exists on remote host'],2)
            else
                % bash command to check that a file exists
                Nstatus = Xobj.issueCommand(['[ -f ' Xobj.SremoteWorkFolder ' ]']);
                if Nstatus==0
                    error('openCOSSAN:SSHConnection:checkWorkingFolder',...
                        'A file named %s already exists on the remote machine',...
                        Xobj.SremoteWorkFolder)
                else
                    Nstatus = Xobj.issueCommand(['mkdir ' Xobj.SremoteWorkFolder]);
                    assert(Nstatus==0,'openCOSSAN:SSHConnection:checkWorkingFolder',...
                        'Error creating the remote working folder')
                    OpenCossan.cossanDisp(['openCOSSAN:SSHConnection:initializeSSHconnection ' ...
                        ' Working directory ' Xobj.SremoteWorkFolder ' created on remote host'],2)
                end
            end
            
        end
        
        function Xobj = closeSSHconnection(Xobj)
            if ~isempty(Xobj.JsshConnection)
                % if it is connected, close the connection and remove the
                % java object
                Xobj.JsshConnection = ...
                    opencossan.highperformancecomputing.SSHConnection.sshfrommatlabclose(Xobj.JsshConnection);
                Xobj.JsshConnection = [];
            else
                
            end
        end
        
        function delete(Xobj)
            % object destructor
            if ~isempty(Xobj.JsshConnection)
                % close ssh connection before clearing the object
                Xobj.closeSSHconnection;
            end
        end
        
        function Lempty = isempty(Xobj)
            % check if all the public, non-costant properties of the object
            % are empty
            Lempty = isempty(Xobj.Sdescription) && ...
                isempty(Xobj.SsshUser) && ...
                isempty(Xobj.SsshHost) && ...
                isempty(Xobj.SsshPrivateKey) && ...
                isempty(Xobj.SremoteWorkFolder) && ...
                isempty(Xobj.SremoteMCRPath) && ...
                isempty(Xobj.SremoteCossanRoot) && ...
                isempty(Xobj.SremoteExternalPath) && ...
                isempty(Xobj.JsshConnection);        
        end
        
        function SremoteHome = get.SremoteHome(Xobj)
            
            if isempty(Xobj.JsshConnection)
                % if the user has not yet connect to the remote host,
                % connects to it, get the remote home and disconnect
                Xobj.openSSHconnection;
                [~,SremoteHome] = Xobj.issueCommand('echo $HOME');
                Xobj.closeSSHconnection;
            else
                % if the user is already connected to the remote host, get
                % the remote home
                [~,SremoteHome] = Xobj.issueCommand('echo $HOME');
            end
            % remove the extra new line at the end of the string
            SremoteHome = SremoteHome(1:end-1);
        end
        
        function set.SremoteWorkFolder(Xobj,SremoteWorkFolder)
            assert(~isempty(SremoteWorkFolder),'openCOSSAN:SSHConnection:set',...
                'It is mandatory to specify a remote working folder')
            assert(strcmp(SremoteWorkFolder(1),'/'),'openCOSSAN:SSHConnection:set',...
                'It is mandatory to specify an absolute path for the remote working folder')
            Xobj.SremoteWorkFolder=SremoteWorkFolder;
            Xobj.checkWorkingFolder();
        end
        
        putFile(Xobj,varargin)
        putDir(Xobj,varargin)
        getFile(Xobj,varargin)
        getDir(Xobj,varargin)
        [status, result]  =  issueCommand(Xobj,Scommand)
        
    end
    
    methods (Static)
        % this are some functions from the sshfrommatlab toolbox (see
        % license.txt)
        channel  =  sshfrommatlab(userName,hostName,password)
        channel  =  sshfrommatlab_publickey_file(userName,hostName,private_key, private_key_password)
        channel  =  sshfrommatlabclose(channel)
    end
    
    
end