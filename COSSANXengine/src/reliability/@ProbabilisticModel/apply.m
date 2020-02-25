function Xout = apply(Xpm,Pinput)
% APPLY  Evaluate the ProbabilisticModel
% This method calls the method apply of the Model class and subsequently the
% method apply of the class PerformanceFunctioon
%
%   MANDATORY ARGUMENTS:
%    - Pinput represents an Input object; or Samples object; or Structure array
%    - Xout is a SimulationData object
%
%
%   Usage:  Xout = apply(Xpm,Pinput)
%
% See Also: http://cossan.co.uk/wiki/index.php/apply@ProbabilisticModel
%
% Copyright~1993-2020, COSSAN Working Group,University of Innsbruck, Austria
% Author: Edoardo-Patelli

%% 1.   Argument Check
if ~(isa(Pinput,'Input')) && ~(isa(Pinput,'struct')) && ~(isa(Pinput,'Samples'))
	error('openCOSSAN:reliability:ProbabilisticModel:apply', ...
        'The 2nd argument must be: \n 1) Input object \n 2) Samples object \n 3) a structure of input data');
end

%% 2.   Evaluate the Model and the PerformanceFunction
if ~isempty(Xpm.Xmodel)
    Xout = apply(Xpm.Xmodel,Pinput);
    Xout = apply(Xpm.XperformanceFunction,Xout);
else
    Xout = apply(Xpm.XperformanceFunction,Pinput);
end


%% Export results
Xout.Sdescription=[Xout.Sdescription ' - apply(@ProbabilisticModel)'];
