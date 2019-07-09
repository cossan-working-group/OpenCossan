function setPath(obj)
%SETPATH Add all necessary folders to the Matlab path. If OpenCossan is
%already on the path, it will be removed in order to keep the path clean.

%{
This file is part of OpenCossan <https://cossan.co.uk>.
Copyright (C) 2006-2018 COSSAN WORKING GROUP

OpenCossan is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License or,
(at your option) any later version.

OpenCossan is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with OpenCossan. If not, see <http://www.gnu.org/licenses/>.
%}

if ~isdeployed % TODO: We need a way to check and initialise toolboxes in a deployed version
    
    % Add all subfolders of lib\mex
    addpath(genpath(obj.PathToMex));
    % Add all subfolders of docs\
    addpath(genpath(obj.PathToDocs));
    % Add all subfolders of the distribution path
    addpath(genpath(obj.PathToExternalDistribution));
    
    % Add jar folder to javaclasspath
    javaaddpath(obj.PathToJar);
    
    % Predefined Toolboxes
    for i = 1:size(obj.PredefinedToolboxes,1)
        if isfile(fullfile(obj.Root, obj.PredefinedToolboxes{i,1}))
            run(fullfile(obj.Root, obj.PredefinedToolboxes{i,1}));
        else
            warning('OpenCossan:PredefinedToolBooxInitialisationProblem', ...
                ['Toolbox Initialisation Problem\n' obj.PredefinedToolboxes{i,2} ' has not been initialised\n'])
        end
    end
    
    % Save the userpath
    savepath(fullfile(userpath,'pathdef.m'));
    
end

end
