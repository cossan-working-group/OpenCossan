function exportResults(Xobj,varargin)
%EXPORTRESULTS  This private methods of the class optimizer is used
%to store the results of the optimization, i.e. the batches (iterations)
%
% Author: Edoardo Patelli
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

% Mesure the time required to store the output file
ndelta=OpenCossan.setLaptime('description','Store results on file system');

%% Validate input arguments
OpenCossan.validateCossanInputs(varargin{:})

%% Process optional parameters
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case 'xsimulationoutput'
            assert(isa(varargin{k+1},'SimulationData'), ...
                'openCOSSAN:optimizer:exportResults',...
                ['A simulation output is required after the property PropertyField ' ...
                varargin{k}]);
            XOut=varargin{k+1};
        case {'sbatchname','soutputname'}
            Sname=varargin{k+1};
        case 'cadditionalobject'
            Cadditional=varargin{k+1};
        otherwise
            error('openCOSSAN:optimizer:exportResults',...
                ['PropertyName ' varargin{k} ' not valid'])
    end
end

if isempty(Xobj.SiterationFolder)
    Xobj.SiterationFolder=datestr(now,30);
end

if ~exist('Sname','var')
    Sname=Xobj.SiterationName;
end

OpenCossan.cossanDisp(['[Optimizer:exportResults] Writing partial results (' ...
    Sname ') on the folder: ' OpenCossan.getCossanWorkingPath Xobj.SiterationFolder],3)


%% Export results

% Create a folder to store the partial results
if ~exist(fullfile(OpenCossan.getCossanWorkingPath,'Xobj.SiterationFolder'),'dir')
    [status,mess] = mkdir(fullfile(OpenCossan.getCossanWorkingPath,Xobj.SiterationFolder));
    if ~status
        warning('openCOSSAN:optimizer:exportResults',mess)
    end
end

% Store SimulationData object
% Each component is saved separetly in order to avoid the matlab bug of the
% memory preallocation

% Store the status of the RandomStream
SimOutReserved_RStream=RandStream.getGlobalStream;  %#ok<NASGU>

Sfullname= fullfile(OpenCossan.getCossanWorkingPath,Xobj.SiterationFolder,Sname);
%% Append all the optional arguments
if exist('XOut','var')
    XOut.save('SfileName',Sfullname);
    save(Sfullname,'-append','SimOutReserved_RStream');
else
    save(Sfullname,'SimOutReserved_RStream');
end

if exist('Cadditional','var')
    save(Sfullname,'-append',Cadditional);
end

OpenCossan.cossanDisp(['[Optimizer:exportResults] Iteration #'  ...
    num2str(Xobj.iIterations) ' written in ' ...
    num2str(OpenCossan.getDeltaTime(ndelta))],3)

OpenCossan.cossanDisp(['[Optimizer:exportResults] Results stored in the folder: ' Sfullname],3);

% Mesure the time required to store the output file
OpenCossan.setLaptime('description','End storing results on file system');
