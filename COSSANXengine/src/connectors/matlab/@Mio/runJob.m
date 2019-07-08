function [XSimOut,PoutputALL] = runJob(Xmio,varargin)
%runJob  method to evaluate mio on a grid using a JobManager object
%
%   runJob  method to evaluate mio on a grid using a JobManager object.
%   Before executing this command, the Mio object must be compiled.
%
%   MANDATORY ARGUMENTS:
%
%   - Xmio : Matlab I/O (Mio) object
%   - 'Pinput' : the samples can be passed as a
%						1) structure
%						2) Input object
%						3) Samples object
%   - 'XJobManager' : a JobManager object
%
%
%   OPTIONAL ARGUMENTS:
%
%   - Nconcurrent     : number of jobs to be concurrently executed
%   - XSimOut   : an already existing SimulationData object
%   - Lkeepsimfiles : logical flag to keep the files generated during the
%   simulation. If it is "true", files are kept; otherwise, they are erased
%
%   OUTPUT:
%
%   - XSimOut : SimulationData object
%   - Pout : a structure is returned
%
%
%   USAGE:
%
%   XSimOut = runJob(Xmio,'Pinput',Xinput,'XJobManager',XJobManager) returns
%   a SimulationData object ("XSimOut")
%
%   [XSimOut,Pout] = runJob(Xmio,'Pinput',Xinput,'XJobManager',XJobManager)
%   returns a SimulationData object ("XSimOut"); moreover, "Pout" contains a
%   structure with outputs
%
%
%   EXAMPLES:
%   - XSimOut = runJob(Xmio,'Xinput',Xinput,'XJobManager',XJob)
%   - [XSimOut,Pout] = runJob(Xmio,'Tinput',Tinput,'XJobManager',XJob)
%   - [XSimOut,Pout] = runJob(Xmio,'Pinput',Xsamples,'XJobManager',XJob)
%
% [EP]: P stands for polymorphism
% =====================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2009 IfM
% =====================================================

Cinputs = {}; %#ok<*AGROW>

%% check input parameters
OpenCossan.cossanDisp(['OpenCossan:Mio:runJob  - START -' datestr(clock)],2)
OpenCossan.validateCossanInputs(varargin{:});

for k=1:2:length(varargin) 
    switch lower(varargin{k})
        case{'xjobmanager'}
            Cinputs{end+1} = 'XjobManager';
            Cinputs{end+1} = varargin{k+1};
        case{'minput'}
            Cinputs{end+1} = 'Minput';
            Cinputs{end+1} = varargin{k+1};
        case{'tinput'}
            Cinputs{end+1} = 'Tinput';
            Cinputs{end+1} = varargin{k+1};
        case{'xinput'}
            Cinputs{end+1} = 'Xinput';
            Cinputs{end+1} = varargin{k+1};
        case{'xsamples'}
            Cinputs{end+1} = 'Xsamples';
            Cinputs{end+1} = varargin{k+1};
        case {'nconcurrent'},
            Cinputs{end+1} = 'Nconcurrent';
            Cinputs{end+1} = varargin{k+1};
        case {'xsimout','xsimulationdata'},
            Cinputs{end+1} = 'XSimulationData';
            Cinputs{end+1} = varargin{k+1};    
        otherwise
            error( 'OpenCossan:Mio:runJob',...
                'Property Name %s not valid',varargin{k})
    end
end

%% call the appropriate private runJob method
if Xmio.Lcompiled
    [XSimOut,PoutputALL] = Xmio.runJobCompiled(Cinputs{:});
else
    [XSimOut,PoutputALL] = Xmio.runJobMatlab(Cinputs{:});
end

OpenCossan.cossanDisp(['OpenCossan:Mio:runJob  - STOP-' datestr(clock)],2)

end