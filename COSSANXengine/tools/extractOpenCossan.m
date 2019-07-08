function extractOpenCossan(varargin)
%EXTRACTOPENCOSSAN
% This function extract from a archivescompressed files part of OpenCossan
% Optional input. The archives must be in .tgz or .zip format
%
% 'SdestinationFolder'  Destination folder
% Ldocumentation        Install/Update documentation
% Lexamples             Install/Update Examples and Tutorials
% Lsourses              Install/Update main files
% Laddons               Install/Update addons
% Surl:                 webaddress of the OpenCossan files
% Sfolder:              local folder containing the .tgz files


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

% Predefined values
Ldocs=true;
Lexamples=true;
Lsrc=true;
Laddons=true;


for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'sdestinationpath'}
            SdestPath=varargin{k+1};
            if strcmpi(SdestPath(end),filesep)
                % remove the separator if it is the last character
                SdestPath = SdestPath(1:end-1);
            end
        case {'ldocumentation'}
            Ldocs=varargin{k+1};
        case {'lexamples'}
            Lexamples=varargin{k+1};
        case {'lsourses','lsrc'}
            Lsrc=varargin{k+1};
        case {'laddons'}
            Laddons=varargin{k+1};
        case {'surl','sfolder'}
            Ssource=varargin{k+1};
        otherwise
            error('openCOSSAN:extractOpenCossan:wrongArgument',...
                'The property name %s is not valid',varargin{k})
    end
end

assert (isdir(SdestPath), ...
    'openCOSSAN:exportOpenCossan','please provide a valid directory name\n%s is not a valid directory',SdestPath)

%% CREATE DESTINATION FOLDER
ind= strfind(SdestPath,'COSSANXengine');
if isempty(ind)
    mkdir(SdestPath,'COSSANXengine')
    SdestPathEngine=fullfile(SdestPath,'COSSANXengine');
else
    disp('COSSANXengine folder already existing')
    SdestPathEngine=SdestPath;
end

if ~exist('Ssource','var')
    Ssource=fullfile(OpenCossan.getCossanRoot,'..','..','branches','Archives','development');
end

if Ldocs
    if exist(fullfile(Ssource,'OpenCossanDocs.tgz'),'file')
        untar(fullfile(Ssource,'OpenCossanDocs.tgz'),SdestPathEngine)
    elseif exist(fullfile(Ssource,'OpenCossanDocs.zip'),'file')
        unzip(fullfile(Ssource,'OpenCossanDocs.zip'),SdestPathEngine)
    else
        warning('openCOSSAN:exportOpenCossan:noOpenCossanDocs',...
            'Archive for OpenCossanDocs not available')
    end
end

if Lexamples
    if exist(fullfile(Ssource,'OpenCossanExamples.tgz'),'file')
        untar(fullfile(Ssource,'OpenCossanExamples.tgz'),SdestPathEngine)
    elseif exist(fullfile(Ssource,'OpenCossanExamples.zip'),'file')
        unzip(fullfile(Ssource,'OpenCossanExamples.zip'),SdestPathEngine)
    else
        warning('openCOSSAN:exportOpenCossan:noOpenCossanExamples',...
            'Archive for OpenCossanExamples not available')
    end
    
end

if Lsrc
    if exist(fullfile(Ssource,'OpenCossan.tgz'),'file')
        untar(fullfile(Ssource,'OpenCossan.tgz'),SdestPathEngine)
    elseif exist(fullfile(Ssource,'OpenCossan.zip'),'file')
        unzip(fullfile(Ssource,'OpenCossan.zip'),SdestPathEngine)
    else
        warning('openCOSSAN:exportOpenCossan:noOpenCossan',...
            'Archive for OpenCossan not available')
    end
end

if Laddons
    if exist(fullfile(Ssource,'OpenCossanAddOns.tgz'),'file')
        untar(fullfile(Ssource,'OpenCossanAddOns.tgz'),SdestPath)
    elseif exist(fullfile(Ssource,'OpenCossanAddOns.zip'),'file')
        unzip(fullfile(Ssource,'OpenCossanAddOns.zip'),SdestPath)
    else
        warning('openCOSSAN:exportOpenCossan:noOpenCossanAddOns',...
            'Archive for OpenCossanAddOns not available')
    end
    
end


