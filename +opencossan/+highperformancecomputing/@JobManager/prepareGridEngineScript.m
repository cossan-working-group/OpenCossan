function Sscriptname = prepareGridEngineScript(Xobj,NsimulationNumber)
% This method create a job script file for GridEngine in the cossan working
% path

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
% $Author: Matteo Broggi and Edoardo Patelli$

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

% Preparing job script
if ~exist('NsimulationNumber','var')
    Sscriptname = [Xobj.SjobScriptName '.sh'];
else
    Sscriptname = [Xobj.SjobScriptName num2str(NsimulationNumber) '.sh'];
end

Xssh = OpenCossan.getSSHConnection; % do not change this!
% create a new ASCII file
[Nfid, Serror] = fopen(fullfile(OpenCossan.getCossanWorkingPath,Sscriptname),'w'); 

assert(isempty(Serror),'openCOSSAN:JobManager:submit','Error: %s\n Path: %s', ...
                Serror,fullfile(OpenCossan.getCossanWorkingPath,Sscriptname))

OpenCossan.cossanDisp(['Open file ' fullfile(OpenCossan.getCossanWorkingPath,Sscriptname)],3);

 
if strcmp(Xobj.Sworkingdirectory,'./') || strcmp(Xobj.Sworkingdirectory,'.')
    % Use current directort 
    Xobj.Sworkingdirectory=[];
end

% define shell
fprintf(Nfid,'%s\n','#!/bin/bash');          
fprintf(Nfid,'%s\n','#$ -S /bin/bash');   

% use current working directory
fprintf(Nfid,'%s\n','#$ -cwd ');

if ~isempty(Xobj.Squeue)
    % select queue
    fprintf(Nfid,'%s\n',['#$ -q ' Xobj.Squeue]);   
end

if ~isempty(Xobj.Shostname)
    % select hostname
    fprintf(Nfid,'%s\n',['#$ -l hostname=' Xobj.Shostname]);
end % define shell

if ~isempty(Xobj.SparallelEnvironment)
    % select parallel environment and slots
    fprintf(Nfid,'%s\n',['#$ -pe ' Xobj.SparallelEnvironment...
        ' ' num2str(Xobj.Nslots)]);
end

% Save std error in the cwd
fprintf(Nfid,'%s\n',['#$ -e ' Xobj.Sfoldername '.err' ]);
% Save std output in the cwd
fprintf(Nfid,'%s\n',['#$ -o ' Xobj.Sfoldername '.out']);

% get the cwd
fprintf(Nfid,'%s\n','START_DIR=`pwd` ');

%% create subfolder and copy input files
if ~isempty(Xobj.Sfoldername)
    if ~OpenCossan.hasSSHConnection
        % change directory to the job work folder
        fprintf(Nfid,'%s\n',['cd ' fullfileunix(Xobj.Sworkingdirectory,Xobj.Sfoldername) ';']);
    else
        % change directory to the job work folder on the cluster
        fprintf(Nfid,'%s\n',['cd ' fullfileunix(Xssh.SremoteWorkFolder ,Xobj.Sfoldername) ';']);
    end
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

fprintf(Nfid,'%s\n','echo Script execution finished; date');

%% move results to the old directory
if ~isempty(Xobj.Sfoldername)
    % move stdout and stderr to the Sfoldername    
    if ~OpenCossan.hasSSHConnection
        fprintf(Nfid,'%s\n',['mv $START_DIR/' Xobj.Sfoldername '.err ' fullfileunix(Xobj.Sworkingdirectory,Xobj.Sfoldername)]);
        fprintf(Nfid,'%s\n',['mv $START_DIR/' Xobj.Sfoldername '.out ' fullfileunix(Xobj.Sworkingdirectory,Xobj.Sfoldername)]);
    else
        fprintf(Nfid,'%s\n',['mv $START_DIR/' Xobj.Sfoldername '.err ' fullfileunix(Xssh.SremoteWorkFolder,Xobj.Sfoldername)]);
        fprintf(Nfid,'%s\n',['mv $START_DIR/' Xobj.Sfoldername '.out ' fullfileunix(Xssh.SremoteWorkFolder,Xobj.Sfoldername)]);
    end
end

fclose(Nfid);

end

