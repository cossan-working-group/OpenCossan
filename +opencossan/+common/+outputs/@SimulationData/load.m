function XsimOut=load(varargin)
%LOAD This method load each component of the SimulationData object stored
%in a Matlab file and recompose the SimulationData object
%
%   MANDATORY ARGUMENTS
%   * Name of the file
%
%   OUTPUT
%   - SimulationData object
%
%   USAGE
%   Status = Xobj.save('SfileName','myFileName')
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/load@SimulationData
%
% Copyright 1983-2015 COSSAN Working Group, University of Innsbruck, Austria
% Author: Edoardo Patelli

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

% Initialize variables
Sdescription='';
CreservedNames={'SimOutReserved_Nsamples'; ...
    'SimOutReserved_Sdescription'; ...
    'SimOutReserved_Tsize'; ...
    'SimOutReserved_Cnames'};


%% Validate input arguments
OpenCossan.validateCossanInputs(varargin{:})

%% Check Inputs
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'sfilename'}
            %check input
            SfileName = varargin{k+1};
        case {'cnames'}
            Cnames = varargin{k+1};
        case {'sdescription'}
            Sdescription = varargin{k+1};
        otherwise
            error('openCOSSAN:output:SimulationData:load', ...
                'PropertyName %s is not valid ', varargin{k})
    end
end

assert(logical(exist('SfileName','var')),...
    'openCOSSAN:output:SimulationData:load', ...
    'SfileName of SimulationData must be defined')


%% Load components
if exist('Cnames','var')
    load(SfileName,Cnames{:});
    load(SfileName,CreservedNames{:});
else
    % load SimulationData
    load(SfileName);
    Cnames = SimOutReserved_Cnames;
end

% Remove Reserved field from the list of variables
for ires=1:length(CreservedNames)
    Cnames(strcmp(Cnames,CreservedNames(ires)))=[];
end

% Preallocate memory
CellTot=cell(SimOutReserved_Nsamples,length(Cnames));
Tvalues = table();
for ipar=1:length(Cnames)
    varinfo = whos(Cnames{ipar}); % get the information on the variable
    switch varinfo.class
        case 'common.Dataseries'
            Xds = eval( Cnames{ipar} );
            % reassign the values of Dataseries in a Nsamples x 1
            % cell array of 1-samples Dataseries
            for isample=1:SimOutReserved_Nsamples
                CellTot{isample,ipar} = Xds.getSamples(isample);
            end
        case 'cell'
            % check that the cell contains only dataseries
            if strcmp(Sclass,'cell')
                CSclass=eval(['cellfun(@(x)class(x),' Cnames{ipar} ...
                    ',''UniformOutput'',false)']);
                if ~all(ismember(CSclass,'Dataseries'))
                    warning('openCOSSAN:SimulationData:load',...
                        [Cnames{ipar} ' does not contain Dataseries only.'...
                        ' Cannot load the variable into a SimulationData.' ])
                    continue
                end
            end
            % reassign the values of Dataseries
            for isample=1:SimOutReserved_Nsamples
                CellTot(isample,ipar) = eval([Cnames{ipar} '(' num2str(isample) ')']);
            end
        case 'double'
            Tvalues.(Cnames{ipar}) = eval(Cnames{ipar});
    end
end

if isempty(Sdescription)
    Sdescription = eval('SimOutReserved_Sdescription');
end

XsimOut = opencossan.common.outputs.SimulationData('Sdescription',Sdescription,'Table',Tvalues);
