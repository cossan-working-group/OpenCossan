function createStartupFile
%% createStartupFile
% This static method create a startup file for OpenCossan
%
% See also: https://cossan.co.uk/wiki/index.php/@OpenCossan
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


global OPENCOSSAN

assert(~isempty(OPENCOSSAN),'openCOSSAN:OpenCossan', ...
    'This static method can be used only if OpenCossan has been initialized\nPlease initialize OpenCossan')

% Get the startup folder
Sname=which('OpenCossan');
[~,~,Sext]=fileparts(Sname);

switch Sext
    case '.m'
        Lpcode=false;
    case '.p'
        Lpcode=true;
end

Sfolder=userpath;

    if verLessThan('matlab', '9.1')
        % remove trailing ":" from the end of the string returned by userpath
        % Not necessary for Matlab > R2016b
        Sfolder=Sfolder(1:end-1);
    end


Sfilename=fullfile(Sfolder,'startup.m');
% Check if a startup.m file exist

if exist(Sfilename,'file')
    n=1;
    while exist([Sfilename '.backup' num2str(n)],'file')
        n=n+1;
    end
    OpenCossan.cossanDisp(['Creating backup file ' [Sfilename '.backup' num2str(n)]],1)
    copyfile(Sfilename,[Sfilename '.backup' num2str(n)])
end

fid=fopen(Sfilename,'w+');
fprintf(fid,'%% STARTUP file create by OpenCossan.createStartupFile\n');

if exist('DatabaseDriver','class') 
%% Add database driver to the jarpath
    fprintf(fid,'%% Add Java classes to the jarpath\n');
    for n=1:length(OpenCossan.CjarFileName)
        Sjarname=fullfile(OPENCOSSAN.SexternalPath,'dist',OPENCOSSAN.CjarFileName{n});
        fprintf(fid,'javaaddpath(''%s'');\n',Sjarname);
    end
    fprintf(fid,'javaaddpath(''%s'');\n',fullfile(OPENCOSSAN.SexternalPath,'dist'));
end

%% Add OpenCossan to the path
fprintf(fid,'%% Add OpenCossan to the path\n');
if Lpcode
    fprintf(fid,'addpath(''%s'');\n',fullfile(OPENCOSSAN.ScossanRoot));
else
    fprintf(fid,'addpath(''%s'');\n',fullfile(OPENCOSSAN.ScossanRoot,'src','common'));
end

% Add OpenCossan initialization
fprintf(fid,'%% Initialize Cossan\n');

fprintf(fid,'OpenCossan(''ScossanPath'',''%s'',...\n''Sexternalpath'',''%s'',...\n',OPENCOSSAN.ScossanRoot,OPENCOSSAN.SexternalPath);

if ~isempty(OPENCOSSAN.SmcrPath)
    fprintf(fid,'''SmcrPath'',''%s'' ,...\n',OPENCOSSAN.SmcrPath);
end

if ~isempty(OPENCOSSAN.SmatlabDatabasePath)
    fprintf(fid,'''Smatlabdatabasepath'',''%s'' ...\n',OPENCOSSAN.SmatlabDatabasePath);
end
fprintf(fid,');\n');
fprintf(fid,'OpenCossan.printLogo;');


%% Copy pathdef.m into startup folder
Spos=which('pathdef');
if ~strcmp(Spos,fullfile(Sfolder,'pathdef.m'))
   [Lstatus,Smessage]=copyfile(Spos,Sfolder);
   if Lstatus
       OPENCOSSAN.cossanDisp('pathdef.m file copied into the userpath folder',1)
   else
       OPENCOSSAN.cossanDisp('Failed to copy pathdef.m into userpath folder',1)
       OPENCOSSAN.cossanDisp(Smessage)
   end
end
    

fclose(fid);
OPENCOSSAN.cossanDisp('Startup file created successfully',1)
OPENCOSSAN.cossanDisp('Restart matlab to test the startup file',1)


