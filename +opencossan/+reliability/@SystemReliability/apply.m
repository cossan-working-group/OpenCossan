function Xout = apply(Xsys,Pinput)
% APPLY  Evaluate the SystemReliability model
% This method calls the method apply of the Model class and subsequently the
% method apply of the classes PerformanceFunctioon defined in the
% SystemReliability object
%
%   MANDATORY ARGUMENTS:
%    - Pinput represents an Input object; or Samples object; or Structure array
%    - Xout is a SimulationData object
%
%   Usage:  Xout = apply(Xpm,Pinput)
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/apply@SystemReliability
%
% Copyright~1993-2011, COSSAN Working Group,University of Innsbruck, Austria
% Author: Edoardo-Patelli

%% Argument Check
if ~(isa(Pinput,'Input')) && ~(isa(Pinput,'struct')) && ~(isa(Pinput,'Samples')),
    error('openCOSSAN:SystemReliability:apply', ...
        'The 2nd argument must be: \n 1) Input object \n 2) Samples object \n 3) a structure of input data');
end

%% Evaluate the Model and the PerformanceFunction

Xout = apply(Xsys.Xmodel,Pinput);
for n=1:length(Xsys.NperformanceFunctions)
    Xout = apply(Xsys.XperformanceFunction(n),Xout);
end

%% Export results
Xout.Sdescription=[Xout.Sdescription ' - apply(@SystemReliability)'];
