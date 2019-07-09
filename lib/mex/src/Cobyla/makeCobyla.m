% Script to generate mex file for COBYLA.
% Created by Edoardo Patelli

disp('Compiling the COBYLA mex interface ..');

assert(~isempty(OpenCossan.getCossanRoot),'openCOSSAN:makeCobyla','Please initialize OpenCossan')

if isunix
    mex CFLAGS#"-D_GNU_SOURCE -fPIC -pthread   -fexceptions -D_FILE_OFFSET_BITS=64 -Wall -fPIC -O3" cobyla_matlab.c cobyla.h cobyla.c
elseif ispc
    mex cobyla_matlab.c cobyla.c
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





