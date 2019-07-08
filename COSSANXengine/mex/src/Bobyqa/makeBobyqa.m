% Script to generate mex file for COBYLA.
% Created by Edoardo Patelli

disp('Compiling the BOBYQA mex interface ..');

assert(~isempty(OpenCossan.getCossanRoot),'openCOSSAN:makeBobyqa','Please initialize OpenCossan')

if ispc
    cc=mex.getCompilerConfigurations();
    if ~isempty(cc) % if gnumex is configured, getCompilerConfigurations will return empty
        assert(~strcmpi(cc(1).Manufacturer,'Microsoft'),'openCOSSAN:makeBobyqa',...
            ['You cannot compile BOBYQA with Visual Studio because MS is not '...
            'able to comply to a standard created in 1999.\n',...
            'Install MinGW and gnumex to compile BOBYQA.'])
    end
end
mex CFLAGS#"-D_GNU_SOURCE -fPIC -pthread   -fexceptions -D_FILE_OFFSET_BITS=64 -Wall -fPIC -O3" bobyqa_matlab.c bobyqa.c
% List of created mex files
r=dir(['*.' mexext]);

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





