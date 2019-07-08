% Script to generate mex file for COBYLA.
% Created by Edoardo Patelli

disp('Compiling the Stochastic Ranking ED auxiliary mex files ..');

assert(~isempty(OpenCossan.getCossanRoot),'openCOSSAN:makeSRES','Please initialize OpenCossan')

% mex for global intermediate recombination (can be ignored...)
mex CFLAGS#"-D_GNU_SOURCE -fPIC -pthread -fexceptions -D_FILE_OFFSET_BITS=64 -Wall -fPIC -O3" arithx.c
% mex for stochasti ranking sorting
mex CFLAGS#"-D_GNU_SOURCE -fPIC -pthread -fexceptions -D_FILE_OFFSET_BITS=64 -Wall -fPIC -O3" srsort.c

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