function [Xm] = compile(Xm,varargin)
%COMPILE  Construct a standalone building of the mio object
%
%
%   MANDATORY ARGUMENTS:
% 
%   - Xmio : COSSAN-X object mapping input to output, using a m-function
%
%
%   OPTIONAL ARGUMENTS: 
%
%   - Lverbose : produce debug output 
%   - Stargetarch : Specify the target architecture %TODO
%   - Sadditionalpath : Specify the path of additional file 
%
%   OUTPUT:
%
%   - Xmio : COSSAN-X object mapping input to output, using a m-function
% 
%   EXAMPLES: 
%
%   - Xm = compile(Xm,'Lverbose',true)
%   - Xm = compile(Xm,'Lverbose',true,'Sadditionalpath','/mystuff')
%
%
% =====================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2009 IfM
% =====================================================

global OPENCOSSAN
%% 1.   Process input parameters
for i=1:2:length(varargin),
    switch lower(varargin{i}),
        case {'sadditionalpath'},   %set additional path for compiling
            Xm.Sadditionalpath  = varargin{i+1};
        case {'swrappername'},   %set additional path for compiling
            Xm.SwrapperName  = varargin{i+1};
    end
end

if ~isempty(Xm.Sadditionalpath)
    addpath(Xm.Sadditionalpath);
end

%% 2.   Move to the folder of the Mio function
% Spwd    = pwd;  %record current directory
% cd(Xm.Spath);   %switch to path where Mio function is contained

%% 3.   Checks whether or not folder for building compiled version of Mio
%% exists
Sbuildnamefolder    = 'build_mio';  %default name of folder for building
if exist(fullfile(Xm.Spath,Sbuildnamefolder),'dir'),   %checks whether or not the folder for building already exists
	warning('openCOSSAN:Mio:compile',...
        'A previuos build folder has been detected and it will be deleted')
	rmdir(fullfile(Xm.Spath,Sbuildnamefolder),'s');    %remove old folder
end
mkdir(fullfile(Xm.Spath,Sbuildnamefolder));   %create building folder anew
%%  3.  Copy the mio function in the build_mio directory
if isempty(Xm.Sscript)
    [~, message]   = copyfile('*.m',fullfile(Xm.Spath,Sbuildnamefolder));   %copy m-function
    if ~isempty(message),
        OpenCossan.cossanDisp(message,3);  %displays action performed to screen
    end
end
%% 4.   Copy file mbuildopts.sh to build_mio directory
% Sdummy  = which('Mio');     %string containing location of class Mio
% Nend    = regexp(Sdummy,'Mio\.m') - 1;  %use regular expression to get path of class Mio
% copyfile([Sdummy(1:Nend) 'compile/mbuildopts.sh'] ,...
%     [pwd '/mbuildopts.sh'] );   %copy file mbuildopts.sh
% cd(Sbuildnamefolder);           %switch to directory for building compiled Mio

%% 5.   Create a wrapper file
OpenCossan.cossanDisp(['Creating ' fullfile(Xm.Spath,Sbuildnamefolder,Xm.SwrapperName) '.m file'],3);
% cd(Sbuildnamefolder);
Nfid     = fopen([fullfile(Xm.Spath,Sbuildnamefolder,Xm.SwrapperName) '.m'],'w');   %creates empty wrapper file

% Add try and catch
fprintf(Nfid,'try\n');
createWrapper(Xm,Nfid)
fclose(Nfid);

%% 6.   Compile wrapper using Matlab
Smcc = [OPENCOSSAN.SmatlabPath filesep 'bin' filesep 'mcc -m ' ...
    fullfile(Xm.Spath,Sbuildnamefolder,Xm.SwrapperName) '.m  -R nojvm -d '...
    fullfile(Xm.Spath,Sbuildnamefolder)];

if OpenCossan.getVerbosityLevel>2     %define command for compiling
    Smcc=[Smcc ' -v'];
end

%Smcc=[Smcc ' -a '];

for n=1:length(OPENCOSSAN.CsrcPathFolders) 
    Smcc=[Smcc ' -a ' OpenCossan.getCossanRoot filesep OPENCOSSAN.CsrcPathFolders{n} ' '];
end;
if ~isempty(Xm.Sadditionalpath)
    Smcc=[Smcc  ' -a ' Xm.Sadditionalpath];
end

[status,result]=system(Smcc);    %compile wrapper

assert(status==0, 'openCOSSAN:Mio:compile', ...
    'Failed with the following error %s',result)

OpenCossan.cossanDisp(sprintf('Compilation output:\n%s',result),3)

%% 7.   Copy executable to bin directory
%7.1.   In case directory bin does not exist, create one
if ~exist([Xm.Spath, filesep 'bin'],'dir'),  
	mkdir(Xm.Spath,'bin');
end
%7.2.   Copy required files
copyfile(fullfile(Xm.Spath,Sbuildnamefolder,['run_' Xm.SwrapperName '.sh']),fullfile(Xm.Spath,'bin',['run_' Xm.SwrapperName '.sh']));
copyfile(fullfile(Xm.Spath,Sbuildnamefolder,Xm.SwrapperName),fullfile(Xm.Spath,'bin', Xm.SwrapperName));

%% 8.   Move to bin directory and check that files were copied
% cd(['..' filesep 'bin']);  %move to bin directory
if exist(fullfile(Xm.Spath,'bin',Xm.SwrapperName),'file') && exist(fullfile(Xm.Spath,'bin',['run_' Xm.SwrapperName '.sh']),'file'),   %check existence of files
	Xm.Lcompiled    = true;
    OpenCossan.cossanDisp(['Compilation of ' Xm.SwrapperName '.m successfull.'],3)
else
	Xm.Lcompiled    = false;
    warning('openCOSSAN:Mio:compile','The compilation of the mio wrapper has failed.')
end

%% 9.   Return original directory
% cd(Spwd);

%% 10.  Remove additional path for compilation
if ~isempty(Xm.Sadditionalpath),
	rmpath(Xm.Sadditionalpath);
end

return
