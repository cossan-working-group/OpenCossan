function [Trv] = uniformdiscrete(Trv)
%UNIFORMDISCRETE compute missing parameters (if is possible) of the
%uniformdiscrete
%                       distribution
% Input/Output is the structure of the random variable

Trv.Sdistribution='unid';
if Trv.shift ~= 0;
    error('openCOSSAN:rv:uniformdiscrete','shifted uniformdiscrete distributions can not be defined, use lowerBound and upperBound ');
end
if ~isempty(Trv.Cpar{1,2}) && ~isempty(Trv.Cpar{2,2})
    Trv.lowerBound=Trv.Cpar{1,2};
    Trv.upperBound=Trv.Cpar{2,2};
end
if ~isempty(Trv.lowerBound) && ~isempty(Trv.upperBound) && ~isinf(Trv.lowerBound) && ~isinf(Trv.upperBound)
    if Trv.lowerBound>= Trv.upperBound,
        error('openCOSSAN:rv:uniformdiscrete','Upper bound (2nd argument) must be greater than lower bound (1st argument).');
    end
    
    
    [Nmean,Nvar]=unidstat( Trv.upperBound - Trv.lowerBound);
    
    
    Trv.mean = Trv.lowerBound+Nmean;
    Trv.std  = sqrt(Nvar);
else
    
    error('openCOSSAN:rv:uniformdiscrete','Invalid input arguments, uniformdiscrete distributions must be created using lowerBound and upperBound ');
    
end