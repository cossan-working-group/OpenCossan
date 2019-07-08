function VX = cdf2stdnorm(VU)      
%CDF2STDNORM Maps  to the standard normal space when the value(s) of the 
%cdf is provided
% 
%  MANDATORY ARGUMENTS:
%    - VU: array containing the values of the cdf to be
%          mapped in the physical space 
%
%  OUTPUT ARGUMENTS
%    - VX: array containing the values mapped in the standard normal space
%
%  Usage: VX = RandomVariable.cdf2stdnorm(VU)
%
%  See also: RandomVariable, stdnorm2cdf
%
% =====================================================
% COSSAN-X COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2008 IfM 
% =====================================================



%% argument check (0 <= cdf <=1)
res  =(VU <0) | (VU >1);
if sum(res) ~= 0
    error('openCOSSAN:RandomVariable:cdf2physical',...
        'the value of the cdf has to be in the range [0 1]');
end

%% estimation in the SNS
VX = norminv(VU);

end

