function setPath(varargin)
%SETPATH This method sets and resets the path of OpenCossan
% If the cossanPath is already set the previous definition is overwritten
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


if isdeployed
    error('openCOSSAN:OpenCossan', ...
        'It is not possible to use this method in the deployed version of OpenCossan')
else
    %% Process inputs
    OpenCossan.validateCossanInputs(varargin{:})
    
    % initialize variables
    CmexPathFolders=[];
    CsrcPathFolders=[];
    CdocPathFolders=[];
    CtutorialPathFolders=[];
    
    for k=1:2:length(varargin)
        switch lower(varargin{k})
            case {'scossanroot','scossanpath'}
                Sroot=varargin{k+1};
                if strcmpi(Sroot(end),filesep)
                    % remove the separator if is the last character
                    Sroot = Sroot(1:end-1);
                end
            case {'cmexcossanpaths' 'csmexcossanpaths'}
                CmexPathFolders=varargin{k+1};
            case {'ctutorialcossanpaths' 'cstutorialcossanpaths'}
                CtutorialPathFolders=varargin{k+1};
            case {'cssrccossanpaths' 'csrccossanpaths','csourcecossanpaths'}
                CsrcPathFolders=varargin{k+1};
            case {'cdocscossanpaths' 'csdocscossanpaths'}
                CdocPathFolders=varargin{k+1};
            otherwise
                error('openCOSSAN:OpenCossan',...
                    ['The property name ' varargin{k} ' is not valid'])
        end
    end
    
    assert(~isempty(Sroot), 'openCOSSAN:OpenCossan', ...
        'Please specify the main folder of the OpenCossan toolbox.')
    
    % get the root of openCOSSAN path if exists. If
    % openCOSSAN is not in the path, this function will fail
    SpredefinedRoot=OpenCossan.getCossanRoot;
    
    fprintf('* Please wait while define the OpenCossan path...\n')
    
    if ~isempty(SpredefinedRoot)
        fprintf('** OpenCossan path is already defined and it is going to be regenerated!!!\n')
        OpenCossan.removePath;
    end
    
    fprintf('** Adding OpenCossan to the Matlab path\n')
    
    % if openCOSSAN is not in path, and no directory is specified in
    % input, return an error and quit
    
    fprintf('* Please wait while generating OpenCossan path...\n')
    addpath(Sroot); %#ok<*MCAP>
    
    %% Add path 
    CSpaths=[CsrcPathFolders CmexPathFolders CtutorialPathFolders];
    for n=1:length(CSpaths)
        addpath(fullfile(SpredefinedRoot,CSpaths{n}));
        fprintf('*** Adding: %s\n',fullfile(SpredefinedRoot,CSpaths{n}))
    end
    
    %% Documentation
    for n=1:length(CdocPathFolders)
        Sfullpath=fullfile(SpredefinedRoot,'..',CdocPathFolders{n});
        addpath(Sfullpath);
        fprintf('*** Adding: %s\n',Sfullpath)
    end
    
    %% Add Extras path (Non-Free class)
    SextrasPath=fullfile(SpredefinedRoot,'src', filesep,'extras');
    if exist(SextrasPath,'dir')
        addpath(SextrasPath);
        fprintf('*** Adding: %s\n',SextrasPath)
    end
    
    SuserPath = userpath; 
    
    if verLessThan('matlab', '9.1')
        % remove trailing ":" from the end of the string returned by userpath
        % Not necessary for Matlab > R2016b
        SuserPath=SuserPath(1:end-1);
    end
        
    savepath(fullfile(SuserPath,'pathdef.m')); %#ok<MCSVP>
    fprintf('** Done!!!\n')
    
end
