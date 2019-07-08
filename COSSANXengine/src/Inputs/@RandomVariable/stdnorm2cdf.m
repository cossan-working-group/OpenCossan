function VU = stdnorm2cdf(VX)
%STDNORM2CDF returns the value of the cdf when samples are provided in the
%standard normal space
% 
%  MANDATORY ARGUMENTS:
%    - VX: Vector containing the values in the standard normal space
%
%  OUTPUT ARGUMENTS
%    - VU: array containing the values of the cdf
%
%  Usage: VU = RandomVariable.stdnorm2cdf(Xrv,VX)
%
%  See also: RandomVariable, cdf2stdnorm
%
% =====================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2008 IfM
% =====================================================

%% estimation of the cdf
    VU = normcdf(VX);

end

