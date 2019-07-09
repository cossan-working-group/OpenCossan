function exportResults(Xobj,varargin)
%EXPORTRESULTS  This private methods of the class simulations is used
%to store the results of the simulation, i.e. the batches, on the
%disk
%
% Author: Edoardo Patelli
% Institute for Risk and Uncertainty, University of Liverpool, UK
% email address: openengine@cossan.co.uk
% Website: http://www.cossan.co.uk

% =====================================================================
% This file is part of OpenCossan.  The open general purpose matlab
% toolbox for numerical analysis, risk and uncertainty quantification.
%
% OpenCossan is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License.
%
% OpenCossan is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
% =====================================================================

import opencossan.OpenCossan

% Mesure the time required to store the output file
ndelta=OpenCossan.getTimer().lap('description','Store results on file system');


%% Process optional parameters
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case 'xsimulationoutput'
            assert(isa(varargin{k+1},'opencossan.common.outputs.SimulationData'), ...
                'openCOSSAN:simulation:exportResults',...
                'A simulation output is required after the property PropertyField %s', ...
                varargin{k});
            XOut=varargin{k+1};
        case 'xlinesamplingoutput'
            assert(isa(varargin{k+1},'opencossan.simulations.LineSamplingOutput'), ...
                'openCOSSAN:simulation:exportResults',...
                'A LineSamplingOutput is required after the property PropertyField %s', ...
                varargin{k});
            XOut=varargin{k+1};
        case 'xlinesamplingdata'
            assert(isa(varargin{k+1},'opencossan.simulations.LineSamplingData'), ...
                'openCOSSAN:simulation:exportResults',...
                'A LineSamplingData object is required after the property PropertyField %s', ...
                varargin{k});
            XOut=varargin{k+1};
        case 'xsubsetoutput'
            assert(isa(varargin{k+1},'opencossan.simulations.SubsetOutput'), ...
                'openCOSSAN:simulation:exportResults',...
                'A LineSamplingOutput is required after the property PropertyField %s', ...
                varargin{k});
            XOut=varargin{k+1};
        case 'sbatchname'
            SbatchName=varargin{k+1};
        case 'cadditionalobject'
            Cadditional=varargin{k+1};
        otherwise
            error('openCOSSAN:simulation:exportResults',...
                'PropertyName %s is not allowed',varargin{k})
    end
end

if isempty(Xobj.SbatchFolder)
    Xobj.SbatchFolder=datestr(now,30);
end

if ~exist('SbatchName','var')
    SbatchName=Xobj.SbatchName;
end

Sfullpath=fullfile(OpenCossan.getWorkingPath,Xobj.SbatchFolder);

OpenCossan.cossanDisp(['[Simulation:exportResults] Writing partial results (' SbatchName ') on the folder: ' Sfullpath],3)


%% Export results

% Create a folder to store the partial results
if ~exist([OpenCossan.getWorkingPath 'Xobj.SbatchFolder'],'dir')
    [status,mess] = mkdir(Sfullpath);
    if ~status
        warning('openCOSSAN:simulations:savePartialResults',mess)
    end
end

% Store SimulationData object
% Each component is saved separetly in order to avoid the matlab bug of the
% memory preallocation

% Store the status of the RandomStream
%SimOutReserved_RStream=RandStream.getGlobalStream; %#ok<NASGU>
SimOutReserved_RStream=OpenCossan.getRandomStream; %#ok<NASGU>

Sfullname=fullfile(Sfullpath,SbatchName);
%% Append all the optional arguments
if exist('XOut','var')
    save(Sfullname,'XOut');
    save(Sfullname,'-append','SimOutReserved_RStream');
else
    save(Sfullname,'SimOutReserved_RStream');
end

if exist('Cadditional','var')
    save(Sfullname,'-append',Cadditional);
end

OpenCossan.cossanDisp(['[Simulation:exportResults] Batch #' num2str(Xobj.ibatch) ' written in ' num2str(OpenCossan.getTimer().delta(ndelta))],4)
OpenCossan.cossanDisp(['[Simulation:exportResults] Results stored in the folder: ' Sfullname],4);


if ~isempty(OpenCossan.getDatabaseDriver)   % Add record to the Database
    if isempty(Xobj.Sdescription)
        Xobj.Sdescription='Not available';
    end
    %% Add record
    insertRecord(OpenCossan.getDatabaseDriver,'StableType','Simulation', ...
        'Nid',getNextPrimaryID(OpenCossan.getDatabaseDriver,'Simulation'),...
        'XsimulationData',XOut,'Nbatchnumber',Xobj.ibatch)
    
end


% Mesure the time required to store the output file
OpenCossan.getTimer().lap('description','End storing results on file system');
