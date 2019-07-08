function XfatFracOut = addSimulation( XfatFracOut, Xds )
%ADDSIMULATION Summary of this function goes here
%   Detailed explanation goes here

if ~isa(Xds,'Dataseries')
   error('openCOSSAN:Fatigue:addSimulation',...
         'Argument must be a Dataseries object');
end

XfatFracOut.XdataSeries(end+1) = Xds;
end

