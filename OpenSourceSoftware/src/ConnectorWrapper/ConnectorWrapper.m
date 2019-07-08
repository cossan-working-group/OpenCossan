%% Connector wrapper 
%% Initialize needed classes 

% Initialize OpenCossan
OpenCossan

% create a fake empty object
Xobj=SimulationData;

%%
display(['Finished engine startup on ' system('hostname')])

datestr(now,0)

%% Execute FE code
% Load inputs from file 
load ConnectorInput.mat

% Set vervosity level
OpenCossan.setVerbosityLevel(Xc_to_file.NverboseLevel);

if Xc_to_file.NverboseLevel >=3
    disp('[openCOSSAN.common.ConnectorWrapper] Running Connector wrapper')
end

[Xout,~,LerrorPartials,LsuccessfullExtractPartials] = Xc_to_file.run(Pinput);

save ConnectorOutput.mat Xout LerrorPartials LsuccessfullExtractPartials

display('Finished connector execution:')
datestr(now,0)
