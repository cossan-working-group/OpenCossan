function setEnvironmentVariables(obj)
%SETENVIRONMENTVARIABLES Set the appropriate environment variables such as
%LD_LIBRARY_PATH etc.

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

%% Create variable values
externalPath = obj.PathToExternalDistribution;

if isunix
    binPath = fullfile(externalPath,'bin');
    libPath = fullfile(externalPath,'lib');
    delimiter = ':';
elseif ispc
    % there is no difference between path and runtime library
    % path in windows!
    binPath = externalPath;
    libPath = externalPath;
    delimiter = ';';
end
includePath = fullfile(externalPath,'include');

%% Set PATH
pathEnv = obj.BinPath;

if isempty(pathEnv)
    setenv('PATH', binPath );
elseif ~contains(pathEnv,binPath)
    setenv('PATH', [pathEnv delimiter binPath ]);
end

%% Set LIBRARY PATH
pathEnv = obj.LibPath;
env = 'LIB';
if isunix
    if ismac
        env = 'DYLD_LIBRARY_PATH';
    else
        env = 'LD_LIBRARY_PATH';
    end
end

if isempty(pathEnv)
    setenv(env, libPath );
elseif ~contains(pathEnv,libPath)
    setenv(env, [pathEnv delimiter libPath ]);
end

%% Set INCLUDE PATH
pathEnv = obj.IncludePath;
if isunix
    env = 'C_INCLUDE_PATH';
else
    env = 'INCLUDE';
end

if isempty(pathEnv)
    setenv(env, includePath );
elseif ~contains(pathEnv,includePath)
    setenv(env, [pathEnv delimiter includePath ]);
end

end

