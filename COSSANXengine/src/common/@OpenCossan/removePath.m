function removePath
%REMOVEPATH This method reset the matlabb path, removing OpenCossan
% If the cossanPath is already set the previous definition is overwritten
% get the root of OpenCossan path if OpenCossan is already in path. If
% OpenCossan is not in the path, this function will fail
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
    
    SpredefinedRoot=OpenCossan.getCossanRoot;
    
    if isempty(SpredefinedRoot)
        fprintf('** OpenCossan path not defined!  Nothing to remove here\n')
    else
        fprintf('** Removing OpenCossan from Matlab path\n')
        %get the path;
        Spath=path;
        
        % Identify OpenCossan path
        Sexpression=['(' SpredefinedRoot '[^' pathsep ...
            ']*' pathsep ')|(' pathsep ...
            SpredefinedRoot '[^' pathsep ']*)'];
        Cpath=regexp(Spath,Sexpression,'tokens');
        
        
        for n=1:length(Cpath)
            fprintf('*** Removing: %s\n',Cpath{n}{:})
            rmpath(Cpath{n}{:})
        end
        

        SuserPath = userpath;
        if verLessThan('matlab', '9.1')
            % remove trailing ":" from the end of the string returned by userpath
            % Not necessary for Matlab > R2016b
            SuserPath=SuserPath(1:end-1);
        end
    
        savepath(fullfile(SuserPath,'pathdef.m')); %#ok<MCSVP>
        
        % Check if OpenCossan has been defined in the path
        
        ipos=regexpi(path,['(\w+(?<=' filesep 'COSSANXengine))']);
        
        if isempty(ipos)
            fprintf('** OpenCossan successfully removed from the Matlab path\n')
        else
            fprintf('* %i path(s) of OpenCossan are still on your path. \n* Please re-run removePath method or remove remaining path manually\n',length(ipos))
        end
        
        
    end
    
end


