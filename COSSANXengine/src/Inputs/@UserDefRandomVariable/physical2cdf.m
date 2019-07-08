function VU = physical2cdf(Xrv,VX)
%TODO
%MAP2STDNORM returns the value of the cdf when samples are provided in the
%physical space
% 
%  MANDATORY ARGUMENTS:
%    - Xrv: the UserDefRandomVariable object
%    - VX: Vector containing the values in the physical space
%
%  OUTPUT ARGUMENTS
%    - VU: array containing the values of the cdf
%
%  Usage: VU = physical2cdf(Xrv,VX)
%
%  See also: RandomVariable, cdf2physical
%
% =====================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2008 IfM
% =====================================================

%% argument check

if isempty(Xrv) || isempty(VX) || ~isa(VX,'numeric')
    error('Incorrect number of rguments');
end

%% estimation of the cdf

VU = cdf(Xrv.empirical_distribution,VX);

end

