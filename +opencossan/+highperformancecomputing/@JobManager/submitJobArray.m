function CSjobID = submitJobArray(Xobj,varargin)
% submit a job array to a job manager
%
% See also: https://cossan.co.uk/wiki/index.php/submitJob@JobManagerArray
%
% Author: Matteo Broggi & Edoardo Patelli
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

%% Process optional inputs
% NOTE: all the optional input parameters are properties of the jobmanager
% object
%
OpenCossan.validateCossanInputs(varargin{:})

Lresubmit = false;

for iopt=1:2:length(varargin)
    switch lower(varargin{iopt})
        case {'ntotaljobs'}
            Ntotaljobs = varargin{iopt+1}; % mandatory
        case {'sfoldername'}
            Xobj.Sfoldername = varargin{iopt+1}; % not mandatory
        case {'lresubmit'}
            Lresubmit = varargin{iopt+1}; % not mandatory, default false
        otherwise
            error('openCOSSAN:JobManager:submit',...
                'PropertyName %s not allowed',varargin{iopt});
    end
end

if isinf(Xobj.Nconcurrent)
    Xobj.Nconcurrent = Ntotaljobs;
end

OpenCossan.cossanDisp(['OpenCOSSAN:JobManager:submitJobArray  - START -' datestr(clock)],3);

%% check if the defined hostname is available
if ~isempty(Xobj.Shostname)
    if ~Xobj.Xjobmanagerinterface.checkHost('Shostname',Xobj.Shostname,'SqueueName',Xobj.Squeue)
        error('openCOSSAN:JobManager:submit',...
            ['Specified hostname (%s) is not available to receive jobs.' ...
            '\n Please check the gridmanager configuration or' ...
            ' contact your system administrator.'],Xobj.Shostname);
    end
end

if ~Lresubmit
    %% create the job script file
    % TODO: improve the script file/job name by getting it from the
    % analysis instead of using always "CossanJob"
    
    if strcmpi(Xobj.Xjobmanagerinterface.Stype,'gridengine')
        Sscriptname = Xobj.prepareGridEngineArrayScript();
    elseif strcmpi(Xobj.Xjobmanagerinterface.Stype,'lsf')
        Sscriptname = Xobj.prepareLSFArrayScript();
    else
        % this error should never be reached, but is kept in case the user
        % manually alter the property SsubmitJob of JobManagerInterface
        error('openCOSSAN:JobManager:submit',...
            'Unsupported submission command: %s',Xobj.Xjobmanagerinterface.SsubmitJob)
    end
else
    %% check that the scriptfile exists
    Sscriptname = [Xobj.SjobScriptName '.sh'];
    assert(logical(exist(fullfile(OpenCossan.getCossanWorkingPath,Sscriptname),'file')),...
        'openCOSSAN:JobManager:submit',...
        ['Cannot resubmit the job. Job script file ' Sscriptname ' does not exist.']);
end
if OpenCossan.hasSSHConnection
    XsshConnection = OpenCossan.getSSHConnection();
    warning('off','openCOSSAN:SSHConnection:putFile') % suppress overwrite warning
    % copy the script file to the remote host
    XsshConnection.putFile('SlocalFileName',fullfile(OpenCossan.getCossanWorkingPath,Sscriptname),...
        'SremoteDestinationFolder',XsshConnection.SremoteWorkFolder);
    warning('on','openCOSSAN:SSHConnection:putFile')
end

%% Submit the job
if OpenCossan.hasSSHConnection
    % this is the location of the submission script on the head node when
    % SSH is used
    Sscriptname = fullfileunix(XsshConnection.SremoteWorkFolder,Sscriptname);
    
    % TODO: I think it should be the following
    %Sscriptname = fullfileunix(OpenCossan.XsshConnection.SremoteWorkFolder,Sscriptname);
else
    % this is the location of the submission script on the head node when
    % SSH is not used
    Sscriptname = fullfile(OpenCossan.getCossanWorkingPath,Sscriptname);
end

if strcmpi(Xobj.Xjobmanagerinterface.Stype,'gridengine')
    string=[Xobj.Xjobmanagerinterface.SsubmitJob ' -V -N ' Xobj.Sjobname ' -t 1-' num2str(Ntotaljobs) ' -tc ' num2str(Xobj.Nconcurrent)  ' ' Sscriptname];   
elseif strcmpi(Xobj.Xjobmanagerinterface.Stype,'lsf')
    % TODO: implement job array for LSF -> read the manual!!!!!
    string=[Xobj.Xjobmanagerinterface.SsubmitJob ' -J '  Xobj.Sjobname  ' < ' Sscriptname];
end

if ~OpenCossan.hasSSHConnection
    OpenCossan.cossanDisp(['Submitted cmd: '  string],3);
else
    OpenCossan.cossanDisp(['Submitted SSH cmd: '  string],3);
end

if ~OpenCossan.hasSSHConnection
    [status, SsubmitJobOut]=system(string);
else
    [status, SsubmitJobOut]=OpenCossan.issueSSHcommand(string);
end

assert(status==0,'openCOSSAN:JobManager:submit','Non-zero output status from qsub command')

OpenCossan.cossanDisp(SsubmitJobOut,3);

% retrieve the job number using a regular expression extracting numbers
CSjobID = regexp(SsubmitJobOut,'\d+','match');
if isempty(CSjobID)
    error('openCOSSAN:JobManager:submit',['No job ID found! Status job: ' SsubmitJobOut]);
end
% keep only the first number as job ID
if length(CSjobID)>1
    CSjobID = CSjobID(1);
end

OpenCossan.cossanDisp(['COSSAN-X:JobManager:submit  - STOP -' datestr(clock)],3);
end


