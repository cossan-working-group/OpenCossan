function createStartupFile()
%% createStartupFile
% This static method create a startup file for OpenCossan
%
% See also: https://cossan.co.uk/wiki/index.php/@OpenCossan

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

cossan = opencossan.OpenCossan.getInstance();

startup = fileread(which('opencossan.common.utilities.startup'));

startup = replace(startup,'{{OpenCossanRoot}}',replace(cossan.Root,'\','\\'));

if ~isempty(cossan.MatlabDatabasePath)
    startup = replace(startup,'{{MatlabDatabasePath}}',cossan.MatlabDatabasePath);
else
    startup = replace(startup,'{{MatlabDatabasePath}}','');
end

if ~isempty(cossan.McrPath)
    startup = replace(startup,'{{McrPath}}', cossan.McrPath);
else
    startup = replace(startup,'{{McrPath}}','');
end

dest = fullfile(userpath,'startup.m');

% Check if a startup.m file exist
if isfile(dest)
    n=1;
    while isfile([dest '.backup' num2str(n)])
        n = n+1;
    end
    opencossan.OpenCossan.cossanDisp(['Creating backup file ' [dest '.backup' num2str(n)]],1)
    copyfile(dest,[dest '.backup' num2str(n)])
end

% Write the new startup.m file
fid = fopen(dest,'w+');
fprintf(fid,startup);
fclose(fid);
