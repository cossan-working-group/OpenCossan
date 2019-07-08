function [XSimOut,varargout] = runJob(Xc,varargin)
% RUNJOB runs a 3rd party code via a job management program
%
%   USAGE:  Xout=runJob(Xc,'PropertyName', PropertyValue, ...)
%
%  The run method runs a 3rd party software and returns a SimulationOuput object.
%  The 3rd party software is executed on a remote machine, submitting
%  the job using a job management program, defined in a JobManager object.
%
%  [Xout,Toutput]=runJob(Xc,'PropertyName', PropertyValue, ...) returns
%  the SimulationOuput object Xout and the structure of extracted values
%  (by means of the extractor object)
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/runJob@Connector
%

% $Copyright~1993-2014,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
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

% Default  values
LremoteInjectExtract = false;
XjobManager = [];

%% check input parameters
OpenCossan.cossanDisp(['openCOSSAN:Connector:runJob  - START -' datestr(clock)],2)
OpenCossan.validateCossanInputs(varargin{:});

for k=1:2:length(varargin) 
    switch lower(varargin{k})
        case{'lremoteinjectextract'}
            LremoteInjectExtract = varargin{k+1};
        case{'xjobmanager'}
            XjobManager = varargin{k+1};
        case{'pinput','xinput','tinput','xsamples','xsimulationdata'}
            switch class(varargin{k+1})
                case 'Input'
                    if varargin{k+1}.Xsamples.Nsamples==0 
                        % Use the default values (mean) of the
                        % RandomVariables if no samples are present in the
                        % Input object  
                        Tinput=get(varargin{k+1},'defaultvalues');
                    else
                        Tinput=getStructure(varargin{k+1});
                    end
                    assert (~isempty(Tinput), ...
                            'openCOSSAN:Connector:runJob:emplyInut',...
                            'The Input object is empty. ');                    
                case 'Samples'
                    Tinput=varargin{k+1}.Tsamples;
                case 'SimulationData'
                    Tinput = varargin{k+1}.Tvalues;
                case 'struct'
                    Tinput=varargin{k+1};
                otherwise
                    error('openCOSSAN:connector:runJob:wrongObject',...
                        'The input object of class %s is not supported.', class(varargin{1}));
            end
        otherwise
            error( 'openCOSSAN:Connector:runJob:wrongInputArgument',...
                'Property Name %s not valid',varargin{k})
    end
end

assert(~isempty(XjobManager),...
        'openCOSSAN:connector:runJob:noJoBManager',...
        'A JobManager object is required to run this method.')
    
if isempty(Xc.SfolderTimeStamp)
    Xc.SfolderTimeStamp = datestr(now,30);
end

%% call the appropriate private runJob method
if LremoteInjectExtract
    % call the right method for remote inject/extract run
    if OpenCossan.hasSSHConnection
       [XSimOut,Tout,LerrorFound] = Xc.runJobRemoteInjectExtractSSH(Tinput,XjobManager);
    else
       [XSimOut,Tout,LerrorFound] = Xc.runJobRemoteInjectExtract(Tinput,XjobManager);
    end
else
    % there is only one method for local inject/extract run
    [XSimOut,Tout,LerrorFound] = Xc.runJobLocalInjectExtract(Tinput,XjobManager);
end

varargout{1} = Tout;
varargout{2} = LerrorFound;

OpenCossan.cossanDisp(['COSSAN-X:connector:runJob  - STOP-' datestr(clock)],2)

end
