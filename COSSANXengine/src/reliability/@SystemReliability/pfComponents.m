function [Xsys varargout]=pfComponents(Xsys,Xsimulations)
% PFCOMPONENTS This method is used to estimate the failure probability of
% each basic events (components) definied in the object SystemReliability 
% The method returns a SystemReliability object and a SimulationData
%
% Input Argument
% Xsimulation: A Simulation Object
%
% Output Arguments
% Xsys:          SystemReliability object
% varargout{1}:  SimulationData object 
%
% Usage:
% Xcs=Xsys.pfComponents(Xsimulations)

%% Process inputs arguments

if length(Xsimulations)==1
    LsingleXsim=true;
elseif length(Xsimulations)==length(Xsys.Cnames)
    LsingleXsim=false;
else
   error('openCOSSAN:reliability:SystemReliabiliy:pfComponents',...
         ['The numeber of simulation object must be equal to 1 or ' ...
         'to the number od componentes (' num2str(length(Xsys.Cnames)) ]);
end

for n=1:length(Xsys.Cnames)
    % Create a probabilistic model 
    Xprobmod=ProbabilisticModel('Xmodel',Xsys.Xmodel,'XperformanceFunction',Xsys.XperformanceFunctions(n));
    
    % Estimatie the failure probability using the Xsimulation object 
    if LsingleXsim
        [XfailureProbability(n) Xout(n)]=Xprobmod.computeFailureProbability(Xsimulations); %#ok<AGROW>
    else
        [XfailureProbability(n) Xout(n)]=Xprobmod.computeFailureProbability(Xsimulations(n)); %#ok<AGROW>
    end
end

%% add the results to the SystemReliability object
Xsys.XfailureProbability=XfailureProbability;

varargout{1}=Xout;
    

