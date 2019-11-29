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
% See Also: http://cossan.co.uk/wiki/index.php/load@SimulationData
%
% Copyright 2006-2017 COSSAN Working Group,
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

% Initialize variables
Sdescription='';
LexportMatrix=true;
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
    Cnames=SimOutReserved_Cnames;
end

% Remove Reserved field from the list of variables
for ires=1:length(CreservedNames)
    Cnames(strcmp(Cnames,CreservedNames(ires)))=[];
end

% Preallocate memory
CellTot=cell(SimOutReserved_Nsamples,length(Cnames));

for ipar=1:length(Cnames)
    if ~eval(['isa(' Cnames{ipar} ',''double'')'])
        LexportMatrix=false;
    end
    
    Tvarinfo=whos(Cnames{ipar}); % get the information on the variable
    if all(Tvarinfo.size == SimOutReserved_Tsize.(Cnames{ipar}))
        % If this statement is true, only 1 sample was present in the
        % structure. Thus, it is a Parameter.
        CellTot(1,ipar)=eval(['{' Cnames{ipar} '}']);
    else
        Sclass = eval(['class(' Cnames{ipar} ')']);
        switch Sclass
            case 'Dataseries'
                Xds = eval( Cnames{ipar} );
                % reassign the values of Dataseries in a Nsamples x 1 
                % cell array of 1-samples Dataseries
                for isample=1:SimOutReserved_Nsamples
                    CellTot{isample,ipar} = Xds(isample);
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
                % Reassign the values to the cellarray for the realizations
                % of the factors (RandomVariable, Functions, Outputs)
                if eval(['size(' Cnames{ipar} ',1)'])==1
                    CellTot(:,ipar)=eval(['num2cell(' Cnames{ipar} ')']);
                else
                    for isample=1:SimOutReserved_Nsamples
                        CellTot(isample,ipar)= eval(['{reshape(' Cnames{ipar} ...
                            '(:,' num2str(isample) '),SimOutReserved_Tsize.' Cnames{ipar} ')}' ]);
                    end
                end
        end
        
    end
end

if ~isempty(CellTot)
    len = cellfun('prodofsize', CellTot);
    if all(all(len==1)) && LexportMatrix
        Msamples=zeros(size(CellTot));
        for ipar=1:length(Cnames)
            Msamples(:,ipar)=eval(Cnames{ipar});
        end
    else
        Msamples=[];
    end
else
    Msamples=[];
end

Tvalues=cell2struct(CellTot,Cnames,2);


XsimOut= SimulationData('Sdescription',Sdescription,'Tvalues',Tvalues,'Mvalues',Msamples);
