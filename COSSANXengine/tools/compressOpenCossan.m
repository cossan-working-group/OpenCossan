function compressOpenCossan(varargin)
%EXPORTOPENCOSSAN
% This function export as compressed file OpenCossan
% Optional inputs:
%
% 'SdestinationFolder'
% 'Sformat': zip (default) or tar

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

global OPENCOSSAN
% Predefined values
if ~isempty(OPENCOSSAN)
    SdestPath=fullfile(OPENCOSSAN.ScossanRoot,'..','..','Archives','stable');
end
Sformat='zip';
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
        case {'ldocumentation','ldocs'}
            Ldocs=varargin{k+1};
        case {'lexamples'}
            Lexamples=varargin{k+1};
        case {'lsourses','lsrc'}
            Lsrc=varargin{k+1};
        case {'laddons'}
            Laddons=varargin{k+1};
        case {'sformat'}
            Sformat=varargin{k+1};
        otherwise
            error('openCOSSAN:OpenCossan',...
                'The property name %s is not valid',varargin{k})
    end
end

assert (isdir(SdestPath), ...
    'openCOSSAN:compressOpenCossan','please provide a valid directory name\n%s is not a valid directory',SdestPath)

switch Sformat
    case 'tar'
        if Ldocs
            tar(fullfile(SdestPath,'OpenCossanDocs.tgz'),OPENCOSSAN.CdocsPathFolders,OpenCossan.getCossanRoot)
        end
        
        if Lexamples
            tar(fullfile(SdestPath,'OpenCossanExamples.tgz'),OPENCOSSAN.CtutorialsPathFolders,OpenCossan.getCossanRoot)
        end
        
        if Lsrc
            Cfolders=[OPENCOSSAN.CsrcPathFolders,OPENCOSSAN.CmexPathFolders];
            tar(fullfile(SdestPath,'OpenCossan.tgz'),Cfolders,OpenCossan.getCossanRoot)
        end
        
        if Laddons
            % This contains the OpenSourceSoftware
            % Include src and dist of OpenSourceSoftware
            Cfolders={fullfile(OpenCossan.getCossanExternalPath)};
            
            tar(fullfile(SdestPath,'OpenCossanAddOns.tgz'),Cfolders,OpenCossan.getCossanRoot)
        end
    case 'zip'
        if Ldocs
            zip(fullfile(SdestPath,'OpenCossanDocs.zip'),OPENCOSSAN.CdocsPathFolders,OpenCossan.getCossanRoot)
        end
        
        if Lexamples
            zip(fullfile(SdestPath,'OpenCossanExamples.zip'),OPENCOSSAN.CtutorialsPathFolders,OpenCossan.getCossanRoot)
        end
        
        if Lsrc
            Cfolders=[OPENCOSSAN.CsrcPathFolders,OPENCOSSAN.CmexPathFolders];
            zip(fullfile(SdestPath,'OpenCossan.zip'),Cfolders,OpenCossan.getCossanRoot)
        end
        
        if Laddons
            % This contains the OpenSourceSoftware
            % Include src and dist of OpenSourceSoftware
            Cfolders={fullfile(OpenCossan.getCossanExternalPath)};
            
            zip(fullfile(SdestPath,'OpenCossanAddOns.zip'),Cfolders,OpenCossan.getCossanRoot)
        end
    otherwise
        error('openCOSSAN:compressOpenCossan','Compress format %s not supported',Sformat)
end




