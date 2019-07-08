disp('Compiling the FANN mex interface (requires FANN library to be installed)...');

assert(~isempty(OpenCossan.getCossanRoot),'openCOSSAN:makeFann','Please initialize OpenCossan')

if isunix&&~ismac
    [~,RELEASE]=system('lsb_release -r | awk ''{print $2}''');
    RELEASE = RELEASE(1:end-1);
    [~,DISTIBRUTION]=system('lsb_release -i | awk ''{print $3}''');
    DISTIBRUTION = DISTIBRUTION(1:end-1);
    [~,PROC]=system('uname -p');
    PROC = PROC(1:end-1);
elseif ispc
    %% SET ENVIROMENT FOR WINDOWS MACHINES
    DISTIBRUTION='Windows';
    [~,RELEASE]=system('ver');
    [Vs]=regexp(RELEASE,'\d');
    RELEASE=RELEASE(Vs(1):Vs(end));
    PROC = computer('arch');
elseif ismac
    %% Set environment for MacOS X
    [~,RELEASE]=system('sw_vers -productVersion');
    RELEASE = RELEASE(1:end-1);
    DISTIBRUTION = 'Mac_OS_X';
    PROC = computer('arch');
else
    error('unsupported platform')
end

switch PROC
    case 'i686'
        ARCH='glnx86';
    case 'x86_64'
        ARCH='glnxa64';
    case {'win64','maci64'}
        ARCH=PROC;
    otherwise
        ARCH='glnx86';
end

DESTDIR=fullfile(OpenCossan.getCossanRoot,'..','OpenSourceSoftware',...
    'dist',DISTIBRUTION,RELEASE,ARCH);

% Check if the FANN library exists

assert(isfile(fullfile(DESTDIR,filesep,'lib','libfann.so')),...
    'OpenCossan:noFANNlibrary',['I can not find FANN library (%s) in %s. \n' ...
    'Check FANN installation'],'libfann.so',fullfile(DESTDIR,filesep,'lib'))

assert(isfile(fullfile(DESTDIR,filesep,'include','fann.h')),...
    'OpenCossan:noFANNlibrary',['I can not find FANN library (%s) in %s. \n' ...
    'Check FANN installation'],'fann.h',fullfile(DESTDIR,filesep,'include'))

if isunix
    setenv('LIBRARY_PATH', [getenv('LIBRARY_PATH') ':' DESTDIR filesep 'lib']);
    setenv('C_INCLUDE_PATH', [getenv('C_INCLUDE_PATH') ':' DESTDIR filesep 'include']);
elseif ispc
    % the correct environment are already set by the initialized OpenCossan
%     setenv('INCLUDE', [getenv('INCLUDE') ';' DESTDIR filesep 'include']);
%     setenv('LIB', [getenv('LIB') ';' DESTDIR filesep]);
end

if isunix
    mex CFLAGS#"-D_GNU_SOURCE -fPIC -pthread -fexceptions -D_FILE_OFFSET_BITS=64 -Wall -fPIC -O3" -lm -lfann -c helperFann.c
    mex CFLAGS#"-D_GNU_SOURCE -fPIC -pthread -fexceptions -D_FILE_OFFSET_BITS=64 -Wall -fPIC -O3" -lm -lfann createFann.c helperFann.o
    mex CFLAGS#"-D_GNU_SOURCE -fPIC -pthread -fexceptions -D_FILE_OFFSET_BITS=64 -Wall -fPIC -O3" -lm -lfann trainFann.c helperFann.o
    mex CFLAGS#"-D_GNU_SOURCE -fPIC -pthread -fexceptions -D_FILE_OFFSET_BITS=64 -Wall -fPIC -O3" -lm -lfann testFann.c helperFann.o
elseif ispc
    % be sure that FANN has been compiled with the same compiler as used in mex
    mextype=mex.getCompilerConfigurations('C');
    if strcmpi(mextype.ShortName,'mingw64')
        mex(['-I' getenv('INCLUDE')],'-lfann','-c','helperFann.c')
        mex(['-I' getenv('INCLUDE')],['-L' getenv('LIB')],'-lfann','createFann.c','helperFann.obj')
        mex(['-I' getenv('INCLUDE')],['-L' getenv('LIB')],'-lfann','trainFann.c','helperFann.obj')
        mex(['-I' getenv('INCLUDE')],['-L' getenv('LIB')],'-lfann','testFann.c','helperFann.obj')
    else
        mex -lfann -c helperFann.c fann.lib
        mex -lfann createFann.c helperFann.obj fann.lib
        mex -lfann trainFann.c helperFann.obj fann.lib
        mex -lfann testFann.c helperFann.obj fann.lib
    end
end

% List of created mex files
r=dir('*.mex*');
Spath=fullfile(OpenCossan.getCossanRoot,'mex','bin');

for n=1:length(r)
    % Move the compiled file in the appropriate folder
    [status,message,messageid]=movefile(r(n).name,Spath,'f');
    
    if status
        disp(['MEX FILE ' r(n).name ' created and moved in ' Spath ]);
    else
        disp(message);
        disp(messageid);
    end
end
% Clean up!
if isunix
    delete('helperFann.o')
elseif ispc
    delete('helperFann.obj')
end