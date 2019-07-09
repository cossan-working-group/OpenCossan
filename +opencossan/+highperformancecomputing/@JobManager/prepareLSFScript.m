function Sscriptname = prepareLSFScript(Xobj, NsimulationNumber)
% This method create a job script file for LSF/OpenLava

% OpenCossan.getCossanWorkingPath: working path (this should be folder where all
%           the final analysis are stored). It should be on the local machine if
%           SSHconnection is used otherwise is a shared folder
%
% SSHConnection.SremoteWorkFolder --> folder on the head node (shared?)
%
% JobManager.Sworkingdirectory --> This should be a local working folder (not
%                                  necessary a shared folder)
%
% TODO: add -u valid email (the email are not sent by the cluster, yet).
%
%

Xssh = OpenCossan.getSSHConnection();

% Preparing job script
if ~exist('NsimulationNumber','var')
    Sscriptname = [Xobj.SjobScriptName '.sh'];
else
    Sscriptname = [Xobj.SjobScriptName num2str(NsimulationNumber) '.sh'];
end

% create a new ASCII file
[Nfid, Serror] = fopen(fullfile(OpenCossan.getCossanWorkingPath,Sscriptname),'w'); 

assert(isempty(Serror),'openCOSSAN:JobManager:submit','Error: %s\n Path: %s', ...
                Serror,fullfile(OpenCossan.getCossanWorkingPath,Sscriptname))

OpenCossan.cossanDisp(['Open file ' fullfile(OpenCossan.getCossanWorkingPath,Sscriptname)],3);

% define shell
fprintf(Nfid,'%s\n','#!/bin/bash');

if ~isempty(Xobj.Squeue)
    % select queue
    fprintf(Nfid,'%s\n',['#BSUB -q ' Xobj.Squeue]);   
end

if ~isempty(Xobj.Shostname)
    % select hostname
    fprintf(Nfid,'%s\n',['#BSUB -m ' Xobj.Shostname]);
end

if ~isempty(Xobj.Nslots)
    % select number of slots
    fprintf(Nfid,'%s\n',['#BSUB -n ' num2str(Xobj.Nslots)]); % support for [lb,ub]?
end

if ~OpenCossan.hasSSHConnection
    % Save std error
    fprintf(Nfid,'%s\n',['#BSUB -e ' fullfileunix(Xobj.Sworkingdirectory,Xobj.Sfoldername,Xobj.Sfoldername) '.err' ]);
    % Save std output
    fprintf(Nfid,'%s\n',['#BSUB -o ' fullfileunix(Xobj.Sworkingdirectory,Xobj.Sfoldername,Xobj.Sfoldername) '.out']);
else
    % Save std error
    fprintf(Nfid,'%s\n',['#BSUB -e ' fullfileunix(Xssh.SremoteWorkFolder,Xobj.Sfoldername,Xobj.Sfoldername) '.err' ]);
    % Save std output
    fprintf(Nfid,'%s\n',['#BSUB -o ' fullfileunix(Xssh.SremoteWorkFolder,Xobj.Sfoldername,Xobj.Sfoldername) '.out']);
end
fprintf(Nfid,'%s\n','#BSUB -N');         % suppress job report in output redirect

% get the cwd
fprintf(Nfid,'%s\n','START_DIR=`pwd` ');

%% create subfolder and copy input files
if ~isempty(Xobj.Sfoldername) && ~isempty(Xobj.Sworkingdirectory)
    % if there is ssh connection, the files have been already copyed to the
    % remote host in the remote working directory
    fprintf(Nfid,'%s\n',['mkdir -p ' fullfileunix(Xobj.Sworkingdirectory,Xobj.Sfoldername) ';']);
    if ~OpenCossan.hasSSHConnection
        fprintf(Nfid,'%s\n',['cp ' fullfileunix(OpenCossan.getCossanWorkingPath,Xobj.Sfoldername)...
            ' ' Xobj.Sworkingdirectory ' -R;']);
    else
        fprintf(Nfid,'%s\n',['cp ' fullfileunix(Xssh.SremoteWorkFolder,Xobj.Sfoldername)...
            ' ' Xobj.Sworkingdirectory ' -R;']);
    end
    fprintf(Nfid,'%s\n',['cd ' fullfileunix(Xobj.Sworkingdirectory,Xobj.Sfoldername) ';']);
end

fprintf(Nfid,'%s\n','echo Script execution started; date');


%% Add MCR Pre-execution command
if ~isempty(Xobj.Xjobmanagerinterface.SMCRpreexec)
    fprintf(Nfid,'%s\n',Xobj.Xjobmanagerinterface.SMCRpreexec);
end

%% Add preprocessor cmd
if ~isempty(Xobj.Spreexecmd)
    fprintf(Nfid,'%s\n',Xobj.Spreexecmd);
end

%% Write hostname on the out file
fprintf(Nfid,'%s\n','hostname');
%% Main code
fprintf(Nfid,'%s\n',[Xobj.Sexecmd ' ' Xobj.Sexeflags]);

%% Add Postprocessor
if ~isempty(Xobj.Spostexecmd)
    fprintf(Nfid,'%s\n',Xobj.Spostexecmd);
end
%% Add MCR Post-execution command
if ~isempty(Xobj.Xjobmanagerinterface.SMCRpostexec)
    fprintf(Nfid,'%s\n',Xobj.Xjobmanagerinterface.SMCRpostexec);
end

%% copy back files from execution folder
if OpenCossan.hasSSHConnection
    fprintf(Nfid,'%s\n',['cp ' fullfileunix(Xobj.Sworkingdirectory,Xobj.Sfoldername)...
        ' ' fullfileunix(Xssh.SremoteWorkFolder) ' -Ru;']);    
end

fprintf(Nfid,'%s\n','echo Script execution finished; date');

fclose(Nfid);

end

