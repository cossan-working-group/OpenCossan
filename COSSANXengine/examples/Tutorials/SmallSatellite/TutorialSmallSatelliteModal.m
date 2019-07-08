%% Tutorial Small Satellite - Create the NASTRAN model
%
% This tutorial shows how to perform SFEM analysis using Perturbation
% method. 
%
% Description of deterministic model:
%
% Tutorial satellite model is constructed in NASTRAN (~5000 DOFs). Modal
% analysis is performed on the structure, where the variation in the
% 2nd natural frequency is sought.
%
% Description of probabilistic model:
%
% The uncertainties in the Young's modulus and density are 
% modeled using independent normal RV's.  
%
% See also http://cossan.cfd.liv.ac.uk/wiki/index.php/
%
% Copyright 2006-2018 Cossan Working Group
% $Revision: 1 $  $Date: 2011/02/28 $

%% Create the input

% define the RVs
Evert   = RandomVariable('Sdistribution','normal', 'mean',7e6,'cov',0.15);    
Ehor    = RandomVariable('Sdistribution','normal', 'mean',7e6,'cov',0.15);
Ecyl    = RandomVariable('Sdistribution','normal', 'mean',7e6,'cov',0.15); 
Enozzle = RandomVariable('Sdistribution','normal', 'mean',7e6,'cov',0.15);

Dvert   = RandomVariable('Sdistribution','normal', 'mean',2700e-6,'cov',0.1); 
Dhor    = RandomVariable('Sdistribution','normal', 'mean',2700e-6,'cov',0.1); 
Dcyl    = RandomVariable('Sdistribution','normal', 'mean',2700e-6,'cov',0.1);    
Dnozzle = RandomVariable('Sdistribution','normal', 'mean',2700e-6,'cov',0.1);   

Xrvs = RandomVariableSet('Cmembers',{'Evert','Ehor','Ecyl','Enozzle',...
                                     'Dvert','Dhor','Dcyl','Dnozzle'}); 
Xinp = Input('Sdescription','Xinput object');       
Xinp = add(Xinp,Xrvs);

%% Construct the Model

Sdirectory = fileparts(which('TutorialSmallSatelliteModal'));
Xinj       = Injector('Sscanfilepath',fullfile(Sdirectory,'FEinputFiles'),'Sscanfilename','Modal.cossan',...
                      'Sfile','Modal.inp');
Xcon       = Connector('SpredefinedType','nastran_x86_64',...
                     'SmaininputPath',fullfile(Sdirectory,'FEinputFiles'),...
                     'Smaininputfile','Modal.dat');
Xcon       = add(Xcon,Xinj);
Xeval      = Evaluator('Xconnector',Xcon,'CSmembers',{'Xcon'});
Xmodel     = Model('Xevaluator',Xeval,'Xinput',Xinp);

display(Xmodel);


%% Define a SSH connection with the Risk Cluster

% Be sure you can connect without password using private key.
% To generate the privite key follow the next steps
% (https://www.linuxtrainingacademy.com/ssh-login-without-password/)
% 1. Create an SSH Key
% !ssh-keygen
% 2. Copy the SSH Public Key to the Remote Host
% ! ssh-copy-id iru1.liv.ac.uk
% 3. Login to the Remote Host Without a Password
% ! ssh iru1.liv.ac.uk

Susername=input('Define username: ','s');

% Assume that the user can connect without a password
%Spassword = input('Define password: ','s');
SsshPrivateKey = input('Path to the private key: ','s');
            
%
SSHConnection('SSSHhost','iru1.liv.ac.uk','SSSHuser',Susername,...% we need an unprivileged user dedicated to tests
              'SremoteWorkFolder',fullfileunix('/home',Susername,'tmp'),...
              'SsshPassword','',... 
              'SsshPrivateKey',SsshPrivateKey,...
              'SremoteMCRPath','/Apps/MATLAB/MATLAB_Compiler_Runtime/v91',...
              'SremoteExternalPath',fullfileunix('/Apps/OpenCossan')); % we need a distributed OpenSourceSoftware on the server
                % try a command via ssh
                out = OpenCossan.issueSSHcommand('ls -la');


