disp('Compiling the FANN mex interface (requires the fann library to be installed)..');

assert(~isempty(OpenCossan.getCossanRoot),'openCOSSAN:makeFann:initialisationError','Please initialize OpenCossan')

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

if isunix
    setenv('LIBRARY_PATH', [getenv('LIBRARY_PATH') ':' DESTDIR filesep 'lib']);
    setenv('C_INCLUDE_PATH', [getenv('C_INCLUDE_PATH') ':' DESTDIR filesep 'include']);
elseif ispc
    % the correct environment are already set by the initialized OpenCossan
%     setenv('INCLUDE', [getenv('INCLUDE') ';' DESTDIR filesep 'include']);
%     setenv('LIB', [getenv('LIB') ';' DESTDIR filesep]);
end

if isunix
    mex CFLAGS="-D_GNU_SOURCE -fPIC -pthread -fexceptions -D_FILE_OFFSET_BITS=64 -Wall -fPIC -O3 -std=c99" -lm -ldoublefann -c helperFann.c
    mex CFLAGS="-D_GNU_SOURCE -fPIC -pthread -fexceptions -D_FILE_OFFSET_BITS=64 -Wall -fPIC -O3 -std=c99" -lm -ldoublefann createFann.c helperFann.o
    mex CFLAGS="-D_GNU_SOURCE -fPIC -pthread -fexceptions -D_FILE_OFFSET_BITS=64 -Wall -fPIC -O3 -std=c99" -lm -ldoublefann trainFann.c helperFann.o
    mex CFLAGS="-D_GNU_SOURCE -fPIC -pthread -fexceptions -D_FILE_OFFSET_BITS=64 -Wall -fPIC -O3 -std=c99" -lm -ldoublefann testFann.c helperFann.o
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

movefile('*.mex*',fullfile(OpenCossan.getCossanRoot,'mex','bin'),'f')
if isunix
    delete('helperFann.o')
elseif ispc
    delete('helperFann.obj')
end
