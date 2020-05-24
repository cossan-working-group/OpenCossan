function Sscriptname = prepareScript(obj,taskNumber)
% This method creates a job script for Slurm 

% OpenCossan.getCossanWorkingPath: working path (this should be folder where all
%           the final analysis are stored). It should be on the local machine if
%           SSHconnection is used otherwise is a shared folder
%
% SSHConnection.SremoteWorkFolder --> folder on the head node (shared?)
%
% JobManager.Sworkingdirectory --> This should be a local working folder (not
%                                  necessary a shared folder)
%
% TODO: add -M valid email  and -m be (the email are not sent by the cluster,
% yet).
%
% See Also:
% http://cossan.co.uk/wiki/index.php/prepareGridEngineScript@JobManager
%
% $Copyright~1993-2014,~COSSAN~Working~Group,~University~of~Liverpool,~UK$
% $Author:  Edoardo Patelli$


% Preparing job script
if ~exist('NsimulationNumber','var')
    Sscriptname = [obj.SjobScriptName '.sh'];
else
    Sscriptname = [obj.SjobScriptName num2str(taskNumber) '.sh'];
end

Xssh = OpenCossan.getSSHConnection; % do not change this!
% create a new ASCII file
[Nfid, Serror] = fopen(fullfile(OpenCossan.getCossanWorkingPath,Sscriptname),'w'); 

assert(isempty(Serror),'openCOSSAN:JobManager:submit','Error: %s\n Path: %s', ...
                Serror,fullfile(OpenCossan.getCossanWorkingPath,Sscriptname))

OpenCossan.cossanDisp(['Open file ' fullfile(OpenCossan.getCossanWorkingPath,Sscriptname)],3);

 
if strcmp(obj.Sworkingdirectory,'./') || strcmp(obj.Sworkingdirectory,'.')
    % Use current directort 
    obj.Sworkingdirectory=[];
end

% define shell
fprintf(Nfid,'%s\n','#!/bin/bash');          
fprintf(Nfid,'%s\n','#$ -S /bin/bash');   

% use current working directory
fprintf(Nfid,'%s\n','#$ -cwd ');

if ~isempty(obj.Squeue)
    % select queue
    fprintf(Nfid,'%s\n',['#$ -q ' obj.Squeue]);   
end

if ~isempty(obj.Shostname)
    % select hostname
    fprintf(Nfid,'%s\n',['#$ -l hostname=' obj.Shostname]);
end % define shell

if ~isempty(obj.SparallelEnvironment)
    % select parallel environment and slots
    fprintf(Nfid,'%s\n',['#$ -pe ' obj.SparallelEnvironment...
        ' ' num2str(obj.Nslots)]);
end

% Save std error in the cwd
fprintf(Nfid,'%s\n',['#$ -e ' obj.Sfoldername '.err' ]);
% Save std output in the cwd
fprintf(Nfid,'%s\n',['#$ -o ' obj.Sfoldername '.out']);

% get the cwd
fprintf(Nfid,'%s\n','START_DIR=`pwd` ');

%% create subfolder and copy input files
if ~isempty(obj.Sfoldername)
    if ~OpenCossan.hasSSHConnection
        % change directory to the job work folder
        fprintf(Nfid,'%s\n',['cd ' fullfileunix(obj.Sworkingdirectory,obj.Sfoldername) ';']);
    else
        % change directory to the job work folder on the cluster
        fprintf(Nfid,'%s\n',['cd ' fullfileunix(Xssh.SremoteWorkFolder ,obj.Sfoldername) ';']);
    end
end

fprintf(Nfid,'%s\n','echo Script execution started; date');


%% Add MCR Pre-execution command
if ~isempty(obj.Xjobmanagerinterface.SMCRpreexec)
    fprintf(Nfid,'%s\n',obj.Xjobmanagerinterface.SMCRpreexec);
end

%% Add preprocessor cmd
if ~isempty(obj.Spreexecmd)
    fprintf(Nfid,'%s\n',obj.Spreexecmd);
end

%% Write hostname on the out file
fprintf(Nfid,'%s\n','hostname');
%% Main code
fprintf(Nfid,'%s\n',[obj.Sexecmd ' ' obj.Sexeflags]);

%% Add Postprocessor
if ~isempty(obj.Spostexecmd)
    fprintf(Nfid,'%s\n',obj.Spostexecmd);
end
%% Add MCR Post-execution command
if ~isempty(obj.Xjobmanagerinterface.SMCRpostexec)
    fprintf(Nfid,'%s\n',obj.Xjobmanagerinterface.SMCRpostexec);
end

fprintf(Nfid,'%s\n','echo Script execution finished; date');

%% move results to the old directory
if ~isempty(obj.Sfoldername)
    % move stdout and stderr to the Sfoldername    
    if ~OpenCossan.hasSSHConnection
        fprintf(Nfid,'%s\n',['mv $START_DIR/' obj.Sfoldername '.err ' fullfileunix(obj.Sworkingdirectory,obj.Sfoldername)]);
        fprintf(Nfid,'%s\n',['mv $START_DIR/' obj.Sfoldername '.out ' fullfileunix(obj.Sworkingdirectory,obj.Sfoldername)]);
    else
        fprintf(Nfid,'%s\n',['mv $START_DIR/' obj.Sfoldername '.err ' fullfileunix(Xssh.SremoteWorkFolder,obj.Sfoldername)]);
        fprintf(Nfid,'%s\n',['mv $START_DIR/' obj.Sfoldername '.out ' fullfileunix(Xssh.SremoteWorkFolder,obj.Sfoldername)]);
    end
end

fclose(Nfid);

end

