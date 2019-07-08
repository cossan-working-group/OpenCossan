function Xobj = merge(Xobj,Xobj2)
%MERGE merges 1 SimulationData and 1 Subsetoutput object
%
%   MANDATORY ARGUMENTS
%   - Xobj2: SimulationData object
%
%   OUTPUT
%   - Xobj: object of class Subsetoutput
%
%   USAGE
%   Xobj = Xobj.merge(Xobj2)

% Argument Check
if ~isa(Xobj2,'SimulationData')  ,
    error('openCOSSAN:SubsetOutput:merge',...
        [ inputname(2) ' is not a SimulationData object']);
end
if  isa(Xobj2,'SubsetOutput') ,
    error('openCOSSAN:SubsetOutput:merge',...
        [ inputname(2) ' must not be a SubsetOutput object']);
end

%merge Sim.Out. data
Xobj2 = merge@SimulationData(Xobj2,Xobj);

Xobj.Tvalues = Xobj2.Tvalues;


end

