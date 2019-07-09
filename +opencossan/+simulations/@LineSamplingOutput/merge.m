function Xobj = merge(Xobj,Xobj2)
%MERGE merge 2 LineSamplingOutput objects
%
%   MANDATORY ARGUMENTS
%   - Xobj2: LineSamplingOutput object
%
%   OUTPUT
%   - Xobj: object of class LineSamplingOutput
%
%   USAGE
%   Xobj = Xobj.merge(Xobj2)

% merge
% - 2 lsout objects
% - if the 2nd object is a simulation output: cp everything to object1

import opencossan.common.outputs.SimulationData

% Argument Check
if isa(Xobj2,'opencossan.simulations.LineSamplingOutput')
    
    if ~strcmp(Xobj.SperformanceFunctionName,Xobj2.SperformanceFunctionName)
        error('openCOSSAN:LineSamplingOutput:merge',...
            'The LineSamplingOutput object must have the same SperformanceFunctionName value');
    end
    
    Xobj.VnumPointLine = [Xobj.VnumPointLine; Xobj2.VnumPointLine];
    
elseif isa(Xobj2,'opencossan.common.outputs.SimulationData')
    
    %merge Sim.Out. data
    Xobj2 = merge@opencossan.common.outputs.SimulationData(Xobj2,Xobj);
    
    Xobj.Tvalues = Xobj2.Tvalues;
    %     Xobj.Mvalues  = Xobj2.Mvalues;
    
    if Xobj.Nsamples~=sum(Xobj.VnumPointLine)
        error('openCOSSAN:LineSamplingOutput:merge',...
            'The number of samples must be equal to the sum of the number of points on the lines');
    end
    
else
    error('openCOSSAN:LineSamplingOutput:merge',...
        [ inputname(1) ' is not a simulations.LineSamplingOutput object']);
    
end
end

