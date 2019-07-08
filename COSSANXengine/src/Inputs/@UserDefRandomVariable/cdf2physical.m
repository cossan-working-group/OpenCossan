function VX = cdf2physical(Xrv,VU)
%CDF2PHYSICAL Maps the the specified RandomVariable to the physical space
%when the value(s) of the cdf is provided
%
%  MANDATORY ARGUMENTS:
%    - Xrv: the RandomVariable object
%    - VU: array containing the values of the cdf to be
%          mapped in the physical space
%
%  OUTPUT ARGUMENTS
%    - VX: array containing the values mapped in the physical space
%
%  Usage: VX = cdf2physical(Xrv,VU)
%
%  See also: RandomVariable, physical2cdf
%
% =====================================================
% COSSAN-X COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2008 IfM
% =====================================================

if isempty(Xrv) || isempty(VU) || ~isa(VU,'numeric')
    error('Incorrect number of arguments');
end

%% argument check (0 <= cdf <=1)
res  =(VU <0) | (VU >1);
if sum(res) ~= 0
    error('openCOSSAN:RandomVariable:cdf2physical',...
        'the value of the cdf has to be in the range [0 1]');
end


VX = icdf(Xrv.empirical_distribution,VU );


end
