function [Vrf,Vval] = relativeFrequencies(Xs,varargin)
%
%   relativeFrequencies   calculates relative frequencies of a Samples
%
%   MANDATORY ARGUMENTS
%
%   - Starget : name of the RV for which relative frequencies are
%   calculated
%
%   OPTIONAL ARGUMENTS
%
%
%   OUTPUT
%
%   - Vrf   : Vector of relative frequencies
%   - Vval  : Vector of values related with relative frequencies
%
%   USAGE
%   [Vrf, Vval] = relativeFrequencies(Xs,'Starget','RV1')
%
%
%   EXAMPLES
%   Vrf = relativeFrequencies(Xs,'Starget','RV1')
%
% =====================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2009 IfM
% =====================================================

%% 1.   Argument Check
if mod(length(varargin),2),
    error('openCOSSAN:Samples:relativeFrequencies',...
        'each FIELD should be followed by its corresponding VALUE');
    %always a FIELD must be followed by its corresponding value
end

%% 2.   Process input options - Get name of random variable used for sorting
if strcmpi(varargin{1},'starget')
    Crvname = Xs.CnamesRandomVariable;   %extract names of random variables present in object Samples
    index   = find(strcmp(Crvname,varargin{2}));  %compare random variables present in object Samples with random variable name passed by the user
    if isempty(index),  %in case the name passed by the user does not match, return an error
        error('openCOSSAN:Samples:relative_frequencies', ...
            ['The target RV name ' varargin{2} ' is not present in the Samples object']);
    end
    Vtarget=Xs.MsamplesHyperCube(:,index);     %extract values of samples random variable to be sorted
else
    error('openCOSSAN:Samples:relative_frequencies', ...
        'No valid Valid PropertyName');
end

%% 3.   Analyze samples
Mrf     = tabulate(Vtarget); %analyze samples using method 'tabulate'

%% 4.   Prepare output
Vrf     = Mrf(:,3)/100;
Vval    = Mrf(:,1);


return
