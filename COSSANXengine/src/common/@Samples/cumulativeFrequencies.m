function [Vcf,Vval] = cumulativeFrequencies(Xs,varargin)
%cumulativeFrequencies  calculates cumulative relative frequencies of 
%   the samples in an object of the class Samples
%
%   MANDATORY ARGUMENTS
%   
%   - Starget : name of the RV for which cumulative frequencies are
%   calculated
%
%   OPTIONAL ARGUMENTS
%
%   OUTPUT
%
%   - Vcf   : Vector of CUMULATIVE frequencies
%   - Vval  : Vector of values related with cumulative frequencies
%
%   USAGE
%   
%   [Vcf, Vval] = cumulativeFrequencies(Xs,PropertyName, PropertyValue)
%
%   EXAMPLE
%
%   [Vcf Vval]  = cumulativeFrequencies(Xs,'Starget','RV1')
%
% =====================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2009 IfM
% =====================================================

%% 1.   Argument Check
if mod(length(varargin),2),
    error('openCOSSAN:Samples:cumulativeFrequencies',...
        'each optimization FIELD should be followed by its corresponding VALUE');
    %always a FIELD must be followed by its corresponding value
end

%% 2.   Define default values
Stype   = 'ascend'; %by default, samples are sorted in ascending order

%% 3.   Process input options
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'starget'}
            Starget     = varargin{k+1};
            if ~any(strcmpi(Starget,Xs.CnamesRandomVariable)),  %in case the name passed by the user does not match, return an error
                error('openCOSSAN:Samples:cumulativeFrequencies', ...
                    ['The target RV name ' varargin{k+1} ' is not present in the object Samples']);
            end
        otherwise
            warning('openCOSSAN:Samples:cumulativeFrequencies', ...
                ['PropertyName:  ' varargin{k} ' not available'])
    end
end

%% Sort object Samples according to specified random variable
Xs_sort     = Xs.sort('Starget',Starget,'Stype',Stype);

%% Calculate relavtive frequencies
[Vrf, Vval] = Xs_sort.relativeFrequencies('Starget',Starget);

%% 6.   Output
Vcf     = cumsum(Vrf);

return
